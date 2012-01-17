//=============================================================================
//===   Copyright (C) 2001-2010 Food and Agriculture Organization of the
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
package org.fao.geonet.notifier;

import jeeves.resources.dbms.Dbms;
import jeeves.server.resources.ResourceManager;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;

public class MetadataNotifierTask implements Runnable {
    private ResourceManager rm;
    private GeonetContext gc;

    public MetadataNotifierTask(ResourceManager rm, GeonetContext gc) {
        this.rm = rm;
        this.gc = gc;
    }

    public void run() {
        Dbms dbms = null;
        try {
            dbms = (Dbms) rm.openDirect(Geonet.Res.MAIN_DB);
            gc.getMetadataNotifier().updateMetadataBatch(dbms, gc);
        } catch (Exception x) {
            System.out.println(x.getMessage());
            x.printStackTrace();
        } finally {
            if (dbms != null) {
                try {
                    rm.close(Geonet.Res.MAIN_DB, dbms);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
