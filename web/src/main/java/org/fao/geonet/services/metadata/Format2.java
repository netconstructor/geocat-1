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

package org.fao.geonet.services.metadata;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import org.fao.geonet.constants.Params;
import org.jdom.Element;

import java.io.File;
import java.io.FilenameFilter;

/**
 * Allows a user to set the xsl used for displaying metadata
 * 
 * @author jeichar
 */
public class Format2 implements Service
{

    private Show showService;
    private String userXslDir;
    private static String xslExtension = ".xsl";
    
    public Element exec(Element params, ServiceContext context) throws Exception
    {
        String xslid = Util.getParam(params, "xsl", null);
        String uuid = Util.getParam(params, Params.UUID, null);
        String id = Util.getParam(params, Params.ID, null);
        String list = Util.getParam(params, "list", null);
        
        if (list != null || (xslid == null && uuid == null && id == null)) {
        	Element response = new Element("metadata");
        	String xslFormatters[] = new File(userXslDir).list(new XslFilter());
        	for (String xsl : xslFormatters)
        		response.addContent(new Element("formatter").setText(xsl.substring(0, xsl.indexOf(xslExtension))));
        	
        	return response;
        }
        
        if( uuid==null && id==null ){
            throw new IllegalArgumentException("Either '"+Params.UUID+"' or '"+Params.ID+"'is a required parameter");
        }
        
        if( !xslid.matches(RegisterXsl.ID_XSL_REGEX)){
            throw new IllegalArgumentException("only letters and characters are permitted in the id");
        }
        
        File xslUrl = new File(userXslDir+xslid+".xsl");
        
        if(!xslUrl.exists())
            throw new IllegalArgumentException("The 'xsl' parameter must be a valid URL");
        Xml.loadFile(xslUrl);
        
        Element metadata = showService.exec(params, context);
        Element transformed = Xml.transform(metadata, xslUrl.getAbsolutePath());
        Element response = new Element("metadata");
        response.addContent(transformed);
        return response;
    }

    public void init(String appPath, ServiceConfig params) throws Exception
    {
        showService = new Show();
        showService.init(appPath, params);

        userXslDir = params.getMandatoryValue(RegisterXsl.USER_XSL_DIR);
        if(!userXslDir.endsWith(File.separator)) {
            userXslDir = userXslDir + File.separator;
        }
        if(!new File(userXslDir).isAbsolute()) {
            userXslDir = appPath+File.separator+userXslDir;
        }
    }
    
	private class XslFilter implements FilenameFilter {
		public boolean accept(File directory, String filename) {
			if (filename.endsWith(xslExtension))
				return true;
			return false;
		}
	}
    
}
