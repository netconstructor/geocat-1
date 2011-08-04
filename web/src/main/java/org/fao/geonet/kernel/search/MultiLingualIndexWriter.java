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

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;

import jeeves.utils.Log;

import org.apache.lucene.analysis.KeywordAnalyzer;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.WhitespaceAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.store.NIOFSDirectory;
import org.fao.geonet.constants.Geonet;
import org.jdom.Attribute;
import org.jdom.Element;

/**
 * Provides support for writing to multiple indices. Each local/language will
 * have its own index.
 * 
 * @author jeichar
 */
class MultiLingualIndexWriter
{

    private MultiLingualIndexSupport _support;
    
    /**
     * 
     * @param searchManager
     * @param defaultLangDir
     */
    public MultiLingualIndexWriter(SearchManager searchManager,
            File defaultLangDir)
    {
        _support = new MultiLingualIndexSupport(searchManager.getLuceneDir());
        
    }
    private File getIndexDir(Attribute attribute)
    {
        String locale = MultiLingualIndexSupport.DEFAULT_LANGUAGE;
        if (attribute != null) {
            locale = attribute.getValue();
        }
        
        if( locale.trim().length()==0){
            locale = MultiLingualIndexSupport.DEFAULT_LANGUAGE;
        }
        File luceneDir = _support.luceneDir(locale);
        return luceneDir;
    }

}
