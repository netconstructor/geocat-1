package org.fao.geonet.kernel;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import jeeves.exceptions.JeevesException;
import jeeves.interfaces.Schedule;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ScheduleContext;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Xml;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Edit;
import org.fao.geonet.constants.Geonet;
import org.jdom.Element;
import org.jdom.filter.Filter;
import org.joda.time.DateTime;

public class UnpublishInvalidMetadataJob implements Schedule, Service {

    static final String AUTOMATED_ENTITY = "Automated";

    @Override
    public void init(String appPath, ServiceConfig params) throws Exception {

    }

    @Override
    public void exec(ScheduleContext context) throws Exception {
        if (new DateTime().getHourOfDay() == 1) {
            GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
            Dbms dbms = (Dbms) context.getResourceManager().openDirect(Geonet.Res.MAIN_DB);
            try {
                performJob(gc, dbms);
            } finally {
                context.getResourceManager().close(Geonet.Res.MAIN_DB, dbms);
            }
        }

    }

    @Override
    public Element exec(Element params, ServiceContext context) throws Exception {
        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

        performJob(gc, dbms);
        return new Element("success");
    }

    // --------------------------------------------------------------------------------

    private void performJob(GeonetContext gc, Dbms dbms) throws SQLException, Exception {
        Integer keepDuration = gc.getSettingManager().getValueAsInt("system/publish_tracking_duration");
        if (keepDuration == null) {
            keepDuration = 14;
        }

        // clean up expired changes
        dbms.execute("DELETE FROM publish_tracking where changedate < current_date-" + Math.min(1, keepDuration));

        List<MetadataRecord> metadataids = lookUpMetadataIds(dbms);

        DataManager dataManager = gc.getDataManager();
        dataManager.startIndexGroup();
        try {
            for (MetadataRecord metadataRecord : metadataids) {
                String id = "" + metadataRecord.id;
                try {
                    Record newTodayRecord = validate(gc, metadataRecord, dbms, dataManager);
                    if (newTodayRecord != null) {
                        newTodayRecord.insertInto(dbms);
                    }
                    dataManager.indexMetadataGroup(dbms, id, false, null);
                } catch (Exception e) {
                    String error = Xml.getString(JeevesException.toElement(e));
                    Log.error(Geonet.INDEX_ENGINE, "Error during Validation/Unpublish process of metadata " + id + ".  Exception: " + error);
                }
            }
        } finally {
            dataManager.endIndexGroup();
        }
    }

    private Record validate(GeonetContext gc, MetadataRecord metadataRecord, Dbms dbms, DataManager dataManager) throws Exception {
        String id = "" + metadataRecord.id;
        Element md = gc.getXmlSerializer().select(dbms, "metadata", id, null);
        String schema = gc.getSchemamanager().autodetectSchema(md);
        Record todayRecord = null;
        boolean published = isPublished(id, dbms);
        Element report = dataManager.doValidate(null, dbms, schema, id, md, "eng", false).one();
        if (published) {
            String failureReason = failureReason(report);
            if (!failureReason.isEmpty()) {
                boolean validated = false;
                String entity = AUTOMATED_ENTITY;
                published = false;
                todayRecord = new Record(metadataRecord.id, validated, published, entity, failureReason);
                dbms.execute("DELETE FROM operationallowed WHERE metadataid = ? and (groupid = 1 or groupid = -1)", metadataRecord.id);
            }
        }

        return todayRecord;
    }

    public static boolean isPublished(String id, Dbms dbms) throws SQLException {
        @SuppressWarnings("rawtypes")
        List children = dbms.select(
                "SELECT metadataid FROM operationallowed where metadataid=" + id + " and groupid = 1 and operationid = 0").getChildren(
                "record");
        return !children.isEmpty();
    }

    private String failureReason(Element report) {

        @SuppressWarnings("unchecked")
        Iterator<Element> reports = report.getDescendants(new ReportFinder());

        StringBuilder builder = new StringBuilder();
        while (reports.hasNext()) {
            report = reports.next();
            String reportType = report.getAttributeValue("rule", Edit.NAMESPACE);
            if (true) {
                @SuppressWarnings("unchecked")
                Iterator<Element> errors = report.getDescendants(new ErrorFinder());
                if (errors.hasNext()) {
                    if (builder.length() > 0)
                        builder.append(", ");
                    builder.append(reportType);
                }
            }
        }

        return builder.toString();
    }

    @SuppressWarnings("unchecked")
    private List<MetadataRecord> lookUpMetadataIds(Dbms dbms) throws SQLException {
        Element results = dbms.select("select id from metadata where istemplate='n' and isharvested='n'");

        List<MetadataRecord> recordMap = new ArrayList<MetadataRecord>();

        for (Element result : (Collection<Element>) results.getChildren("record")) {
            MetadataRecord record = new MetadataRecord(result);
            recordMap.add(record);
        }

        return recordMap;
    }

    @SuppressWarnings("unchecked")
    static List<Record> values(Dbms dbms, int startOffset, int endOffset) throws Exception {
        Element results = dbms.select("SELECT * from publish_tracking where changedate > current_date-" + startOffset+" and changedate <= current_date - "+endOffset);

        List<Record> recordMap = new ArrayList<Record>();

        @SuppressWarnings("rawtypes")
        List children = results.getChildren("record");
        for (Element result : (Collection<Element>) children) {
            Record record = new Record(result);
            recordMap.add(record);
        }

        return recordMap;
    }

    public static class Record {
        int id;
        String entity;
        boolean validated;
        boolean published;
        String failureReason;

        Record(Element record) {
            this.id = Integer.parseInt(record.getChildTextTrim("metadataid"));
            this.entity = record.getChildTextTrim("entity");
            this.validated = Boolean.parseBoolean(record.getChildTextTrim("validated"));
            this.published = Boolean.parseBoolean(record.getChildTextTrim("published"));
            this.failureReason = record.getChildTextTrim("failurereason");
        }

        public Record(int id, boolean validated, boolean published, String entity, String failureReason) {
            this.id = id;
            this.entity = entity;
            this.validated = validated;
            this.published = published;
            this.failureReason = failureReason;
        }

        public void insertInto(Dbms dbms) throws SQLException {
            dbms.execute("INSERT INTO publish_tracking (metadataid, entity, validated, published, failureReason) VALUES (?,?,?,?,?)", id,
                    entity, codeForDatabase(validated), codeForDatabase(published), failureReason.replace('"', '\''));
        }

        private String codeForDatabase(boolean value) {
            return value ? "y" : "n";
        }

        public Element toElement() {
            return new Element("record").addContent(new Element("id").setText("" + id)).addContent(new Element("entity").setText(entity))
                    .addContent(new Element("validated").setText("" + validated))
                    .addContent(new Element("published").setText("" + published))
                    .addContent(new Element("failureReason").setText(failureReason));
        }
    }

    static class MetadataRecord {
        int id;
        String title;
        String owner;
        String changedate;

        MetadataRecord(Element record) {
            this.id = Integer.parseInt(record.getChildTextTrim("id"));
            this.title = record.getChildTextTrim("title");
            this.owner = record.getChildTextTrim("owner");
            this.changedate = record.getChildTextTrim("changedate");
        }
    }

    static class ErrorFinder implements Filter {
        private static final long serialVersionUID = 1L;

        @Override
        public boolean matches(Object obj) {
            if (obj instanceof Element) {
                Element element = (Element) obj;
                String name = element.getName();
                if (name.equals("error")) {
                    return true;
                } else if (name.equals("failed-assert")) {
                    return true;
                }
            }
            return false;
        }
    }

    static class ReportFinder implements Filter {
        private static final long serialVersionUID = 1L;

        @Override
        public boolean matches(Object obj) {
            if (obj instanceof Element) {
                Element element = (Element) obj;
                String name = element.getName();
                if (name.equals("report")) {
                    return true;
                }
            }
            return false;
        }
    }
}
