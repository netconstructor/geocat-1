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

import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import org.apache.lucene.search.Sort;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Edit;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.csw.common.Csw;
import org.fao.geonet.csw.common.ElementSetName;
import org.fao.geonet.csw.common.OutputSchema;
import org.fao.geonet.csw.common.ResultType;
import org.fao.geonet.csw.common.exceptions.CatalogException;
import org.fao.geonet.csw.common.exceptions.InvalidParameterValueEx;
import org.fao.geonet.csw.common.exceptions.NoApplicableCodeEx;
import org.fao.geonet.kernel.SelectionManager;
import org.fao.geonet.kernel.search.spatial.Pair;
import org.fao.geonet.util.spring.StringUtils;
import org.jdom.Element;

import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

//=============================================================================

public class SearchController
{
    
	private final CatalogSearcher _searcher;
    public SearchController(File summaryConfig, File luceneConfig)
    {
        _searcher = new CatalogSearcher(summaryConfig, luceneConfig);
    }
	
	//---------------------------------------------------------------------------
    //---
    //--- Single public method to perform the general search tasks
    //---
    //---------------------------------------------------------------------------

    /**
     * Performs the general search tasks.
     *
     * @param context
     * @param startPos
     * @param maxRecords
     * @param resultType
     * @param outSchema
     * @param setName
     * @param filterExpr
     * @param filterVersion
     * @param sort
     * @param elemNames
     * @param maxHitsFromSummary
     * @return
     * @throws CatalogException
     */
    public Pair<Element, Element> search(ServiceContext context, int startPos, int maxRecords,
                                         ResultType resultType, OutputSchema outSchema, ElementSetName setName,
                                         Element filterExpr, String filterVersion, Sort sort,
                                         Set<String> elemNames, int maxHitsFromSummary) throws CatalogException {
	Element results = new Element("SearchResults", Csw.NAMESPACE_CSW);

	Pair<Element, List<ResultItem>> summaryAndSearchResults = _searcher.search(context, filterExpr, filterVersion, sort, resultType, startPos, maxRecords, maxHitsFromSummary);
	
	UserSession session = context.getUserSession();
	session.setProperty(Geonet.Session.SEARCH_RESULT, _searcher);

	// clear selection from session when query filter change
	String requestId = Util.scramble(Xml.getString(filterExpr));
	String sessionRequestId = (String) session.getProperty(Geonet.Session.SEARCH_REQUEST_ID);
	if (sessionRequestId != null && !sessionRequestId.equals(requestId)) {
		// possibly close old selection
		SelectionManager oldSelection = (SelectionManager)session.getProperty(Geonet.Session.SELECTED_RESULT);
		
		if (oldSelection != null){
			oldSelection.close();
			oldSelection = null;
		}	
	}
	session.setProperty(Geonet.Session.SEARCH_REQUEST_ID, requestId);
	
	List<ResultItem> resultsList = summaryAndSearchResults.two();
	int counter = Math.min(maxRecords,resultsList.size());
	if ((resultType == ResultType.RESULTS || resultType == ResultType.RESULTS_WITH_SUMMARY) && resultsList.size() > 0) {
		for (int i=0; (i<maxRecords) && (i<resultsList.size()); i++) {
		    String  id = resultsList.get(i).getID();
		    Element md = retrieveMetadata(context, id, setName, outSchema, elemNames, resultType);

		    if (md == null) context.warning("SearchController : Metadata not found or invalid schema : "+ id);
		    else results.addContent(md);
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

    //---------------------------------------------------------------------------

    /**
     * Retrieves metadata from the database.
     * Conversion between metadata record and output schema are defined in xml/csw/schemas/ directory.
     *
     * @return	The XML metadata record if the record could be converted to
     * the required output schema. Null if no conversion available for
     * the schema (eg. fgdc record could not be converted to ISO).
     *
     * @param context
     * @param id
     * @param setName
     * @param outSchema
     * @param elemNames
     * @param resultType
     * @return
     * @throws CatalogException
     */
    public static Element retrieveMetadata(ServiceContext context, String id,  ElementSetName setName,
                                           OutputSchema outSchema, Set<String> elemNames, ResultType resultType) throws CatalogException {
	try {
		//--- get metadata from DB
		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		Element  res = gc.getDataManager().getMetadata(context, id, false); 
		
		if (res==null)
		    return null;

		String schema = res.getChild(Edit.RootChild.INFO, Edit.NAMESPACE).getChildText(Edit.Info.Elem.SCHEMA);

		String FS = File.separator;
		
		// --- transform iso19115 record to iso19139
		// --- If this occur user should probably migrate the catalogue from iso19115 to iso19139.
		// --- But sometimes you could harvest remote node in iso19115 and make them available through CSW
		if (schema.equals("iso19115")) {
			res = Xml.transform(res, context.getAppPath() + "xsl" + FS + "conversion" + FS + "import" + FS + "ISO19115-to-ISO19139.xsl");
			schema = "iso19139";
		}
		
		//--- skip metadata with wrong schemas

        // To be improved. See #343
		if (schema.equals("fgdc-std") || schema.equals("dublin-core") || schema.equals("iso19110")) {
		    if (outSchema != OutputSchema.OGC_CORE){
		    	return null;
            }
        }

		//--- apply stylesheet according to setName and schema

		String prefix ; 
		if (outSchema == OutputSchema.OGC_CORE)
			prefix = "ogc";
		else if (outSchema == OutputSchema.ISO_PROFILE)
			prefix = "iso";
		else {
			// FIXME ISO PROFIL : Use declared primeNS in current node.
			prefix = "fra";
			if (!schema.contains("iso19139")){
				// FIXME : should we return null or an exception in that case and which exception
				throw new InvalidParameterValueEx("outputSchema not supported for metadata " + 
						id + " schema.", schema);
			}
		}
	
		String schemaDir  = context.getAppPath() +"xml"+ FS +"csw"+ FS +"schemas"+ FS +schema+ FS;
		String styleSheet = schemaDir + prefix +"-"+ setName +".xsl";

		HashMap<String, String> params = new HashMap<String, String>();
		params.put("lang", context.getLanguage());
		params.put("displayInfo", resultType == ResultType.RESULTS_WITH_SUMMARY ? "true" : "false");
		
		res = Xml.transform(res, styleSheet, params);

		//--- if the client has specified some ElementNames, then we search for them
		//--- if they are in anything else other that csw:Record, if csw:Record 
		//--- remove only the unwanted ones

		if (elemNames != null) {
		    if (outSchema != OutputSchema.OGC_CORE) {
                /* original implementation. Seems incorrect -- see http://trac.osgeo.org/geonetwork/ticket/492.
						Element frags = (Element)res.clone();
						frags.removeContent();
						for (String s : elemNames) {
							try {
								Content o = (Content)XPath.getElement(res, s);
								if (o != null) frags.addContent((Content)o.clone());
							} catch (Exception e) {
								e.printStackTrace();
								throw new InvalidParameterValueEx("elementName has invalid XPath : "+s,e.getMessage());
							}
						}
						res = frags;
				*/
                String transformation = createElementNameTransformation(elemNames);
                InputStream is = new ByteArrayInputStream(transformation.getBytes("UTF-8"));
                Source ss = new StreamSource(is);
                boolean requireNonCachingTransformerFactory = true;
                res = Xml.transform(res, ss, requireNonCachingTransformerFactory);
			}
            else {
                removeElements(res, elemNames);
			}
		}
		return res;
	}
    catch (Exception e) {
		context.error("Error while getting metadata with id : "+ id);
		context.error("  (C) StackTrace:\n"+ Util.getStackTrace(e));
		throw new NoApplicableCodeEx("Raised exception while getting metadata :"+ e);
    }
	}

    /**
     * Creates a transformation containing
     *
     * <xsl:apply-templates select="[xpath"/>
     *
     * for each requested Xpath.
     *
     * TODO better put this in a file and pass it parameters from Java ?
     *
     * @param elemNames
     * @return
     */
    private static String createElementNameTransformation(Set<String> elemNames) {

        String result =
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:csw=\"http://www.opengis.net/cat/csw/2.0.2\" xmlns:gmd=\"http://www.isotc211.org/2005/gmd\" xmlns:gco=\"http://www.isotc211.org/2005/gco\" xmlns:srv=\"http://www.isotc211.org/2005/srv\" xmlns:ows=\"http://www.opengis.net/ows\" xmlns:geonet=\"http://www.fao.org/geonetwork\">\n" +
                "<xsl:output indent=\"yes\"/>\n" +
                "<xsl:param name=\"displayInfo\"/>\n" +
                //"<xsl:template match=\"gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']\">\n" +
                "<xsl:template match=\"/*\">\n" +
                "<xsl:variable name=\"info\" select=\"geonet:info\"/>\n" +
                "<xsl:copy>\n";

        for (String xpath : elemNames) {
            if(StringUtils.hasLength(xpath)) {
                result += "<xsl:apply-templates select=\"" + xpath + "\"/>\n";
            }
        }

        result +=
                "<!-- GeoNetwork elements added when resultType is equal to results_with_summary -->\n" +
                "<xsl:if test=\"$displayInfo = 'true'\">\n" +
                "<xsl:copy-of select=\"$info\"/>\n" +
                "</xsl:if>\n" +
                "</xsl:copy>\n" +
                "</xsl:template>\n" +
                "<xsl:template match=\"@*|node()\">\n" +
                "<xsl:copy>\n" +
                "<xsl:apply-templates select=\"@*|node()\"/>\n" +
                "</xsl:copy>\n" +
                "</xsl:template>\n" +
                "\n" +
                "</xsl:stylesheet>";

        System.out.println("generated transformation:\n" + result);
        return result;
    }

    //---------------------------------------------------------------------------

    private static void removeElements(Element md, Set<String> elemNames)
    {
	Iterator i=md.getChildren().iterator();

	while (i.hasNext())
	    {
		Element elem = (Element) i.next();

		if (!FieldMapper.match(elem, elemNames))
		    i.remove();
	    }
    }

    //---------------------------------------------------------------------------

}

//=============================================================================


