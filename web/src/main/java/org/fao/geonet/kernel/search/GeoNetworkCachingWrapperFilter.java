package org.fao.geonet.kernel.search;

import org.apache.lucene.search.CachingWrapperFilter;
import org.apache.lucene.search.Filter;

/**
 * Class to make avalaible the cached filter. Used in LanguageSearcher
 */
public class GeoNetworkCachingWrapperFilter extends CachingWrapperFilter {   
    public Filter getFilter() {
        return filter;
    }

    public GeoNetworkCachingWrapperFilter(Filter filter) {
        super(filter);
    }
}
