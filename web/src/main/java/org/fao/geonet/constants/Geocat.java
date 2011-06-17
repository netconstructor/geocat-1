package org.fao.geonet.constants;

import com.vividsolutions.jts.geom.Geometry;
import org.geotools.feature.simple.SimpleFeatureTypeBuilder;
import org.geotools.referencing.crs.DefaultGeographicCRS;
import org.opengis.feature.simple.SimpleFeatureType;

/**
 * Geocat constants
 */
public class Geocat {
    public static class Params {
        public static final String ACTION = "action";
    }

    public static class Spatial {
        public static final String IDS_ATTRIBUTE_NAME = "id";
        public static final String GEOM_ATTRIBUTE_NAME = "the_geom";
        public static final String SPATIAL_INDEX_TYPENAME = "spatialindex";

        public static final String SPATIAL_FILTER_JCS = "SpatialFilterCache";
        public static final SimpleFeatureType FEATURE_TYPE;

        static {
            SimpleFeatureTypeBuilder builder = new SimpleFeatureTypeBuilder();
            builder.add(GEOM_ATTRIBUTE_NAME, Geometry.class, DefaultGeographicCRS.WGS84);
            builder.setDefaultGeometry(GEOM_ATTRIBUTE_NAME);
            builder.setName(SPATIAL_INDEX_TYPENAME);
            FEATURE_TYPE = builder.buildFeatureType();
        }

    }

    public class Profile {
        public static final String SHARED = "Shared";
    }

    public class Config {
        public static final String EXTENT_CONFIG = "extent";
        public static final String REUSABLE_OBJECT_CONFIG = "reusable";
    }

    public class Module {
        public static final String EXTENT = "extent";
        public static final String REUSABLE = "reusable";
        public static final String MONITORING = "monitoring";
    }
}
