//=============================================================================
//===	Copyright (C) 2001-2005 Food and Agriculture Organization of the
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
//===	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: GeoNetwork@fao.org
//==============================================================================

package org.fao.geonet.kernel.harvest;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import jeeves.exceptions.BadInputEx;
import jeeves.exceptions.BadParameterEx;
import jeeves.exceptions.MissingParameterEx;
import jeeves.resources.dbms.Dbms;
import jeeves.server.resources.ProviderManager;
import jeeves.utils.Log;
import jeeves.utils.Xml;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.harvest.Common.Type;
import org.fao.geonet.kernel.harvest.harvester.AbstractHarvester;
import org.fao.geonet.kernel.setting.SettingManager;
import org.jdom.Element;

//=============================================================================

public class HarvestManager
{
	//---------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//---------------------------------------------------------------------------

	public HarvestManager(String appPath, SettingManager sm, ProviderManager pm)
								throws Exception
	{
		xslPath    = appPath + Geonet.Path.STYLESHEETS+ "/xml";
		settingMan = sm;
		providMan  = pm;

		Element entries = settingMan.get("harvesting", -1);
		entries = Xml.transform(entries, xslPath +"/setting-to-harvesting.xsl");

		Iterator i = entries.getChildren().iterator();

		while (i.hasNext())
		{
			Element entry = (Element) i.next();
			Type    type  = Type.parse(entry.getAttributeValue("type"));

			AbstractHarvester ah = AbstractHarvester.create(type, sm, pm);
			ah.init(entry);
			hmHarvesters.put(ah.getID(), ah);
		}
	}

	//---------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//---------------------------------------------------------------------------

	public Element get(String id) throws Exception
	{
		Element result = (id == null)
									? settingMan.get("harvesting", -1)
									: settingMan.get("harvesting/id:"+id, -1);

		if (result == null)
			return null;

		result = Xml.transform(result, xslPath +"/setting-to-harvesting.xsl");

		if (result.getName().equals("node"))
			addInfo(result);
		else
		{
			Iterator nodes = result.getChildren().iterator();

			while (nodes.hasNext())
				addInfo((Element) nodes.next());
		}

		return result;
	}

	//---------------------------------------------------------------------------

	public String add(Dbms dbms, Element node) throws BadInputEx, SQLException
	{
		Log.debug(Geonet.HARVEST_MAN, "Adding harvesting node : \n"+ Xml.getString(node));

		String type = node.getAttributeValue("type");

		if (type == null)
			throw new MissingParameterEx("attribute:type", node);

		//--- raises an exception if type is unknown

		Type nodeType = Type.parse(type);

		AbstractHarvester ah = AbstractHarvester.create(nodeType, settingMan, providMan);

		String id = ah.add(dbms, node);
		hmHarvesters.put(ah.getID(), ah);

		return id;
	}

	//---------------------------------------------------------------------------

	public synchronized boolean update(Dbms dbms, Element node) throws BadInputEx, SQLException
	{
		Log.debug(Geonet.HARVEST_MAN, "Updating harvesting node : \n"+ Xml.getString(node));

		String id = node.getAttributeValue("id");

		if (id == null)
			throw new MissingParameterEx("attribute:id", node);

		AbstractHarvester ah = hmHarvesters.get(id);

		if (ah == null)
			return false;

		ah.update(dbms, node);
		return true;
	}

	//---------------------------------------------------------------------------
	/** This method must be synchronized because it cannot run if we are updating some entries */

	public synchronized boolean remove(Dbms dbms, String id) throws SQLException
	{
		Log.debug(Geonet.HARVEST_MAN, "Removing harvesting with id : "+ id);

		AbstractHarvester ah = hmHarvesters.get(id);

		if (ah == null)
			return false;

		ah.destroy();
		hmHarvesters.remove(id);
		settingMan.remove(dbms, "harvesting/id:"+id);

		return true;
	}

	//---------------------------------------------------------------------------

	public boolean start(Dbms dbms, String id) throws SQLException
	{
		Log.debug(Geonet.HARVEST_MAN, "Starting harvesting with id : "+ id);

		AbstractHarvester ah = hmHarvesters.get(id);

		if (ah == null)
			return false;

		ah.start(dbms);
		return true;
	}

	//---------------------------------------------------------------------------

	public boolean stop(Dbms dbms, String id) throws SQLException
	{
		Log.debug(Geonet.HARVEST_MAN, "Stopping harvesting with id : "+ id);

		AbstractHarvester ah = hmHarvesters.get(id);

		if (ah == null)
			return false;

		ah.stop(dbms);
		return true;
	}

	//---------------------------------------------------------------------------

	public boolean run(String id)
	{
		Log.debug(Geonet.HARVEST_MAN, "Running harvesting with id : "+ id);

		AbstractHarvester ah = hmHarvesters.get(id);

		if (ah == null)	return false;
			else 				return ah.run();
	}

	//---------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//---------------------------------------------------------------------------

	private void addInfo(Element node)
	{
		String id = node.getAttributeValue("id");
		hmHarvesters.get(id).addInfo(node);
	}

	//---------------------------------------------------------------------------
	//---
	//--- Vars
	//---
	//---------------------------------------------------------------------------

	private String          xslPath;
	private SettingManager  settingMan;
	private ProviderManager providMan;

	private HashMap<String, AbstractHarvester> hmHarvesters = new HashMap<String, AbstractHarvester>();
}

//=============================================================================

