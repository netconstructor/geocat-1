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

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import jeeves.server.context.ServiceContext;
import jeeves.server.resources.ResourceManager;
import jeeves.utils.Log;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;

public class MetadataNotifierControl {
    private ServiceContext srvContext;
    private GeonetContext gc;
    private static final ScheduledExecutorService scheduler = Executors
            .newScheduledThreadPool(1);

    public MetadataNotifierControl(ServiceContext srvContext, GeonetContext gc) {
        this.srvContext = srvContext;
        this.gc = gc;
    }

    public void runOnce() throws Exception {
        if(Log.isDebugEnabled(Geonet.DATA_MANAGER))
            Log.debug(Geonet.DATA_MANAGER, "MetadataNotifierControl runOnce start");
        
        ResourceManager rm = srvContext.getResourceManager();
        if(Log.isDebugEnabled(Geonet.DATA_MANAGER))
            Log.debug(Geonet.DATA_MANAGER, "getUnregisteredMetadata after dbms");
        final MetadataNotifierTask updateTask = new MetadataNotifierTask(
                rm, gc);

        @SuppressWarnings("unused")
        final ScheduledFuture<?> updateTaskHandle = scheduler.schedule(
                updateTask, 20, TimeUnit.SECONDS);
        if(Log.isDebugEnabled(Geonet.DATA_MANAGER))
            Log.debug(Geonet.DATA_MANAGER, "MetadataNotifierControl runOnce finish");
    }

    public void shutDown() throws Exception {
        scheduler.shutdown();
    }

}
