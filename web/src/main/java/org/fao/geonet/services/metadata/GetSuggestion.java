//=============================================================================
//===	Copyright (C) 2011 Food and Agriculture Organization of the
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

package org.fao.geonet.services.metadata;

import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.MdInfo;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.services.Utils;
import org.jdom.Element;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Get suggestion for all metadata
 * 
 * <ul>
 * <li>
 * 1) Discover registered processes:
 * 
 * Use metadata.suggestion?id=2&action=list to retrieve the list of processes
 * registered for the metadata schema.
 * 
 * <pre>
 * {@code
 *   <suggestions>
 *     <suggestion process="keywords-comma-exploder"/>
 *   </suggestions>
 * }
 * </pre>
 * 
 * The process attribute contains the process identifier.
 * </li>
 * <li>
 * 2) Check if processes have suggestions for the metadata record Use
 * metadata.suggestion?id=2&action=analyze to analyze for all known processes or
 * metadata.suggestion?id=2&action=analyze&process=keywords-comma-exploder to
 * analyze for only one process.
 * </li>
 * <li>
 * 3) Apply the transformation using the @see {@link XslProcessing} service
 * metadata.processing?id=41&process=keywords-comma-exploder
 * </li>
 * </ul>
 */
public class GetSuggestion implements Service {

    ArrayList<String> process = new ArrayList<String>();
    String appPath;
    private static final String XSL_SUGGEST = "suggest.xsl";

    public void init(String appPath, ServiceConfig params) throws Exception {
        this.appPath = appPath;
    }

    public Element exec(Element params, ServiceContext context)
            throws Exception {

        Element response = new Element("suggestions");
        GeonetContext gc = (GeonetContext) context
                .getHandlerContext(Geonet.CONTEXT_NAME);
        DataManager dm = gc.getDataManager();
        AccessManager am = gc.getAccessManager();
        Dbms dbms = (Dbms) context.getResourceManager()
                .open(Geonet.Res.MAIN_DB);

        String runProcess = Util.getParam(params, Params.PROCESS, "");
        String action = Util.getParam(params, "action", "list");
        List<Element> children = params.getChildren();
        Map<String, String> xslParameter = new HashMap<String, String>();
        xslParameter.put("guiLang", context.getLanguage());
        xslParameter.put("baseUrl", context.getBaseUrl());
        for (Element param : children) {
            xslParameter.put(param.getName(), param.getTextTrim());
        }

        // Retrieve metadata record
        String id = Utils.getIdentifierFromParameters(params, context);
        MdInfo mdInfo = dm.getMetadataInfo(dbms, id);
        boolean forEditing = false, withValidationErrors = false, keepXlinkAttributes = false;
        Element md = gc.getDataManager().getMetadata(context, id, forEditing, withValidationErrors, keepXlinkAttributes);

        // List or analyze all suggestions process registered for this schema
        if ("list".equals(action) || "analyze".equals(action)) {
            MetadataSchema metadataSchema = dm.getSchema(mdInfo.schemaId);
            String filePath = metadataSchema.getSchemaDir() + "/"
                    + XSL_SUGGEST;
            File xslProcessing = new File(filePath);
            if (xslProcessing.exists()) {
                // -- here we send parameters set by user from
                // URL if needed.
                Element processList = Xml.transform(md, filePath, xslParameter);
                return processList;
            } else {
                return response;
            }
        }
        return response;
    }
}