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

import java.io.File;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;

import org.apache.commons.io.FileUtils;
import org.jdom.Element;

/**
 * Allows a user to set the xsl used for displaying metadata
 * 
 * @author jeichar
 */
public class RegisterXsl implements Service {

    static final String USER_XSL_DIR = "user_xsl_dir";
    static final String ID_XSL_REGEX = "[\\w\\d-_]+";

    private String userXslDir;

    public Element exec( Element params, ServiceContext context ) throws Exception {
        Element xslFile = params.getChild("fname");
        String fileName = xslFile.getTextTrim();
        String id = fileName;

        int extentionIdx = fileName.lastIndexOf('.');
        if (extentionIdx != -1) {
            id = fileName.substring(0, extentionIdx);
        }
        File file = new File(userXslDir + id + ".xsl");
        int i = 0;
        while( file.exists() ) {
            i++;
            file = new File(userXslDir + id + "_" + i + ".xsl");
        }
        file.getParentFile().mkdirs();

        File uploadedFile = new File(context.getUploadDir(), fileName);
        FileUtils.copyFile(uploadedFile, file);

        Element response = new Element("result");
        Element idElem = new Element("id");
        idElem.setAttribute("id", id);
        response.addContent(idElem);

        return response;
    }
    public void init( String appPath, ServiceConfig params ) throws Exception {
        userXslDir = params.getMandatoryValue(USER_XSL_DIR);
        if (!userXslDir.endsWith(File.separator)) {
            userXslDir = userXslDir + File.separator;
        }
        if (!new File(userXslDir).isAbsolute()) {
            userXslDir = appPath + File.separator + userXslDir;
        }
        new File(userXslDir).mkdirs();
    }

}
