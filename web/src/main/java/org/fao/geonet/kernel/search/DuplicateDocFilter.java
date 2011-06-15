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

package org.fao.geonet.kernel.search;

import java.io.IOException;
import java.util.BitSet;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.apache.lucene.document.Document;
import org.apache.lucene.document.FieldSelector;
import org.apache.lucene.document.SetBasedFieldSelector;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.search.Filter;
import org.apache.lucene.search.HitCollector;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;

/**
 * When there are multiple languages certain queries can match the same "document" 
 * in each different language index.  This filter allows the first match but none of the later matche.
 *  
 * @author jeichar
 */
public class DuplicateDocFilter extends Filter
{

    private static final long serialVersionUID = -2575519355562280525L;

    public Query getQuery() {
        return _query;
    }

    public void setQuery(Query query) {
        this._query = query;
    }

    private Query _query;
    final Map<String, IndexReader> hits = new HashMap<String,IndexReader>(); 
    private FieldSelector _fieldSelector;
    
    public DuplicateDocFilter(Query query)
    {
        this._query = query;
        Set fieldsToLoad = Collections.singleton("_id");
        Set lazyFieldstoLoad = Collections.emptySet();
        _fieldSelector = new SetBasedFieldSelector(fieldsToLoad, lazyFieldstoLoad); 
    }

    @Override
    public BitSet bits(final IndexReader reader) throws IOException
    {
        final BitSet bits = new BitSet(reader.maxDoc());
        
        new IndexSearcher(reader).search(_query, new HitCollector()
        {

            public final void collect(int doc, float score)
            {
                Document document;
                try {
                    document = reader.document(doc, _fieldSelector);
                    String key = document.get("_id");
                    IndexReader hit = hits.get(key);
                    if (hit == null) {
                        bits.set(doc);
                        hits.put(key,reader);
                    } else if( hit==reader ){
                        bits.set(doc);
                    }
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            }
        });
        
        return bits;        
    }

}
