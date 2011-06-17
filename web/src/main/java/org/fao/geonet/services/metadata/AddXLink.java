//=============================================================================
//===	Copyright (C) 2008 Swisstopo, BRGM
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
//===	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//===
//===	Contact: Jeroen Ticheler - email: GeoNetwork@osgeo.org
//==============================================================================

package org.fao.geonet.services.metadata;

import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.xlink.XLink;

import org.apache.commons.lang.NotImplementedException;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.reusable.ReusableObjManager;
import org.jdom.Element;

//=============================================================================

/**
 * For editing : adds a tag to a metadata. Access is restricted
 *
 * <ul>
 *	<li>ID : Identifier of the metadata record to update</li>
 *	<li>REF : Reference of the metadata element to be updated</li>
 *	<li>NAME : Name of the metadata element to be updated</li>
 *	<li>VERSION : Current metadata version in edition</li>
 *	<li>HREF : href of the XLink to be created</li>
 * </ul>
 *
 *  @author fxprunayre
 */
public class AddXLink implements Service {
	public void init(String appPath, ServiceConfig params) throws Exception {
	}

	// --------------------------------------------------------------------------
	// ---
	// --- Service
	// ---
	// --------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context)
			throws Exception {
        EditUtils editUtils = new EditUtils(context);
		editUtils.preprocessUpdate(params, context);

		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager dataMan = gc.getDataManager();

		Dbms dbms = (Dbms) context.getResourceManager()
				.open(Geonet.Res.MAIN_DB);

		String id = Util.getParam(params, Params.ID);
		String ref = Util.getParam(params, Params.REF);
		String name = Util.getParam(params, Params.NAME);
		String href = Util.getParam(params, XLink.HREF, "");
		// HACK.  I am ignoring role and hardcoding a call to ReusableObjectManager to determine what the role should be
		// This is because I need reusable objects to be non_validated vs validated.
		// String role = Util.getParam(params, jeeves.xlink.XLink.ROLE, "");

		String version = Util.getParam(params, Params.VERSION);
        synchronized (dataMan) {

    		editUtils.updateContent(params, true, true);

    		List<XLink> links = new ArrayList<XLink>();

    		// FIXME : here we could improve processing, defining a
    		// prefix for xlink element to be added could be directly
    		// processed in updateContent so you don't do stuff twice
    		// or more.
    		//--- Add one xlink element sent in href parameter
    		if (!href.equals("")) {
    			//href.replace("&amp;", "&").replace("#", "%23")

                String role = gc.getReusableObjMan().isValidated(href, context) ? "": ReusableObjManager.NON_VALID_ROLE;
                href = gc.getReusableObjMan().createAsNeeded(href,context);
    			URL url = new URL (href);
    			context.debug("Add as xlink url: " + href);

    			links.add(new XLink (url, "", role));
    		}

    		//--- Add all element starting with prefix href_ if exist.
    		// Gui only available for keywords.
    		List<Element> list = params.getChildren();
    		for (Element el : list) {
    			if (el.getName().startsWith("href_")) {
    				String link = Util.getParam(params, el.getName(), "");

    				if (!link.equals("")) {
    					//--- add metadata locales in order to retrieve keywords needed
    					// by the metadata record.
    					String locales = Util.getParam(params, "keyword.locales", "");
    					if (!locales.equals(""))
    						link += "&amp;locales=" + locales;
    		            String role = gc.getReusableObjMan().isValidated(link, context) ? "": ReusableObjManager.NON_VALID_ROLE;
    					URL url = new URL (link);
    					context.debug("Add as xlink url: " + link);
    					links.add(new XLink (url, "", role));
    				}
    			}
    		}

            throw new NotImplementedException("Need to implement this still");
    		/*if (!dataMan.addXLinkForElement(dbms, id, md, ref, name, links, version))
    		    throw new Exception(id);

    		Element elResp = new Element(Jeeves.Elem.RESPONSE);
    		elResp.addContent(new Element(Geonet.Elem.ID).setText(id));
    		return elResp;
    		*/
        }
	}
}

// =============================================================================

