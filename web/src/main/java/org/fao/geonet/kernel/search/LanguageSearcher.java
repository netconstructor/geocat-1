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
import java.io.IOException;
import java.util.*;

import org.apache.lucene.document.Document;
import org.apache.lucene.document.FieldSelector;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.*;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.store.NIOFSDirectory;
import org.fao.geonet.kernel.search.spatial.SpatialFilter;
import org.fao.geonet.kernel.search.spatial.OgcGenericFilters;


/**
 *
 * JE: I would like to remove this and replace it with LuceneSearcher
 *
 * @author jeichar
 */
public class LanguageSearcher extends Searcher {

    private final Searcher _searcher;
    private final Set<String> _stopWords;

    public String locale;
    public File luceneDir;

    public LanguageSearcher(String path, String locale) throws CorruptIndexException, IOException {
        _searcher = new IndexSearcher(new NIOFSDirectory(new File(path)));
        _stopWords = new GeocatAnalyzer(locale).getStopWords();

        this.locale = locale;
        this.luceneDir = luceneDir;
    }

    public void close() throws IOException {
        _searcher.close();
    }

    public Document doc(int n, FieldSelector fieldSelector) throws CorruptIndexException, IOException {
        return _searcher.doc(n, fieldSelector);
    }

    public Document doc(int i) throws CorruptIndexException, IOException {
        return _searcher.doc(i);
    }

    public int docFreq(Term term) throws IOException {
        return _searcher.docFreq(term);
    }

    public int[] docFreqs(Term[] terms) throws IOException {
        return _searcher.docFreqs(terms);
    }


    public Explanation explain(Query query, int doc) throws IOException {
        Query modifiedQuery = removeStopWordTerms(query);
        return _searcher.explain(modifiedQuery, doc);
    }


    public Explanation explain(Weight weight, int doc) throws IOException {
        return _searcher.explain(weight, doc);
    }


    public Similarity getSimilarity() {
        return _searcher.getSimilarity();
    }

    public int maxDoc() throws IOException {
        return _searcher.maxDoc();
    }


    public Query rewrite(Query query) throws IOException {
        return _searcher.rewrite(query);
    }



    public TopFieldDocs search(Query query, Filter filter, int n, Sort sort) throws IOException {
        Query modifiedQuery = removeStopWordTerms(query);

        return _searcher.search(modifiedQuery, filter, n, sort);
    }


    public TopDocs search(Query query, Filter filter, int n) throws IOException {
        Query modifiedQuery = removeStopWordTerms(query);

        return _searcher.search(modifiedQuery, filter, n);
    }


    public void search(Weight weight, Filter filter, Collector results) throws IOException {
        _searcher.search(weight,filter,results);
    }

    public TopFieldDocs search(Weight weight, Filter filter, int n, Sort sort) throws IOException {

        /*
                 if ((filter instanceof GeoNetworkCachingWrapperFilter) ) {

                     JE: I hope this is not needed anymore because hopefully GN has fixed CSW search to take into account stop works

                    Filter cachedFilter = ((GeoNetworkCachingWrapperFilter) filter).getFilter();

                    if (cachedFilter instanceof DuplicateFilter) {
                        DuplicateFilter df = (DuplicateFilter) cachedFilter;

                        Query filterQuery = df.getQuery();
                        Query modifiedQuery = removeStopWordTerms(filterQuery);

                        df.setQuery(modifiedQuery);

                        weight = createWeight(df.getQuery());
                    } else if (cachedFilter instanceof GeoNetworkChainedFilter) {
                       GeoNetworkChainedFilter cf = (GeoNetworkChainedFilter) cachedFilter;
                        Filter[] cfList = cf.getFilters();
                        List<Query> allQueries = new ArrayList<Query>();
                        for (Filter f : cfList) {
                            if (f instanceof DuplicateFilter) {
                                DuplicateDocFilter df = (DuplicateDocFilter) f;
                                Query filterQuery = df.getQuery();

                                Query modifiedQuery = removeStopWordTerms(filterQuery);
                                allQueries.add(modifiedQuery);

                                df.setQuery(modifiedQuery);

                            } else if (f instanceof SpatialFilter) {

                                SpatialFilter df = (SpatialFilter) f;
                                Query filterQuery = df.getQuery();

                                Query modifiedQuery = removeStopWordTerms(filterQuery);
                                allQueries.add(modifiedQuery);

                                df.setQuery(modifiedQuery);

                            }
                        }

                         weight = createWeight(weight.getQuery().combine(allQueries.toArray(new Query[0])));
                    }
                }
        */
        return  _searcher.search(weight, filter, n, sort);
    }


    public TopDocs search(Weight weight, Filter filter, int n) throws IOException {
        return _searcher.search(weight, filter, n);
    }


    public void setSimilarity(Similarity similarity) {
        _searcher.setSimilarity(similarity);
    }


    public String toString() {
        return _searcher.toString();
    }


    public Query removeStopWordTerms(Query original) {
        Query updated;

        if (original instanceof TermQuery) {
            TermQuery termQuery = (TermQuery) original;
            Term term = termQuery.getTerm();
            updated = updateTerm(original, term);
        } else if (original instanceof FuzzyQuery) {
            FuzzyQuery query = (FuzzyQuery) original;
            updated = updateTerm(original, query.getTerm());
        } else if (original instanceof PrefixQuery) {
            PrefixQuery query = (PrefixQuery) original;
            updated = updateTerm(original, query.getPrefix());
        } else if (original instanceof WildcardQuery) {
            WildcardQuery query = (WildcardQuery) original;
            updated = updateTerm(original, query.getTerm());
        } else if (original instanceof PhraseQuery) {
            PhraseQuery query = (PhraseQuery) original;
            PhraseQuery newQuery = new PhraseQuery();
            newQuery.setSlop(query.getSlop());
            newQuery.setBoost(query.getBoost());
            for (Term term : query.getTerms()) {
                if (updateTerm(original, term) != null) {
                    newQuery.add(term);
                }
            }
            updated = newQuery;
        } else if (original instanceof BooleanQuery) {
            BooleanQuery q = (BooleanQuery) original;
            BooleanQuery newBooleanQuery = new BooleanQuery();
            newBooleanQuery.setBoost(q.getBoost());
            newBooleanQuery.setMinimumNumberShouldMatch(q.getMinimumNumberShouldMatch());

            BooleanClause[] clauses = q.getClauses();

            for (BooleanClause clause : clauses) {
                Query newQuery = removeStopWordTerms(clause.getQuery());
                if (newQuery != null) {
                    BooleanClause newClause = new BooleanClause(newQuery, clause.getOccur());
                    newBooleanQuery.add(newClause);
                }
            }

            updated = newBooleanQuery;
        } else {
            updated = original;
        }

        return updated;
    }

    private Query updateTerm(Query original, Term term) {
        Query updated;
        if (term == null) {
            updated = null;
        } else {

            String txt = term.text();
            txt = txt == null ? "" : txt;
            String fld = term.field();
            fld = fld == null ? "" : fld;

            // if not one of the "known" fields then remove the elements
            // that
            // are removed by the stopCodes
            if (fld.equals("_isTemplate") || fld.startsWith("_op")
                    || fld.startsWith("_locale") || fld.startsWith("_valid")
                    || fld.startsWith("_visibleForOwnerOnly")) {

                updated = original;
            } else if ((_stopWords.contains(txt.toLowerCase().trim()) || _stopWords.contains(txt.toUpperCase()
                    .trim()))) {
                updated = null;
            } else {
                updated = original;
            }
        }
        return updated;
    }
}
