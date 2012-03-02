//=============================================================================
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

package org.fao.geonet.kernel.csw.services.getrecords;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import jeeves.constants.Jeeves;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.apache.lucene.search.Sort;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Edit;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.csw.common.Csw;
import org.fao.geonet.csw.common.ElementSetName;
import org.fao.geonet.csw.common.OutputSchema;
import org.fao.geonet.csw.common.ResultType;
import org.fao.geonet.csw.common.exceptions.CatalogException;
import org.fao.geonet.csw.common.exceptions.InvalidParameterValueEx;
import org.fao.geonet.csw.common.exceptions.NoApplicableCodeEx;
import org.fao.geonet.guiservices.metadata.GetRelated;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.kernel.SelectionManager;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.kernel.search.LuceneConfig;
import org.fao.geonet.kernel.search.spatial.Pair;
import org.geotools.data.DataStore;
import org.jdom.Content;
import org.jdom.Element;

//=============================================================================

public class SearchController
{

	private final CatalogSearcher _searcher;
    public SearchController(DataStore ds, File summaryConfig, LuceneConfig luceneConfig)
    {
        _searcher = new CatalogSearcher(ds, summaryConfig, luceneConfig);
    }

    public CatalogSearcher getSearcher() {
    	return _searcher;
    }

	//---------------------------------------------------------------------------
    //---
    //--- Single public method to perform the general search tasks
    //---
    //---------------------------------------------------------------------------

    /**
	 * Perform the general search tasks
	 */
    public Pair<Element, Element> search(ServiceContext context, int startPos, int maxRecords,
                                         ResultType resultType, OutputSchema outSchema, ElementSetName setName,
                                         Element filterExpr, String filterVersion, Sort sort,
                                         Set<String> elemNames, int maxHitsFromSummary,String cswServiceSpecificContraint) throws CatalogException
    {
	Element results = new Element("SearchResults", Csw.NAMESPACE_CSW);

	Pair<Element, List<ResultItem>> summaryAndSearchResults = _searcher.search(context, filterExpr, filterVersion, sort,
            resultType, startPos, maxRecords, maxHitsFromSummary, cswServiceSpecificContraint);

	UserSession session = context.getUserSession();
	session.setProperty(Geonet.Session.SEARCH_RESULT, _searcher);

	// clear selection from session when query filter change
    QueryReprentationForSession sessionQueryReprentation = (QueryReprentationForSession) session.getProperty(Geonet.Session.SEARCH_REQUEST_ID);
    QueryReprentationForSession requestQueryReprentation = new QueryReprentationForSession(context, filterExpr);

    if (sessionQueryReprentation == null ||
            !requestQueryReprentation.equals(sessionQueryReprentation)) {
		// possibly close old selection
		SelectionManager oldSelection = (SelectionManager)session.getProperty(Geonet.Session.SELECTED_RESULT);

		if (oldSelection != null){
			oldSelection.close();
			oldSelection = null;
		}
	}
	session.setProperty(Geonet.Session.SEARCH_REQUEST_ID, requestQueryReprentation);

	List<ResultItem> resultsList = summaryAndSearchResults.two();
	int counter = 0;
    for (int i=0; (i<maxRecords) && (i<resultsList.size()); i++) {
        ResultItem resultItem = resultsList.get(i);
        String  id = resultItem.getID();
        Element md = retrieveMetadata(context, id, setName, outSchema, elemNames, resultType);
        // metadata cannot be retrieved
        if (md == null) {
            context.warning("SearchController : Metadata not found or invalid schema : "+ id);
        }
        // metadata can be retrieved
        else {
            // metadata must be included in response
            if((resultType == ResultType.RESULTS || resultType == ResultType.RESULTS_WITH_SUMMARY)) {
                results.addContent(md);
            }
            counter++;
        }
    }


	Element summary = summaryAndSearchResults.one();

	int numMatches = Integer.parseInt(summary.getAttributeValue("count"));
	results.setAttribute("numberOfRecordsMatched",  numMatches+"");
	results.setAttribute("numberOfRecordsReturned", counter +"");
	results.setAttribute("elementSet",              setName.toString());

	if (numMatches > counter) {
		results.setAttribute("nextRecord", counter + startPos + "");
	} else {
		results.setAttribute("nextRecord","0");
	}

	return Pair.read(summary, results);
    }

    /**
     * Retrieves metadata from the database. Conversion between metadata record and output schema are defined in xml/csw/schemas/ directory.
     *
     * @param context
     * @param id
     * @param setName
     * @param outSchema
     * @param elemNames
     * @param resultType
     * @return	The XML metadata record if the record could be converted to the required output schema. Null if no conversion available for
     *          the schema (eg. fgdc record could not be converted to ISO).
     * @throws CatalogException
     */
	public static Element retrieveMetadata(ServiceContext context, String id,
			ElementSetName setName, OutputSchema outSchema,
			Set<String> elemNames, ResultType resultType)
			throws CatalogException {

	try	{
		//--- get metadata from DB
		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        boolean forEditing = false, withValidationErrors = false, keepXlinkAttributes = false;
        Element res = gc.getDataManager().getGeocatMetadata(context, id, forEditing, withValidationErrors, keepXlinkAttributes, true, true);
		SchemaManager scm = gc.getSchemamanager();
		if (res==null) {
            return null;
        }
		Element info = res.getChild(Edit.RootChild.INFO, Edit.NAMESPACE);
		String schema = info.getChildText(Edit.Info.Elem.SCHEMA);
		String fullSchema = schema;

		boolean isCHE = schema.equals("iso19139.che") && OutputSchema.CHE_PROFILE == outSchema;
		// PMT GeoCat c2c : Backported from old geocat
		if (schema.contains("iso19139")) schema = "iso19139";

		// --- transform iso19115 record to iso19139
		// --- If this occur user should probably migrate the catalogue from iso19115 to iso19139.
		// --- But sometimes you could harvest remote node in iso19115 and make them available through CSW
		if (schema.equals("iso19115")) {
		    String FS = File.separator;
			res = Xml.transform(res, context.getAppPath() + "xsl" + FS
					+ "conversion" + FS + "import" + FS + "ISO19115-to-ISO19139.xsl");
			schema = "iso19139";
		}

		//--- skip metadata with wrong schemas
		if (schema.equals("fgdc-std") || schema.equals("dublin-core"))
		    if(outSchema != OutputSchema.OGC_CORE)
		    	return null;

			// convert metadata to outputSchema
			if (outSchema != OutputSchema.OWN && !isCHE) {

				String FS = File.separator;

				// --- transform iso19115 record to iso19139
				// --- If this occur user should probably migrate the catalogue
				// from
				// iso19115 to iso19139.
				// --- But sometimes you could harvest remote node in iso19115
				// and
				// make them available through CSW
				if (schema.equals("iso19115")) {
					res = Xml.transform(res, context.getAppPath() + "xsl" + FS
							+ "conversion" + FS + "import" + FS
							+ "ISO19115-to-ISO19139.xsl");
					schema = "iso19139";
				}

				if (fullSchema.equals("iso19139.che")) {
					HashMap<String, String> params = new HashMap<String, String>();
					params.put("lang", context.getLanguage());
					params.put("includeInfo", "true");

					res = Xml.transform(res, context.getAppPath() + "xsl" + FS
							+ "conversion" + FS + "export" + FS + "xml_iso19139.xsl", params);
			  }
				// --- skip metadata with wrong schemas
				if (schema.equals("fgdc-std") || schema.equals("dublin-core")
						|| schema.equals("iso19110"))
					if (outSchema != OutputSchema.OGC_CORE)
						return null;

				// --- apply stylesheet according to setName and schema
				String prefix;
				if (outSchema == OutputSchema.OGC_CORE){
					prefix = "ogc";

                    // --- Search for related services to add dc:URI elements to ogc output.
                    // Append list of service to the current metadata record.
                    // Process related service to retrieve coupledResources.
                    GetRelated serviceSearcher = new GetRelated();
                    serviceSearcher.init(context.getAppPath(), gc.getHandlerConfig());
                    Element idElem = new Element(Params.ID).setText(id);
                    Element uuidElem = new Element(Params.UUID).setText(res.getChild(Edit.RootChild.INFO, Edit.NAMESPACE).getChildText(Params.UUID));
                    Element typeElem = new Element("type").setText("service");
                    Element relatedServices = serviceSearcher.exec(  new Element (Jeeves.Elem.REQUEST)
                            .addContent(new Element (Edit.RootChild.INFO, Edit.NAMESPACE).addContent(idElem).addContent(uuidElem))
                            .addContent(typeElem), context);

                    res.addContent(relatedServices);
				}else if (outSchema == OutputSchema.ISO_PROFILE)
					prefix = "iso";
				else {
					// PMT c2c previous geocat backport, was:
					// throw new
					// InvalidParameterValueEx("outputSchema not supported for metadata "
					// + id + " schema.", schema);
					if (!schema.contains("iso19139")) {
						// FIXME : should we return null or an exception in that
						// case and which exception
						throw new InvalidParameterValueEx(
								"outputSchema not supported for metadata " + id
										+ " schema.", schema);
					}
					return res;
				}

				String schemaDir = scm.getSchemaCSWPresentDir(schema) + FS;
				String styleSheet = schemaDir + prefix + "-" + setName + ".xsl";

				HashMap<String, String> params = new HashMap<String, String>();
				params.put("lang", context.getLanguage());
				params.put("displayInfo",
						resultType == ResultType.RESULTS_WITH_SUMMARY ? "true"
								: "false");

				try {

					// issue #133730 : MDs harvested as Dublin-Core
					// format are not well detected here.
					// we add a check to ensure that no extra xsl transformation
					// would not be applied.
					if (!res.getName().equals("simpledc")) {
						res = Xml.transform(res, styleSheet, params);
					}
					// we still need to do some transformation
					// in order to ensure csw response compliance
					// (simpledc -> csw:record)
					else {
						Element tempElem = new Element("Record", "csw",
								"http://www.opengis.net/cat/csw/2.0.2");
						tempElem.setContent(res.cloneContent());
						res = tempElem;
					}

				} catch (Exception e) {
					context.error("Error while transforming metadata with id : "
							+ id + " using " + styleSheet);
					context.error("  (C) StackTrace:\n" + Util.getStackTrace(e));
					return null;
				}

			} // end of "if (outSchema !== OWN)"

			// --- if the client has specified some ElementNames, then we search
			// for
			// --- them (all are relative XPaths to the root element)
			if (elemNames != null) {
				MetadataSchema mds = scm.getSchema(schema);
				Element frags = (Element) res.clone();
				frags.removeContent();
				for (String s : elemNames) {
					try {
						List obs = Xml.selectNodes(res, s, mds.getSchemaNS());
						for (Object o : obs) {
							if (o instanceof Element) {
								Element elem = (Element) o;
								frags.addContent((Content) elem.clone());
							}
						}
					} catch (Exception e) {
						e.printStackTrace();
						throw new InvalidParameterValueEx(
								"elementName has invalid XPath : " + s,
								e.getMessage());
					}
				}
				if (resultType == ResultType.RESULTS_WITH_SUMMARY) {
					frags.addContent((Content) info.clone());
				}
				res = frags;
			}

			// PMT GeoCat2 : is this code still necessary ? (was in previous
			// version)
			// --- if the client has specified some ElementNames, then we remove
			// the unwanted children
			// if (elemNames != null)
			// removeElements(res, elemNames);
			// The block above (if elemNames != null) seems to do slightly the
			// same thing

			return res;
		} catch (Exception e) {
			context.error("Error while getting metadata with id : " + id);
			context.error("  (C) StackTrace:\n" + Util.getStackTrace(e));
			throw new NoApplicableCodeEx(
					"Raised exception while getting metadata :" + e);
		}

	}

}

//=============================================================================


