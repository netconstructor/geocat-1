//==============================================================================
//===	Copyright (C) 2001-2008 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.kernel.reusable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.base.Function;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import jeeves.xlink.Processor;
import jeeves.xlink.XLink;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.reusable.Utils.FindXLinks;
import org.fao.geonet.kernel.reusable.log.ReusableObjectLogger;
import org.jdom.Element;

import com.google.common.collect.HashMultimap;
import com.google.common.collect.Multimap;

/**
 * Makes a list of all the non-validated elements
 * 
 * @author jeichar
 */
public class Reject implements Service
{

    public Element exec(Element params, ServiceContext context) throws Exception
    {
        String page = Util.getParamText(params, "type");
        String[] ids = Util.getParamText(params, "id").split(",");
        String msg = Util.getParamText(params, "msg");

        Element results = reject(context, ReusableTypes.valueOf(page), ids, msg, null);

        return results;
    }

    public Element reject(ServiceContext context, ReusableTypes reusableType, String[] ids, String msg,
            String strategySpecificData) throws Exception
    {
        Log.debug(ReusableObjectLogger.REUSABLE_LOGGER_ID, "Starting to reject following reusable objects: \n"
                + reusableType + " (" + Arrays.toString(ids) + ")\nRejection message is:\n" + msg);
        UserSession session = context.getUserSession();
        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);
        String baseUrl = Utils.mkBaseURL(context.getBaseUrl(), gc.getSettingManager());
        ReplacementStrategy strategy = Utils.strategy(reusableType, context);

        Element results = new Element("results");
        if (strategy != null) {
            results.addContent(performReject(ids, strategy, context, gc, dbms, session, baseUrl, msg,
                    strategySpecificData));
        }
        Log.info(ReusableObjectLogger.REUSABLE_LOGGER_ID, "Successfully rejected following reusable objects: \n"
                + reusableType + " (" + Arrays.toString(ids) + ")\nRejection message is:\n" + msg);

        return results;
    }

    private List<Element> performReject(String[] ids, final ReplacementStrategy strategy, ServiceContext context,
            GeonetContext gc, Dbms dbms, final UserSession session, String baseURL, String msg,
            String strategySpecificData) throws Exception
    {

        final Function<String,String> idConverter = strategy.numericIdToConcreteId(session);
        final String[] invalidXlinkLuceneField = strategy.getInvalidXlinkLuceneField();

        Multimap<String/* ownerid */, String/* metadataid */> emailInfo = HashMultimap.create();
        List<Element> result = new ArrayList<Element>();
        for (String id : ids) {
            Set<MetadataRecord> results = Utils.getReferencingMetadata(context, invalidXlinkLuceneField, id, true, idConverter);

            // compile a list of email addresses for notifications
            for (MetadataRecord record : results) {
                emailInfo.put(record.ownerId, record.id);
            }

            updateHrefs(strategy, context, dbms, session, id, results, baseURL, strategySpecificData);
            for (MetadataRecord metadataRecord : results) {
                final SearchManager searchmanager = gc.getSearchmanager();
                final String metadataId = metadataRecord.id;
                DataManager.indexMetadata(dbms, metadataId, searchmanager, true);
            }

            Element e = new Element("id");
            e.setText(id);
            result.add(e);
        }

        if (!emailInfo.isEmpty()) {
            emailNotifications(strategy, context, dbms, session, msg, emailInfo, baseURL, strategySpecificData);
        }
        strategy.performDelete(ids, dbms, session, strategySpecificData);

        return result;

    }

    private void updateHrefs(final ReplacementStrategy strategy, ServiceContext context, Dbms dbms,
            final UserSession session, String id, Set<MetadataRecord> results, String baseURL,
            String strategySpecificData) throws Exception
    {
        // Move the reusable object to the DeletedObjects table and update
        // the xlink attribute information
        // so that the objects are obtained from that table
        Map<String/* oldHref */, String/* newHref */> updatedHrefs = new HashMap<String, String>();
        for (MetadataRecord metadataRecord : results) {
            for (String href : metadataRecord.xlinks) {
                Iterator<Element> xlinks = metadataRecord.xml.getDescendants(new FindXLinks(href));
                while (xlinks.hasNext()) {
                    Element xlink = xlinks.next();
                    String oldHRef = xlink.getAttributeValue(XLink.HREF, XLink.NAMESPACE_XLINK);
                    String newHref;
                    if (!updatedHrefs.containsKey(oldHRef)) {
                        Element fragment = Processor.resolveXLink(oldHRef);

                        // update xlink service
                        int newId = DeletedObjects.insert(dbms, context.getSerialFactory(), Xml.getString(fragment), href);
                        newHref = DeletedObjects.href(newId, baseURL);
                        updatedHrefs.put(oldHRef, newHref);
                    } else {
                        newHref = updatedHrefs.get(oldHRef);

                    }
                    // Remove non_validated role value (if necessary) so that
                    // xlink is not editable
                    xlink.removeAttribute(XLink.ROLE, XLink.NAMESPACE_XLINK);
                    xlink.setAttribute(XLink.HREF, newHref, XLink.NAMESPACE_XLINK);
                }
            }


            metadataRecord.commit(dbms);
        }
    }

    private void emailNotifications(final ReplacementStrategy strategy, ServiceContext context, Dbms dbms,
            final UserSession session, String msg, Multimap<String, String> emailInfo, String baseURL,
            String strategySpecificData) throws Exception
    {
        if (msg == null) {
            msg = "";
        }
        String msgHeader = Utils.translate(context.getAppPath(), context.getLanguage(), "deletedSharedObject/msg",
                "\n\n");
        String subject = Utils.translate(context.getAppPath(), context.getLanguage(), "deletedSharedObject/subject",
                " / ");

        Utils.sendEmail(new SendEmailParameter(context, dbms, msg, emailInfo, baseURL, msgHeader, subject));
    }

    public void init(String appPath, ServiceConfig params) throws Exception
    {
    }

}
