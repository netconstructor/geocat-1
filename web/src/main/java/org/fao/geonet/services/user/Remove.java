//=============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
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

package org.fao.geonet.services.user;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;

import org.fao.geonet.constants.Geocat;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.reusable.ReusableTypes;
import org.fao.geonet.services.reusable.Reject;
import org.fao.geonet.util.LangUtils;
import org.jdom.Element;

//=============================================================================

/** Removes a user from the system. It removes the relationship to a group too
  */

public class Remove implements Service
{
	private Type type;

    //--------------------------------------------------------------------------
	//---
	//--- Init
	//---
	//--------------------------------------------------------------------------

	public void init(String appPath, ServiceConfig params) throws Exception {
	       this.type = Type.valueOf(params.getValue("type", "NORMAL"));
	}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

    public Element exec(Element params, ServiceContext context) throws Exception
	{
		String id = Util.getParam(params, Params.ID);

        Element rejectResult = handleSharedUser(id, params, context);
        if(rejectResult != null) {
            return rejectResult;
        }

		UserSession usrSess = context.getUserSession();
		String      myProfile = usrSess.getProfile();
		String      myUserId  = usrSess.getUserId();

		if (myUserId.equals(id)) {
			throw new IllegalArgumentException("You cannot delete yourself from the user database");
		}

		if (myProfile.equals(Geonet.Profile.ADMINISTRATOR) ||
				myProfile.equals("UserAdmin"))  {

			Dbms dbms = (Dbms) context.getResourceManager().open (Geonet.Res.MAIN_DB);
			
			if (myProfile.equals("UserAdmin")) {
				java.util.List adminlist =dbms.select("SELECT groupId FROM UserGroups WHERE userId="+myUserId+" or userId = "+id+" group by groupId having count(*) > 1").getChildren();
				if (adminlist.size() == 0) {
				  throw new IllegalArgumentException("You don't have rights to delete this user because the user is not part of your group");
				}
			}

			dbms.execute ("DELETE FROM UserGroups WHERE userId=" + id);
			dbms.execute ("DELETE FROM Users      WHERE     id=" + id);
		} else {
			throw new IllegalArgumentException("You don't have rights to delete this user");
		}

		return new Element(Jeeves.Elem.RESPONSE);
	}

    @SuppressWarnings("unchecked")
    private Element handleSharedUser(String id, Element params, ServiceContext context) throws Exception {
        Dbms dbms = (Dbms) context.getResourceManager().open (Geonet.Res.MAIN_DB);
        Element profileQuery = dbms.select("Select profile from users where id=?",Integer.parseInt(id));
        
        if(!profileQuery.getChildren().isEmpty()) {
            for (Element e : (java.util.List<Element>) profileQuery.getChildren()) {
                if( type == Type.NORMAL && Geocat.Profile.SHARED.equals(e.getChildTextTrim("profile")))
                    throw new IllegalArgumentException("This remove user service instance cannot remove shared objects");
            }
        }
        
        if(type != Type.NORMAL && !Boolean.parseBoolean(Util.getParam(params, "forceDelete", "false"))) {
            String msg = LangUtils.loadString("reusable.rejectDefaultMsg", context.getAppPath(), context.getLanguage());
            return new Reject().reject(context, ReusableTypes.contacts, new String[]{id}, msg, null);
        }
        return null;
    }
}

//=============================================================================

