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

package org.fao.geonet.services.extent;

import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.geotools.data.DataStore;
import org.geotools.data.DefaultQuery;
import org.geotools.data.FeatureSource;
import org.geotools.data.Query;
import org.geotools.data.wfs.WFSDataStore;
import org.geotools.data.wfs.WFSDataStoreFactory;
import org.geotools.factory.CommonFactoryFinder;
import org.geotools.factory.GeoTools;
import org.geotools.referencing.CRS;
import org.geotools.referencing.crs.DefaultGeographicCRS;
import org.opengis.feature.simple.SimpleFeature;
import org.opengis.feature.simple.SimpleFeatureType;
import org.opengis.filter.Filter;
import org.opengis.filter.FilterFactory2;
import org.opengis.filter.expression.Literal;
import org.opengis.filter.expression.PropertyName;
import org.opengis.referencing.crs.CoordinateReferenceSystem;

public class WFS
{
    final Map<String, Serializable> wfsDataStoreParams = new HashMap<String, Serializable>();
    final Set<FeatureType>          modifiable         = new LinkedHashSet<FeatureType>();
    final Map<String, FeatureType>  types              = new LinkedHashMap<String, FeatureType>();
    public final String             wfsId;
    private DataStore            datastore;

    public WFS(String id)
    {
        this.wfsId = id;
    }

    public synchronized DataStore getDataStore() throws IOException
    {
        if (datastore == null) {
            final WFSDataStoreFactory factory = new WFSDataStoreFactory();
            this.datastore = factory.createDataStore(wfsDataStoreParams);
        }
        return datastore;
    }

    FeatureType addFeatureType(String typename, String idColumn, String geoIdColumn, String descColumn,
            String searchColumn, String projection, boolean modifiable)
    {
        final FeatureType type = new FeatureType(typename, idColumn, geoIdColumn, descColumn, searchColumn, projection);
        types.put(typename, type);
        if (modifiable) {
            this.modifiable.add(type);
        }

        return type;
    }

    @Override
    public String toString()
    {
        return wfsDataStoreParams.get(WFSDataStoreFactory.URL.key).toString();
    }

    public class FeatureType
    {

        public static final String SHOW_NATIVE = "SHOW_NATIVE";

        public final String               typename;
        public final String               idColumn;
        public final String               geoIdColumn;
        public final String               descColumn;
        public final String               searchColumn;
        public final String               showNativeColumn;
        private CoordinateReferenceSystem projection;
        private String                    srs;

        public FeatureType(final String typename, final String idColumn, final String geoIdColumn,
                final String descColumn, final String searchColumn, String projection)
        {
            this.typename = typename;
            this.idColumn = idColumn;
            this.descColumn = descColumn;
            this.srs = projection;
            this.searchColumn = searchColumn;
            this.geoIdColumn = geoIdColumn;
            this.showNativeColumn = SHOW_NATIVE;

        }

        public FeatureSource<SimpleFeatureType, SimpleFeature> getFeatureSource() throws IOException
        {
            final DataStore datastore = getDataStore();
            if (Arrays.asList(datastore.getTypeNames()).contains(typename)) {
                return datastore.getFeatureSource(typename);
            } else {
                return null;
            }
        }

        public boolean isModifiable()
        {
            return modifiable.contains(this);
        }

        @Override
        public String toString()
        {

            String string = WFS.this.toString() + ": typename (" + idColumn + "," + descColumn + ")";
            if (isModifiable()) {
                string += "modifiable";
            }
            return string;
        }

        public Query createQuery(String id, String[] properties)
        {
            final Filter filter = createFilter(id);
            final DefaultQuery query = new DefaultQuery(typename, filter, properties);
            return query;
        }

        public Filter createFilter(String id)
        {
            final FilterFactory2 factory = CommonFactoryFinder.getFilterFactory2(GeoTools.getDefaultHints());
            final Literal literal = factory.literal(id);
            final PropertyName property = factory.property(idColumn);
            final Filter filter = factory.equals(property, literal);
            return filter;
        }

        public String wfsId()
        {
            return wfsId;
        }

        public WFS wfs()
        {
            return WFS.this;
        }

        public synchronized CoordinateReferenceSystem projection()
        {
            try {
                this.projection = CRS.decode(srs);
            } catch (Exception e) {
                this.projection = DefaultGeographicCRS.WGS84;
                this.srs = "EPSG:4326";
            }
            return projection;
        }

        public String srs()
        {
            return srs;
        }
    }

    public FeatureType getFeatureType(String typename)
    {
        return types.get(typename);
    }

    public Collection<FeatureType> getFeatureTypes()
    {
        return types.values();
    }

    public Collection<FeatureType> getModifiableTypes()
    {
        return modifiable;
    }

    public String listModifiable()
    {
        final List<String> name = new ArrayList<String>();
        for (final FeatureType type : getModifiableTypes()) {
            name.add(type.typename);
        }
        return name.toString();
    }

}
