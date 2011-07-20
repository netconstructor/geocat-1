package org.fao.geonet.kernel.reusable;

import jeeves.resources.dbms.Dbms;

import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.ThesaurusManager;
import org.fao.geonet.services.extent.ExtentManager;
import org.fao.geonet.kernel.reusable.log.ReusableObjectLogger;
import org.jdom.Element;

public class ProcessParams
{
    public final Dbms                 dbms;
    public final ReusableObjectLogger logger;
    public final Element              elementToProcess;
    public final Element              metadata;
    public final ThesaurusManager     thesaurusManager;
    public final ExtentManager        extentManager;
    public final String               baseURL;
    public final String               metadataId;
    public final boolean              addOnly;
    public final String 			  defaultLang;
	public final SettingManager settingsManager;

    public ProcessParams(Dbms dbms, ReusableObjectLogger logger, String metadataId, Element elementToProcess,
            Element metadata, ThesaurusManager thesaurusManager, ExtentManager extentManager, String baseURL,
            SettingManager settingMan, boolean addOnly, String defaultLang)
    {
        this.dbms = dbms;
        this.logger = logger;
        this.elementToProcess = elementToProcess;
        this.metadata = metadata;
        this.thesaurusManager = thesaurusManager;
        this.extentManager = extentManager;
        this.baseURL = Utils.mkBaseURL(baseURL, settingMan);
        this.addOnly = addOnly;
        this.metadataId = metadataId;
        this.defaultLang = defaultLang;
        this.settingsManager = settingMan;
    }

    public ProcessParams(Dbms dbms, String metadataId, Element elementToProcess, Element metadata,
            ThesaurusManager thesaurusManager, ExtentManager extentManager, SettingManager settingMan, String baseURL,
            boolean addOnly)
    {
        this(dbms, ReusableObjectLogger.THREAD_SAFE_LOGGER, metadataId, elementToProcess, metadata, thesaurusManager,
                extentManager, baseURL, settingMan, addOnly,null);
    }

    public ProcessParams(Dbms dbms, String metadataId, Element elementToProcess, Element metadata,
            ThesaurusManager thesaurusManager, ExtentManager extentManager, SettingManager settingMan, String baseURL)
    {
        this(dbms, ReusableObjectLogger.THREAD_SAFE_LOGGER, metadataId, elementToProcess, metadata, thesaurusManager,
                extentManager, baseURL, settingMan, false,null);
    }
    
    public ProcessParams updateElementToProcess(Element newElem) {
    	return new ProcessParams(dbms, logger, metadataId, newElem, metadata, thesaurusManager, extentManager, baseURL, settingsManager, addOnly, defaultLang);
    }
}