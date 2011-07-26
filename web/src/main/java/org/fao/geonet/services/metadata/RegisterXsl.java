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
import org.fao.geonet.constants.Params;
import org.jdom.Element;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.FileChannel;
import java.nio.channels.ReadableByteChannel;
import java.util.UUID;

/**
 * Allows a user to set the xsl used for displaying metadata
 * 
 * @author jeichar
 */
public class RegisterXsl implements Service
{

    static final String USER_XSL_DIR = "user_xsl/";
    private Show        showService;

    public Element exec(Element params, ServiceContext context) throws Exception
    {
    	String xslUrlParam = Util.getParam(params, "xsl",null);
    	String xslFile     = Util.getParam(params, "file",null);

    	String id = Util.getParam(params, Params.ID,null);

    	if (id == null) {
    		id = UUID.randomUUID().toString();
    	}

    	if( !id.matches("[\\w\\d-]+")){
    		throw new IllegalArgumentException("only letters and characters are permitted in the id");
    	}


    	// PMT c2c : trying to use the posted (multipart) file
    	if (xslFile != null)
    	{
    		File file = new File(context.getAppPath() + USER_XSL_DIR + id + ".xsl");
    		int i = 0;
    		while (file.exists()) {
    			i++;
    			file = new File(context.getAppPath() + USER_XSL_DIR + id + "_" + i + ".xsl");
    		}
    		file.getParentFile().mkdirs();

    		FileInputStream from = null;
    		FileOutputStream to = null;
    		try {
    			from = new FileInputStream(context.getUploadDir()  + xslFile);
    			to = new FileOutputStream(file);
    			byte[] buffer = new byte[4096];
    			int bytesRead;

    			while ((bytesRead = from.read(buffer)) != -1)
    				to.write(buffer, 0, bytesRead); // write
    		} finally {
    			if (from != null)
    				try {
    					from.close();
    				} catch (IOException e) {
    					;
    				}
    			if (to != null)
    				try {
    					to.close();
    				} catch (IOException e) {
    					;
    				}
    		}
    		Element response = new Element("result");
    		Element idElem = new Element("id");
    		idElem.setAttribute("id", id);
    		response.addContent(idElem);

    		return response;
    	}
    	// end

    	// previous code:
    	else
    	{
    		URL xslUrl;

    		try {
    			xslUrl = new URL(xslUrlParam);
    		} catch (MalformedURLException e) {
    			throw new IllegalArgumentException("The 'xsl' parameter must be a valid URL");
    		}

    		File file = new File(context.getAppPath() + USER_XSL_DIR + id + ".xsl");
    		int i = 0;
    		while (file.exists()) {
    			i++;
    			file = new File(context.getAppPath() + USER_XSL_DIR + id + "_" + i + ".xsl");
    		}
    		file.getParentFile().mkdirs();
    		copy(xslUrl, file);

    		if (i > 0) {
    			id = id + "_" + i;
    		}

    		Element response = new Element("result");
    		Element idElem = new Element("id");
    		idElem.setAttribute("id", id);
    		response.addContent(idElem);

    		return response;
    	}
    }
    private void copy(URL xslUrl, File file) throws IOException
    {
        InputStream in = null;
        ReadableByteChannel inchannel = null;
        FileOutputStream out = null;
        FileChannel outchannel = null;
        try {
            in = xslUrl.openStream();
            inchannel = Channels.newChannel(in);
            out = new FileOutputStream(file);
            outchannel = out.getChannel();

            java.nio.ByteBuffer byteBuffer = java.nio.ByteBuffer.allocate(8092);
            int read;
            do {
                byteBuffer.clear();
                read = inchannel.read(byteBuffer);
                byteBuffer.flip();
                if (byteBuffer.remaining() > 0) {
                    outchannel.write(byteBuffer);
                }
            } while (read != -1);

        } finally {
            if (in != null)
                in.close();
            if (inchannel != null)
                inchannel.close();
            if (out != null)
                out.close();
            if (outchannel != null)
                outchannel.close();
        }

    }

    public void init(String appPath, ServiceConfig params) throws Exception
    {
        showService = new Show();
        showService.init(appPath, params);
    }

}
