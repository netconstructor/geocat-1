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
import java.io.FileFilter;
import java.io.IOException;
import java.util.Arrays;
import java.util.Comparator;

import org.apache.commons.lang.NotImplementedException;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.MapFieldSelector;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.MultiReader;
import org.apache.lucene.search.MultiSearcher;
import org.apache.lucene.search.Searcher;
import org.apache.lucene.store.NIOFSDirectory;

/**
 * 
 * @author jeichar
 */
public class MultiLingualIndexSupport
{

    public static final String DEFAULT_LANGUAGE = "eng";

    private final class MatchOrder implements Comparator<File>
    {
        private final String[] locales;

        private MatchOrder(String[] locales)
        {
            this.locales = locales;
        }

        private int index(File index){
            for (int i = 0; i < locales.length; i++) {
                if(locales[i].equals(toLocale(index))){
                    return i;
                }
            }
            return Integer.MAX_VALUE;
        }

        public int compare(File o1, File o2)
        {
            Integer v1 = index(o1);
            Integer v2 = index(o2);
            return v1.compareTo(v2);
        }
    }

    private final class IndexFileNameFilter implements FileFilter
    {
        public boolean accept(File dir, String name)
        {
            return name.startsWith(_defaultLangName);
        }

        public boolean accept(File pathname)
        {
            return accept(pathname.getParentFile(), pathname.getName());
        }
    }

    private final FileFilter indexFileNameFilter = new IndexFileNameFilter();
    protected final File           _luceneBaseDir;
    protected final  String         _defaultLangName;

    public MultiLingualIndexSupport(SearchManager searchManager)
    {
        File defaultLangDir = searchManager.getLuceneDir();
        this._luceneBaseDir = defaultLangDir.getParentFile();
        this._defaultLangName = defaultLangDir.getName();
    }

    public MultiLingualIndexSupport(File defaultLangDir)
    {
        this._luceneBaseDir = defaultLangDir.getParentFile();
        this._defaultLangName = defaultLangDir.getName();
    }
    
    protected final File luceneDir(String locale)
    {
        File indexDir = new File(_luceneBaseDir, _defaultLangName + "_"
                + locale);
        return indexDir;
    }

    public File[] listIndices()
    {
        File[] listFiles = _luceneBaseDir.listFiles(indexFileNameFilter);
        if (listFiles.length == 0) {
            // if no indices exist then just return the default index directory
            return new File[] { new File(_luceneBaseDir, _defaultLangName) };
        } else {
            return listFiles;
        }
    }
    
    public String[] listLocales(){
        File[] indices = listIndices();
        String[] locales = new String[indices.length]; 
        for (int i = 0; i < indices.length; i++) {
            locales[i] = toLocale(indices[i]);
        }
        return locales;
    }

    private String toLocale(File  index)
    {
        int beginIndex = index.getName().indexOf('_');
        if( beginIndex==-1 ) return "";
        return index.getName().substring(beginIndex+1);
    }

    public String[] sortCurrentLocalFirst(final String currentLocale){
        String[] locales = listLocales();
        Arrays.sort(locales, new Comparator<String>(){

            public int compare(String o1, String o2)
            {
                Integer v1 = o1.equals(currentLocale)?-1:0;
                Integer v2 = o2.equals(currentLocale)?-1:0;
                return v1.compareTo(v2);
            }
            
        });
        
        return locales;
    }
    

    /**
     * Creates a searcher for searching all language indexes
     * 
     * @param locales
     *            The list of locals to search. The order is important because
     *            if a document is found in the first index it will not be
     *            reported in subsequent hits in other indices
     * @return A searcher that searches all the locals provided
     * 
     * @throws java.io.IOException thrown if an underlying io exception occurs
     */
    public MultiSearcher createMultiMetaSearcher(final String[] locales)
            throws IOException
    {
        final File[] indices = listIndices();
        Arrays.sort(indices, new MatchOrder(locales));
        Searcher[] searchers = new Searcher[locales.length];
        int i = 0;
        for (; i < searchers.length; i++) {
			searchers[i] = new LanguageSearcher(indices[i].getAbsolutePath(), locales[i]);
        }
        if( i!=locales.length ){
            throw new IllegalArgumentException("Not all locales requested are available"+Arrays.toString(locales));
        }
        return new MultiSearcher(searchers);
    }

    public IndexWriter createWriter(File index, File localeDir)
            throws IOException
    {
        String[] parts = index.getName().split("_");
        String locale = null;
        if (parts.length == 2) {
            locale = parts[1];
        }

        return new IndexWriter(new NIOFSDirectory(index),
                new GeocatAnalyzer(locale), true, IndexWriter.MaxFieldLength.UNLIMITED);
    }

    /**
     * Creates a {@link org.apache.lucene.index.IndexReader} for reading all language indexes.
     * 
     * @param locales
     *            The list of locales to read. 
     * @return A searcher that searches all the locals provided
     * 
     * @throws java.io.IOException thrown if an underlying io exception occurs
     */
    public IndexReader createMultiReader(String[] locales) throws IOException
    {
        File[] indices = listIndices();
        Arrays.sort(indices, new MatchOrder(locales));
        IndexReader[] subReaders = new IndexReader[locales.length];
        int i = 0;
        for (; i < subReaders.length; i++) {
            subReaders[i] = IndexReader.open(new NIOFSDirectory(indices[i]));
        }
        if( i!=locales.length ){
            throw new IllegalArgumentException("Not all locales requested are available"+Arrays.toString(locales));
        }

        return new MultiReader(subReaders);
    }
}
