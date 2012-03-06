//==============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
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

import com.cybozu.labs.langdetect.Detector;
import com.cybozu.labs.langdetect.DetectorFactory;
import com.cybozu.labs.langdetect.LangDetectException;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.io.WKTReader;
import jeeves.constants.Jeeves;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.tokenattributes.TermAttribute;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.FieldSelector;
import org.apache.lucene.document.FieldSelectorResult;
import org.apache.lucene.document.Fieldable;
import org.apache.lucene.document.MapFieldSelector;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.misc.ChainedFilter;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanClause.Occur;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.CachingWrapperFilter;
import org.apache.lucene.search.Filter;
import org.apache.lucene.search.FuzzyQuery;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.MatchAllDocsQuery;
import org.apache.lucene.search.PhraseQuery;
import org.apache.lucene.search.PrefixQuery;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.Searcher;
import org.apache.lucene.search.Sort;
import org.apache.lucene.search.SortField;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TermRangeQuery;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.search.TopFieldCollector;
import org.apache.lucene.search.WildcardQuery;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Edit;
import org.fao.geonet.constants.Geocat;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.exceptions.UnAuthorizedException;
import org.fao.geonet.kernel.MdInfo;
import org.fao.geonet.kernel.search.LuceneConfig.LuceneConfigNumericField;
import org.fao.geonet.kernel.search.SummaryComparator.SortOption;
import org.fao.geonet.kernel.search.SummaryComparator.Type;
import org.fao.geonet.kernel.search.log.SearcherLogger;
import org.fao.geonet.kernel.search.lucenequeries.DateRangeQuery;
import org.fao.geonet.kernel.search.spatial.Pair;
import org.fao.geonet.kernel.search.spatial.SpatialFilter;
import org.fao.geonet.kernel.setting.SettingInfo;
import org.fao.geonet.util.JODAISODate;
import org.fao.geonet.util.XslUtil;
import org.jdom.Element;

import bak.pcj.map.ObjectKeyIntMap;
import bak.pcj.map.ObjectKeyIntMapIterator;
import bak.pcj.map.ObjectKeyIntOpenHashMap;

import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.io.WKTReader;
import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.lang.reflect.Constructor;
import java.text.CharacterIterator;
import java.text.StringCharacterIterator;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

//==============================================================================
// search metadata locally using lucene
//--------------------------------------------------------------------------------

public class LuceneSearcher extends MetaSearcher
{
	private static SearchManager _sm;
	private String        _styleSheetName;
	private Element       _summaryConfig;

	private Query         _query;
	private Filter        _filter;
	private Sort          _sort;
	private Element       _elSummary;
	private FieldSelector _selector;
	private IndexReader		_reader;

	private int           _maxSummaryKeys;
	private int           _maxHitsInSummary;
	private int           _numHits;
	private String        _resultType;
    private String        _language;

	private Set<String>	_tokenizedFieldSet;
	private LuceneConfig _luceneConfig;
	private String _boostQueryClass;

	/** Filter geometry object WKT, used in the logger
	  * ugly way to store this object, as ChainedFilter API is a little bit cryptic to me...
	  */
	private String _geomWKT = null;

	//--------------------------------------------------------------------------------
	// constructor
	public LuceneSearcher (SearchManager sm, String styleSheetName, Element summaryConfig, LuceneConfig luceneConfig)
	{
		_sm             = sm;
		_styleSheetName = styleSheetName;
		_summaryConfig  = summaryConfig;
		_selector = new FieldSelector() {
			public final FieldSelectorResult accept(String name) {
				if (name.equals("_id")) return FieldSelectorResult.LOAD;
				else return FieldSelectorResult.NO_LOAD;
			}
		};

		// build _tokenizedFieldSet
		_luceneConfig = luceneConfig;
		_boostQueryClass = _luceneConfig.getBoostQueryClass();
		_tokenizedFieldSet = luceneConfig.getTokenizedField();
	}

	//--------------------------------------------------------------------------------
	// MetaSearcher API

	public void search(ServiceContext srvContext, Element request, ServiceConfig config) throws Exception {

        Log.debug(Geonet.LUCENE, "LuceneSearcher search()");
        
        String sBuildSummary = request.getChildText(Geonet.SearchResult.BUILD_SUMMARY);
		boolean buildSummary = sBuildSummary == null || sBuildSummary.equals("true");
		
		_reader = _sm.getIndexReader(srvContext.getLanguage());
        Log.debug(Geonet.LUCENE, "LuceneSearcher computing query");
        computeQuery(srvContext, request, config);
        Log.debug(Geonet.LUCENE, "LuceneSearcher initializing search range");
		initSearchRange(srvContext);
        Log.debug(Geonet.LUCENE, "LuceneSearcher performing query");
		performQuery(getFrom()-1, getTo(), buildSummary);

		SettingInfo si = new SettingInfo(srvContext);
		if (si.isSearchStatsEnabled()) {
			if (_sm.getLogAsynch()) {
				// Run asynch
				Log.debug("jeeves.service","Log search in asynch mode - start.");
				GeonetContext gc = (GeonetContext) srvContext.getHandlerContext(Geonet.CONTEXT_NAME);
				gc.getThreadPool().runTask(new SearchLoggerTask(srvContext, _sm.getLogSpatialObject(), _sm.getLuceneTermsToExclude(), _query, _numHits, _sort, _geomWKT, config.getValue(Jeeves.Text.GUI_SERVICE,"n")));
				Log.debug("jeeves.service","Log search in asynch mode - end.");
			} else {
				// Run synch - alter search performance
				Log.debug("jeeves.service","Log search in synch mode - start.");
				SearcherLogger searchLogger = new SearcherLogger(srvContext, _sm.getLogSpatialObject(), _sm.getLuceneTermsToExclude());
				searchLogger.logSearch(_query, _numHits, _sort, _geomWKT, config.getValue(Jeeves.Text.GUI_SERVICE,"n"));
				Log.debug("jeeves.service","Log search in synch mode - end.");
			}
		}
	}

	//--------------------------------------------------------------------------------

	public List<org.jdom.Document> presentDocuments(ServiceContext srvContext, Element request, ServiceConfig config) throws Exception {
		throw new UnsupportedOperationException("Not supported by Lucene searcher");
	}

	//--------------------------------------------------------------------------------


	/**
	 * @return		An empty response if no result or a list of results. Return
	 * only geonet:info element in fast mode.
	 */
	public Element present(ServiceContext srvContext, Element request, ServiceConfig config)
		throws Exception
	{
		updateSearchRange(request);

		GeonetContext gc = null;
		if (srvContext != null)
			gc = (GeonetContext) srvContext.getHandlerContext(Geonet.CONTEXT_NAME);

		String sFast = request.getChildText(Geonet.SearchResult.FAST);
		boolean fast = sFast != null && sFast.equals("true");
		boolean inFastMode = fast || "index".equals(sFast);

		// build response
		Element response =  new Element("response");
		response.setAttribute("from",  getFrom()+"");
		response.setAttribute("to",    getTo()+"");
		Log.debug(Geonet.SEARCH_ENGINE, Xml.getString(response));

		// Add summary if required and exists
		String sBuildSummary = request.getChildText(Geonet.SearchResult.BUILD_SUMMARY);
		boolean buildSummary = sBuildSummary == null || sBuildSummary.equals("true");

		if (buildSummary && _elSummary != null)
			response.addContent((Element)_elSummary.clone());

		if (getTo() > 0) {
			TopDocs tdocs = performQuery(getFrom()-1, getTo(), false); // get enough hits to show a page

			int nrHits = getTo() - (getFrom()-1);
			if (tdocs.scoreDocs.length >= nrHits) {
				for (int i = 0; i < nrHits; i++) {
					Document doc;
					if (inFastMode) {
						doc = _reader.document(tdocs.scoreDocs[i].doc); // no selector
					} else {
						doc = _reader.document(tdocs.scoreDocs[i].doc, _selector);
					}
					String id = doc.get("_id");
					Element md = null;

					if (fast) {
						md = getMetadataFromIndex(doc, id, false, null);
					} else if ("index".equals(sFast)) {
					    // Retrieve information from the index for the record
						md = getMetadataFromIndex(doc, id, true, _luceneConfig.getDumpFields());

						// Retrieve dynamic properties according to context (eg. editable)
					    gc.getDataManager().buildExtraMetadataInfo(srvContext, id, md.getChild(Edit.RootChild.INFO, Edit.NAMESPACE));
                    } else if (srvContext != null) {
                        boolean forEditing = false, withValidationErrors = false, keepXlinkAttributes = false;
                        md = gc.getDataManager().getMetadata(srvContext, id, forEditing, withValidationErrors, keepXlinkAttributes);
                    }

					//--- a metadata could have been deleted just before showing
					//--- search results

					if (md != null) {
						// Calculate score and add it to info elem
						if (_luceneConfig.isTrackDocScores()) {
							Float score = tdocs.scoreDocs[i].score;
							Element info = md.getChild (Edit.RootChild.INFO, Edit.NAMESPACE);
							addElement(info, Edit.Info.Elem.SCORE, score.toString());
						}
						response.addContent(md);
					}
				}
			} else {
				throw new Exception("Failed: Not enough search results ("+tdocs.scoreDocs.length+") available to meet request for "+nrHits+".");
			}
		}

		return response;
	}

	//--------------------------------------------------------------------------------

	public int getSize()
	{
		return _numHits;
	}

	//--------------------------------------------------------------------------------

	public Element getSummary() throws Exception
	{
		Element response =  new Element("response");
		response.addContent((Element)_elSummary.clone());
		return response;
	}

	//--------------------------------------------------------------------------------

    private boolean closed = false;
	public synchronized void close() {
        if(!closed) {
            try {
                closed = true;
                if (_reader != null) {
                    _sm.releaseIndexReader(_reader);
                }
            } catch (IOException e) {
                Log.error(Geonet.SEARCH_ENGINE,"Failed to close Index Reader: "+e.getMessage());
                e.printStackTrace();
            } catch (InterruptedException e) {
                Log.error(Geonet.SEARCH_ENGINE,"Failed to close Index Reader: "+e.getMessage());
                e.printStackTrace();
            }
        }
	}

	//--------------------------------------------------------------------------------
	// private setup, index, delete and search functions

    /**
     *
     * Determines requested language as follows:
     * - uses value of requestedLanguage search parameter, if it is present;
     * - else uses autodetection, if that is enabled;
     * - else uses servicecontext (GUI) language, if available;
     * - else uses GeoNetwork Default language.
     *
     * @param srvContext
     * @param request
     */
    private void determineLanguage(ServiceContext srvContext, Element request) {
        SettingInfo settingInfo = _sm.get_settingInfo();
        if(settingInfo.getIgnoreRequestedLanguage()) {
            Log.debug(Geonet.LUCENE, "requestedlanguage ignored");            
            _language = null;
            return;
        }
        String requestedLanguage = request.getChildText("requestedLanguage");
        // requestedLanguage in request
        if(StringUtils.isNotEmpty(requestedLanguage)) {
            Log.debug(Geonet.LUCENE, "found requestedlanguage in request: " + requestedLanguage);
            _language = requestedLanguage;
        }
        // no requestedLanguage in request
        else {
            boolean detected = false;
            // autodetection is enabled
            if(settingInfo.getAutoDetect()) {
                Log.debug(Geonet.LUCENE, "auto-detecting request language");
                
                String javaVersion = System.getProperty("java.version");
                // java < 1.6 not supported
                if(StringUtils.isNotEmpty(javaVersion) && javaVersion.startsWith("1.5")) {
                    Log.warning(Geonet.LUCENE, "you are running on Java " + javaVersion + ", auto-detecting languages is disabled. Upgrade to at least 1.6.");
                }
                else {
                    try {
                        Detector detector = DetectorFactory.create();
                        String test = request.getChildText("any");
                        if(StringUtils.isNotEmpty(test)) {
                            detector.append(test);
                            String l = detector.detect();
                            Log.debug(Geonet.LUCENE, "automatic language detection: '" + request.getChildText("any") + "' is in language " + l);
                            
                            _language = l;
                            detected = true;
                        }
                    }
                    catch (LangDetectException x) {
                        Log.error(Geonet.LUCENE, "Error auto-detecting language: " + x.getMessage());
                        x.printStackTrace();
                    }
                }
            }
            // autodetection is disabled or detection failed
            if(!detected) {
                Log.debug(Geonet.LUCENE, "autodetection is disabled or detection failed");
                
                // servicecontext available
                if (srvContext != null) {
                    Log.debug(Geonet.LUCENE, "taking language from servicecontext");                    
                    _language = XslUtil.twoCharLangCode(srvContext.getLanguage());
                }
                // no servicecontext available
                else {
                    Log.debug(Geonet.LUCENE, "taking GeoNetwork default language");
                    _language = XslUtil.twoCharLangCode(Geonet.DEFAULT_LANGUAGE); // TODO : set default not language in config
                }
            }
        }
        Log.debug(Geonet.LUCENE, "*** determined language is: " + _language);        
    }

    /**
     * TODO javadoc.
     *
     * @param srvContext
     * @param request
     * @param config
     * @throws Exception
     */
	private void computeQuery(ServiceContext srvContext, Element request, ServiceConfig config) throws Exception {

        determineLanguage(srvContext, request);

		String sMaxRecordsInKeywordSummary = request.getChildText("maxHitsInSummary");
		if (sMaxRecordsInKeywordSummary == null) sMaxRecordsInKeywordSummary = config.getValue("maxHitsInSummary", "1000");
		_maxHitsInSummary = Integer.parseInt(sMaxRecordsInKeywordSummary);

		String sMaxSummaryKeys = request.getChildText("maxSummaryKeys");
		if (sMaxSummaryKeys == null) sMaxSummaryKeys = config.getValue("maxSummaryKeys", "10");
		_maxSummaryKeys = Integer.parseInt(sMaxSummaryKeys);

		if (srvContext != null) {
			GeonetContext gc = (GeonetContext) srvContext.getHandlerContext(Geonet.CONTEXT_NAME);

			Dbms dbms = (Dbms) srvContext.getResourceManager().open(Geonet.Res.MAIN_DB);

            @SuppressWarnings("unchecked")
            List<Element> requestedGroups = request.getChildren(SearchParameter.GROUP);
            Set<String> userGroups = gc.getAccessManager().getUserGroups(dbms, srvContext.getUserSession(), srvContext.getIpAddress());
            UserSession userSession = srvContext.getUserSession();
            // unless you are logged in as Administrator, check if you are allowed to query the groups in the query
            if (userSession == null || userSession.getProfile() == null ||
                    ! (userSession.getProfile().equals(Geonet.Profile.ADMINISTRATOR) && userSession.isAuthenticated())) {
                if(requestedGroups!=null && !requestedGroups.isEmpty()) {
                    for(Element group : requestedGroups) {
                        if(! "".equals(group.getText())
                        		&& ! userGroups.contains(group.getText())) {
                            throw new UnAuthorizedException("You are not authorized to do this.", null);
                        }
                    }
                }
            }

            // remove elements from user input that compromise this request
            for (String fieldName : UserQueryInput.SECURITY_FIELDS){
                request.removeChildren(fieldName);
            }

			// if 'restrict to' is set then don't add any other user/group info
			if ((request.getChild(SearchParameter.GROUP) == null) ||
                (!StringUtils.isEmpty(request.getChild(SearchParameter.GROUP).getText().trim()))) {
				for (String group : userGroups) {
					request.addContent(new Element(SearchParameter.GROUP).addContent(group));
                }
                String owner = null;
                if (userSession != null) {
                    owner = userSession.getUserId();
                }
                if (owner != null) {
					request.addContent(new Element(SearchParameter.OWNER).addContent(owner));
                }
			    //--- in case of an admin show all results
                if (userSession != null) {
                    if (userSession.isAuthenticated()) {
                        if (userSession.getProfile().equals(Geonet.Profile.ADMINISTRATOR)) {
                            request.addContent(new Element(SearchParameter.ISADMIN).addContent("true"));
}
                        else if (userSession.getProfile().equals(Geonet.Profile.REVIEWER)) {
                            request.addContent(new Element(SearchParameter.ISREVIEWER).addContent("true"));
}
                    }
                }
            }

			//--- handle the time elements

			processTimeRange(request.getChild(SearchParameter.DATEFROM), "0000-01-01", request.getChild(SearchParameter.DATETO), "9999-01-01");

			//--- some other stuff

			Log.debug(Geonet.LUCENE, "CRITERIA:\n"+ Xml.getString(request));

            SettingInfo settingInfo = _sm.get_settingInfo();
            boolean requestedLanguageOnly = settingInfo.getRequestedLanguageOnly();
            Log.debug(Geonet.LUCENE, "requestedLanguageOnly: " + requestedLanguageOnly);


            if (_styleSheetName.equals(Geonet.File.SEARCH_Z3950_SERVER)) {
				// Construct Lucene query by XSLT, not Java, for Z3950 anyway :-)
				Element xmlQuery = _sm.transform(_styleSheetName, request);
				Log.debug(Geonet.SEARCH_ENGINE, "XML QUERY:\n"+ Xml.getString(xmlQuery));
				_query = makeLocalisedQuery(xmlQuery, SearchManager.getAnalyzer(_language), _tokenizedFieldSet, _luceneConfig.getNumericFields(), _language, requestedLanguageOnly);
			} 
            else {
		        // Construct Lucene query (Java)
                Log.debug(Geonet.LUCENE, "LuceneSearcher constructing Lucene query (LQB)");                
                LuceneQueryInput luceneQueryInput = new LuceneQueryInput(request);
                luceneQueryInput.setRequestedLanguageOnly(requestedLanguageOnly);
                _query = new LuceneQueryBuilder(_tokenizedFieldSet, _luceneConfig.getNumericFields(), SearchManager.getAnalyzer(_language), _language).build(luceneQueryInput);
                Log.debug(Geonet.SEARCH_ENGINE,"Lucene query: " + _query);

                try {
                    // only for debugging -- might cause NPE is query was wrongly constructed
                    //Query rw = _query.rewrite(_reader);
                    //Log.debug(Geonet.SEARCH_ENGINE,"Rewritten Lucene query: " + _query);
                    //System.out.println("** rewritten:\n"+ rw);
                }
                catch(Throwable x){
                    Log.warning(Geonet.SEARCH_ENGINE,"Error rewriting Lucene query: " + _query);
                    //System.out.println("** error rewriting query: "+x.getMessage());
                }
			}

			// Boosting query
			if (_boostQueryClass != null) {
				try {
					Log.debug(Geonet.SEARCH_ENGINE, "Create boosting query:" + _boostQueryClass);
					Class boostClass = Class.forName(_boostQueryClass);
					Class[] clTypesArray = _luceneConfig.getBoostQueryParameterClass();
					Object[] inParamsArray = _luceneConfig.getBoostQueryParameter();

					Class[] clTypesArrayAll = new Class[clTypesArray.length + 1];
					clTypesArrayAll[0] = Class.forName("org.apache.lucene.search.Query");

					for (int j=0; j<clTypesArray.length; j++) {
						clTypesArrayAll[j+1] = clTypesArray[j];
					}
					Object[] inParamsArrayAll = new Object[inParamsArray.length + 1];
					inParamsArrayAll[0] = _query;
					for (int j=0; j<inParamsArray.length; j++) {
						inParamsArrayAll[j+1] = inParamsArray[j];
					}
					try {
						Log.debug(Geonet.SEARCH_ENGINE, "Creating boost query with parameters:" + inParamsArrayAll.toString());
						Constructor c = boostClass.getConstructor(clTypesArrayAll);
						_query = (Query) c.newInstance(inParamsArrayAll);
					} catch (Exception e) {
						Log.warning(Geonet.SEARCH_ENGINE, " Failed to create boosting query: " + e.getMessage()
								+ ". Check Lucene configuration");
						e.printStackTrace();
					}
				} catch (Exception e1) {
					Log.warning(Geonet.SEARCH_ENGINE, " Error on boosting query initialization: " + e1.getMessage()
							+ ". Check Lucene configuration");
				}
			}

		    // Use RegionsData rather than fetching from the DB everytime
		    //
		    //request.addContent(Lib.db.select(dbms, "Regions", "region"));
		    Element regions = RegionsData.getRegions(dbms);
		    request.addContent(regions);
		}

        /*
        TODO heikki why was it set again here? Seems wrong
		if (srvContext != null)
        	_language = srvContext.getLanguage();
        else
        	_language = Geonet.DEFAULT_LANGUAGE; // TODO : set default not language in config

		*/

		Geometry geometry = getGeometry(request);
		SpatialFilter spatialfilter = null;
        if (geometry != null) {
            if (_sm.getLogSpatialObject()) {
                _geomWKT = geometry.toText();
            }
            spatialfilter = _sm.getSpatial().filter(_query, geometry, request);
        }

        Filter duplicateRemovingFilter = new DuplicateDocFilter(_query, 1000000);
        Filter filter;
        if (spatialfilter == null) {
            filter = duplicateRemovingFilter;
        } else {
            Filter[] filters = new Filter[]{duplicateRemovingFilter, spatialfilter};
            filter = new ChainedFilter(filters, ChainedFilter.AND);
        }

        _filter = new CachingWrapperFilter(filter);

        String sortBy = Util.getParam(request, Geonet.SearchResult.SORT_BY, Geonet.SearchResult.SortBy.RELEVANCE);
		boolean sortOrder = (Util.getParam(request, Geonet.SearchResult.SORT_ORDER, "").equals(""));
		Log.debug(Geonet.SEARCH_ENGINE, "Sorting by : " + sortBy);

        SettingInfo settingInfo = _sm.get_settingInfo();
        boolean sortRequestedLanguageOnTop = settingInfo.getRequestedLanguageOnTop();
        Log.debug(Geonet.LUCENE, "sortRequestedLanguageOnTop: " + sortRequestedLanguageOnTop);

        _sort = makeSort(Collections.singletonList(Pair.read(sortBy, sortOrder)), _language, sortRequestedLanguageOnTop);
		
		_resultType = config.getValue(Geonet.SearchResult.RESULT_TYPE, Geonet.SearchResult.ResultType.HITS);
		/* resultType is not specified in search params - it's in config?
		Content child = request.getChild(Geonet.SearchResult.RESULT_TYPE);
        if (child == null) {
            _resultType = Geonet.SearchResult.ResultType.HITS;
        }
        else {
            _resultType = child.getValue();
        }
			*/
	}

	//---------------------------------------------------------------------------

	private void processTimeRange(Element fromTime, String defaultFromTime, Element toTime, String defaultToTime) {
		if (fromTime != null && toTime != null) {
			if (fromTime.getTextTrim().equals("") &&
								 toTime.getTextTrim().equals("")) {
				fromTime.detach(); toTime.detach();
			} else {
				if (fromTime.getTextTrim().equals("")) {
					fromTime.setText(defaultFromTime);
				} else if (toTime.getTextTrim().equals("")) {
					toTime.setText(defaultToTime);
				}
				String newFromTime = JODAISODate.parseISODateTime(fromTime.getText());
				fromTime.setText(newFromTime);
				String newToTime = JODAISODate.parseISODateTime(toTime.getText());
				toTime.setText(newToTime);
			}
		}
	}

	//--------------------------------------------------------------------------------
	/**
	 * Execute Lucene query with sorting option.
	 *
	 * Default sort by option is RELEVANCE.
	 * Default sort order option is not reverse order. Reverse order is active
	 * if sort order option is set and not null
     * @param startHit start
	 * @param endHit end
	 * @param buildSummary Compute summary. If true, checks if not already generated (by previous search)
     * @return topdocs
     * @throws Exception hmm
     */
	private TopDocs performQuery(int startHit, int endHit, boolean buildSummary) throws Exception
	{

		int numHits;

		boolean computeSummary = false;
		if (buildSummary) {
			computeSummary = _elSummary == null;
			if (computeSummary) {
				// get as many results as instructed or enough for search summary
				numHits = Math.max(_maxHitsInSummary,endHit);
			} else {
				numHits = endHit;
			}
		} else {
			numHits = endHit;
		}

		Pair<TopDocs,Element> results = doSearchAndMakeSummary( numHits, startHit, endHit, 
				_maxSummaryKeys, _language, _resultType, _summaryConfig, 
				_reader, _query, _filter, _sort, computeSummary,
				_luceneConfig.isTrackDocScores(), _luceneConfig.isTrackMaxScore(), _luceneConfig.isDocsScoredInOrder()
		);
		TopDocs hits = results.one();
		_elSummary = results.two();
		_numHits = Integer.parseInt(_elSummary.getAttributeValue("count"));

		Log.debug(Geonet.SEARCH_ENGINE, "Hits found : "+_numHits+"");

		return hits;
	}

	//--------------------------------------------------------------------------------

	private Geometry getGeometry(Element request) throws Exception
    {
        String geomWKT = Util.getParam(request, Geonet.SearchResult.GEOMETRY, null);
        if (geomWKT != null) {
            WKTReader reader = new WKTReader();
            return reader.read(geomWKT);
        }
        return null;
    }

    /**
     * Creates the Sort to use in the search.
     *
     * @param fields
     * @param requestLanguage
     * @param sortRequestedLanguageOnTop
     * @return
     */
    public static Sort makeSort(List<Pair<String, Boolean>> fields, String requestLanguage,
                                boolean sortRequestedLanguageOnTop) {
        List<SortField> sortFields = new ArrayList<SortField>();
        if (sortRequestedLanguageOnTop && requestLanguage != null) {
            // Add a sort so the metadata defined in the requested language are the first metadata in results
            sortFields.add(new LangSortField(requestLanguage));
        }
        for (Pair<String, Boolean> sortBy : fields) {
            Log.debug(Geonet.SEARCH_ENGINE, "Sorting by : " + sortBy);
            SortField sortField = makeSortField(sortBy.one(), sortBy.two());
            if( sortField!=null ) sortFields.add(sortField);
        }
        sortFields.add(SortField.FIELD_SCORE);
        return new Sort(sortFields.toArray(new SortField[sortFields.size()]));
    }

	//--------------------------------------------------------------------------------
    /**
     * Define sort field. By default, the field is assumed to be a string.
     * Only popularity and rating are sorted based on integer type.
     * In order to works well sort field needs to be not tokenized in Lucene index.
     *
     * Relevance is the default Lucene sorting mechanism.
     *
     * @param sortBy sort field
     * @param sortOrder sort order
     * @return sortfield
     */
    private static SortField makeSortField(String sortBy, boolean sortOrder)
    {
        int sortType = SortField.STRING;

        if( sortBy.equals(Geonet.SearchResult.SortBy.RELEVANCE) ){
            return null;
        }

        // FIXME : here we should be able to define field type ?
        // Add "_" prefix for internal fields. Maybe we should
        // update that in DataManager indexMetadata to have the list of
        // internal Lucene fields (ie. not defined in index-fields.xsl).
        if (sortBy.equals(Geonet.SearchResult.SortBy.POPULARITY)
        		|| sortBy.equals(Geonet.SearchResult.SortBy.RATING)) {
            sortType = SortField.INT;
            sortBy = "_" + sortBy;
        } else if (sortBy.equals(Geonet.SearchResult.SortBy.SCALE_DENOMINATOR)) {
            sortType = SortField.INT;
        } else if (sortBy.equals(Geonet.SearchResult.SortBy.DATE)
        		|| sortBy.equals(Geonet.SearchResult.SortBy.TITLE)) {
            sortBy = "_" + sortBy;
        }
        Log.debug(Geonet.SEARCH_ENGINE, "Sort by: " + sortBy + " order: " + sortOrder + " type: " + sortType);
        if (sortType == SortField.STRING) {
            return new SortField(sortBy, CaseInsensitiveFieldComparatorSource.instance(), sortOrder);
        }
        return new SortField(sortBy, sortType, sortOrder);
    }

    /**
     * TODO javadoc.
     *
     * @param xmlQuery
     * @param analyzer
     * @param tokenizedFieldSet
     * @param numericFieldSet
     * @param langCode
     * @param requestedLanguageOnly
     * @return
     * @throws Exception
     */
    public static Query makeLocalisedQuery( Element xmlQuery, PerFieldAnalyzerWrapper analyzer,
                                            Set<String> tokenizedFieldSet,
                                            Map<String, LuceneConfigNumericField> numericFieldSet, String langCode,
                                            boolean requestedLanguageOnly )
            throws Exception {
        Query returnValue = makeQuery(xmlQuery, analyzer, tokenizedFieldSet, numericFieldSet);
        if(StringUtils.isNotEmpty(langCode)) {
            returnValue = LuceneQueryBuilder.addLocaleTerm(returnValue, langCode, requestedLanguageOnly);
        }
        Log.debug(Geonet.SEARCH_ENGINE, "Lucene Query: " + returnValue.toString());
        return returnValue;
    }

    /**
	 *  Makes a new lucene query.
	 *
	 *  If the field to be queried is tokenized then this method applies
	 *  the appropriate analyzer (see SearchManager) to the field.
	 * @param numericFieldSet TODO
	 *
	 */
	@SuppressWarnings({"deprecation"})
    public static Query makeQuery(Element xmlQuery, PerFieldAnalyzerWrapper analyzer, Set<String> tokenizedFieldSet, Map<String, LuceneConfigNumericField> numericFieldSet) throws Exception
	{
	    Log.debug(Geonet.SEARCH_ENGINE, "MakeQuery input XML:\n" + Xml.getString(xmlQuery));
		String name = xmlQuery.getName();
		Query returnValue;

		if (name.equals("TermQuery"))
		{
			String fld = xmlQuery.getAttributeValue("fld");
            returnValue = textFieldToken(xmlQuery.getAttributeValue("txt"), fld, xmlQuery.getAttributeValue("sim"), analyzer, tokenizedFieldSet);
		}
		else if (name.equals("FuzzyQuery"))
		{
			String fld = xmlQuery.getAttributeValue("fld");
            returnValue = textFieldToken(xmlQuery.getAttributeValue("txt"), fld, xmlQuery.getAttributeValue("sim"), analyzer, tokenizedFieldSet);
		}
		else if (name.equals("PrefixQuery"))
		{
			String fld = xmlQuery.getAttributeValue("fld");
			String txt = analyzeQueryText(fld, xmlQuery.getAttributeValue("txt"), analyzer, tokenizedFieldSet);
			returnValue = new PrefixQuery(new Term(fld, txt));
		}
		else if (name.equals("MatchAllDocsQuery"))
		{
            return new MatchAllDocsQuery();
		}
		else if (name.equals("WildcardQuery"))
		{
			String fld = xmlQuery.getAttributeValue("fld");
            returnValue = textFieldToken(xmlQuery.getAttributeValue("txt"), fld, xmlQuery.getAttributeValue("sim"), analyzer, tokenizedFieldSet);
		}
		else if (name.equals("PhraseQuery"))
		{
			PhraseQuery query = new PhraseQuery();
            for (Object o : xmlQuery.getChildren()) {
                Element xmlTerm = (Element) o;
                String fld = xmlTerm.getAttributeValue("fld");
                String txt = analyzeQueryText(fld, xmlTerm.getAttributeValue("txt"), analyzer, tokenizedFieldSet);
				if(txt.length() > 0) {
					query.add(new Term(fld, txt));
				}
            }
			returnValue = query;
		}
		else if (name.equals("RangeQuery"))
		{
			String  fld        = xmlQuery.getAttributeValue("fld");
			String  lowerTxt   = xmlQuery.getAttributeValue("lowerTxt");
			String  upperTxt   = xmlQuery.getAttributeValue("upperTxt");
			String  sInclusive = xmlQuery.getAttributeValue("inclusive");
			boolean inclusive  = "true".equals(sInclusive);

			LuceneConfigNumericField fieldConfig = numericFieldSet.get(fld);
			if (fieldConfig != null) {
				returnValue = LuceneQueryBuilder.buildNumericRangeQueryForType(fld, lowerTxt, upperTxt, inclusive, inclusive, fieldConfig.getType());
			} else {
				lowerTxt = (lowerTxt == null ? null : analyzeQueryText(fld, lowerTxt, analyzer, tokenizedFieldSet));
				upperTxt = (upperTxt == null ? null : analyzeQueryText(fld, upperTxt, analyzer, tokenizedFieldSet));

				returnValue = new TermRangeQuery(fld, lowerTxt, upperTxt, inclusive, inclusive);
			}
		}
		else if (name.equals("DateRangeQuery"))
		{
			String  fld        = xmlQuery.getAttributeValue("fld");
			String  lowerTxt   = xmlQuery.getAttributeValue("lowerTxt");
			String  upperTxt   = xmlQuery.getAttributeValue("upperTxt");
			String  sInclusive = xmlQuery.getAttributeValue("inclusive");
			returnValue = new DateRangeQuery(fld, lowerTxt, upperTxt, sInclusive);
		}
		else if (name.equals("BooleanQuery"))
		{
			BooleanQuery query = new BooleanQuery();
            for (Object o : xmlQuery.getChildren()) {
                Element xmlBooleanClause = (Element) o;
                String sRequired = xmlBooleanClause.getAttributeValue("required");
                String sProhibited = xmlBooleanClause.getAttributeValue("prohibited");
                boolean required = sRequired != null && sRequired.equals("true");
                boolean prohibited = sProhibited != null && sProhibited.equals("true");
                BooleanClause.Occur occur = LuceneUtils.convertRequiredAndProhibitedToOccur(required, prohibited);
                List<Element> subQueries = xmlBooleanClause.getChildren();
                Element xmlSubQuery;
                if (subQueries != null && subQueries.size() != 0) {
                    xmlSubQuery = subQueries.get(0);
                    Query query2 = makeQuery(xmlSubQuery, analyzer, tokenizedFieldSet, numericFieldSet);
                    if(query2 != null) {
                        query.add(query2, occur);
                    }
                }
            }
			BooleanQuery.setMaxClauseCount(16384); // FIXME: quick fix; using Filters should be better

			returnValue = query;
		}
		else throw new Exception("unknown lucene query type: " + name);

        Log.debug(Geonet.SEARCH_ENGINE, "Lucene Query: " + (returnValue==null?"":returnValue.toString()));
		return returnValue;
	}

    public static Query textFieldToken(String string, String luceneIndexField, String similarity,
                                    PerFieldAnalyzerWrapper analyzer, Set<String> tokenizedFieldSet) {
            if(string == null) {
                throw new IllegalArgumentException("Cannot create Lucene query for null string");
            }
            Query query = null;

            String analyzedString = "";
            // wildcards - preserve them by analyzing the parts of the search string around them separately
            // (this is because Lucene's StandardTokenizer would remove wildcards, but that's not what we want)
            if(string.indexOf('*') >= 0 || string.indexOf('?') >= 0) {
                String starsPreserved = "";
                String[] starSeparatedList = string.split("\\*");
                for(String starSeparatedPart : starSeparatedList) {
                    String qPreserved = "";
                    // ? present
                    if(starSeparatedPart.indexOf('?') >= 0) {
                        String[] qSeparatedList = starSeparatedPart.split("\\?");
                        for(String qSeparatedPart : qSeparatedList) {
                            String analyzedPart = LuceneSearcher.analyzeQueryText(luceneIndexField, qSeparatedPart, analyzer, tokenizedFieldSet);
                            qPreserved += '?' + analyzedPart;
                        }
                        // remove leading ?
                        qPreserved = qPreserved.substring(1);
                        starsPreserved += '*' + qPreserved;
                    }
                    // no ? present
                    else {
                        starsPreserved += '*' + LuceneSearcher.analyzeQueryText(luceneIndexField, starSeparatedPart, analyzer, tokenizedFieldSet);
                    }
                }
                // remove leading *
                if (!org.apache.commons.lang.StringUtils.isEmpty(starsPreserved)) {
                    starsPreserved = starsPreserved.substring(1);
                }

                // restore ending wildcard
                if (string.endsWith("*")) {
                    starsPreserved += "*";
                } else if (string.endsWith("?")) {
                    starsPreserved += "?";
                }

                analyzedString = starsPreserved;
            }
            // no wildcards
            else {
                analyzedString = LuceneSearcher.analyzeQueryText(luceneIndexField, string, analyzer, tokenizedFieldSet);
            }

            if(StringUtils.isEmpty(analyzedString)) {
            // no wildcards
            if(string.indexOf('*') < 0 && string.indexOf('?') < 0) {
                // similarity is not set or is 1
                if(similarity == null || similarity.equals("1")) {
                        query = new TermQuery(new Term(luceneIndexField, analyzedString));
                }
                // similarity is not null and not 1
                else {
                    Float minimumSimilarity = Float.parseFloat(similarity);
                        query = new FuzzyQuery(new Term(luceneIndexField, analyzedString), minimumSimilarity);
                }
            }
            // wildcards
            else {
                    query = new WildcardQuery(new Term(luceneIndexField, analyzedString));
                }
            }
            if(StringUtils.hasLength(analyzedString) && tokenizedFieldSet.contains(luceneIndexField)) {
                if(analyzedString.contains(" ")) {
                    // if analyzer creates spaces (by converting ignored characters like -) then make boolean query
                    String[] terms = analyzedString.split(" ");
                    BooleanQuery booleanQuery = new BooleanQuery();
                    query = booleanQuery;
                    for (String term : terms) {
                        booleanQuery.add(createTermQuery(luceneIndexField, similarity, term, term), Occur.MUST);
                    }
                } else {
                    query = createTermQuery(luceneIndexField, similarity, string, analyzedString);
                }
            }
            return query;
        }

	private static Query createTermQuery(String luceneIndexField, String similarity, String string, String analyzedString) {
	    Query query;
        if(string.indexOf('*') < 0 && string.indexOf('?') < 0) {
            // no wildcards

           // similarity is not set or is 1
           if(similarity == null || similarity.equals("1")) {
                   query = new TermQuery(new Term(luceneIndexField, analyzedString));
           }
           // similarity is not null and not 1
           else {
               Float minimumSimilarity = Float.parseFloat(similarity);
                   query = new FuzzyQuery(new Term(luceneIndexField, analyzedString), minimumSimilarity);
           }
       }
       // wildcards
       else {
               query = new WildcardQuery(new Term(luceneIndexField, analyzedString));
           }
        return query;
    }

    //--------------------------------------------------------------------------------

	private static Map<String,Map<String,Object>> getSummaryConfig(Element summaryConfig, String resultType, int maxSummaryKeys) throws Exception {

		Map<String, Map<String,Object>> results = new HashMap<String, Map<String, Object>>();

		Element resultTypeConfig = summaryConfig.getChild("def").getChild(resultType);
        @SuppressWarnings("unchecked")
		List<Element> elements = resultTypeConfig.getChildren();

		for (Element summaryElement : elements) {
			String name = summaryElement.getAttributeValue("name");
			String plural = summaryElement.getAttributeValue("plural");
			String key = summaryElement.getAttributeValue("indexKey");
			String order = summaryElement.getAttributeValue("order");
			String maxString = summaryElement.getAttributeValue("max");
			String type = summaryElement.getAttributeValue("type");
			if (order == null) {
				order = "frequency";
			}
			int max;
			if (maxString == null) {
				max = 10;
			} else {
				max = Integer.parseInt(maxString);
			}
			max = Math.min(maxSummaryKeys, max);
			if( type==null ){
				type = "string";
			}

			Map<String,Object> values = new HashMap<String,Object>();
			values.put("name", name);
			values.put("plural", plural);
			values.put("max", max);
			values.put("order", order);
			values.put("type", type);
			values.put("typeConfig", summaryConfig.getChild("typeConfig"));
			results.put(key,values);
		}

		return results;
	}

	//--------------------------------------------------------------------------------

	private static SummaryComparator getSummaryComparator(String langCode, Map<String, Object> summaryConfigValuesForKey) throws Exception
	{

			SortOption sortOption = SortOption.parse((String)summaryConfigValuesForKey.get("order"));
			return new SummaryComparator(sortOption, Type.parse((String)summaryConfigValuesForKey.get("type")), langCode, (Element)summaryConfigValuesForKey.get("typeConfig"));
	}

	//--------------------------------------------------------------------------------

	private static Map<String, ObjectKeyIntOpenHashMap> prepareSummaryMaps(Set<String> indexKeys) throws Exception
	{
		Map<String, ObjectKeyIntOpenHashMap> summaryMaps = new HashMap<String, ObjectKeyIntOpenHashMap>();
		for (String key : indexKeys) {
			summaryMaps.put(key, new ObjectKeyIntOpenHashMap());
		}
		return summaryMaps;
	}

	//--------------------------------------------------------------------------------

	private static Map<String, ObjectKeyIntOpenHashMap> buildSummaryMaps(Element elSummary, IndexReader reader, ScoreDoc[] sdocs, final Map<String, ObjectKeyIntOpenHashMap> summaryMaps) {
		elSummary.setAttribute("hitsusedforsummary", sdocs.length+"");

		FieldSelector keySelector = new FieldSelector() {
			public final FieldSelectorResult accept(String name) {
				if (name.equals("_id") || summaryMaps.get(name) != null) return FieldSelectorResult.LOAD;
				else return FieldSelectorResult.NO_LOAD;
			}
		};

		bak.pcj.set.IntBitSet read=new bak.pcj.set.IntBitSet(sdocs.length);
        for (ScoreDoc sdoc : sdocs) {
            Document doc = null;
            try {
                doc = reader.document(sdoc.doc, keySelector);
                String _id = doc.get("_id");
                int id = Integer.parseInt(_id);
                if(read.contains(id)) continue;
                read.add(id);

                for (String key : summaryMaps.keySet()) {
                    ObjectKeyIntMap summary = summaryMaps.get(key);
                    String hits[] = doc.getValues(key);
                    if (hits != null) {
                        Set<String> visited = new HashSet<String>();
                        for (String info : hits) {
                            if(visited.contains(info)) continue;
                            visited.add(info);
                            Integer catCount = summary.get(info);
                            if (catCount == null) {
                                catCount = 1;
                            }
                            else {
                                catCount = catCount + 1;
                            }
                            summary.put(info, catCount);
                        }
                    }
                }
            } catch (Exception e) {
                Log.error(Geonet.SEARCH_ENGINE, e.getMessage() + " Caused Failure to get document " + sdoc.doc);
                e.printStackTrace();
            }

        }

		return summaryMaps;
	}

	//--------------------------------------------------------------------------------

	private static Element addSortedSummaryKeys(Element elSummary, String langCode, HashMap<String,ObjectKeyIntOpenHashMap> summaryMaps, HashMap<String,HashMap<String,Object>> summaryConfigValues) throws Exception {

		for ( String indexKey : summaryMaps.keySet() ) {
			Map <String,Object> summaryConfigValuesForKey = summaryConfigValues.get(indexKey);
            Element rootElem = new Element((String)summaryConfigValuesForKey.get("plural"));
            // sort according to frequency
			SummaryComparator summaryComparator = getSummaryComparator(langCode, summaryConfigValuesForKey);
			ObjectKeyIntOpenHashMap summary = summaryMaps.get(indexKey);

			if(summary.isEmpty()) continue;
		  Log.debug(Geonet.SEARCH_ENGINE, "Sorting "+summary.size()+" according to frequency of " + indexKey);

			TreeSet<SummaryComparator.SummaryElement> sortedSummary = new TreeSet<SummaryComparator.SummaryElement>(summaryComparator);
			ObjectKeyIntMapIterator entries = summary.entries();
			while(entries.hasNext()) {
			    entries.next();
                sortedSummary.add(new SummaryComparator.SummaryElement(entries));
			}

			Integer max = (Integer)summaryConfigValuesForKey.get("max");

			int nKeys = 0;
            for (SummaryComparator.SummaryElement me : sortedSummary) {
                if (++nKeys > max) {
                    break;
                }

                String keyword = me.name;
                int keyCount = me.count;

                Element childElem = new Element((String) summaryConfigValuesForKey.get("name"));
                childElem.setAttribute("count", Integer.toString(keyCount));
                childElem.setAttribute("name", keyword);
                rootElem.addContent(childElem);
            }
			elSummary.addContent(rootElem);
		}

		return elSummary;
	}

	//--------------------------------------------------------------------------------


	/**
	 * Do Lucene search and optionally build a summary for the search.
	 * 
	 * @param numHits	the maximum number of hits to collect
	 * @param startHit	the start hit to return in the TopDocs if not building summary
	 * @param endHit	the end hit to return in the TopDocs if not building summary
	 * @param maxSummaryKeys	the max number of keys to process in a summary
	 * @param langCode	the language code used by SummaryComparator
	 * @param resultType	the resultType is used to define the type of summary to build according to summary configuration in config-summary.xml.
	 * @param summaryConfig	the summary configuration
	 * @param reader  reader
	 * @param query   query
	 * @param cFilter filter
	 * @param sort	the sort criteria
	 * @param buildSummary	true to build query summary element. Summary is stored in the second element of the returned Pair.
	 * @param trackDocScores	specifies whether document scores should be tracked and set on the results.
	 * @param trackMaxScore	specifies whether the query's maxScore should be tracked and set on the resulting TopDocs.
	 * @param docsScoredInOrder	specifies whether documents are scored in doc Id order or not by the given Scorer
	 *
	 * @return	the topDocs for the search. When building summary, topDocs will contains all search hits
	 * and need to be filtered to return only required hits according to search parameters.
	 *
	 * @throws Exception hmm
	 */
	public static Pair<TopDocs, Element> doSearchAndMakeSummary(int numHits, int startHit, int endHit, int maxSummaryKeys, 
			String langCode, String resultType, Element summaryConfig, 
			IndexReader reader, Query query, Filter cFilter, Sort sort, boolean buildSummary,
			boolean trackDocScores, boolean trackMaxScore, boolean docsScoredInOrder) throws Exception
	{

		Log.debug(Geonet.SEARCH_ENGINE, "Setting up the TFC with numHits "+numHits);
		TopFieldCollector tfc = TopFieldCollector.create(sort, numHits, true, trackDocScores, trackMaxScore, docsScoredInOrder);

        if(query != null && reader != null ){
            // too dangerous to do this only for logging, as it may throw NPE if Query was not constructed correctly
            // However if you need to see what Lucene queries are really used, print the rewritten query instead
            // Query rw = query.rewrite(reader);
            // System.out.println("Lucene query: " + rw.toString());
            Log.debug(Geonet.SEARCH_ENGINE, "Lucene query: " + query.toString());
        }
		new IndexSearcher(reader).search(query, cFilter, tfc);

		Element elSummary= new Element("summary");
		elSummary.setAttribute("count", tfc.getTotalHits()+"");
		elSummary.setAttribute("type", "local");

		// topDocs could only be called once.
		// A second call will return null docs.
		TopDocs tdocs;

		if (buildSummary) {
			Log.debug(Geonet.SEARCH_ENGINE, "Building summary");

			// -- prepare
			Map<String, Map<String,Object>> summaryConfigValues = getSummaryConfig(summaryConfig, resultType, maxSummaryKeys);
			Log.debug(Geonet.SEARCH_ENGINE, "ResultType is "+resultType+", SummaryKeys are "+summaryConfigValues);
			HashMap<String,ObjectKeyIntOpenHashMap> summaryMaps = prepareSummaryMaps(summaryConfigValues.keySet());

			// -- get all hits from search to build the summary
			tdocs = tfc.topDocs(0, numHits);

			// -- add summary keys to summary element
			summaryMaps = buildSummaryMaps(elSummary, reader, tdocs.scoreDocs, summaryMaps);
			elSummary = addSortedSummaryKeys(elSummary, langCode, summaryMaps, summaryConfigValues);
		} else {
			tdocs = tfc.topDocs(startHit, endHit);
		}

		return Pair.read(tdocs,elSummary);
	}

	//--------------------------------------------------------------------------------
	/**
	 * Retrieve metadata from the index
	 *
	 * @param doc
	 * @param id
	 * @param dumpAllField	If dumpFields is null and dumpAllField set to true, dump all index content.
	 * @param dumpFields	If not null, dump only the fields define in {@link LuceneConfig#getDumpFields()}.
	 * @return
	 */
	public static Element getMetadataFromIndex(Document doc, String id, boolean dumpAllField, Map<String, String> dumpFields){
        // Retrieve the info element
        String root       = doc.get("_root");
        String schema     = doc.get("_schema");
        String source     = doc.get("_source");
        String uuid       = doc.get("_uuid");

        String createDate = doc.get("_createDate");
        if (createDate != null) createDate = createDate.toUpperCase();
        String changeDate = doc.get("_changeDate");
        if (changeDate != null) changeDate = changeDate.toUpperCase();

        // Root element is using root element name if not using only the index content (ie. dumpAllField)
        // probably because the XSL need that info later ?
        Element md = new Element("metadata");

        Element info = new Element(Edit.RootChild.INFO, Edit.NAMESPACE);

        addElement(info, Edit.Info.Elem.ID,          id);
        addElement(info, Edit.Info.Elem.UUID,        uuid);
        addElement(info, Edit.Info.Elem.SCHEMA,      schema);
        addElement(info, Edit.Info.Elem.CREATE_DATE, createDate);
        addElement(info, Edit.Info.Elem.CHANGE_DATE, changeDate);
        addElement(info, Edit.Info.Elem.SOURCE,      source);

        if (dumpFields != null) {
  		  	for (Iterator iterator = dumpFields.keySet().iterator(); iterator.hasNext();) {
				String fieldName = (String) iterator.next();
				Field[] values = doc.getFields(fieldName);
				for (Field f : values) {
					if (f != null) {
						md.addContent(new Element(dumpFields.get(fieldName)).setText(f.stringValue()));
					}
				}
  		  	}
        } else {

	        List<Fieldable> fields = doc.getFields();
	        for (Iterator<Fieldable> i = fields.iterator(); i.hasNext(); ) {
	          Fieldable field = i.next();
	          String name  = field.name();
	          String value = field.stringValue();

	          // Dump the categories to the info element
	          if (name.equals("_cat")) {
	              addElement(info, Edit.Info.Elem.CATEGORY, value);
	          } else if (dumpAllField) {
	              // And all other field to the root element in dump all mode
	        	  md.addContent(new Element(name).setText(value));
	          }
	       }
        }
        md.addContent(info);
        return md;
	}

    //--------------------------------------------------------------------------------
	/**
	 * <p>
	 * Gets all metadata uuids in current searcher
	 * </p>
	 *
	 * @param maxHits max hits
	 * @return current searcher result in "fast" mode
	 *
	 * @throws Exception hmm
	 */
    public List<String>  getAllUuids(int maxHits) throws Exception {

				FieldSelector uuidselector = new FieldSelector() {
					public final FieldSelectorResult accept(String name) {
						if (name.equals("_uuid")) return FieldSelectorResult.LOAD;
						else return FieldSelectorResult.NO_LOAD;
					}
				};

        List<String> response = new ArrayList<String>();
		TopDocs tdocs = performQuery(0, maxHits, false);

        for ( ScoreDoc sdoc : tdocs.scoreDocs ) {
          Document doc = _reader.document(sdoc.doc, uuidselector);
          String uuid = doc.get("_uuid");
					if (uuid != null) response.add(uuid);
        }
        return response;
    }


	/**
	 * <p>
	 * Gets all metadata info as a int Map in current searcher
	 * </p>
	 *
	 *
	 * @throws IOException
	 * @throws CorruptIndexException
	 */
    public Map<Integer,MdInfo> getAllMdInfo(int maxHits) throws Exception {

			FieldSelector mdInfoSelector = new FieldSelector() {
				public final FieldSelectorResult accept(String name) {
					if (name.equals("_id"))          return FieldSelectorResult.LOAD;
					if (name.equals("_root"))        return FieldSelectorResult.LOAD;
					if (name.equals("_schema"))      return FieldSelectorResult.LOAD;
					if (name.equals("_createDate"))  return FieldSelectorResult.LOAD;
					if (name.equals("_changeDate"))  return FieldSelectorResult.LOAD;
					if (name.equals("_source"))      return FieldSelectorResult.LOAD;
					if (name.equals("_isTemplate"))  return FieldSelectorResult.LOAD;
					if (name.equals("_title"))       return FieldSelectorResult.LOAD;
					if (name.equals("_uuid"))        return FieldSelectorResult.LOAD;
					if (name.equals("_isHarvested")) return FieldSelectorResult.LOAD;
					if (name.equals("_owner"))       return FieldSelectorResult.LOAD;
					if (name.equals("_groupOwner"))  return FieldSelectorResult.LOAD;
					else return FieldSelectorResult.NO_LOAD;
				}
			};

      Map<Integer,MdInfo> response = new HashMap<Integer,MdInfo>();
			TopDocs tdocs = performQuery(0, maxHits, false);

      for ( ScoreDoc sdoc : tdocs.scoreDocs ) {
        Document doc = _reader.document(sdoc.doc, mdInfoSelector);

				MdInfo mdInfo = new MdInfo();
				mdInfo.id           = doc.get("_id");
        mdInfo.uuid         = doc.get("_uuid");
        mdInfo.schemaId     = doc.get("_schema");
				String isTemplate   = doc.get("_isTemplate");
				if (isTemplate.equals("y")) {
					mdInfo.template = MdInfo.Template.TEMPLATE;
				} else if (isTemplate.equals("s")) {
					mdInfo.template = MdInfo.Template.SUBTEMPLATE;
				} else {
					mdInfo.template = MdInfo.Template.METADATA;
				}
				String isHarvested  = doc.get("_isHarvested");
				if (isHarvested != null) {
        	mdInfo.isHarvested  = doc.get("_isHarvested").equals("y");
				} else {
					mdInfo.isHarvested  = false;
				}
        mdInfo.createDate   = doc.get("_createDate");
        mdInfo.changeDate   = doc.get("_changeDate");
        mdInfo.source       = doc.get("_source");
        mdInfo.title        = doc.get("_title");
        mdInfo.root         = doc.get("_root");
        mdInfo.owner        = doc.get("_owner");
        mdInfo.groupOwner   = doc.get("_groupOwner");

				response.put(Integer.parseInt(mdInfo.id), mdInfo);
      }
      return response;
    }

	//--------------------------------------------------------------------------------
	/**
     * Search in Lucene index and return Lucene index
     * field value. Metadata records is retrieved
     * based on its uuid.
     *
     * @param id metadata uuid
     * @param fieldname lucene field value
     * @return
     */
    public static String getMetadataFromIndex(String webappName, String priorityLang, String id, String fieldname) throws Exception
    {
            List<String> fieldnames = new ArrayList<String>();
            fieldnames.add(fieldname);
            return getMetadataFromIndex(webappName, priorityLang, id, fieldnames).get(fieldname);
    }
    public static String getMetadataFromIndexById(String webappName, String priorityLang, String id, String fieldname) throws Exception
    {
            List<String> fieldnames = new ArrayList<String>();
            fieldnames.add(fieldname);
            return getMetadataFromIndex(webappName, priorityLang, "_id", id, fieldnames).get(fieldname);
    }

    public static Map<String,String> getMetadataFromIndex(String webappName, String priorityLang, String uuid, List<String> fieldnames) throws Exception {
        return getMetadataFromIndex(webappName, priorityLang, "_uuid", uuid, fieldnames);
    }

    public static Map<String,String> getMetadataFromIndex(String webappName, String priorityLang, String idField, String id, List<String> fieldnames) throws Exception
 {
        MapFieldSelector selector = new MapFieldSelector(fieldnames);

        IndexReader reader;
        LuceneIndexReaderFactory factory = null;
        SearchManager searchmanager = null;
        ServiceContext context = ServiceContext.get();
        if (context != null) {
            GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
            searchmanager = gc.getSearchmanager();
            reader = searchmanager.getIndexReader(priorityLang);
        } else {
            File luceneDir = new File(System.getProperty(webappName + ".lucene.dir", webappName), "nonspatial");
            factory = new LuceneIndexReaderFactory(luceneDir);
            reader = factory.getReader(priorityLang);
        }
        Searcher searcher = new IndexSearcher(reader);

        Map<String, String> values = new HashMap<String, String>();

        try {
            TermQuery query = new TermQuery(new Term(idField, id));
            SettingInfo settingInfo = _sm.get_settingInfo();
            boolean sortRequestedLanguageOnTop = settingInfo.getRequestedLanguageOnTop();
            Log.debug(Geonet.LUCENE, "sortRequestedLanguageOnTop: " + sortRequestedLanguageOnTop);
            
            Sort sort = makeSort(Collections.<Pair<String, Boolean>> emptyList(), priorityLang, sortRequestedLanguageOnTop);
            Filter filter = NoFilterFilter.instance();
            TopDocs tdocs = searcher.search(query, filter, 1, sort);

            for( ScoreDoc sdoc : tdocs.scoreDocs ) {
                Document doc = reader.document(sdoc.doc, selector);

                for( String fieldname : fieldnames ) {
                    values.put(fieldname, doc.get(fieldname));
                }
            }

        } catch (CorruptIndexException e) {
            // TODO: handle exception
            Log.error(Geonet.LUCENE, e.getMessage());
        }
        catch (IOException e) {
            // TODO: handle exception
            Log.error(Geonet.LUCENE, e.getMessage());
        }
        finally {
            try {
                searcher.close();
            }
            finally {
                if (factory != null) {
                    factory.close();
                }
                else if (searchmanager != null) {
                    searchmanager.releaseIndexReader(reader);
                }
            }
        }
        return values;
    }

	public static String analyzeQueryText(String field, String aText, PerFieldAnalyzerWrapper analyzer, Set<String> tokenizedFieldSet) {
		Log.debug(Geonet.SEARCH_ENGINE, "Analyze field "+field+" : "+aText);
		if (tokenizedFieldSet.contains(field)) {
			String analyzedText = analyzeText(field, aText, analyzer);
			Log.debug(Geonet.SEARCH_ENGINE, "Analyzed text is "+analyzedText);
			return analyzedText;
		}
        else return aText;
	}


	/**
	 * Splits text into tokens using the Analyzer that is matched to the field.
	 *
	 * @param requestStr
	 * @return
	 */
	public static String analyzeText(String field, String requestStr, PerFieldAnalyzerWrapper a) {

		boolean phrase = false;
		if ((requestStr.startsWith("\"") && requestStr.endsWith("\""))) phrase = true;

		TokenStream ts = a.tokenStream(field, new StringReader(requestStr));
		TermAttribute termAtt = ts.addAttribute(TermAttribute.class);

		List<String> tokenList = new ArrayList<String>();
		try {
			while (ts.incrementToken()) {
				tokenList.add(termAtt.term());
			}
		}
        catch (Exception e) {
            // TODO why swallow
			e.printStackTrace();
		}

		StringBuffer result = new StringBuffer();

		for (int i = 0;i < tokenList.size();i++) {
			if (i > 0) {
				result.append(" ");
				result.append(tokenList.get(i));
			} else {
				result.append(tokenList.get(i));
			}
		}
		String outStr = result.toString();
		if (phrase) outStr = "\"" + outStr + "\"";
		return outStr;
	}

	// Unused at the moment - but might be useful later
    public static String escapeLuceneChars(String aText, String excludes) {
     final StringBuilder result = new StringBuilder();
     final StringCharacterIterator iterator = new StringCharacterIterator(aText);
     char character =  iterator.current();
     while (character != CharacterIterator.DONE ) {
       if (character == '\\' && !excludes.contains("\\")) {
         result.append("\\");
       } else if (character == '!' && !excludes.contains("!")) {
         result.append("\\");
       } else if (character == '(' && !excludes.contains("(")) {
         result.append("\\");
       } else if (character == ')' && !excludes.contains(")")) {
         result.append("\\");
       } else if (character == '*' && !excludes.contains("*")) {
         result.append("\\");
       } else if (character == '+' && !excludes.contains("+")) {
         result.append("\\");
       } else if (character == '-' && !excludes.contains("-")) {
         result.append("\\");
       } else if (character == ':' && !excludes.contains(":")) {
         result.append("\\");
       } else if (character == '?' && !excludes.contains("?")) {
         result.append("\\");
       } else if (character == '[' && !excludes.contains("[")) {
         result.append("\\");
       } else if (character == ']' && !excludes.contains("]")) {
         result.append("\\");
       } else if (character == '^' && !excludes.contains("^")) {
         result.append("\\");
       } else if (character == '{' && !excludes.contains("{")) {
         result.append("\\");
       } else if (character == '}' && !excludes.contains("}")) {
         result.append("\\");
       }
       result.append(character);
       character = iterator.next();
     }
		 Log.debug(Geonet.SEARCH_ENGINE, "Escaped: "+result.toString());
     return result.toString();
  }
    /**
     * Task to launch a new thread for search logging.
     *
     * Other idea: Another approach could be to use JMS, to send an
		 * asynchronous message with search info in order to log them.
     *
     * @author francois
     */
    class SearchLoggerTask implements Runnable {
        private ServiceContext srvContext;
        boolean logSpatialObject;
        String luceneTermsToExclude;
		Query query;
		int numHits;
		Sort sort;
		String geomWKT;
		String value;


        public SearchLoggerTask(ServiceContext srvContext,
				boolean logSpatialObject, String luceneTermsToExclude,
				Query query, int numHits, Sort sort, String geomWKT,
				String value) {
        			this.srvContext = srvContext;
        			this.logSpatialObject = logSpatialObject;
        			this.luceneTermsToExclude = luceneTermsToExclude;
        			this.query = query;
        			this.numHits = numHits;
        			this.sort = sort;
        			this.geomWKT = geomWKT;
        			this.value = value;
    	}

		public void run() {
            try {
            	// Log.debug("geonetwork.search-logger", "sleep for 10sec");
            	// Thread.sleep(10000);
            	// Log.debug("geonetwork.search-logger", "wake up.");
            	SearcherLogger searchLogger = new SearcherLogger(srvContext, logSpatialObject, luceneTermsToExclude);
        		searchLogger.logSearch(query, numHits, sort, geomWKT, value);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    
}