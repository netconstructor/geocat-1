package org.fao.geonet.services.extent;

import jeeves.utils.Log;
import org.apache.log4j.Logger;
import org.fao.geonet.constants.Geocat;
import org.geotools.data.DataStore;
import org.geotools.data.wfs.WFSDataStoreFactory;
import org.geotools.util.logging.Logging;
import org.jdom.Element;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Handler;
import java.util.logging.LogRecord;

import static org.fao.geonet.services.extent.ExtentHelper.*;

/**
 * The configuration object for Extents. It allows access to the Datastore(s)
 * for obtaining the extents
 *
 * @author jeichar
 */
public class ExtentManager {

    private static ExtentManager instance;
    public static final String GEOTOOLS_LOG_NAME = "geotools";

    public static ExtentManager getInstance() {
        return instance;
    }

    private final class WfsLogHandler extends Handler {

        @Override
        public void publish(LogRecord record) {
            Log.debug(GEOTOOLS_LOG_NAME, record.getMessage());
        }

        @Override
        public void flush() {
            // nothing
        }

        @Override
        public void close() throws SecurityException {
            // nothing

        }
    }

    private final Map<String, WFS> wfss = new HashMap<String, WFS>();

    public ExtentManager(java.util.List<Element> extentConfig) throws Exception {
        instance = this;
        if (Logger.getLogger(GEOTOOLS_LOG_NAME).isDebugEnabled()) {
            Logging.getLogger("org.geotools.data.wfs").setLevel(java.util.logging.Level.FINE);
            Logging.getLogger("org.geotools.data.wfs").addHandler(new WfsLogHandler());
        }
        if (extentConfig == null) {
            Log.error(Geocat.Module.EXTENT, "No Extent configuration found.");
        } else {
            for (Element wfsElem : extentConfig) {
                final String url = wfsElem.getAttributeValue("url");
                String id = wfsElem.getAttributeValue(ID);
                if (url == null) {
                    throw new Exception("the url attribute for extent wfs configuration id=" + id + "is missing");
                }
                if (id == null) {
                    id = DEFAULT_WFS_ID;
                }

                final WFS wfs = new WFS(id);

                wfs.wfsDataStoreParams.put(WFSDataStoreFactory.URL.key, url);
                wfs.wfsDataStoreParams.put(WFSDataStoreFactory.ENCODING.key, "UTF-8");
                wfss.put(id, wfs);

                for (final Object obj : wfsElem.getChildren(TYPENAME)) {
                    final Element elem = (Element) obj;
                    final String typename = elem.getAttributeValue(TYPENAME);
                    final String idColumn = elem.getAttributeValue(ID_COLUMN);
                    if (idColumn == null) {
                        throw new Exception("the idColumn attribute for extent wfs configuration " + id + ":" + url
                                + "is missing");
                    }

                    final String projection = elem.getAttributeValue("CRS");
                    final String descColumn = elem.getAttributeValue(DESC_COLUMN);
                    final String geoIdColumn = elem.getAttributeValue(GEO_ID_COLUMN);
                    final String searchColumn = elem.getAttributeValue("searchColumn");
                    final String modifiable = elem.getAttributeValue(MODIFIABLE_FEATURE_TYPE);

                    wfs.addFeatureType(typename, idColumn, geoIdColumn, descColumn, searchColumn, projection, "true"
                            .equalsIgnoreCase(modifiable));
                }
            }

        }

    }

    public DataStore getDataStore() throws IOException {
        return wfss.get(DEFAULT_WFS_ID).getDataStore();
    }

    public DataStore getDataStore(String id) throws IOException {
        final String concId = id == null ? DEFAULT_WFS_ID : id;
        return wfss.get(concId).getDataStore();
    }

    public Map<String, WFS> getWFSs() {
        return wfss;
    }

    public WFS getWFS(String wfs) {
        if (wfs == null) {
            return wfss.get(DEFAULT_WFS_ID);
        }
        return wfss.get(wfs);
    }

    public WFS getWFS() {
        return wfss.get(DEFAULT_WFS_ID);
    }

}
