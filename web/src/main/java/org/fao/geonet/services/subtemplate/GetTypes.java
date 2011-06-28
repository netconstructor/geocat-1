//=============================================================================
//===   Copyright (C) 2011 Food and Agriculture Organization of the
//===   United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===   and United Nations Environment Programme (UNEP)
//===
//===   This program is free software; you can redistribute it and/or modify
//===   it under the terms of the GNU General Public License as published by
//===   the Free Software Foundation; either version 2 of the License, or (at
//===   your option) any later version.
//===
//===   This program is distributed in the hope that it will be useful, but
//===   WITHOUT ANY WARRANTY; without even the implied warranty of
//===   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===   General Public License for more details.
//===
//===   You should have received a copy of the GNU General Public License
//===   along with this program; if not, write to the Free Software
//===   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===   Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===   Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================
package org.fao.geonet.services.subtemplate;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.services.schema.Info;
import org.jdom.Element;

import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;

public class GetTypes implements Service {

	private static String[] elementNames = {"label", "description"};
	
    public void init(String appPath, ServiceConfig params) throws Exception {
    }

    public Element exec(Element params, ServiceContext context)
            throws Exception {

        Dbms dbms = (Dbms) context.getResourceManager()
                .open(Geonet.Res.MAIN_DB);

        Element subTemplateTypes = dbms
                .select("SELECT root AS type, schemaId FROM metadata WHERE isTemplate = 's' GROUP BY root, schemaId ORDER BY root");

        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        SchemaManager scm = gc.getSchemamanager();

        for (Object e : subTemplateTypes.getChildren()) {
            if (e instanceof Element) {
            	Element record = ((Element)e);
            	try {
            		String schema = record.getChildText("schemaid");
            		String name = Info.findNamespace(record.getChildText("type"), scm, (schema==null?"iso19139":schema));
            		Element info = Info.getHelp(scm, new Element("info"), "labels.xml", schema, name, "", "", "", context);
            		if (info != null) {
            			for (String childName : elementNames) {
            				Element child = info.getChild(childName);
            				if (child != null) {
            					record.addContent(child.detach());
            				}
            			}
            		}
            	} catch (Exception ex) {
            		// Can't retrieve information for the type
            	}
            }
        }

        return subTemplateTypes;
    }
}
