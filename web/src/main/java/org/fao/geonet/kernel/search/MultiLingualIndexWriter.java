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
    private final SearchManager      _searchManager;
    private HashMap<String, PerFieldAnalyzerWrapper> _analyzers; 
    
    /**
     * 
     * @param searchManager
     * @param defaultLangDir
     */
    public MultiLingualIndexWriter(SearchManager searchManager,
            File defaultLangDir)
    {
        _searchManager = searchManager;
        _support = new MultiLingualIndexSupport(searchManager);
        
    }

    // creates a new document
    private Document newDocument(Element xml)
    {
        Document doc = new Document();
        for (Iterator iter = xml.getChildren().iterator(); iter.hasNext();) {
            Element field = (Element) iter.next();
            String name = field.getAttributeValue("name");
            // RGFIX: should be only needed for non-tokenized fields
			String string = field.getAttributeValue("string"); // Lower case field is handled by Lucene Analyzer.
            if (string.trim().length() > 0) {
                String sStore = field.getAttributeValue("store");
                String sIndex = field.getAttributeValue("index");
                String sToken = field.getAttributeValue("token");
                boolean bStore = sStore != null && sStore.equals("true");
                boolean bIndex = sIndex != null && sIndex.equals("true");
                boolean token = sToken != null && sToken.equals("true");
                Field.Store store = null;
                if (bStore) {
                    store = Field.Store.YES;
                } else {
                    store = Field.Store.NO;
                }
                Field.Index index = null;
                if (bIndex && token) {
                    index = Field.Index.TOKENIZED;
                }
                if (bIndex && !token) {
                    index = Field.Index.UN_TOKENIZED;
                }
                if (!bIndex) {
                    index = Field.Index.NO;
                }
                doc.add(new Field(name, string, store, index));
            }
        }
        return doc;
    }

    public void write(Element xmlDoc) throws Exception
    {

        for (Iterator iterator = xmlDoc.getContent().iterator(); iterator
                .hasNext();) {
            Element docElem = (Element) iterator.next();

            Attribute attribute = docElem.getAttribute("locale");
            String langCode=null;
            if( attribute!=null ){
                langCode = attribute.getValue();
            }
            
            // TODO : we could probably improve that if we set one Analyzer per language
            // and keep the different kind of analyzer.
            //
            // Define the default Analyzer
            PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(new GeocatAnalyzer(langCode, _searchManager.getStylesheetsDir()));
    		// Here you could define specific analyzer for each fields stored in the index.
    		//
    		// For example adding a different analyzer for any (ie. full text search) 
    		// could be better than a standard analyzer which has a particular way of 
    		// creating tokens.
    		// In that situation, when field is "mission AD-T" is tokenized to "mission" "AD" & "T"
    		// using StandardAnalyzer.
    		// A WhiteSpaceTokenizer tokenized to "mission" "AD-T"
    		// which could be better in some situation.
    		// But when field is "mission AD-34T" is tokenized to "mission" "AD-34T" using StandardAnalyzer due to number.
    		// analyzer.addAnalyzer("any", new WhitespaceAnalyzer());
    		// 
    		// Uuid stored using a standard analyzer will be change to lower case.
    		// Whitespace will not.
    		analyzer.addAnalyzer("_uuid", new WhitespaceAnalyzer());
    		analyzer.addAnalyzer("_title", new WhitespaceAnalyzer());
    		analyzer.addAnalyzer("_defaultTitle", new WhitespaceAnalyzer());
    		analyzer.addAnalyzer("operatesOn", new WhitespaceAnalyzer());
    		analyzer.addAnalyzer("_groupOwnerName", new WhitespaceAnalyzer());
    		analyzer.addAnalyzer("subject", new KeywordAnalyzer());
    		
            
            if (!docElem.getName().equals("Document")) {
                Log
                        .error(Geonet.INDEX_ENGINE,
                                "All children of the root index Element must be 'Document' elements");
            }
            Document doc = newDocument(docElem);

            File luceneDir = getIndexDir(attribute);
            boolean create = !luceneDir.exists();
            if (create) {
                luceneDir.mkdirs();
            }
            IndexWriter writer = new IndexWriter(luceneDir, analyzer, create);
            try {
                writer.addDocument(doc);
            } finally {
                writer.close();
            }
        }
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
