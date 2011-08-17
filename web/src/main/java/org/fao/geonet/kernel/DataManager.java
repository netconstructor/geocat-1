//==============================================================================
//===
//=== DataManager
//===
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

package org.fao.geonet.kernel;

import jeeves.constants.Jeeves;
import jeeves.exceptions.JeevesException;
import jeeves.exceptions.OperationNotAllowedEx;
import jeeves.exceptions.XSDValidationErrorEx;
import jeeves.resources.dbms.Dbms;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.SerialFactory;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import jeeves.utils.Xml.ErrorHandler;
import jeeves.xlink.Processor;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Edit;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.exceptions.SchematronValidationErrorEx;
import org.fao.geonet.kernel.csw.domain.CswCapabilitiesInfo;
import org.fao.geonet.kernel.harvest.HarvestManager;
import org.fao.geonet.kernel.reusable.ProcessParams;
import org.fao.geonet.kernel.reusable.ReusableObjManager;
import org.fao.geonet.kernel.reusable.log.ReusableObjectLogger;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.search.spatial.Pair;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.services.extent.ExtentManager;
import org.fao.geonet.util.ISODate;
import org.jdom.Attribute;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;

import java.io.File;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;
import java.util.Vector;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.DelayQueue;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * Handles all operations on metadata (select,insert,update,delete etc...).
 *
 */
public class DataManager {

    //--------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//--------------------------------------------------------------------------

    /**
     *
     * @return
     */
    public EditLib getEditLib() {
        return editLib;
    }

    /**
     * initializes the search manager and index not-indexed metadata.
     * @param context
     * @param scm
     * @param sm
     * @param am
     * @param dbms
     * @param ss
     * @param reusableObjMan
     * @param extentMan
     * @param thesMan
     * @param baseURL
     * @param htmlCacheDir
     * @param dataDir
     * @param appPath
     * @throws Exception
     */
	public DataManager(final Element params, ServiceContext context, SchemaManager scm, SearchManager sm, AccessManager am, Dbms dbms, SettingManager ss, ThesaurusManager thesMan, ReusableObjManager reusableObjMan, ExtentManager extentMan, String baseURL, String htmlCacheDir, String dataDir, String appPath) throws Exception
	{
		searchMan = sm;
		accessMan = am;
		settingMan= ss;
		schemaMan = scm;
		editLib = new EditLib(schemaMan);
        servContext=context;
        this.reusableObjMan = reusableObjMan;
        this.extentMan = extentMan;
        this.thesaurusMan = thesMan;
		this.validator = new Validator(htmlCacheDir);
		this.baseURL = baseURL;
        this.dataDir = dataDir;
		this.appPath = appPath;
		int corePoolSize = Util.getParam(params, "indexThreadPoolSize", 4);
		ThreadFactory threadFactory = new ThreadFactory() {
			ThreadFactory innerFactory = Executors.defaultThreadFactory();
			public Thread newThread(Runnable r) {
				Thread thread = innerFactory.newThread(r);
				thread.setDaemon(true);
				thread.setName("Index Task Thread");
				thread.setPriority(Integer.parseInt(Util.getParam(params, "indexThreadPoolPriority", ""+Thread.NORM_PRIORITY)));
				return thread;
			}
		};
		indexThreadPool = new ScheduledThreadPoolExecutor(corePoolSize, threadFactory);
		stylePath = context.getAppPath() + FS + Geonet.Path.STYLESHEETS + FS;

		XmlSerializer.setSettingManager(ss);

		init(context, dbms, false);
	}

    /**
     *
     */
    private synchronized void finishRebuilding() {
        rebuilding = false;
    }

	/**
	 * Init Data manager and refresh index if needed. 
	 * Can also be called after GeoNetwork startup in order to rebuild the lucene 
	 * index
	 * 
	 * @param context
	 * @param dbms
	 * @param force         Force reindexing all from scratch
	 *
	 **/
	public synchronized void init(ServiceContext context, Dbms dbms, Boolean force) throws Exception {

		if (rebuilding) throw new OperationNotAllowedEx("Index rebuilding already in progress");

		// get all metadata from DB
		Element result = dbms.select("SELECT id, changeDate FROM Metadata ORDER BY id ASC");
		
		Log.debug(Geonet.DATA_MANAGER, "DB CONTENT:\n'"+ Xml.getString(result) +"'"); 

		// get lastchangedate of all metadata in index
		HashMap<String,String> docs = searchMan.getDocsChangeDate();

		// set up results HashMap for post processing of records to be indexed
		ArrayList<Integer> toIndex = new ArrayList<Integer>();

		Log.debug(Geonet.DATA_MANAGER, "INDEX CONTENT:");

		// index all metadata in DBMS if needed
		for(int i = 0; i < result.getContentSize(); i++) {
			// get metadata
			Element record = (Element) result.getContent(i);
			String  id     = record.getChildText("id");
			int iId = Integer.parseInt(id);
	
			Log.debug(Geonet.DATA_MANAGER, "- record ("+ id +")");

			String idxLastChange = docs.get(id);

			// if metadata is not indexed index it
			if (idxLastChange == null) {
				Log.debug(Geonet.DATA_MANAGER, "-  will be indexed");
				toIndex.add(iId);
	
			// else, if indexed version is not the latest index it
			} else {
				docs.remove(id);
	
				String lastChange    = record.getChildText("changedate");
	
       	Log.debug(Geonet.DATA_MANAGER, "- lastChange: " + lastChange); 
       	Log.debug(Geonet.DATA_MANAGER, "- idxLastChange: " + idxLastChange); 
	
				// date in index contains 't', date in DBMS contains 'T'
				if (force || !idxLastChange.equalsIgnoreCase(lastChange)) {
					Log.debug(Geonet.DATA_MANAGER, "-  will be indexed");
					toIndex.add(iId);
				}
			}
		}

		// if anything to index then schedule it to be done after servlet is
		// up so that any links to local fragments are resolvable
		if ( toIndex.size() > 0 ) {
			scheduleIndexTask(context, toIndex);
		}

		if (docs.size() > 0) { // anything left?
			Log.debug(Geonet.DATA_MANAGER, "INDEX HAS RECORDS THAT ARE NOT IN DB:"); 
		}

		// remove from index metadata not in DBMS
		for ( String id : docs.keySet() )
		{
			searchMan.delete("_id", id);

      Log.debug(Geonet.DATA_MANAGER, "- removed record (" + id + ") from index");
		}
	}

    public void scheduleIndexTask(ServiceContext context, ArrayList<Integer> toIndex) {
        IndexMetadataTask indexMetadataTask = new IndexMetadataTask(context, toIndex);
        indexThreadPool.schedule(indexMetadataTask, 10, TimeUnit.MILLISECONDS);
    }

    /**
     *
     * @param context
     * @throws Exception
     */
	public synchronized void rebuildIndexXLinkedMetadata(ServiceContext context) throws Exception {
		
		if (rebuilding) throw new OperationNotAllowedEx("Index rebuilding already in progress");

		// get all metadata with XLinks
		ArrayList<Integer> toIndex = searchMan.getDocsWithXLinks();

		Log.debug(Geonet.DATA_MANAGER, "Will index "+toIndex.size()+" records with XLinks");
		if ( toIndex.size() > 0 ) {
			// clean XLink Cache so that cache and index remain in sync
			Processor.clearCache();	

			scheduleIndexTask(context, toIndex);
		}
	}

    /**
     *
     */
	class IndexMetadataTask implements Runnable {
		ServiceContext context;
		ArrayList<Integer> toIndex;

        IndexMetadataTask(ServiceContext context, ArrayList<Integer> toIndex) {
			this.context = context;
			this.toIndex = toIndex;
		}

		public void run() {

			try {

				// poll context to see whether servlet is up yet
				while (!context.isServletInitialized()) {
					Log.debug(Geonet.DATA_MANAGER, "Waiting for servlet to finish initializing.."); 
					Thread.sleep(10000); // sleep 10 seconds
				}

				// servlet up so safe to index all metadata that needs indexing

				Dbms dbms = (Dbms) context.getResourceManager().openDirect(Geonet.Res.MAIN_DB);
				startIndexGroup();
				try {
					for ( Integer id : toIndex ) {
						indexMetadataGroup(dbms, id.toString(), false);
					}
				} finally {
					endIndexGroup();
				}

				//-- commit Dbms resource (which makes it available to pool again) 
				//-- to avoid exhausting Dbms pool
				context.getResourceManager().close(Geonet.Res.MAIN_DB, dbms);
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				finishRebuilding();
			}
		}
	}

    /**
     *
     * @throws Exception
     */
	public void startIndexGroup() throws Exception {
		searchMan.startIndexGroup();
	}

    /**
     *
     * @throws Exception
     */
	public void endIndexGroup() throws Exception {
		searchMan.endIndexGroup();
	}

    /**
     *
     * @param dbms
     * @param id
     * @throws Exception
     */
	public void indexMetadataGroup(Dbms dbms, String id) throws Exception {
		Log.debug(Geonet.DATA_MANAGER, "Indexing record (" + id + ")"); //DEBUG
		indexMetadata(dbms, id, true,true);
	}
	public void indexMetadataGroup(Dbms dbms, String id, boolean processSharedObjects) throws Exception {
		Log.debug(Geonet.DATA_MANAGER, "Indexing record (" + id + ")"); //DEBUG
		indexMetadata(dbms, id, true,processSharedObjects);
	}

    /**
     *
     * @param dbms
     * @param id
     * @param indexGroup
     * @throws Exception
     */
	public void indexMetadata(Dbms dbms, String id, boolean indexGroup, boolean processSharedObjects) throws Exception {
        try {
        	synchronized (indexing) {
    	        indexing.push(true);
            }
            Vector<Element> moreFields = new Vector<Element>();
            int id$ = new Integer(id);
            
            // get metadata, extracting and indexing any xlinks
            Element md   = XmlSerializer.selectNoXLinkResolver(dbms, "Metadata", id);

            // get metadata table fields
            String query = "SELECT schemaId, createDate, changeDate, source, isTemplate, root, " +
                "title, uuid, isHarvested, owner, groupOwner, popularity, rating FROM Metadata WHERE id = ?";

            Element rec = dbms.select(query, id$).getChild("record");

            String  schema     = rec.getChildText("schemaid");
            String  createDate = rec.getChildText("createdate");
            String  changeDate = rec.getChildText("changedate");
            String  source     = rec.getChildText("source");
            String  isTemplate = rec.getChildText("istemplate");
            String  root       = rec.getChildText("root");
            String  title      = rec.getChildText("title");
            String  uuid       = rec.getChildText("uuid");
            String  isHarvested= rec.getChildText("isharvested");
            String  owner      = rec.getChildText("owner");
            String  groupOwner = rec.getChildText("groupowner");
            String  popularity = rec.getChildText("popularity");
            String  rating     = rec.getChildText("rating");
            
            
             if("n".equalsIgnoreCase(isHarvested) && processSharedObjects && schema.trim().equals("iso19139.che")) {
            	try {
	                ProcessParams processParameters = new ProcessParams(dbms, ReusableObjectLogger.THREAD_SAFE_LOGGER, id, md, md, thesaurusMan, extentMan, baseURL, settingMan, false, null,servContext);
	                List<Element> modified = reusableObjMan.process(processParameters);
	                
	                if(modified != null && !modified.isEmpty()) {
	                    md = modified.get(0);
	                    XmlSerializer.update(dbms, id, md, new ISODate().toString(), null);
	                }
            	} catch (Exception e) {
            		Log.error(Geonet.DATA_MANAGER, "error while trying to update shared objects of metadata, "+id+" "+e.getMessage()); //DEBUG
            	}
            }
            if (XmlSerializer.resolveXLinks()) {
                List<Attribute> xlinks = Processor.getXLinks(md);
                if (xlinks.size() > 0) {
                    moreFields.add(makeField("_hasxlinks", "1", true, true, false));
                    StringBuilder sb = new StringBuilder();
                    for (Attribute xlink : xlinks) {
                        sb.append(xlink.getValue()); sb.append(" ");
                    }
                    moreFields.add(makeField("_xlink", sb.toString(), true, true, false));
                    Processor.processXLink(md,servContext); 
                }
                else {
                    moreFields.add(makeField("_hasxlinks", "0", true, true, false));
                }
            }
            else {
                moreFields.add(makeField("_hasxlinks", "0", true, true, false));
            }

            

            Log.debug(Geonet.DATA_MANAGER, "record schema (" + schema + ")"); //DEBUG
            Log.debug(Geonet.DATA_MANAGER, "record createDate (" + createDate + ")"); //DEBUG

            moreFields.add(makeField("_root",        root,        true, true, false));
            moreFields.add(makeField("_schema",      schema,      true, true, false));
            moreFields.add(makeField("_createDate",  createDate,  true, true, false));
            moreFields.add(makeField("_changeDate",  changeDate,  true, true, false));
            moreFields.add(makeField("_source",      source,      true, true, false));
            moreFields.add(makeField("_isTemplate",  isTemplate,  true, true, false));
            moreFields.add(makeField("_title",       title,       true, true, false));
            moreFields.add(makeField("_uuid",        uuid,        true, true, true));
            moreFields.add(makeField("_isHarvested", isHarvested, true, true, false));
            moreFields.add(makeField("_owner",       owner,       true, true, false));
            moreFields.add(makeField("_dummy",       "0",        false, true, false));
            moreFields.add(makeField("_popularity",  popularity,  true, true, false));
            moreFields.add(makeField("_rating",      rating,      true, true, false));

            if (groupOwner != null)
                moreFields.add(makeField("_groupOwner", groupOwner, true, true, false));

            // get privileges
            List operations = dbms
                                .select("SELECT groupId, operationId FROM OperationAllowed WHERE metadataId = ? ORDER BY operationId ASC", id$)
                                    .getChildren();

            for (Object operation1 : operations) {
                Element operation = (Element) operation1;
                String groupId = operation.getChildText("groupid");
                String operationId = operation.getChildText("operationid");
                moreFields.add(makeField("_op" + operationId, groupId, true, true, false));
            }
            // get categories
            List categories = dbms
                                .select("SELECT id, name FROM MetadataCateg, Categories WHERE metadataId = ? AND categoryId = id ORDER BY id", id$)
                                    .getChildren();

            for (Object category1 : categories) {
                Element category = (Element) category1;
                String categoryName = category.getChildText("name");
                moreFields.add(makeField("_cat", categoryName, true, true, false));
            }

            // getValidationInfo
            // -1 : not evaluated
            // 0 : invalid
            // 1 : valid
            List<Element> validationInfo = dbms
                                             .select("SELECT valType, status FROM Validation WHERE metadataId = ?", id$)
                                                 .getChildren();
            if (validationInfo.size() == 0) {
                moreFields.add(makeField("_valid", "-1", true, true, false));
            }
            else {
                String isValid = "1";
                for (Object elem : validationInfo) {
                    Element vi = (Element) elem;
                    String type = vi.getChildText("valtype");
                    String status = vi.getChildText("status");
                    if ("0".equals(status)) {
                        isValid = "0";
                    }
                    moreFields.add(makeField("_valid_" + type, status, true, true, false));
                }
                moreFields.add(makeField("_valid", isValid, true, true, false));
            }
            if (indexGroup) {
                searchMan.indexGroup(schemaMan.getSchemaDir(schema), md, id, moreFields, isTemplate, title);
            }
            else {
                searchMan.index(schemaMan.getSchemaDir(schema), md, id, moreFields, isTemplate, title);
            }
        }
		catch (Exception x) {
			Log.error(Geonet.DATA_MANAGER, "The metadata document index with id=" + id + " is corrupt/invalid - ignoring it. Error: " + x.getMessage());
			x.printStackTrace();
		} finally {
        	synchronized (indexing) {
    	        indexing.pop();
            }

		}
	}

    /**
     *
     * @param beginAt
     * @param interval
     * @throws Exception
     */
	public void rescheduleOptimizer(Calendar beginAt, int interval) throws Exception {
		searchMan.rescheduleOptimizer(beginAt, interval);
	}

    /**
     *
     * @throws Exception
     */
	public void disableOptimizer() throws Exception {
		searchMan.disableOptimizer();
	}

    /**
     *
     * @param name
     * @param value
     * @param store
     * @param index
     * @param token
     * @return
     */
	private static Element makeField(String name, String value, boolean store,
												boolean index, boolean token) {
		Element field = new Element("Field");

		field.setAttribute("name",   name);
		field.setAttribute("string", value);
		field.setAttribute("store",  store+"");
		field.setAttribute("index",  index+"");
		field.setAttribute("token",  token+"");

		return field;
	}

	//--------------------------------------------------------------------------
	//---
	//--- Schema management API
	//---
	//--------------------------------------------------------------------------

    /**
     *
     * @param hm
     */
	public void setHarvestManager(HarvestManager hm) {
		harvestMan = hm;
	}

    /**
     *
     * @param name
     * @return
     */
	public MetadataSchema getSchema(String name) {
		return schemaMan.getSchema(name);
	}

    /**
     *
     * @return
     */
	public Set<String> getSchemas() {
		return schemaMan.getSchemas();
	}

    /**
     *
     * @param name
     * @return
     */
	public boolean existsSchema(String name) {
		return schemaMan.existsSchema(name);
	}

    /**
     *
     * @param name
     * @return
     */
	public String getSchemaDir(String name) {
		return schemaMan.getSchemaDir(name);
	}

    /**
     * Use this validate method for XML documents with dtd.
     *
     * @param schema
     * @param doc
     * @throws Exception
     */
	public void validate(String schema, Document doc) throws Exception {
		Xml.validate(doc);	
	}

    /**
     * Use this validate method for XML documents with xsd validation.
     *
     * @param schema
     * @param md
     * @throws Exception
     */
	public void validate(String schema, Element md) throws Exception {
		String schemaLoc = md.getAttributeValue("schemaLocation", Geonet.XSI_NAMESPACE);
		Log.debug(Geonet.DATA_MANAGER, "Extracted schemaLocation of "+schemaLoc);
		if (schemaLoc == null) schemaLoc = "";

		if (schema == null) {
			// must use schemaLocation 
			Xml.validate(md);
		} else {
			// if schemaLocation use that
			if (!schemaLoc.equals("")) { 
				Xml.validate(md);
			// otherwise use supplied schema name 
			} else {
				Xml.validate(getSchemaDir(schema) + Geonet.File.SCHEMA, md);
			}
		}
	}

    /**
     *
     * @param schema
     * @param md
     * @param eh
     * @return
     * @throws Exception
     */
	public Element validateInfo(String schema, Element md, ErrorHandler eh) throws Exception {
		String schemaLoc = md.getAttributeValue("schemaLocation", Geonet.XSI_NAMESPACE);
		Log.debug(Geonet.DATA_MANAGER, "Extracted schemaLocation of "+schemaLoc);
		if (schemaLoc == null) schemaLoc = "";

		if (schema == null) {
			// must use schemaLocation 
			return Xml.validateInfo(md, eh);
		} else {
			// if schemaLocation use that
			if (!schemaLoc.equals("")) { 
				return Xml.validateInfo(md, eh);
			// otherwise use supplied schema name 
			} else {
				return Xml.validateInfo(getSchemaDir(schema) + Geonet.File.SCHEMA, md, eh);
			}
		}
	}

    /**
     * Creates XML schematron report.
     * @param schema
     * @param md
     * @param lang
     * @return
     * @throws Exception
     */
	public Element doSchemaTronForEditor(String schema,Element md,String lang) throws Exception { 
    	// enumerate the metadata xml so that we can report any problems found  
    	// by the schematron_xml script to the geonetwork editor 
    	editLib.enumerateTree(md); 
    	
    	// get an xml version of the schematron errors and return for error display 
    	Element schemaTronXmlReport = getSchemaTronXmlReport(schema, md, lang, null); 
    	
    	// remove editing info added by enumerateTree 
    	editLib.removeEditingInfo(md); 
    	
    	return schemaTronXmlReport; 
	}

    /**
     *
     * @param dbms
     * @param id
     * @return
     * @throws Exception
     */
	public String getMetadataSchema(Dbms dbms, String id) throws Exception {
		List list = dbms.select("SELECT schemaId FROM Metadata WHERE id = " +id).getChildren();

		if (list.size() == 0)
			throw new IllegalArgumentException("Metadata not found for id : " +id);
		else {
			// get metadata
			Element record = (Element) list.get(0);
			return record.getChildText("schemaid");
		}
	}

    /**
     *
     * @param md
     * @return
     * @throws Exception
     */
	public Element enumerateTree(Element md) throws Exception {
		editLib.enumerateTree(md);
		return md;
	}

        /**
     * Validates metadata against XSD and schematron files related to metadata schema throwing XSDValidationErrorEx
     * if xsd errors or SchematronValidationErrorEx if schematron rules fails
     *
     * @param schema
     * @param xml
     * @param context
     * @throws Exception
     */
	public static void validateMetadata(String schema, Element xml, ServiceContext context) throws Exception
	{
		validateMetadata(schema,xml,context," ");
	}

    /**
     * Validates metadata against XSD and schematron files related to metadata schema throwing XSDValidationErrorEx
     * if xsd errors or SchematronValidationErrorEx if schematron rules fails
     *
     * @param schema
     * @param xml
     * @param context
     * @param fileName
     * @throws Exception
     */
	public static void validateMetadata(String schema, Element xml, ServiceContext context, String fileName) throws Exception
	{
		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);

		DataManager dataMan = gc.getDataManager();

		dataMan.setNamespacePrefix(xml);
		try {
			dataMan.validate(schema, xml);
		} catch (XSDValidationErrorEx e) {
			if (!fileName.equals(" ")) {
				throw new XSDValidationErrorEx(e.getMessage()+ "(in "+fileName+"): ",e.getObject());
			} else {
				throw new XSDValidationErrorEx(e.getMessage(),e.getObject());
			}
		}

		//-----------------------------------------------------------------------
		//--- if the uuid does not exist we generate it

		String uuid = dataMan.extractUUID(schema, xml);

		if (uuid.length() == 0)
			uuid = UUID.randomUUID().toString();

		//--- Now do the schematron validation on this file - if there are errors
		//--- then we say what they are!
		//--- Note we have to use uuid here instead of id because we don't have
		//--- an id...

		Element schemaTronXml = dataMan.doSchemaTronForEditor(schema,xml,context.getLanguage());
		xml.detach();
		if (schemaTronXml != null && schemaTronXml.getContent().size() > 0) {
			Element schemaTronReport = dataMan.doSchemaTronForEditor(schema,xml,context.getLanguage());

            List<Namespace> theNSs = new ArrayList<Namespace>();
            theNSs.add(Namespace.getNamespace("geonet", "http://www.fao.org/geonetwork"));
            theNSs.add(Namespace.getNamespace("svrl", "http://purl.oclc.org/dsdl/svrl"));

            Element failedAssert = Xml.selectElement(schemaTronReport, "geonet:report/svrl:schematron-output/svrl:failed-assert", theNSs);

            if (failedAssert != null) {
			    throw new SchematronValidationErrorEx("Schematron errors detected for file "+fileName+" - "
					    + Xml.getString(schemaTronReport) + " for more details",schemaTronReport);
            }
		}

	}

    /**
     * Creates XML schematron report for each set of rules defined in schema directory.
     * @param schema
     * @param md
     * @param lang
     * @param valTypeAndStatus
     * @return
     * @throws Exception
     */
	private Element getSchemaTronXmlReport(String schema, Element md, String lang, Map<String, Integer[]> valTypeAndStatus) throws Exception {
		// NOTE: this method assumes that you've run enumerateTree on the 
		// metadata

		MetadataSchema metadataSchema = getSchema(schema);
		String[] rules = metadataSchema.getSchematronRules();
		
		// Schematron report is composed of one or more report(s)
		// for each set of rules.
		Element schemaTronXmlOut = new Element("schematronerrors",
				Edit.NAMESPACE);

		for (String rule : rules) {
			// -- create a report for current rules.
			// Identified by a rule attribute set to shematron file name
			Log.debug(Geonet.DATA_MANAGER, " - rule:" + rule);
			String ruleId = rule.substring(0, rule.indexOf(".xsl"));
			Element report = new Element("report", Edit.NAMESPACE);
			report.setAttribute("rule", ruleId,
					Edit.NAMESPACE);

			String schemaTronXmlXslt = metadataSchema.getSchemaDir() + File.separator
					+ rule;
			try {
				Map<String,String> params = new HashMap<String,String>();
				params.put("lang", lang);
				params.put("rule", rule);
				params.put("dataDir", this.dataDir);
				Element xmlReport = Xml.transform(md, schemaTronXmlXslt, params);
				if (xmlReport != null) {
					report.addContent(xmlReport);
				}
				// add results to persitent validation information
				int firedRules = 0;
				Iterator<Element> i = xmlReport.getDescendants(new ElementFilter ("fired-rule", Namespace.getNamespace("http://purl.oclc.org/dsdl/svrl")));
				while (i.hasNext()) {
                    i.next();
                    firedRules ++;
                }
				int invalidRules = 0;
                i = xmlReport.getDescendants(new ElementFilter ("failed-assert", Namespace.getNamespace("http://purl.oclc.org/dsdl/svrl")));
                while (i.hasNext()) {
                    i.next();
                    invalidRules ++;
                }
				Integer[] results = {invalidRules!=0?0:1, firedRules, invalidRules};
				if (valTypeAndStatus != null) {
				    valTypeAndStatus.put(ruleId, results);
				}
			} catch (Exception e) {
				Log.error(Geonet.DATA_MANAGER,"WARNING: schematron xslt "+schemaTronXmlXslt+" failed");
				e.printStackTrace();
			}

			// -- append report to main XML report.
			schemaTronXmlOut.addContent(report);
		}

		return schemaTronXmlOut;
	}

    /**
     * Valid the metadata record against its schema. For each error found, an xsderror attribute is added to
	 * the corresponding element trying to find the element based on the xpath return by the ErrorHandler.
     *
     * @param schema
     * @param md
     * @return
     * @throws Exception
     */
	private synchronized Element getXSDXmlReport(String schema, Element md) throws Exception {
		// NOTE: this method assumes that enumerateTree has NOT been run on the metadata
		ErrorHandler errorHandler = new ErrorHandler();
		errorHandler.setNs(Edit.NAMESPACE);
		Element xsdErrors;
		
		try {
		    xsdErrors = validateInfo(schema,
				md, errorHandler);
		}catch (Exception e) {
		    xsdErrors = JeevesException.toElement(e);
		    return xsdErrors;
        }
		
		if (xsdErrors != null) {
			MetadataSchema mds = getSchema(schema);
			List<Namespace> schemaNamespaces = mds.getSchemaNS();
		
			//-- now get each xpath and evaluate it
			//-- xsderrors/xsderror/{message,xpath} 
			List list = xsdErrors.getChildren();
			for (Object o : list) {
				Element elError = (Element) o;
				String xpath = elError.getChildText("xpath", Edit.NAMESPACE);
				String message = elError.getChildText("message", Edit.NAMESPACE);
				message = "\\n" + message;

				//-- get the element from the xpath and add the error message to it 
				Element elem = Xml.selectElement(md, xpath, schemaNamespaces);
				if (elem != null) {
					String existing = elem.getAttributeValue("xsderror",Edit.NAMESPACE);
					if (existing != null) message = existing + message;
					elem.setAttribute("xsderror",message,Edit.NAMESPACE);
				} else {
					Log.warning(Geonet.DATA_MANAGER,"WARNING: evaluating XPath "+xpath+" against metadata failed - XSD validation message: "+message+" will NOT be shown by the editor");
				}
			}
		}
		return xsdErrors;
	}

    /**
     *
     * @return
     */
	public AccessManager getAccessManager() {
		return accessMan;
	}

	//--------------------------------------------------------------------------
	//---
	//--- General purpose API
	//---
	//--------------------------------------------------------------------------

    /**
     *
     * @param schema
     * @param md
     * @return
     * @throws Exception
     */
	public String extractUUID(String schema, Element md) throws Exception {
		String styleSheet = getSchemaDir(schema) + Geonet.File.EXTRACT_UUID;
		String uuid       = Xml.transform(md, styleSheet).getText().trim();

		Log.debug(Geonet.DATA_MANAGER, "Extracted UUID '"+ uuid +"' for schema '"+ schema +"'");

		//--- needed to detach md from the document
		md.detach();

		return uuid;
	}

    /**
     *
     * @param schema
     * @param uuid
     * @param md
     * @return
     * @throws Exception
     */
	public Element setUUID(String schema, String uuid, Element md) throws Exception {
		//--- setup environment

		Element env = new Element("env");
		env.addContent(new Element("uuid").setText(uuid));

		//--- setup root element

		Element root = new Element("root");
		root.addContent(md.detach());
		root.addContent(env.detach());

		//--- do an XSL  transformation

		String styleSheet = getSchemaDir(schema) + Geonet.File.SET_UUID;

		return Xml.transform(root, styleSheet);
	}

    /**
     *
     * @param dbms
     * @param harvestingSource
     * @return
     * @throws Exception
     */
	@SuppressWarnings("unchecked")
	public List<Element> getMetadataByHarvestingSource(Dbms dbms, String harvestingSource) throws Exception {
		String query = "SELECT id FROM Metadata WHERE harvestUuid=?";
		return dbms.select(query, harvestingSource).getChildren();
	}

    /**
     *
     * @param md
     * @return
     * @throws Exception
     */
	public Element extractSummary(Element md) throws Exception {
		String styleSheet = stylePath + Geonet.File.METADATA_BRIEF;
		Element summary       = Xml.transform(md, styleSheet);

		Log.debug(Geonet.DATA_MANAGER, "Extracted summary '\n"+Xml.getString(summary));

		//--- needed to detach md from the document
		md.detach();

		return summary;
	}

    /**
     *
     * @param dbms
     * @param uuid
     * @return
     * @throws Exception
     */
	public String getMetadataId(Dbms dbms, String uuid) throws Exception {
		String query = "SELECT id FROM Metadata WHERE uuid=?";

		List list = dbms.select(query, uuid).getChildren();

		if (list.size() == 0)
			return null;

		Element record = (Element) list.get(0);

		return record.getChildText("id");
	}

    /**
     *
     * @param dbms
     * @param id
     * @return
     * @throws Exception
     */
	public String getMetadataUuid(Dbms dbms, String id) throws Exception {
		String query = "SELECT uuid FROM Metadata WHERE id=?";

		List list = dbms.select(query, new Integer(id)).getChildren();

		if (list.size() == 0)
			return null;

		Element record = (Element) list.get(0);

		return record.getChildText("uuid");
	}

    /**
     *
     * @param dbms
     * @param id
     * @return
     * @throws Exception
     */
	public String getMetadataTemplate(Dbms dbms, String id) throws Exception {
		String query = "SELECT istemplate FROM Metadata WHERE id=?";

		List list = dbms.select(query, new Integer(id)).getChildren();

		if (list.size() == 0)
			return null;

		Element record = (Element) list.get(0);

		return record.getChildText("istemplate");
	}

    /**
     *
     * @param dbms
     * @param id
     * @return
     * @throws Exception
     */
	public MdInfo getMetadataInfo(Dbms dbms, String id) throws Exception {
		String query = "SELECT id, uuid, schemaId, isTemplate, isHarvested, createDate, "+
							"       changeDate, source, title, root, owner, groupOwner, displayOrder "+
							"FROM   Metadata "+
							"WHERE id=?";

		List list = dbms.select(query, new Integer(id)).getChildren();

		if (list.size() == 0)
			return null;

		Element record = (Element) list.get(0);

		MdInfo info = new MdInfo();

		info.id          = id;
		info.uuid        = record.getChildText("uuid");
		info.schemaId    = record.getChildText("schemaid");
		info.isHarvested = "y".equals(record.getChildText("isharvested"));
		info.createDate  = record.getChildText("createdate");
		info.changeDate  = record.getChildText("changedate");
		info.source      = record.getChildText("source");
		info.title       = record.getChildText("title");
		info.root        = record.getChildText("root");
		info.owner       = record.getChildText("owner");
		info.groupOwner  = record.getChildText("groupowner");
                info.displayOrder  = record.getChildText("displayOrder");

		String temp = record.getChildText("istemplate");

		if ("y".equals(temp))
			info.template = MdInfo.Template.TEMPLATE;

		else if ("s".equals(temp))
			info.template = MdInfo.Template.SUBTEMPLATE;

		else
			info.template = MdInfo.Template.METADATA;

		return info;
	}

    /**
     *
     * @param id
     * @return
     */
	public String getVersion(String id) {
		return editLib.getVersion(id);
	}

    /**
     *
     * @param id
     * @return
     */
	public String getNewVersion(String id){
		return editLib.getNewVersion(id);
	}

    /**
     *
     * @param dbms
     * @param id
     * @param isTemplate
     * @param title
     * @throws Exception
     */
	public void setTemplate(Dbms dbms, int id, String isTemplate, String title) throws Exception {
		setTemplateExt(dbms, id, isTemplate, title);
        boolean indexGroup = false;
        indexMetadata(dbms, Integer.toString(id), indexGroup,true);

	}

    /**
     *
     * @param dbms
     * @param id
     * @param isTemplate
     * @param title
     * @throws Exception
     */
	public void setTemplateExt(Dbms dbms, int id, String isTemplate, String title) throws Exception {
		if (title == null) dbms.execute("UPDATE Metadata SET isTemplate=? WHERE id=?", isTemplate, id);
		else               dbms.execute("UPDATE Metadata SET isTemplate=?, title=? WHERE id=?", isTemplate, title, id);
	}

    /**
     *
     * @param dbms
     * @param id
     * @param harvestUuid
     * @throws Exception
     */
	public void setHarvested(Dbms dbms, int id, String harvestUuid) throws Exception {
		setHarvestedExt(dbms, id, harvestUuid);
        boolean indexGroup = false;
        indexMetadata(dbms, Integer.toString(id), indexGroup,true);
	}

    /**
     *
     * @param dbms
     * @param id
     * @param harvestUuid
     * @throws Exception
     */
	public void setHarvestedExt(Dbms dbms, int id, String harvestUuid) throws Exception {
		String value = (harvestUuid != null) ? "y" : "n";
		if (harvestUuid == null) {
			dbms.execute("UPDATE Metadata SET isHarvested=? WHERE id=?", value,id );
		}
        else {
			dbms.execute("UPDATE Metadata SET isHarvested=?, harvestUuid=? WHERE id=?", value, harvestUuid, id);
		}
	}

    /**
     *
     * @param dbms
     * @param id
     * @param harvestUuid
     * @param harvestUri
     * @throws Exception
     */
	public void setHarvestedExt(Dbms dbms, int id, String harvestUuid, String harvestUri) throws Exception {
		String value = (harvestUuid != null) ? "y" : "n";
		String query = "UPDATE Metadata SET isHarvested=?, harvestUuid=?, harvestUri=? WHERE id=?";
		dbms.execute(query, value, harvestUuid, harvestUri, id);
	}

    /**
     *
     * @return
     */
	public String getSiteURL() {
        String protocol = settingMan.getValue("system/server/protocol");
		String host    = settingMan.getValue("system/server/host");
		String port    = settingMan.getValue("system/server/port");
		String locServ = baseURL +"/"+ Jeeves.Prefix.SERVICE +"/en";

		return protocol + "://" + host + (port.equals("80") ? "" : ":" + port) + locServ;
	}

    /**
     *
     * @param md
     * @return
     */
	public String autodetectSchema(Element md) {
		
		Log.debug(Geonet.DATA_MANAGER, "Autodetect schema for metadata with :\n * root element:'" + md.getQualifiedName()
				 + "'\n * with namespace:'" + md.getNamespace()
				 + "\n * with additional namespaces:" + md.getAdditionalNamespaces().toString());
		String schema =  schemaMan.autodetectSchema(md);
		Log.debug(Geonet.DATA_MANAGER, "Schema detected was "+schema);
		return schema;
	}

    /**
     *
     * @param dbms
     * @param id
     * @param displayOrder
     * @throws Exception
     */
  public void updateDisplayOrder(Dbms dbms, String id, String displayOrder) throws Exception {
    String query = "UPDATE Metadata SET displayOrder = ? WHERE id = ?";
    dbms.execute(query, new Integer(displayOrder), new  Integer(id));
  }

    /**
     *
     * @param srvContext
     * @param id
     * @throws Exception hmm
     */
	public void increasePopularity(ServiceContext srvContext, String id) throws Exception {
		GeonetContext gc = (GeonetContext) srvContext.getHandlerContext(Geonet.CONTEXT_NAME);
		gc.getThreadPool().runTask(new IncreasePopularityTask(srvContext, id));
	}

    /**
     * Rates a metadata.
     * @param dbms
     * @param id
     * @param ipAddress ipAddress IP address of the submitting client
     * @param rating range should be 1..5
     * @return
     * @throws Exception hmm
     */
	public int rateMetadata(Dbms dbms, int id, String ipAddress, int rating) throws Exception {
		//
		// update rating on the database
		//
		String query = "UPDATE MetadataRating SET rating=? WHERE metadataId=? AND ipAddress=?";
		int res = dbms.execute(query, rating, id, ipAddress);

		if (res == 0) {
			query = "INSERT INTO MetadataRating(metadataId, ipAddress, rating) VALUES(?,?,?)";
			dbms.execute(query, id, ipAddress, rating);
		}

        //
		// calculate new rating
        //
		query = "SELECT sum(rating) as total FROM MetadataRating WHERE metadataId=?";
		List list = dbms.select(query, id).getChildren();
		String sum = ((Element) list.get(0)).getChildText("total");
		query = "SELECT count(*) as numr FROM MetadataRating WHERE metadataId=?";
		list  = dbms.select(query, id).getChildren();
		String count = ((Element) list.get(0)).getChildText("numr");
		rating = (int)(Float.parseFloat(sum) / Float.parseFloat(count) + 0.5);
		Log.debug(Geonet.DATA_MANAGER, "Setting rating for id:"+ id +" --> rating is:"+rating);
        //
		// update metadata and reindex it
        //
		query = "UPDATE Metadata SET rating=? WHERE id=?";
		dbms.execute(query, rating, id);
        boolean indexGroup = false;
        indexMetadata(dbms, Integer.toString(id), indexGroup,false);

		return rating;
	}

	//--------------------------------------------------------------------------
	//---
	//--- Metadata Insert API
	//---
	//--------------------------------------------------------------------------

    /**
     * Creates a new metadata duplicating an existing template.
     *
     * @param dbms
     * @param templateId
     * @param groupOwner
     * @param sf
     * @param source
     * @param owner
     * @param parentUuid
     * @param isTemplate TODO
     * @return
     * @throws Exception
     */
	public String createMetadata(Dbms dbms, String templateId, String groupOwner,
										  SerialFactory sf, String source, int owner,
										  String parentUuid, String isTemplate) throws Exception {
		String query = "SELECT schemaId, data FROM Metadata WHERE id="+ templateId;
		List listTempl = dbms.select(query).getChildren();

		if (listTempl.size() == 0) {
			throw new IllegalArgumentException("Template id not found : " + templateId);
        }
		Element el = (Element) listTempl.get(0);

		String schema = el.getChildText("schemaid");
		String data   = el.getChildText("data");
		String uuid   = UUID.randomUUID().toString();

		//--- generate a new metadata id
		int serial = sf.getSerial(dbms, "Metadata");
		
		// Update fixed info for metadata record only
		Element xml = Xml.loadString(data, false);
		if (isTemplate.equals('n')) {
		    xml = updateFixedInfo(schema, Integer.toString(serial), uuid, xml, parentUuid, DataManager.UpdateDatestamp.yes, dbms, null);
		}
		
		//--- store metadata
		String id = XmlSerializer.insert(dbms, schema, xml, serial, source, uuid, null, null, isTemplate, null, owner, groupOwner, "");
		copyDefaultPrivForGroup(dbms, id, groupOwner);

		//--- store metadata categories copying them from the template
		List categList = dbms.select("SELECT categoryId FROM MetadataCateg WHERE metadataId = "+templateId).getChildren();

        for (Object aCategList : categList) {
            Element elRec = (Element) aCategList;
            String catId = elRec.getChildText("categoryid");
            setCategory(dbms, id, catId);
        }

		//--- index metadata
        boolean indexGroup = false;
        indexMetadata(dbms, id, indexGroup,true);
		return id;
	}

    /**
     * Inserts a metadata into the database, optionally indexing it, and optionally applying automatic changes to it (update-fixed-info).
     *
     * @param dbms the database
     * @param schema XSD this metadata conforms to
     * @param metadata the metadata to store
     * @param id database id for new metadata record
     * @param uuid unique id for this metadata
     * @param owner user who owns this metadata
     * @param group group this metadata belongs to
     * @param source id of the origin of this metadata (harvesting source, etc.)
     * @param isTemplate whether this metadata is a template
     * @param docType ?!
     * @param title title of this metadata
     * @param category category of this metadata
     * @param createDate date of creation
     * @param changeDate date of modification
     * @param ufo whether to apply automatic changes
     * @param index whether to index this metadata
     * @return id, as a string
     * @throws Exception hmm
     */
    public String insertMetadata(Dbms dbms, String schema, Element metadata, int id, String uuid, int owner, String group, String source,
                                 String isTemplate, String docType, String title, String category, String createDate, String changeDate, boolean ufo, boolean index) throws Exception {

        // TODO resolve confusion about datatypes
        String id$ = Integer.toString(id);

        //--- force namespace prefix for iso19139 metadata
        setNamespacePrefixUsingSchemas(schema, metadata);

        if (ufo && isTemplate.equals("n")) {
            String parentUuid = null;
            metadata = updateFixedInfo(schema, Integer.toString(id), null, metadata, parentUuid, DataManager.UpdateDatestamp.no, dbms, null);
        }

         if (source == null) {
            source = getSiteID();
         }

        if(StringUtils.isBlank(isTemplate)) {
            isTemplate = "n";
        }

        //--- store metadata
        XmlSerializer.insert(dbms, schema, metadata, id, source, uuid, createDate, changeDate, isTemplate, title, owner, group, docType);

        copyDefaultPrivForGroup(dbms, id$, group);

        if (category != null) {
            setCategory(dbms, id$, category);
        }

        if(index) {
            boolean indexGroup = false;
            indexMetadata(dbms, id$, indexGroup,true);
        }

        // Notifies the metadata change to metatada notifier service
        notifyMetadataChange(dbms, metadata, id$);

        return id$;
    }

	//--------------------------------------------------------------------------
	//---
	//--- Metadata Get API
	//---
	//--------------------------------------------------------------------------

    /**
     * Retrieves a metadata (in xml) given its id with no geonet:info.
     * @param srvContext
     * @param id
     * @return
     * @throws Exception
     */
	public Element getMetadataNoInfo(ServiceContext srvContext, String id) throws Exception {
		Element md = getMetadata(srvContext, id, false, false, false);
		md.removeChild(Edit.RootChild.INFO, Edit.NAMESPACE);
		return md;
	}

    /**
     * Retrieves a metadata (in xml) given its id; adds editing information if requested and validation errors if requested.
     *
     * @param srvContext
     * @param id
     * @param forEditing
     * @param withEditorValidationErrors
     * @return
     * @throws Exception
     */
    public Element getMetadata(ServiceContext srvContext, String id, boolean forEditing, boolean withEditorValidationErrors) throws Exception {
        return getMetadata(srvContext,id,forEditing,withEditorValidationErrors,true);
    }

	public Element getMetadata(ServiceContext srvContext, String id, boolean forEditing, boolean withEditorValidationErrors, boolean elementsHide) throws Exception {
		Dbms dbms = (Dbms) srvContext.getResourceManager().open(Geonet.Res.MAIN_DB);
		boolean doXLinks = XmlSerializer.resolveXLinks();
		Element md = XmlSerializer.selectNoXLinkResolver(dbms, "Metadata", id);
		if (md == null) return null;

		String version = null;

		if (forEditing) { // copy in xlink'd fragments but leave xlink atts to editor
			if (doXLinks) Processor.processXLink(md,srvContext); 
			String schema = getMetadataSchema(dbms, id);
			
			if (withEditorValidationErrors) {
			    version = doValidate(srvContext.getUserSession(), dbms, schema, id, md, srvContext.getLanguage(), forEditing).two();
			}
            else {
                editLib.expandElements(schema, md);
                version = editLib.getVersionForEditing(schema, id, md);
            }
		}
        else {
			if (doXLinks) Processor.detachXLink(md,srvContext);
		}

		md.addNamespaceDeclaration(Edit.NAMESPACE);
		Element info = buildInfoElem(srvContext, id, version);
		md.addContent(info);

		md.detach();
		return md;
	}

    /**
     * Retrieves a metadata element given it's ref.
     *
     * @param md
     * @param ref
     * @return
     */
	public Element getElementByRef(Element md, String ref) {
		return editLib.findElement(md, ref);
	}

    /**
     * Returns true if the metadata exists in the database.
     * @param dbms
     * @param id
     * @return
     * @throws Exception
     */
	public boolean existsMetadata(Dbms dbms, int id) throws Exception {
		//FIXME : should use lucene
		List list = dbms.select("SELECT id FROM Metadata WHERE id="+ id).getChildren();
		return list.size() != 0;
	}

    /**
     * Returns true if the metadata uuid exists in the database.
     * @param dbms
     * @param uuid
     * @return
     * @throws Exception
     */
	public boolean existsMetadataUuid(Dbms dbms, String uuid) throws Exception {
		//FIXME : should use lucene

		List list = dbms.select("SELECT uuid FROM Metadata WHERE uuid='" + uuid + "'").getChildren();
		return list.size() != 0;
	}

    /**
     * Returns all the keywords in the system.
     *
     * @return
     * @throws Exception
     */
	public Element getKeywords() throws Exception {
		Vector keywords = searchMan.getTerms("keyword");
		Element el = new Element("keywords");

        for (Object keyword : keywords) {
            el.addContent(new Element("keyword").setText((String) keyword));
        }
		return el;
	}

	//--------------------------------------------------------------------------
	//---
	//--- Metadata Update API
	//---
	//--------------------------------------------------------------------------

    /**
     *  For update of owner info.
     *
     * @param dbms
     * @param id
     * @param owner
     * @param groupOwner
     * @throws Exception
     */
	public synchronized void updateMetadataOwner(Dbms dbms, int id, String owner, String groupOwner) throws Exception {
		dbms.execute("UPDATE Metadata SET owner=?, groupOwner=? WHERE id=?", new Integer(owner), new Integer(groupOwner), id);
	}

    /**
     * Updates a metadata record. Deletes validation report currently in session (if any). If user asks for validation the validation report will be (re-)created then.
     *
     * @param session
     * @param dbms
     * @param id
     * @param md
     * @param validate
     * @param lang
     * @param changeDate
     * @param minor
     *
     * @return
     * @throws Exception
     */
	public synchronized boolean updateMetadata(UserSession session, Dbms dbms, String id, Element md, boolean validate, boolean ufo, boolean index, String lang, String changeDate, String minor) throws Exception {
		// when invoked from harvesters, session is null
        if(session != null) {
            session.removeProperty(Geonet.Session.VALIDATION_REPORT + id);
        }
		String schema = getMetadataSchema(dbms, id);
        if(ufo) {
            String parentUuid = null;
		    md = updateFixedInfo(schema, id, null, md, parentUuid, DataManager.UpdateDatestamp.no, dbms, minor);
        }
        
        md = processSharedObjects(dbms, id, md);
        
		//--- write metadata to dbms
        XmlSerializer.update(dbms, id, md, changeDate, minor);

        String isTemplate = getMetadataTemplate(dbms, id);
        // Notifies the metadata change to metatada notifier service
        if (isTemplate.equals("n")) {
            // Notifies the metadata change to metatada notifier service
            notifyMetadataChange(dbms, md, id);
        }

		try {
    		//--- do the validation last - it throws exceptions
    		if (session != null && validate) {
    			doValidate(session, dbms, schema,id,md,lang, false);
    		}
		}
        finally {
            if(index) {
                //--- update search criteria
                boolean indexGroup = false;
                indexMetadata(dbms, id, indexGroup, false);
            }
		}
		return true;
	}

	public Element processSharedObjects(Dbms dbms, String id, Element md)
			throws Exception, SQLException {
		ProcessParams processParameters = new ProcessParams(dbms, ReusableObjectLogger.THREAD_SAFE_LOGGER, id, md, md, thesaurusMan, extentMan, baseURL, settingMan, false, null,servContext);
        List<Element> modified = reusableObjMan.process(processParameters);
        
        if(!modified.isEmpty()) {
            md = modified.get(0);
            dbms.commit();
        }
		return md;
	}

    /**
     * Validates an xml document, using autodetectschema to determine how.
     *
     * @param xml
     * @return true if metadata is valid
     */
    public boolean validate(Element xml) {
        String schema = autodetectSchema(xml);
        try {
            validate(schema, xml);
            return true;
        }
        // XSD validation error(s)
        catch (Exception x) {
            // do not print stacktrace as this is 'normal' program flow
            Log.debug(Geonet.DATA_MANAGER, "invalid metadata: " + x.getMessage());
            return false;
        }
    }

	/**
	 * Used by the validate embedded service. The validation report is stored in the session.
	 * 
	 * @param session
	 * @param schema
	 * @param id
	 * @param md
	 * @param lang
	 * @param forEditing TODO
	 * @return
	 * @throws Exception
	 */
	public Pair <Element, String> doValidate(UserSession session, Dbms dbms, String schema, String id, Element md, String lang, boolean forEditing) throws Exception {
	    String version = null;
		Log.debug(Geonet.DATA_MANAGER, "Creating validation report for record #" + id + " [schema: " + schema + "].");
		
		Element sessionReport = (Element)session.getProperty(Geonet.Session.VALIDATION_REPORT + id);		
		if (sessionReport != null && !forEditing) {
			Log.debug(Geonet.DATA_MANAGER, "  Validation report available in session.");
			sessionReport.detach();
			return Pair.read(sessionReport, version);
		}
		
	    Map <String, Integer[]> valTypeAndStatus = new HashMap<String, Integer[]>();
		Element errorReport = new Element ("report", Edit.NAMESPACE);
		errorReport.setAttribute("id", id, Edit.NAMESPACE);

		//-- get an XSD validation report and add results to the metadata 
		//-- as geonet:xsderror attributes on the affected elements 
		Element xsdErrors = getXSDXmlReport(schema,md);
		if (xsdErrors != null && xsdErrors.getContent().size() > 0) {
			errorReport.addContent(xsdErrors);
			Integer[] results = {0, 0, 0};
			valTypeAndStatus.put("xsd", results);
		     Log.debug(Geonet.DATA_MANAGER, "  - XSD error: " + Xml.getString(xsdErrors));
		}
        else {
		    Integer[] results = {1, 0, 0};
		    valTypeAndStatus.put("xsd", results);
		}

		// ...then schematrons
		Element schematronError;
		
		// edit mode
        if (forEditing) {
              Log.debug(Geonet.DATA_MANAGER, "  - Schematron in editing mode.");
              //-- now expand the elements and add the geonet: elements
              editLib.expandElements(schema, md);
              version = editLib.getVersionForEditing(schema, id, md);
                    
              //-- get a schematron error report if no xsd errors and add results
              //-- to the metadata as a geonet:schematronerrors element with 
              //-- links to the ref id of the affected element
              schematronError = getSchemaTronXmlReport(schema, md, lang, valTypeAndStatus);
              if (schematronError != null) {
                  md.addContent((Element)schematronError.clone());
                  Log.debug(Geonet.DATA_MANAGER, "  - Schematron error: " + Xml.getString(schematronError));
              }
		}
        else {
	        // enumerate the metadata xml so that we can report any problems found 
	        // by the schematron_xml script to the geonetwork editor
	        editLib.enumerateTree(md);

	        // get an xml version of the schematron errors and return for error display
	        schematronError = getSchemaTronXmlReport(schema, md, lang, valTypeAndStatus);

	        // remove editing info added by enumerateTree
	        editLib.removeEditingInfo(md);
		}
        
        if (schematronError != null && schematronError.getContent().size() > 0) {
            Element schematron = new Element("schematronerrors", Edit.NAMESPACE);
            Element idElem = new Element("id", Edit.NAMESPACE);
            idElem.setText(id);
            schematron.addContent(idElem);
            errorReport.addContent(schematronError);
            //throw new SchematronValidationErrorEx("Schematron errors detected - see schemaTron report for "+id+" in htmlCache for more details",schematron);
        }
        
        // Save report in session (invalidate by next update) and db
   		session.setProperty(Geonet.Session.VALIDATION_REPORT + id, errorReport);
		saveValidationStatus(dbms, id, valTypeAndStatus, new ISODate().toString());
   		
		return Pair.read(errorReport, version);
	}
	
	/**
	 * Saves validation status information into the database for the current record.
	 * 
	 * @param id   the metadata record internal identifier
	 * @param valTypeAndStatus  the validation type could be xsd or schematron rules set identifier
	 * @param date the validation date time
	 */
	private void saveValidationStatus (Dbms dbms, String id, Map<String, Integer[]> valTypeAndStatus, String date) throws Exception {
	    clearValidationStatus(dbms, id);
	    Set<String> i = valTypeAndStatus.keySet();
	    for (String type : i) {
	        String query = "INSERT INTO Validation (metadataId, valType, status, tested, failed, valDate) VALUES (?,?,?,?,?,?)";
            Integer[] results = valTypeAndStatus.get(type);
            dbms.execute(query, new Integer(id), type, results[0], results[1], results[2], date);
        }
        dbms.commit();
	}

	/**
	 * Removes validation status information for a metadata record.
     *
	 * @param dbms
	 * @param id   the metadata record internal identifier
	 */
	private void clearValidationStatus (Dbms dbms, String id) throws Exception {
	    dbms.execute("DELETE FROM Validation WHERE metadataId=?", new Integer(id));
	    dbms.commit();
	}

	/**
	 * Return the validation status information for the metadata record.
     *
	 * @param dbms
	 * @param id   the metadata record internal identifier
	 * @return
	 */
	private List<Element> getValidationStatus (Dbms dbms, String id) throws Exception {
	    return dbms.select("SELECT valType, status, tested, failed FROM Validation WHERE metadataId=?", new Integer(id)).getChildren();
    }

	//--------------------------------------------------------------------------
	//---
	//--- Metadata Delete API
	//---
	//--------------------------------------------------------------------------

    /**
     * Removes a metadata.
     *
     * @param dbms
     * @param id
     * @throws Exception
     */
	public void deleteMetadata(Dbms dbms, String id) throws Exception {
        String uuid = getMetadataUuid(dbms, id);
        String isTemplate = getMetadataTemplate(dbms, id);

		//--- remove operations
		deleteMetadataOper(dbms, id, false);

		//--- remove categories
		deleteAllMetadataCateg(dbms, id);

		dbms.execute("DELETE FROM MetadataRating WHERE metadataId=?", new Integer(id));
		dbms.execute("DELETE FROM Validation WHERE metadataId=?", new Integer(id));

		//--- remove metadata
		XmlSerializer.delete(dbms, "Metadata", id);

        // Notifies the metadata change to metatada notifier service
        if (isTemplate.equals("n")) {
            notifyMetadataDelete(dbms, id, uuid);
        }

		//--- update search criteria
		searchMan.delete("_id", id+"");
	}

    /**
     *
     * @param dbms
     * @param id
     * @throws Exception
     */
	public synchronized void deleteMetadataGroup(Dbms dbms, String id) throws Exception {
		//--- remove operations
		deleteMetadataOper(dbms, id, false);

		//--- remove categories
		deleteAllMetadataCateg(dbms, id);

		dbms.execute("DELETE FROM MetadataRating WHERE metadataId=?", new Integer(id));
        dbms.execute("DELETE FROM Validation WHERE metadataId=?", new Integer(id));

		//--- remove metadata
		XmlSerializer.delete(dbms, "Metadata", id);

		//--- update search criteria
		searchMan.deleteGroup("_id", id+"");
	}

    /**
     * Removes all operations stored for a metadata.
     * @param dbms
     * @param id
     * @param skipAllIntranet
     * @throws Exception
     */
	public void deleteMetadataOper(Dbms dbms, String id, boolean skipAllIntranet) throws Exception {
		String query = "DELETE FROM OperationAllowed WHERE metadataId=?";

		if (skipAllIntranet)
			query += " AND groupId>1";

		dbms.execute(query, new Integer(id));
	}

    /**
     * Removes all categories stored for a metadata.
     *
     * @param dbms
     * @param id
     * @throws Exception
     */
	public void deleteAllMetadataCateg(Dbms dbms, String id) throws Exception {
		String query = "DELETE FROM MetadataCateg WHERE metadataId=?";

		dbms.execute(query, new Integer(id));
	}

	//--------------------------------------------------------------------------
	//---
	//--- Metadata thumbnail API
	//---
	//--------------------------------------------------------------------------

    /**
     *
     * @param dbms
     * @param id
     * @return
     * @throws Exception
     */
	public Element getThumbnails(Dbms dbms, String id) throws Exception {
		Element md = XmlSerializer.select(dbms, "Metadata", id,servContext);

		if (md == null)
			return null;

		md.detach();

		String schema = getMetadataSchema(dbms, id);

		//--- do an XSL  transformation
		String styleSheet = getSchemaDir(schema) + Geonet.File.EXTRACT_THUMBNAILS;

		Element result = Xml.transform(md, styleSheet);
		result.addContent(new Element("id").setText(id));

		return result;
	}

    /**
     *
     * @param dbms
     * @param id
     * @param small
     * @param file
     * @throws Exception
     */
	public void setThumbnail(Dbms dbms, String id, boolean small, String file) throws Exception {
		int    pos = file.lastIndexOf('.');
		String ext = (pos == -1) ? "???" : file.substring(pos +1);

		Element env = new Element("env");
		env.addContent(new Element("file").setText(file));
		env.addContent(new Element("ext").setText(ext));

		manageThumbnail(dbms, id, small, env, Geonet.File.SET_THUMBNAIL);
	}

    /**
     *
     * @param dbms
     * @param id
     * @param small
     * @throws Exception
     */
	public void unsetThumbnail(Dbms dbms, String id, boolean small) throws Exception {
		Element env = new Element("env");

		manageThumbnail(dbms, id, small, env, Geonet.File.UNSET_THUMBNAIL);
	}

    /**
     *
     * @param dbms
     * @param id
     * @param small
     * @param env
     * @param styleSheet
     * @throws Exception
     */
	private void manageThumbnail(Dbms dbms, String id, boolean small, Element env,
										  String styleSheet) throws Exception {
		Element md = XmlSerializer.select(dbms, "Metadata", id,servContext);

		if (md == null)
			return;

		md.detach();

		String schema = getMetadataSchema(dbms, id);

		//--- remove thumbnail from metadata

		//--- setup environment
		String type = small ? "thumbnail" : "large_thumbnail";
		env.addContent(new Element("type").setText(type));
		transformMd(dbms,id,md,env,schema,styleSheet);
	}

    /**
     *
     * @param dbms
     * @param id
     * @param md
     * @param env
     * @param schema
     * @param styleSheet
     * @throws Exception
     */
	private void transformMd(Dbms dbms, String id, Element md, Element env, String schema, String styleSheet) throws Exception {
		//--- setup root element
		Element root = new Element("root");
		root.addContent(md);
		root.addContent(env);

		//--- do an XSL  transformation
		styleSheet = getSchemaDir(schema) + styleSheet;

		md = Xml.transform(root, styleSheet);
        String changeDate = null;
		XmlSerializer.update(dbms, id, md, changeDate, null);

        // Notifies the metadata change to metatada notifier service
        notifyMetadataChange(dbms, md, id);

		//--- update search criteria
        boolean indexGroup = false;
        indexMetadata(dbms, id, indexGroup,true);

	}

    /**
     *
     * @param dbms
     * @param id
     * @param licenseurl
     * @param imageurl
     * @param jurisdiction
     * @param licensename
     * @param type
     * @throws Exception
     */
	public void setDataCommons(Dbms dbms, String id, String licenseurl, String imageurl, String jurisdiction, String licensename, String type) throws Exception {
		Element env = new Element("env");
		env.addContent(new Element("imageurl").setText(imageurl));
		env.addContent(new Element("licenseurl").setText(licenseurl));
		env.addContent(new Element("jurisdiction").setText(jurisdiction));
		env.addContent(new Element("licensename").setText(licensename));
		env.addContent(new Element("type").setText(type));

		manageCommons(dbms,id,env,Geonet.File.SET_DATACOMMONS);
	}

    /**
     *
     * @param dbms
     * @param id
     * @param licenseurl
     * @param imageurl
     * @param jurisdiction
     * @param licensename
     * @param type
     * @throws Exception
     */
	public void setCreativeCommons(Dbms dbms, String id, String licenseurl, String imageurl, String jurisdiction, String licensename, String type) throws Exception {
		Element env = new Element("env");
		env.addContent(new Element("imageurl").setText(imageurl));
		env.addContent(new Element("licenseurl").setText(licenseurl));
		env.addContent(new Element("jurisdiction").setText(jurisdiction));
		env.addContent(new Element("licensename").setText(licensename));
		env.addContent(new Element("type").setText(type));

		manageCommons(dbms,id,env,Geonet.File.SET_CREATIVECOMMONS);
	}

    /**
     *
     * @param dbms
     * @param id
     * @param env
     * @param styleSheet
     * @throws Exception
     */
	private void manageCommons(Dbms dbms, String id, Element env, String styleSheet) throws Exception {
		Element md = XmlSerializer.select(dbms, "Metadata", id,servContext);

		if (md == null) {
			return;
        }

		md.detach();

		String schema = getMetadataSchema(dbms, id);
		transformMd(dbms,id,md,env,schema,styleSheet);
	}

	//--------------------------------------------------------------------------
	//---
	//--- Privileges API
	//---
	//--------------------------------------------------------------------------

    /**
     *  Adds a permission to a group. Metadata is not reindexed.
     *
     * @param dbms
     * @param mdId
     * @param grpId
     * @param opId
     * @throws Exception
     */
	public void setOperation(Dbms dbms, String mdId, String grpId, String opId) throws Exception {
		setOperation(dbms,new Integer(mdId),new Integer(grpId),new Integer(opId));
	}

    /**
     *
     * @param dbms
     * @param mdId
     * @param grpId
     * @param opId
     * @throws Exception
     */
	public void setOperation(Dbms dbms, int mdId, int grpId, int opId) throws Exception {
		String query = "SELECT metadataId FROM OperationAllowed WHERE metadataId=? AND groupId=? AND operationId=?";
		Element elRes = dbms.select(query, mdId, grpId, opId);
		if (elRes.getChildren().size() == 0) {
			dbms.execute("INSERT INTO OperationAllowed(metadataId, groupId, operationId) VALUES(?,?,?)", mdId, grpId, opId);
		}
	}

    /**
     *
     * @param dbms
     * @param mdId
     * @param grpId
     * @param opId
     * @throws Exception
     */
	public void unsetOperation(Dbms dbms, String mdId, String grpId, String opId) throws Exception {
		unsetOperation(dbms,new Integer(mdId),new Integer(grpId),new Integer(opId));
	}

    /**
     *
     * @param dbms dbms
     * @param mdId metadata id
     * @param groupId group id
     * @param operId operation id
     * @throws Exception hmm
     */
	public void unsetOperation(Dbms dbms, int mdId, int groupId, int operId) throws Exception {
		String query = "DELETE FROM OperationAllowed WHERE metadataId=? AND groupId=? AND operationId=?";
		dbms.execute(query, mdId, groupId, operId);
	}

    /**
     * Sets VIEW and NOTIFY privileges for a metadata to a group.
     *
     * @param dbms the database
     * @param id metadata id
     * @param groupId group id
     * @throws Exception hmmm
     */
	public void copyDefaultPrivForGroup(Dbms dbms, String id, String groupId) throws Exception {
        if(StringUtils.isBlank(groupId)) {
            Log.info(Geonet.DATA_MANAGER, "Attempt to set default privileges for metadata " + id + " to an empty groupid");
            return;
        }
		//--- store access operations for group

		setOperation(dbms, id, groupId, AccessManager.OPER_VIEW);
		setOperation(dbms, id, groupId, AccessManager.OPER_NOTIFY);
		//
		// Restrictive: new and inserted records should not be editable, 
		// their resources can't be downloaded and any interactive maps can't be 
		// displayed by users in the same group 
		// setOperation(dbms, id, groupId, AccessManager.OPER_EDITING);
		// setOperation(dbms, id, groupId, AccessManager.OPER_DOWNLOAD);
		// setOperation(dbms, id, groupId, AccessManager.OPER_DYNAMIC);
		// Ultimately this should be configurable elsewhere
	}

	//--------------------------------------------------------------------------
	//---
	//--- Categories API
	//---
	//--------------------------------------------------------------------------

    /**
     * Adds a category to a metadata. Metadata is not reindexed.
     * @param dbms
     * @param mdId
     * @param categId
     * @throws Exception
     */
	public void setCategory(Dbms dbms, String mdId, String categId) throws Exception {
		Object args[] = { new Integer(mdId), new Integer(categId) };

		if (!isCategorySet(dbms, mdId, categId))
			dbms.execute("INSERT INTO MetadataCateg(metadataId, categoryId) VALUES(?,?)", args);
	}

    /**
     *
     * @param dbms
     * @param mdId
     * @param categId
     * @return
     * @throws Exception
     */
	public boolean isCategorySet(Dbms dbms, String mdId, String categId) throws Exception {
		String query = "SELECT metadataId FROM MetadataCateg " +"WHERE metadataId=? AND categoryId=?";
		Element elRes = dbms.select(query, new Integer(mdId), new Integer(categId));
		return (elRes.getChildren().size() != 0);
	}

    /**
     *
     * @param dbms
     * @param mdId
     * @param categId
     * @throws Exception
     */
	public void unsetCategory(Dbms dbms, String mdId, String categId) throws Exception {
		String query = "DELETE FROM MetadataCateg WHERE metadataId=? AND categoryId=?";
		dbms.execute(query, new Integer(mdId), new Integer(categId));
	}

    /**
     *
     * @param dbms
     * @param mdId
     * @return
     * @throws Exception
     */
	public Element getCategories(Dbms dbms, String mdId) throws Exception {
		String query = "SELECT id, name FROM Categories, MetadataCateg WHERE id=categoryId AND metadataId=?";
		return dbms.select(query, new Integer(mdId));
	}

    /**
     * Update metadata record (not template) using update-fixed-info.xsl
     * 
     * 
     * @param schema
     * @param id
     * @param uuid If the metadata is a new record (not yet saved), provide the uuid for that record
     * @param md
     * @param parentUuid
     * @param updateDatestamp
     * @param dbms
     * @param minor
     * @return
     * @throws Exception
     */
	public Element updateFixedInfo(String schema, String id, String uuid, Element md, String parentUuid, UpdateDatestamp updateDatestamp, Dbms dbms, String minor) throws Exception {
        boolean autoFixing = settingMan.getValueAsBool("system/autofixing/enable", true);
        if(autoFixing) {
        	Log.debug(Geonet.DATA_MANAGER, "Autofixing is enabled, trying update-fixed-info");
            
        	String query = "SELECT uuid, isTemplate FROM Metadata WHERE id = " + id;
            Element rec = dbms.select(query).getChild("record");
            Boolean isTemplate = rec != null && !rec.getChildText("istemplate").equals("n");
            
            // don't process templates
            if(isTemplate) {
                Log.debug(Geonet.DATA_MANAGER, "Not applying update-fixed-info for a template");
                return md;
            }
            else {
                uuid = uuid == null ? rec.getChildText("uuid") : uuid;
                
                //--- setup environment
                Element env = new Element("env");
                env.addContent(new Element("id").setText(id));
                env.addContent(new Element("uuid").setText(uuid));
                if (minor != null) {
                    if (!minor.equals("")) {
                        env.addContent(new Element("changeDate").setText(new ISODate().toString()));
                    }
                }
                if(parentUuid != null) {
                    env.addContent(new Element("parentUuid").setText(parentUuid));
                }
                env.addContent(new Element("updateDateStamp").setText(updateDatestamp.name()));
                env.addContent(new Element("datadir").setText(Lib.resource.getDir(dataDir, Params.Access.PRIVATE, id)));

                // add original metadata to result
                Element result = new Element("root");
                result.addContent(md);
                // add 'environment' to result
                env.addContent(new Element("siteURL")   .setText(getSiteURL()));
                Element system = settingMan.get("system", -1);
                env.addContent(Xml.transform(system, appPath + Geonet.Path.STYLESHEETS+ "/xml/config.xsl"));
                result.addContent(env);
                // apply update-fixed-info.xsl
                String styleSheet = getSchemaDir(schema) + Geonet.File.UPDATE_FIXED_INFO;
                result = Xml.transform(result, styleSheet);
                return result;
            }
        }
        else {
            Log.debug(Geonet.DATA_MANAGER, "Autofixing is disabled, not applying update-fixed-info");
            return md;
        }
	}

    /**
     * Retrieves the unnotified metadata to update/insert for a notifier service
     *
     * @param dbms
     * @param notifierId
     * @return
     * @throws Exception
     */
    public Map<String,Element> getUnnotifiedMetadata(Dbms dbms, String notifierId) throws Exception {
        Log.debug(Geonet.DATA_MANAGER, "getUnnotifiedMetadata start");
        Map<String,Element> unregisteredMetadata = new HashMap<String,Element>();

        String query = "select m.id, m.uuid, m.data, mn.notifierId, mn.action from metadata m left join metadatanotifications mn on m.id = mn.metadataId\n" +
                "where (mn.notified is null or mn.notified = 'n') and (mn.action <> 'd') and (mn.notifierId is null or mn.notifierId = " + notifierId + ")";
        List<Element> results = dbms.select(query).getChildren();
        Log.debug(Geonet.DATA_MANAGER, "getUnnotifiedMetadata after select: " + (results != null));

        if (results != null) {
          for(Element result : results) {
              String uuid = result.getChild("uuid").getText();
              System.out.println("getUnnotifiedMetadata: " + uuid);
              unregisteredMetadata.put(uuid, (Element)((Element)result.clone()).detach());
          }
        }

        Log.debug(Geonet.DATA_MANAGER, "getUnnotifiedMetadata returning #" + unregisteredMetadata.size() + " results");
        return unregisteredMetadata;
    }

    /**
     * Retrieves the unnotified metadata to delete for a notifier service
     *
     * @param dbms
     * @param notifierId
     * @return
     * @throws Exception
     */
    public Map<String,Element> getUnnotifiedMetadataToDelete(Dbms dbms, String notifierId) throws Exception {
        Log.debug(Geonet.DATA_MANAGER, "getUnnotifiedMetadataToDelete start");
        Map<String,Element> unregisteredMetadata = new HashMap<String,Element>();
        Log.debug(Geonet.DATA_MANAGER, "getUnnotifiedMetadataToDelete after dbms");

        String query = "select metadataId as id, metadataUuid as uuid, notifierId, action from metadatanotifications " +
                "where (notified = 'n') and (action = 'd') and (notifierId = " + notifierId + ")";
        List<Element> results = dbms.select(query).getChildren();
        Log.debug(Geonet.DATA_MANAGER, "getUnnotifiedMetadataToDelete after select: " + (results != null));

        if (results != null) {
          for(Element result : results) {
              String uuid = result.getChild("uuid").getText();
              System.out.println("getUnnotifiedMetadataToDelete: " + uuid);
              unregisteredMetadata.put(uuid, (Element)((Element)result.clone()).detach());

          }
        }

        Log.debug(Geonet.DATA_MANAGER, "getUnnotifiedMetadataToDelete returning #" + unregisteredMetadata.size() + " results");
        return unregisteredMetadata;
    }

    /**
     * Marks a metadata record as notified for a notifier service.
     *
     * @param metadataId    Metadata identifier
     * @param notifierId    Notifier service identifier
     * @param deleteNotification    Indicates if the notification was a delete action
     * @param dbms
     * @throws Exception
     */
    public void setMetadataNotified(String metadataId, String metadataUuid, String notifierId, boolean deleteNotification, Dbms dbms) throws Exception {
        String query = "DELETE FROM MetadataNotifications WHERE metadataId=? AND notifierId=?";
        dbms.execute(query, new Integer(metadataId), new Integer(notifierId));
        dbms.commit();

        if (!deleteNotification) {
            query = "INSERT INTO MetadataNotifications (metadataId, notifierId, metadataUuid, notified, action) VALUES (?,?,?,?,?)";
            dbms.execute(query, new Integer(metadataId), new Integer(notifierId), metadataUuid, "y", "u");
            dbms.commit();
        }

        Log.debug(Geonet.DATA_MANAGER, "setMetadataNotified finished for metadata with id " + metadataId + "and notitifer with id " + notifierId);
    }

    /**
     * Marks a metadata record as notified for a notifier service.
     *
     * @param metadataId    Metadata identifier
     * @param notifierId    Notifier service identifier
     * @param dbms
     * @throws Exception
     */
    public void setMetadataNotifiedError(String metadataId, String metadataUuid, String notifierId, boolean deleteNotification, String error, Dbms dbms) throws Exception {
        System.out.println("setMetadataNotifiedError");
       try {
       String query = "DELETE FROM MetadataNotifications WHERE metadataId=? AND notifierId=?";
       dbms.execute(query, new Integer(metadataId), new Integer(notifierId));

       String action = (deleteNotification == true)?"d":"u";
       query = "INSERT INTO MetadataNotifications (metadataId, notifierId, metadataUuid, notified, action, errormsg) VALUES (?,?,?,?,?,?)";
       dbms.execute(query, new Integer(metadataId), new Integer(notifierId), metadataUuid, "n", action, error);
       dbms.commit();

       Log.debug(Geonet.DATA_MANAGER, "setMetadataNotifiedError finished for metadata with id " + metadataId + "and notitifer with id " + notifierId);
       } catch (Exception ex) {
           ex.printStackTrace();
           throw ex;
       }
    }

    /**
     *
     * @param dbms
     * @return
     * @throws Exception
     */
    public List<Element> retrieveNotifierServices(Dbms dbms) throws Exception {
        String query = "SELECT id, url, username, password FROM MetadataNotifiers WHERE enabled = 'y'";
        return dbms.select(query).getChildren();
    }

	
	/**
	 * Updates all children of the selected parent. Some elements are protected
	 * in the children according to the stylesheet used in
	 * xml/schemas/[SCHEMA]/update-child-from-parent-info.xsl.
	 * 
	 * Children MUST be editable and also in the same schema of the parent. 
	 * If not, child is not updated. 
	 * 
	 * @param srvContext
	 *            service context
	 * @param parentUuid
	 *            parent uuid
	 * @param params
	 *            parameters
	 * @param children
	 *            children
	 * @return
	 * @throws Exception
	 */
	public Set<String> updateChildren(ServiceContext srvContext, String parentUuid, String[] children, Map<String, String> params) throws Exception {
		Dbms dbms = (Dbms) srvContext.getResourceManager().open(Geonet.Res.MAIN_DB);

		String parentId = params.get(Params.ID);
		String parentSchema = params.get(Params.SCHEMA);

		// --- get parent metadata in read/only mode
        boolean forEditing = false, withValidationErrors = false;
        Element parent = getMetadata(srvContext, parentId, forEditing, withValidationErrors,false);

		Element env = new Element("update");
		env.addContent(new Element("parentUuid").setText(parentUuid));
		env.addContent(new Element("siteURL").setText(getSiteURL()));
		env.addContent(new Element("parent").addContent(parent));

		// Set of untreated children (out of privileges, different schemas)
		Set<String> untreatedChildSet = new HashSet<String>();

		// only get iso19139 records
		for (String childId : children) {

			// Check privileges
			if (!accessMan.canEdit(srvContext, childId)) {
				untreatedChildSet.add(childId);
				Log.debug(Geonet.DATA_MANAGER, "Could not update child ("
						+ childId + ") because of privileges.");
				continue;
			}

            Element child = getMetadata(srvContext, childId, forEditing, withValidationErrors, false);

			String childSchema = child.getChild(Edit.RootChild.INFO,
					Edit.NAMESPACE).getChildText(Edit.Info.Elem.SCHEMA);

			// Check schema matching. CHECKME : this suppose that parent and
			// child are in the same schema (even not profil different)
			if (!childSchema.equals(parentSchema)) {
				untreatedChildSet.add(childId);
				Log.debug(Geonet.DATA_MANAGER, "Could not update child ("
						+ childId + ") because schema (" + childSchema
						+ ") is different from the parent one (" + parentSchema
						+ ").");
				continue;
			}

			Log.debug(Geonet.DATA_MANAGER, "Updating child (" + childId +") ...");

			// --- setup xml element to be processed by XSLT

			Element rootEl = new Element("root");
			Element childEl = new Element("child").addContent(child.detach());
			rootEl.addContent(childEl);
			rootEl.addContent(env.detach());

			// --- do an XSL transformation

			String styleSheet = getSchemaDir(parentSchema)
					+ Geonet.File.UPDATE_CHILD_FROM_PARENT_INFO;
			Element childForUpdate = new Element("root");
			childForUpdate = Xml.transform(rootEl, styleSheet, params);
			
			XmlSerializer.update(dbms, childId, childForUpdate, new ISODate().toString(), null);


            // Notifies the metadata change to metatada notifier service
            notifyMetadataChange(dbms, childForUpdate, childId);

			rootEl = null;
		}

		return untreatedChildSet;
	}

    /**
     * TODO : buildInfoElem contains similar portion of code with indexMetadata
     * @param context
     * @param id
     * @param version
     * @return
     * @throws Exception
     */
	private Element buildInfoElem(ServiceContext context, String id, String version) throws Exception {
		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

		String query ="SELECT schemaId, createDate, changeDate, source, isTemplate, title, "+
									"uuid, isHarvested, harvestUuid, popularity, rating, owner, displayOrder FROM Metadata WHERE id = " + id;

		// add Metadata table infos: schemaId, createDate, changeDate, source,
		Element rec = dbms.select(query).getChild("record");

		String  schema     = rec.getChildText("schemaid");
		String  createDate = rec.getChildText("createdate");
		String  changeDate = rec.getChildText("changedate");
		String  source     = rec.getChildText("source");
		String  isTemplate = rec.getChildText("istemplate");
		String  title      = rec.getChildText("title");
		String  uuid       = rec.getChildText("uuid");
		String  isHarvested= rec.getChildText("isharvested");
		String  harvestUuid= rec.getChildText("harvestuuid");
		String  popularity = rec.getChildText("popularity");
		String  rating     = rec.getChildText("rating");
		String  owner      = rec.getChildText("owner");
                String  displayOrder = rec.getChildText("displayorder");

		Element info = new Element(Edit.RootChild.INFO, Edit.NAMESPACE);

		addElement(info, Edit.Info.Elem.ID,          id);
		addElement(info, Edit.Info.Elem.SCHEMA,      schema);
		addElement(info, Edit.Info.Elem.CREATE_DATE, createDate);
		addElement(info, Edit.Info.Elem.CHANGE_DATE, changeDate);
		addElement(info, Edit.Info.Elem.IS_TEMPLATE, isTemplate);
		addElement(info, Edit.Info.Elem.TITLE,       title);
		addElement(info, Edit.Info.Elem.SOURCE,      source);
		addElement(info, Edit.Info.Elem.UUID,        uuid);
		addElement(info, Edit.Info.Elem.IS_HARVESTED,isHarvested);
		addElement(info, Edit.Info.Elem.POPULARITY,  popularity);
		addElement(info, Edit.Info.Elem.RATING,      rating);
                addElement(info, Edit.Info.Elem.DISPLAY_ORDER,  displayOrder);

		if (isHarvested.equals("y"))
			info.addContent(harvestMan.getHarvestInfo(harvestUuid, id, uuid));

		if (version != null)
			addElement(info, Edit.Info.Elem.VERSION, version);

		// add operations
		Element operations = accessMan.getAllOperations(context, id, context.getIpAddress());
		HashSet<String> hsOper = accessMan.getOperations(context, id, context.getIpAddress(), operations);

		addElement(info, Edit.Info.Elem.VIEW,     			String.valueOf(hsOper.contains(AccessManager.OPER_VIEW)));
		addElement(info, Edit.Info.Elem.NOTIFY,   			String.valueOf(hsOper.contains(AccessManager.OPER_NOTIFY)));
		addElement(info, Edit.Info.Elem.DOWNLOAD, 			String.valueOf(hsOper.contains(AccessManager.OPER_DOWNLOAD)));
		addElement(info, Edit.Info.Elem.DYNAMIC,  			String.valueOf(hsOper.contains(AccessManager.OPER_DYNAMIC)));
		addElement(info, Edit.Info.Elem.FEATURED, 			String.valueOf(hsOper.contains(AccessManager.OPER_FEATURED)));


		if (!hsOper.contains(AccessManager.OPER_DOWNLOAD)) {
			boolean gDownload = Xml.selectNodes(operations, "guestoperations/record[operationid="+AccessManager.OPER_DOWNLOAD+" and groupid='-1']").size() == 1;
			addElement(info, Edit.Info.Elem.GUEST_DOWNLOAD, gDownload+"");
		}

		if (accessMan.canEdit(context, id))
			addElement(info, Edit.Info.Elem.EDIT, "true");

		if (accessMan.isOwner(context, id)) {
			addElement(info, Edit.Info.Elem.OWNER, "true");
		}

        if(accessMan.isVisibleToAll(dbms, id)) {
            addElement(info, Edit.Info.Elem.IS_PUBLISHED_TO_ALL, "true");
        }
        else {
            addElement(info, Edit.Info.Elem.IS_PUBLISHED_TO_ALL, "false");
        }

		// add owner name
		query = "SELECT username FROM Users WHERE id = " + owner;
		Element record = dbms.select(query).getChild("record");
		if (record != null) {
			String ownerName = record.getChildText("username");
			addElement(info, Edit.Info.Elem.OWNERNAME, ownerName);
		}

		// add categories
		List categories = dbms.select("SELECT id, name FROM MetadataCateg, Categories "+
												"WHERE metadataId = " + id + " AND categoryId = id ORDER BY id").getChildren();

        for (Object category1 : categories) {
            Element category = (Element) category1;
            addElement(info, Edit.Info.Elem.CATEGORY, category.getChildText("name"));
        }

		// add subtemplates
		/* -- don't add as we need to investigate indexing for the fields 
		   -- in the metadata table used here
		List subList = getSubtemplates(dbms, schema);
		if (subList != null) {
			Element subs = new Element(Edit.Info.Elem.SUBTEMPLATES);
			subs.addContent(subList);
			info.addContent(subs);
		}
		*/


        // Add validity information
        List<Element> validationInfo = getValidationStatus(dbms, id);
        if (validationInfo == null || validationInfo.size() == 0) {
            addElement(info, Edit.Info.Elem.VALID, "-1");
        } else {
            String isValid = "1";
            for (Object elem : validationInfo) {
                Element vi = (Element) elem;
                String type = vi.getChildText("valtype");
                String status = vi.getChildText("status");
                if ("0".equals(status)) {
                    isValid = "0";
                }
                String ratio = "xsd".equals(type) ? "" : vi.getChildText("failed") + "/" + vi.getChildText("tested");
                
                info.addContent(new Element(Edit.Info.Elem.VALID + "_details").
                        addContent(new Element("type").setText(type)).
                        addContent(new Element("status").setText(status)).
                        addContent(new Element("ratio").setText(ratio))
                        );
            }
            addElement(info, Edit.Info.Elem.VALID, isValid);
        }
        
		// add baseUrl of this site (from settings)
        String protocol = settingMan.getValue("system/server/protocol");
		String host    = settingMan.getValue("system/server/host");
		String port    = settingMan.getValue("system/server/port");
		addElement(info, Edit.Info.Elem.BASEURL, protocol + "://" + host + (port == "80" ? "" : ":" + port) + baseURL);
		addElement(info, Edit.Info.Elem.LOCSERV, "/srv/en" );
		return info;
	}

    /**
     *
     * @param root
     * @param name
     * @param value
     */
	private static void addElement(Element root, String name, String value) {
		root.addContent(new Element(name).setText(value));
	}

    /**
     *
     * @return
     */
	public String getSiteID() {
		return settingMan.getValue("system/site/siteId");
	}

	
	//---------------------------------------------------------------------------
	//---
	//--- Static methods are for external modules like GAST to be able to use
	//--- them.
	//---
	//---------------------------------------------------------------------------

    /**
     *
     * @param md
     */
	public static void setNamespacePrefix(Element md){
		//--- if the metadata has no namespace or already has a namespace then
		//--- we must skip this phase

		Namespace ns = md.getNamespace();
    if (ns == Namespace.NO_NAMESPACE || (!md.getNamespacePrefix().equals("")))
      return;
		//--- set prefix for iso19139 metadata

		ns = Namespace.getNamespace("gmd", md.getNamespace().getURI());
		setNamespacePrefix(md, ns);
	}

    /**
     *
     * @param md
     * @param ns
     */
	private static void setNamespacePrefix(Element md, Namespace ns) {
		if (md.getNamespaceURI().equals(ns.getURI()))
			md.setNamespace(ns);

		for (Object o : md.getChildren())
			setNamespacePrefix((Element) o, ns);
	}

    /**
     *
     * @param md
     * @throws Exception
     */
	private void setNamespacePrefixUsingSchemas(String schema, Element md) throws Exception {
		//--- if the metadata has no namespace or already has a namespace prefix
		//--- then we must skip this phase

		Namespace ns = md.getNamespace();
    if (ns == Namespace.NO_NAMESPACE)  
      return;

		MetadataSchema mds = schemaMan.getSchema(schema);

		//--- get the namespaces and add prefixes to any that are
		//--- default ie. prefix is ''
		
		ArrayList nsList = new ArrayList();
		nsList.add(ns);
		nsList.addAll(md.getAdditionalNamespaces());
        for (Object aNsList : nsList) {
            Namespace aNs = (Namespace) aNsList;
            if (aNs.getPrefix().equals("")) { // found default namespace
                String prefix = mds.getPrefix(aNs.getURI());
                if (prefix == null) {
                    throw new IllegalArgumentException("No prefix - cannot find a namespace to set for element " + md.getQualifiedName() + " - namespace URI " + ns.getURI());
                }
                ns = Namespace.getNamespace(prefix, aNs.getURI());
                setNamespacePrefix(md, ns);
                if (!md.getNamespace().equals(ns)) {
                    md.removeNamespaceDeclaration(aNs);
                    md.addNamespaceDeclaration(ns);
                }
            }
        }
    }

    /**
     *
     * @param dbms
     * @param md
     * @param id
     * @throws Exception
     */
    public void notifyMetadataChange(Dbms dbms, Element md, String id) throws Exception {
        String isTemplate = getMetadataTemplate(dbms, id);

        if (isTemplate.equals("n")) {
            GeonetContext gc = (GeonetContext) servContext.getHandlerContext(Geonet.CONTEXT_NAME);

            String uuid = getMetadataUuid(dbms, id);
            gc.getMetadataNotifier().updateMetadata(md, id, uuid, dbms, gc);
        }
    }

    /**
     *
     * @param dbms
     * @param id
     * @param uuid
     * @throws Exception
     */
    private void notifyMetadataDelete(Dbms dbms, String id, String uuid) throws Exception {
        GeonetContext gc = (GeonetContext) servContext.getHandlerContext(Geonet.CONTEXT_NAME);
        gc.getMetadataNotifier().deleteMetadata(id, uuid, dbms, gc);        
    }

	/**
	 * Update group owner when handling privileges during import.
	 * Does not update the index.
	 * 
	 * @param dbms
	 * @param mdId
	 * @param grpId
	 * @throws Exception
	 */
	public void setGroupOwner(Dbms dbms, String mdId, String grpId)
			throws Exception {
		dbms.execute("UPDATE Metadata SET groupOwner=? WHERE id=?", Integer
				.parseInt(grpId), Integer.parseInt(mdId));
	}

    /**
     *
     * @param dbms
     * @return
     * @throws Exception
     */
    public Element getCswCapabilitiesInfo(Dbms dbms) throws Exception {
        return dbms.select("SELECT * FROM CswServerCapabilitiesInfo");
    }

    /**
     *
     * @param dbms
     * @param language
     * @return
     * @throws Exception
     */
    public CswCapabilitiesInfo getCswCapabilitiesInfo(Dbms dbms, String language) throws Exception {

        CswCapabilitiesInfo cswCapabilitiesInfo = new CswCapabilitiesInfo();
        cswCapabilitiesInfo.setLangId(language);
        Element capabilitiesInfoRecord = dbms.select("SELECT * FROM CswServerCapabilitiesInfo WHERE langId = ?", language);

        List<Element> records = capabilitiesInfoRecord.getChildren();
        for(Element record : records) {
            String field = record.getChild("field").getText();
            String label = record.getChild("label").getText();

            if (field.equals("title")) {
                cswCapabilitiesInfo.setTitle(label);
            }
            else if (field.equals("abstract")) {
                cswCapabilitiesInfo.setAbstract(label);
            }
            else if (field.equals("fees")) {
                cswCapabilitiesInfo.setFees(label);
            }
            else if (field.equals("accessConstraints")) {
                cswCapabilitiesInfo.setAccessConstraints(label);
            }
        }
        return cswCapabilitiesInfo;
    }

    /**
     *
     * @param dbms
     * @param cswCapabilitiesInfo
     * @throws Exception
     */
    public void saveCswCapabilitiesInfo(Dbms dbms, CswCapabilitiesInfo cswCapabilitiesInfo)
            throws Exception {

        String langId = cswCapabilitiesInfo.getLangId();

        dbms.execute("UPDATE CswServerCapabilitiesInfo SET label = ? WHERE langId = ? AND field = ?", cswCapabilitiesInfo.getTitle(), langId, "title");
        dbms.execute("UPDATE CswServerCapabilitiesInfo SET label = ? WHERE langId = ? AND field = ?", cswCapabilitiesInfo.getAbstract(), langId, "abstract");
        dbms.execute("UPDATE CswServerCapabilitiesInfo SET label = ? WHERE langId = ? AND field = ?", cswCapabilitiesInfo.getFees(), langId, "fees");
        dbms.execute("UPDATE CswServerCapabilitiesInfo SET label = ? WHERE langId = ? AND field = ?",  cswCapabilitiesInfo.getAccessConstraints(), langId, "accessConstraints");
    }

	//--------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//--------------------------------------------------------------------------

	private String baseURL;

	private EditLib editLib;

	private ScheduledThreadPoolExecutor indexThreadPool;
	private AccessManager  accessMan;
	private SearchManager  searchMan;
	private SettingManager settingMan;
	private SchemaManager  schemaMan;
	private HarvestManager harvestMan;
    private final ReusableObjManager reusableObjMan;
    private final ExtentManager extentMan;
    private final Stack<Boolean> indexing = new Stack<Boolean>();
    private final ThesaurusManager thesaurusMan;
    private String dataDir;
    private ServiceContext servContext;
	private String appPath;
	private boolean rebuilding = false;
	private String stylePath;
	private static String FS = File.separator;

	
	private final Validator validator;
    /**
     *
     */
	class IncreasePopularityTask implements Runnable {
        private ServiceContext srvContext;
        String id;
        Dbms dbms = null;

        /**
         *
         * @param srvContext
         * @param id
         */
        public IncreasePopularityTask(ServiceContext srvContext,
				String id) {
        			this.srvContext = srvContext;
        			this.id = id;
    	}

		public void run() {
        try {
       	    dbms = (Dbms) srvContext.getResourceManager().openDirect(Geonet.Res.MAIN_DB);
            String query = "UPDATE Metadata SET popularity = popularity +1 WHERE id = ?";
            dbms.execute(query, new Integer(id));
            boolean indexGroup = false;
            indexMetadata(dbms, id, indexGroup,false);
        }
        catch (Exception e) {
            Log.warning(Geonet.DATA_MANAGER, "The following exception is ignored: " + e.getMessage());
			e.printStackTrace();
		}
        finally {
				try {
					if (dbms != null) srvContext.getResourceManager().close(Geonet.Res.MAIN_DB, dbms);
				}
                catch (Exception e) {
					Log.error(Geonet.DATA_MANAGER, "There may have been an error updating the popularity of the metadata "+id+". Error: " + e.getMessage());
					e.printStackTrace();
				}
			}

        }
	}

    public enum UpdateDatestamp {
        yes, no
    }

    public Element getValidationReport(ServiceContext srvContext, String id) throws Exception
    {
        Dbms dbms = (Dbms) srvContext.getResourceManager().open(Geonet.Res.MAIN_DB);

        // TODO : Xlinks resolved ?
        //Was : Element md = XmlSerializer.select(dbms, "Metadata", id, true);
        Element md = XmlSerializer.select(dbms, "Metadata", id, srvContext);

        if (md == null)
        {
            return null;
        }

        InstrumentAndValidateResult report = instrumentMetadataAndValidate(dbms, id, md, srvContext);

        Element result = new Element("validationReport");
        result.setAttribute("id", id);
        if (report.xsdErrors != null)
            result.addContent(report.xsdErrors);
        if (report.schematronReport != null)
            result.addContent(report.schematronReport);
        return result;
    }
	private InstrumentAndValidateResult instrumentMetadataAndValidate(Dbms dbms, String mdId, Element md, ServiceContext srvContext)
	throws Exception
    {
        String schema = getMetadataSchema(dbms, mdId);
        MetadataSchema mds = getSchema(schema);
        // XSD checking on metadata

        Element xsdErrors = validator.getXSDXmlReport(mds, md);

        // Add editing elements
        editLib.expandElements(schema, md);
        String version = editLib.addEditingInfo(schema, mdId, md);

        // Schematron checking
        Element elemChecks = validator.getSchemaTronXmlReport(mds, md, srvContext.getLanguage());
        return new InstrumentAndValidateResult(xsdErrors, elemChecks, version);
    }
	
	
	private static final class InstrumentAndValidateResult {
        public final Element xsdErrors;
        public final Element schematronReport;
        public final String version;
        public InstrumentAndValidateResult(Element xsdErrors, Element schematronReport, String version)
        {
            this.xsdErrors = xsdErrors;
            this.schematronReport = schematronReport;
            this.version = version;
        }


	}

	public synchronized boolean isIndexing() {
	    return !indexing.isEmpty() && indexThreadPool.getTaskCount() > 0;
    }
}
