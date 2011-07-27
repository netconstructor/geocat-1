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

import jeeves.exceptions.BadParameterEx;
import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import org.fao.geonet.constants.Params;
import org.jdom.Element;

import java.io.File;


/**
 * Allows a user to delete a previously inserted user's xsl stylesheet
 * 
 * @author pmauduit
 */
public class RemoveXsl implements Service {
	
	  public Element exec(Element params, ServiceContext context) throws Exception
	    {
	    	String id = Util.getParam(params, Params.ID,null);
	    	// input sanitization / some checks in accordance of what
	    	// is done into RegisterXsl service
	    	if (id == null) {
	    		throw new BadParameterEx("id", "null");
	    	}
	    	if( !id.matches(RegisterXsl.ID_XSL_REGEX)) {
	    		throw new IllegalArgumentException("only letters and characters are permitted in the id");
	    	}
    		boolean success = new File(context.getAppPath() + RegisterXsl.USER_XSL_DIR + id + ".xsl").delete();

    		if (!success) {
    			throw new IllegalArgumentException("Error occured while trying to remove the stylesheet. File not found ?");
    		}
	    	
	    	return new Element("response").addContent("ok");
	    	
	    }
	  
	    public void init(String appPath, ServiceConfig params) throws Exception {}
}