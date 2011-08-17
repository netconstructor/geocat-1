//=============================================================================
//===	Copyright (C) 2001-2005 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This library is free software; you can redistribute it and/or
//===	modify it under the terms of the GNU Lesser General Public
//===	License as published by the Free Software Foundation; either
//===	version 2.1 of the License, or (at your option) any later version.
//===
//===	This library is distributed in the hope that it will be useful,
//===	but WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//===	Lesser General Public License for more details.
//===
//===	You should have received a copy of the GNU Lesser General Public
//===	License along with this library; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: GeoNetwork@fao.org
//==============================================================================

package jeeves.utils;

import java.io.File;
import java.io.IOException;

import jeeves.server.ConfigurationOverrides;
import jeeves.server.sources.http.JeevesServlet;

import org.jdom.Element;
import org.jdom.JDOMException;

//=============================================================================

public class XmlFileCacher
{
	private JeevesServlet servlet;

    //--------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//--------------------------------------------------------------------------
    public XmlFileCacher(File file)
    {
        this(file, null);
    }
	public XmlFileCacher(File file, JeevesServlet jeevesServlet)
	{
		//--- 10 seconds as default interval
		this(file, 10, jeevesServlet);
	}

	//--------------------------------------------------------------------------
	/**
	 * @param jeevesServlet if non-null the config-overrides can be applied to the xml file when it is loaded
	 */
	public XmlFileCacher(File file, int interval, JeevesServlet jeevesServlet)
	{
		this.file     = file;
		this.interval = interval;
		this.servlet = jeevesServlet;
	}

	//--------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//--------------------------------------------------------------------------

	public Element get() throws JDOMException, IOException
	{
		if (elem == null)
		{
			elem         = load();
			lastTime     = System.currentTimeMillis();
			lastModified = file.lastModified();
		}

		else
		{
			long now   = System.currentTimeMillis();
			int  delta = (int) (now - lastTime) / 1000;

			if((delta >= interval))
			{
				long fileModified = file.lastModified();

				if (lastModified != fileModified)
				{
					elem         = load();
					lastModified = fileModified;
				}

				lastTime = now;
			}
		}


		return elem;
	}

	//--------------------------------------------------------------------------
	//---
	//--- Protected methods
	//---
	//--------------------------------------------------------------------------

	/** Overriding this method makes it possible a conversion to XML on the fly
	  * of files in other formats */

	protected Element load() throws JDOMException, IOException
	{
		Element xml = Xml.loadFile(file);
		if(servlet!=null) {
		    ConfigurationOverrides.updateWithOverrides(file.getPath(), servlet, xml);
		}
        return xml;
	}

	//--------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//--------------------------------------------------------------------------

	private File file;
	private int  interval; //--- in secs
	private long lastTime;
	private long lastModified;

	private Element elem;
}

//=============================================================================


