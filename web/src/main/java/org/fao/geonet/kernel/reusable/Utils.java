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

import java.io.IOException;
import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.UnknownHostException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Pattern;

import javax.mail.MessagingException;
import javax.mail.internet.AddressException;

import com.google.common.base.Function;
import jeeves.resources.dbms.Dbms;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.xlink.XLink;

import org.apache.lucene.document.Document;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.MultiSearcher;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.search.WildcardQuery;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.search.MultiLingualIndexSupport;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.reusable.log.ReusableObjectLogger;
import org.fao.geonet.services.util.Email;
import org.fao.geonet.util.LangUtils;
import org.jdom.Content;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.filter.Filter;

import static java.lang.Double.parseDouble;

/**
 * Utility methods for this package
 *
 * @author jeichar
 */
public final class Utils
{
    static Element updateXLink(ReplacementStrategy strategy, ServiceContext context,
                            Map<String, String> idMapping, String id, boolean validated) throws Exception {
        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

        UserSession session = context.getUserSession();
        final String[] luceneFields = strategy.getInvalidXlinkLuceneField();

        final Function<String, String> idConverter = strategy.numericIdToConcreteId(session);
        Set<MetadataRecord> results = getReferencingMetadata(context, luceneFields, id, true, idConverter);

        for (MetadataRecord metadataRecord : results) {

            for (String xlinkHref : metadataRecord.xlinks) {

                @SuppressWarnings("unchecked")
                Iterator<Element> xlinks = metadataRecord.xml.getDescendants(new FindXLinks(xlinkHref));
                while (xlinks.hasNext()) {
                    Element xlink = xlinks.next();
                    xlink.removeAttribute(XLink.ROLE, XLink.NAMESPACE_XLINK);

                    String oldHref = xlink.getAttributeValue(XLink.HREF, XLink.NAMESPACE_XLINK);
                    String newId = idMapping.get(id);
                    if (newId == null) {
                        newId = id;
                    }
                    String validateHRef = strategy.updateHrefId(oldHref, newId, session);
                    if(validated) {
                        xlink.setAttribute(XLink.HREF, validateHRef, XLink.NAMESPACE_XLINK);
                    }
                }

            }
            metadataRecord.commit(dbms);
        }
        Element e = new Element("id");
        e.setText(id);
        return e;
    }

    public static String id(String href) {
         if(href.indexOf("id=") < 0) {
            return null; // nothing to be done
        }
        String id = href.substring(href.indexOf("id=")+3);
        if(id.contains("&")) {
            id = id.substring(0, id.indexOf('&'));
        }
        return id;
    }

    /**
     * Finds xlinks with the href that contains the fragment provided in the
     * constructor
     *
     * @author jeichar
     */
    public static class FindXLinks implements Filter
    {
        private static final long serialVersionUID = 1L;
        private final Pattern      _fragment;

        public FindXLinks(String fragment)
        {
        	String[] split = fragment.split("___");
        	StringBuilder builder = new StringBuilder();
        	for (String string : split) {
        		if(builder.length() > 0){
        			builder.append("\\w\\w\\w");
        		}
				builder.append(Pattern.quote(string));
			}
        	this._fragment = Pattern.compile(builder.toString());
        }

        public boolean matches(Object arg0)
        {
            if (arg0 instanceof Element) {
                Element element = (Element) arg0;
                String href = element.getAttributeValue(XLink.HREF, XLink.NAMESPACE_XLINK);
                return href != null && _fragment.matcher(href).find();
            }
            return false;
        }

    }

    static final String XSL_REUSABLE_OBJECT_DATA_XSL = "xsl/reusable-object-snippet-flatten.xsl";

    static <T> List<T> convertToList(Iterator iter, Class<T> class1)
    {
        List<T> placeholders = new ArrayList<T>();
        while (iter.hasNext()) {
            placeholders.add(class1.cast(iter.next()));
        }
        return placeholders;
    }

    static Element nextElement(Iterator<Content> elements)
    {
        Content originalElem = null;
        while (!(originalElem instanceof Element) && elements.hasNext()) {
            originalElem = elements.next();
        }
        return (Element) originalElem;
    }

    static String getText(Element xml, String name, String defaultName)
    {
        String text = xml.getChildText(name);
        if (text != null) {
            return text.trim();
        }
        return defaultName;
    }

    static String getText(Element xml, String name)
    {
        return getText(xml, name, "");
    }

    public static boolean isEmpty(Collection<Element> xlinks)
    {
        return xlinks == null || xlinks.isEmpty();
    }

    public static String constructWhereClause(String columnName, String[] ids)
    {
        return columnName + "=" + mkString(Arrays.asList(ids), " OR " + columnName + "=");
    }

    /**
     * Get all the metadata that use the xlink. This does a sql like query so
     * only a unique portion of the sql is required
     *
     * @param context
     */
    public static Set<MetadataRecord> getReferencingMetadata(ServiceContext context, String[] luceneFields, String id, boolean loadMetadata, Function<String,String> idConverter)
            throws Exception {


        String concreteId = idConverter.apply(id);
        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

        SearchManager searchManager = gc.getSearchmanager();

        MultiLingualIndexSupport support = new MultiLingualIndexSupport(searchManager);

        MultiSearcher searcher = support.createMultiMetaSearcher(support.sortCurrentLocalFirst(context.getLanguage()));

        try {
            TreeSet<MetadataRecord> results = new TreeSet<MetadataRecord>(new Comparator<MetadataRecord>() {

                public int compare(MetadataRecord o1, MetadataRecord o2) {
                    return o1.id.compareTo(o2.id);
                }

            });

            for (String field : luceneFields) {
                Term term = new Term(field, "*id=" + concreteId + "*");
                WildcardQuery query = new WildcardQuery(term);
                TopDocs tdocs = searcher.search(query, 1);

                for (ScoreDoc sdoc : tdocs.scoreDocs) {
                    Document element = searcher.doc(sdoc.doc);

                    List<String> xlinks = new ArrayList<String>();
                    for (String value : element.getValues(field)) {
                        if (equalIds(value, concreteId)) {
                            xlinks.add(value);
                        }
                    }
                    if (!xlinks.isEmpty()) {
                        MetadataRecord record = new MetadataRecord(element, xlinks, dbms, loadMetadata);
                        results.add(record);
                    }


                }
            }
            return results;
        } finally {
            searcher.close();
        }
    }

    private static boolean equalIds(String value, String id2) {
        // ids are normally ints bug some (like keywords) are strings

        String id1 = Utils.id(value);
        try {
            double id1Double = parseDouble(id1);
            double id2Double = parseDouble(id2);
            return Math.abs(id1Double - id2Double) < 0.1;
        } catch (NumberFormatException e) {
            return id1.equals(id2);
        }
    }

    public static String mkString(Iterable<? extends Object> iterable)
    {
        return mkString(iterable, "", ",", "");
    }

    public static String mkString(Iterable<? extends Object> iterable, String separator)
    {
        return mkString(iterable, "", separator, "");
    }

    public static String mkString(Iterable<? extends Object> iterable, String pre, String separator, String post)
    {
        StringBuilder out = new StringBuilder();

        for (Object object : iterable) {
            if (out.length() == 0) {
                out.append(pre);
            } else {
                out.append(separator);
            }
            out.append(object);
        }
        out.append(post);

        return out.toString();
    }

    public static String mkBaseURL(String baseURL, SettingManager settingMan)
    {
        String host = settingMan.getValue("system/server/host").trim();
        String portNumber = settingMan.getValue("system/server/port").trim();
        if (host.length() == 0) {
            try {
                host = InetAddress.getLocalHost().getHostName();
            } catch (UnknownHostException e1) {
                host = "http://localhost";
            }
        }
        if (portNumber.length() == 0) {
            portNumber = "8080";
        }

        try {
            new URL(host);
        } catch (MalformedURLException e) {
            try {
                new URL("http://" + host);
                host = "http://" + host;
            } catch (MalformedURLException e2) {
                throw new RuntimeException(e);
            }
        }
        if (host.length() == 0) {
            return baseURL;
        } else {
            return host + ":" + portNumber + baseURL;
        }
    }

    public static String extractUrlParam(Element xlink, String paramName)
    {
        String href = xlink.getAttributeValue(XLink.HREF, XLink.NAMESPACE_XLINK);
        if (href == null) {
            return null;
        }
        int beginIndex = href.indexOf(paramName + "=") + paramName.length() + 1;
        String frag = href.substring(beginIndex);
        int index = frag.indexOf('&');
        if (index < 0) {
            index = frag.length();
        }
        String idString = frag.substring(0, index);
        return idString;
    }

    public static void unpublish(Collection<String> results, ServiceContext context) throws Exception
    {
        if (results.size() > 0) {
            Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);
            StringBuilder query = new StringBuilder(
                    "DELETE FROM OperationAllowed WHERE (groupId <= 1 ) AND (metadataId=");
            Iterator<String> iter = results.iterator();
            query.append(iter.next());
            while (iter.hasNext()) {
                query.append(" OR metadataId=");
                query.append(iter.next());
            }
            query.append(")");
            dbms.execute(query.toString());
        }
    }

    public static ReplacementStrategy strategy(ReusableTypes reusableType, ServiceContext context) throws Exception
    {
        ReplacementStrategy strategy = null;
        String appPath = context.getAppPath();
        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);
        String baseUrl = mkBaseURL(context.getBaseUrl(), gc.getSettingManager());
        String language = context.getLanguage();

        switch (reusableType)
        {
        case extents:
            strategy = new ExtentsStrategy(baseUrl, appPath, gc.getExtentManager(), language);
            break;
        case keywords:
            strategy = new KeywordsStrategy(gc.getThesaurusManager(), appPath, baseUrl, language);
            break;
        case formats:
            strategy = new FormatsStrategy(dbms, appPath, baseUrl, language, context.getSerialFactory());
            break;
        case contacts:
            strategy = new ContactsStrategy(dbms, appPath, baseUrl, language, context.getSerialFactory());
            break;
        default:
            break;
        }
        return strategy;
    }

    public static void addChild(Element record, String elemName, String text)
    {
        Element e = new Element(elemName);
        record.addContent(e);
        e.setText(text);
    }

    public static void sendEmail(SendEmailParameter args) throws SQLException, MessagingException, AddressException
    {
        String query = "SELECT email,id FROM Users WHERE id=" + mkString(args.emailInfo.keySet(), " OR id=");
        Element emailRecords = args.dbms.select(query);
        org.fao.geonet.services.util.Email emailService = new org.fao.geonet.services.util.Email(args.context);

        try {
            Set<String> unnotifiedIds = new HashSet<String>();

            for (Element element : (List<Element>) emailRecords.getChildren()) {
                final String id = element.getChildText("id");
                String email = element.getChildText("email");
                if (!Email.isValidEmailAddress(email)) {
                    unnotifiedIds.addAll(args.emailInfo.get(id));
                } else {
                    String emailBody = args.msg + "\n" + args.baseURL + "/srv/eng/metadata.show?id="
                            + mkString(args.emailInfo.get(id), "\n" + args.baseURL + "/srv/eng/metadata.show?id=");

                    emailService.sendEmail(email, args.subject, args.msgHeader + emailBody);
                }
            }

            if (!unnotifiedIds.isEmpty()) {
                String emailBody = args.msg + "\n" + args.baseURL + "/srv/eng/metadata.show?id="
                        + mkString(unnotifiedIds, "\n" + args.baseURL + "/srv/eng/metadata.show?id=");
                if (Email.isValidEmailAddress(emailService.feedbackAddress)) {
                    emailService.sendEmail(emailService.feedbackAddress, args.subject, emailBody);
                }
                Log.warning(ReusableObjectLogger.REUSABLE_LOGGER_ID, emailBody);
            }
        } catch (Exception e) {
            Log.error(ReusableObjectLogger.REUSABLE_LOGGER_ID,
                    "The System Configuration is not correctly configured and there for emails cannot be sent.  "
                            + "Make sure the email/feedback settings are configured");
        }
    }

    public static String translate(String appPath, String langCode, String key, String separator) throws IOException,
            JDOMException
    {
        String[] translations = { LangUtils.translate(appPath, "deu", key, ""),
                LangUtils.translate(appPath, "fra", key, ""), LangUtils.translate(appPath, "eng", key, ""),
                LangUtils.translate(appPath, "ita", key, "") };

        StringBuilder result = new StringBuilder();

        for (String string : translations) {
            if (string != null && string.trim().length() > 0) {
                if (result.length() > 0) {
                    result.append(separator);
                }
                result.append(string);
            }
        }
        return result.toString();
    }

}
