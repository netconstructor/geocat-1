package org.fao.geonet.kernel.reusable;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.SerialFactory;
import jeeves.utils.Xml;
import jeeves.xlink.Processor;
import jeeves.xlink.XLink;

import org.apache.log4j.Level;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geocat;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.XmlSerializer;
import org.fao.geonet.kernel.search.spatial.Pair;
import org.fao.geonet.kernel.ThesaurusManager;
import org.fao.geonet.services.extent.ExtentManager;
import org.fao.geonet.kernel.reusable.log.Record;
import org.fao.geonet.kernel.reusable.log.ReusableObjectLogger;
import org.fao.geonet.util.ISODate;
import org.fao.geonet.util.LangUtils;
import org.geotools.gml3.GMLConfiguration;
import org.jdom.Content;
import org.jdom.Element;
import org.jdom.Namespace;
import org.jdom.filter.Filter;

public class ReusableObjManager
{
    // The following constants are used in stylesheet and the log4J
    // configuration so make
    // sure they are updated if these are changed
    public static final String                       CONTACTS             = "contacts";
    private static final String                      CONTACTS_PLACEHOLDER = "contactsPlaceholder";
    public static final String                       EXTENTS              = "extents";
    private static final String                      EXTENTS_PLACEHOLDER  = "extentsPlaceholder";
    public static final String                       FORMATS              = "formats";
    private static final String                      FORMATS_PLACEHOLDER  = "formatsPlaceholder";
    public static final String                       KEYWORDS             = "keywords";
    private static final String                      KEYWORDS_PLACEHOLDER = "keywordsPlaceholder";

    private final Lock                               lock                 = new ReentrantLock();

    public static final String                       NON_VALID_ROLE       = "http://www.geonetwork.org/non_valid_obj";

    private final String                             _styleSheet;
    private final String                             _appPath;
    private boolean                                  _processOnInsert;

    private final GMLConfiguration                   gml3Conf             = new GMLConfiguration();
    private final org.geotools.gml2.GMLConfiguration gml2Conf             = new org.geotools.gml2.GMLConfiguration();
    private final SerialFactory _serialFactory;


    public ReusableObjManager(String appPath, List<Element> reusableConfigIter, SerialFactory serialFactory)
    {
        this._serialFactory = serialFactory;
        this._appPath = appPath;
        this._styleSheet = appPath + "/xsl/reusable-objects-extractor.xsl";
        this._processOnInsert = false;

        if(reusableConfigIter == null) {
            Log.warning(Geocat.Module.REUSABLE, "Reusable configuration not specified in config.xml");
        } else if (!reusableConfigIter.isEmpty()) {
            Element config = reusableConfigIter.get(0);
            _processOnInsert = "true".equalsIgnoreCase(config.getAttributeValue("value"));
        }
    }

    public boolean isProcessOnInsert()
    {
        return _processOnInsert;
    }

    public int process(ServiceContext context, Set<String> elements, DataManager dm, boolean sendEmail, boolean idIsUuid, boolean ignoreErrors)
            throws Exception
    {
        try {
            // Note if this lock is removed the ReusableObjectsLogger must also
            // be made thread-safe notes on how to do that are in that class
            if (!lock.tryLock(5, TimeUnit.SECONDS)) {
                throw new IllegalArgumentException("ProcessReusableObject is locked");
            }

            int count = 0;
            ReusableObjectLogger logger = new ReusableObjectLogger();

            Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

            for (String uuid : elements) {
                try {
                    boolean changed = process(context, dm, dbms, uuid, logger, idIsUuid);
                    if (changed) {
                        count++;
                    }

                } catch (Exception e) {
                    StringWriter w = new StringWriter();
                    e.printStackTrace(new PrintWriter(w));
                    Log.debug("Reusable Objects", "Selection: " + uuid + " can not be looked up: " + w.toString());
                    if(!ignoreErrors) {
                    	throw e;
                    }
                }
            }

            if (sendEmail) {
                logger.sendEmail(context);
            }
            return count;
        } finally {
            lock.unlock();
        }
    }

    private boolean process(ServiceContext context, DataManager dm, Dbms dbms, String uuid,
            ReusableObjectLogger logger, boolean idIsUUID) throws Exception
    {
        // the metadata ID
        String id = uuidToId(dbms, dm, uuid, idIsUUID);

        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);

        Element metadata = dm.getMetadata(context, id, false, false, true, false);

        ProcessParams searchParams = new ProcessParams(dbms, logger, id, metadata, metadata, gc.getThesaurusManager(),
                gc.getExtentManager(), context.getBaseUrl(), gc.getSettingManager(), false,null);
        List<Element> process = process(searchParams);
        if (process != null) {
            Element changed = process.get(0);

            if (changed != null) {
                XmlSerializer.update(dbms, id, changed, new ISODate() .toString(),null);
            }
        }
        return process != null;
    }

    public static String uuidToId(Dbms dbms, DataManager dm, String uuid, boolean idIsUUID)
    {
        String id = uuid;

        if (!idIsUUID) {
            // does the request contain a UUID ?
            try {
                // lookup ID by UUID
                id = dm.getMetadataId(dbms, uuid);
                if (id == null) {
                    id = uuid;
                }
            } catch (Exception x) {
                // the selection is not a uuid maybe try id?
                id = uuid;
            }
        }
        return id;
    }

    public List<Element> process(ProcessParams parameterObject) throws Exception, SQLException
    {

        try {
            String metadataId = parameterObject.metadataId;
            if(metadataId == null) {
                metadataId = "anonymous";
            }

            Log.info(Geocat.Module.REUSABLE,
                    "Beginning reusable object processing on metadata object id= " + metadataId);
            Element elementToProcess = parameterObject.elementToProcess;

            String defaultMetadataLang = parameterObject.defaultLang;
            if(defaultMetadataLang == null) {
                defaultMetadataLang = LangUtils.iso19139DefaultLang(parameterObject.metadata);
                if (defaultMetadataLang != null) {
                    defaultMetadataLang = defaultMetadataLang.substring(0, 2).toUpperCase();
                } else {
                    defaultMetadataLang = "EN";
                }
            }

            Element xml = Xml.transform(elementToProcess, _styleSheet);

            boolean changed = false;
            Log.debug(Geocat.Module.REUSABLE, "Replace formats with xlinks");
            changed |= replaceFormats(xml, defaultMetadataLang, parameterObject);
            Log.debug(Geocat.Module.REUSABLE, "Replace contacts with xlinks");
            changed |= replaceContacts(xml, defaultMetadataLang, parameterObject);
            Log.debug(Geocat.Module.REUSABLE, "Replace keywords with xlinks");
            changed |= replaceKeywords(xml, defaultMetadataLang, parameterObject);
            Log.debug(Geocat.Module.REUSABLE, "Replace extents with xlinks");
            changed |= replaceExtents(xml, defaultMetadataLang, parameterObject);

            Log.info(Geocat.Module.REUSABLE, "Finished processing on id=" + parameterObject.metadataId
                    + ".  " + (changed ? "Metadata was modified" : "No change was made"));

            if (changed) {
                ArrayList<Element> results = new ArrayList<Element>(xml.getChild("metadata").getChildren());
                for (Element md : results) {
                    md.detach();
                    for (Object ns : elementToProcess.getAdditionalNamespaces()) {

                        md.addNamespaceDeclaration((Namespace) ns);
                    }
                }
                return results;
            }

            return null;
        } catch (Exception x) {
            StringWriter s = new StringWriter();
            x.printStackTrace(new PrintWriter(s));

            Log.error(Geocat.Module.REUSABLE,
                    "Exception occured while processing metadata object for reusable objects.  Exception is: "
                            + s.getBuffer().toString());
            s.close();

            throw x;
        }
    }

    private boolean replaceKeywords(Element xml, String defaultMetadataLang, ProcessParams params) throws Exception
    {

        Dbms dbms = params.dbms;
        ReusableObjectLogger logger = params.logger;
        String baseURL = params.baseURL;
        ThesaurusManager thesaurusMan = params.thesaurusManager;

        KeywordsStrategy strategy = new KeywordsStrategy(thesaurusMan, _appPath, baseURL, null);
        return performReplace(dbms, xml, defaultMetadataLang, KEYWORDS_PLACEHOLDER, KEYWORDS, logger, strategy,
                params.addOnly);
    }

    private boolean replaceFormats(Element xml, String defaultMetadataLang, ProcessParams params) throws Exception
    {
        Dbms dbms = params.dbms;
        ReusableObjectLogger logger = params.logger;
        String baseURL = params.baseURL;

        FormatsStrategy strategy = new FormatsStrategy(dbms, _appPath, baseURL, null, _serialFactory);
        return performReplace(dbms, xml, defaultMetadataLang, FORMATS_PLACEHOLDER, FORMATS, logger, strategy,
                params.addOnly);
    }

    private boolean replaceContacts(Element xml, String defaultMetadataLang, ProcessParams params) throws Exception
    {
        Dbms dbms = params.dbms;
        ReusableObjectLogger logger = params.logger;
        String baseURL = params.baseURL;

        ContactsStrategy strategy = new ContactsStrategy(dbms, _appPath, baseURL, null, _serialFactory);
        return performReplace(dbms, xml, defaultMetadataLang, CONTACTS_PLACEHOLDER, CONTACTS, logger, strategy,
                params.addOnly);
    }

    private boolean replaceExtents(Element xml, String defaultMetadataLang, ProcessParams params) throws Exception
    {

        Dbms dbms = params.dbms;
        ReusableObjectLogger logger = params.logger;
        String baseURL = params.baseURL;
        ExtentManager extentMan = params.extentManager;

        ExtentsStrategy strategy = new ExtentsStrategy(baseURL, _appPath, extentMan, null, this.gml3Conf, this.gml2Conf);
        return performReplace(dbms, xml, defaultMetadataLang, EXTENTS_PLACEHOLDER, EXTENTS, logger, strategy,
                params.addOnly);
    }

    private boolean performReplace(Dbms dbms, Element xml, String defaultMetadataLang, String placeholderElemName,
            String originalElementName, ReusableObjectLogger logger, ReplacementStrategy strategy, boolean addOnly)
            throws Exception
    {
        Iterator iter = xml.getChild("metadata").getDescendants(new PlaceholderFilter(placeholderElemName));

        List<Element> placeholders = Utils.convertToList(iter, Element.class);

        iter = xml.getChild(originalElementName).getChildren().iterator();
        Iterator<Content> originalElems = Utils.convertToList(iter, Content.class).iterator();

        boolean changed = false;

        for (Element placeholder : placeholders) {
            Element originalElem = Utils.nextElement(originalElems);

            if (XLink.isXLink(originalElem)) {
                originalElem.detach();
                updatePlaceholder(placeholder, originalElem);
                continue;
            }
            changed |= replaceSingleElement(placeholder, originalElem, strategy, defaultMetadataLang, addOnly, dbms,
                    originalElementName, logger);
        }

        return changed;
    }

    private boolean replaceSingleElement(Element placeholder, Element originalElem, ReplacementStrategy strategy,
            String defaultMetadataLang, boolean addOnly, Dbms dbms, String originalElementName,
            ReusableObjectLogger logger) throws Exception
    {

        boolean updated = false;
        if (!addOnly) {
            updated = updatePlaceholder(placeholder, strategy.find(placeholder, originalElem, defaultMetadataLang));
            if (updated)
                Log.debug(Geocat.Module.REUSABLE, "An existing match was found for " + strategy);
        }
        if (!updated) {
            updated = updatePlaceholder(placeholder, strategy.add(placeholder, originalElem, dbms,
                    defaultMetadataLang));
            if (updated)
                Log.debug(Geocat.Module.REUSABLE, "A new reusable element was added for "
                        + strategy);
        }
        if (!updated) {
            updatePlaceholder(placeholder, originalElem);
            Log.debug(Geocat.Module.REUSABLE, strategy + " object was not modified");
        }

        if (updated) {
            logger.log(Level.DEBUG, Record.Type.lookup(originalElementName),
                    "Following object was replaced by xlink(s)" + Xml.getString(originalElem));
        }
        return updated;
    }

    private boolean updatePlaceholder(Element placeholder, Element elem)
    {
        return updatePlaceholder(placeholder, Collections.singleton(elem));
    }

    private boolean updatePlaceholder(Element placeholder, Collection<Element> xlinks)
    {
        return updatePlaceholder(placeholder, Pair.read(xlinks, !xlinks.isEmpty()));
    }

    private boolean updatePlaceholder(Element placeholder, Pair<Collection<Element>, Boolean> xlinks)
    {
        if (xlinks == null) {
            return false;
        }

        if (!Utils.isEmpty(xlinks.one())) {
            for (Element element : xlinks.one()) {
                element.detach();
            }
            Element parent = placeholder.getParentElement();
            int index = parent.indexOf(placeholder);
            if (xlinks.two()) {
                parent.setContent(index, xlinks.one());
            } else {
                parent.addContent(index, xlinks.one());
            }
            return xlinks.two();
        }
        return false;
    }

    private static final class PlaceholderFilter implements Filter
    {

        private static final long serialVersionUID = 1L;
        private final String      elemName;
        public PlaceholderFilter(String elemName)
        {
            this.elemName = elemName;
        }

        public boolean matches(Object obj)
        {
            if (obj instanceof Element) {
                Element elem = (Element) obj;

                return elemName.equals(elem.getName());
            }
            return false;
        }

    }

    public Collection<Element> updateXlink(Element xlink, ProcessParams params) throws Exception
    {
        try {
            // Note if this lock is removed the ReusableObjectsLogger must also
            // be made thread-safe notes on how to do that are in that class
            if (!lock.tryLock(5, TimeUnit.SECONDS)) {
                throw new IllegalArgumentException("ProcessReusableObject is locked");
            }
            Dbms dbms = params.dbms;
            String baseUrl = params.baseURL;

            ReplacementStrategy strategy;

            if (xlink.getName().equals("contact") || xlink.getName().equals("pointOfContact")
                     || xlink.getName().equals("distributorContact") || xlink.getName().equals("citedResponsibleParty")) {
                strategy = new ContactsStrategy(dbms, _appPath, baseUrl, "unknown", _serialFactory);
            } else if (xlink.getName().equals("resourceFormat") || xlink.getName().equals("distributionFormat")) {
                strategy = new FormatsStrategy(dbms, _appPath, baseUrl, "unknown", _serialFactory);
            } else if (xlink.getName().equals("descriptiveKeywords")) {
                strategy = new KeywordsStrategy(params.thesaurusManager, _appPath, baseUrl, "unknown");
            } else {
                strategy = new ExtentsStrategy(baseUrl, _appPath, params.extentManager, "unknown");
            }

            Log.info(Geocat.Module.REUSABLE, "Updating a " + strategy + " in metadata id="
                    + params.metadataId);

            Processor.removeFromCache(xlink.getAttributeValue(XLink.HREF, XLink.NAMESPACE_XLINK));

            String metadataLang = LangUtils.iso19139DefaultLang(params.elementToProcess);
            if (metadataLang != null) {
                metadataLang = metadataLang.substring(0, 2).toUpperCase();
            } else {
                metadataLang = "EN";
            }
            Collection<Element> newElements = strategy.updateObject(xlink, params.dbms, metadataLang);
            Log.info(Geocat.Module.REUSABLE, "New elements were created as a result of update");
            Log.info(Geocat.Module.REUSABLE, "Done updating " + strategy + " in metadata id="
                    + params.metadataId);

            return newElements;
        } finally {
            lock.unlock();
        }
    }


    /**
     * Create the shared object if it needs to be created.  currently only required for extents
     */
    public String createAsNeeded(String href, ServiceContext context) throws Exception {
        try {
            // Note if this lock is removed the ReusableObjectsLogger must also
            // be made thread-safe notes on how to do that are in that class
            if (!lock.tryLock(5, TimeUnit.SECONDS)) {
                throw new IllegalArgumentException("ProcessReusableObject is locked");
            }
            ReusableTypes type = hrefToReusableType(href);

            return Utils.strategy(type, context).createAsNeeded(href, context.getUserSession());
        } finally {
            lock.unlock();
        }
    }


    public boolean isValidated(String href, ServiceContext context) throws Exception
    {
        try {
            // Note if this lock is removed the ReusableObjectsLogger must also
            // be made thread-safe notes on how to do that are in that class
            if (!lock.tryLock(5, TimeUnit.SECONDS)) {
                throw new IllegalArgumentException("ProcessReusableObject is locked");
            }
            ReusableTypes type = hrefToReusableType(href);

            return Utils.strategy(type, context).isValidated((Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB),
                    href);
        } finally {
            lock.unlock();
        }
    }

    private ReusableTypes hrefToReusableType(String href) {
        ReusableTypes type;
        if (href.contains("xml.keyword.get")) {
            type = ReusableTypes.keywords;
        } else if (href.contains("xml.user.get")) {
            type = ReusableTypes.contacts;
        } else if (href.contains("xml.format.get")) {
            type = ReusableTypes.formats;
        } else if (href.contains("xml.extent.get")) {
            type = ReusableTypes.extents;
        } else {
            throw new IllegalArgumentException(href + " is not recognized as a reusable object xlink");
        }
        return type;
    }


    public static boolean isValidated(Element xlinkParent)
    {
        return NON_VALID_ROLE.equals(xlinkParent.getAttributeValue(XLink.ROLE, XLink.NAMESPACE_XLINK));
    }

}
