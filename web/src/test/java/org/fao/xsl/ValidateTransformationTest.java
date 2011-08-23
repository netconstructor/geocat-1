package org.fao.xsl;

import static org.fao.geonet.services.extent.ExtentHelper.ExtentTypeCode.EXCLUDE;
import static org.fao.geonet.services.extent.ExtentHelper.ExtentTypeCode.INCLUDE;
import static org.fao.geonet.services.extent.ExtentHelper.ExtentTypeCode.NA;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map.Entry;

import jeeves.utils.Xml;

import org.jdom.Element;
import org.jdom.filter.Filter;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.Multimap;

public class ValidateTransformationTest
{

    static final File data      = TransformationTestSupport.data;
    static final File outputDir = TransformationTestSupport.outputDir;

    @Before
    public void deleteOutputDir()
    {
        TransformationTestSupport.delete(outputDir);
    }

    @Test
    public void smallGeom() throws Throwable
    {
        File file = new File(data, "non_validating/smallGeom.xml");
		Multimap<String, Requirement> rules = ArrayListMultimap.create();
	    file = testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void doNotCreateEmptyBasicGeoId() throws Throwable
    {
        File file = new File(data, "gm03V2/noBasicGeoId.xml");
		Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("identificationInfo",new Not(new Exists(new Finder("basicGeodataID"))));
	    file = testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void serviceDoesNotHaveBasicGeoId() throws Throwable
    {
        File file = new File(data, "iso19139/service_19139che.xml");
		Multimap<String, Requirement> rules = ArrayListMultimap.create();
	    file = testFile(file, Control.ISO_GM03, rules, true);
        rules.put("identificationInfo",new Not(new Exists(new Finder("basicGeodataID"))));
	    file = testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void DoNotAddDatasetByDefault18386() throws Throwable
    {
        File file = new File(data, "non_validating/bug18386.xml");
		Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("gmd:dataQualityInfo", new Not(new Exists(new Finder("DQ_Scope/level"))));
	    file = testFile(file, Control.GM03_1_ISO, rules, false);
    }

    @Test
    public void gm03V1orgName() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
		Multimap<String, Requirement> rules = ArrayListMultimap.create();
		rules.put("che:parentResponsibleParty",
                new Exists(new Finder("organisationName",
                new Exists(new Finder("LocalisedCharacterString",
						   new EqualText("Office federal de topographie"))))));
        file = testFile(file, Control.GM03_1_ISO, rules, true);
    }

    @Test
    public void gm03V2orgName() throws Throwable
    {
        File file = new File(data, "gm03V2/missing_orgname_ basicGeoDataID_ basicGeodataIDType.xml");
		Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("che:CHE_CI_ResponsibleParty",
                new Exists(new Finder("organisationName",
                new Exists(new Finder("CharacterString",
                           new EqualText("Kanton Thurgau, Amt fur Geoinformation"))))));
        rules.put("che:CHE_MD_DataIdentification", new Exists(new Finder("basicGeodataID")));
        rules.put("che:CHE_MD_DataIdentification", new Exists(new Finder("basicGeodataIDType")));
        file = testFile(file, Control.GM03_2_ISO, rules, true);

        rules = ArrayListMultimap.create();

        rules.put("GM03_2Comprehensive.Comprehensive.MD_DataIdentification", new Exists(new Finder("basicGeodataID")));
        rules.put("GM03_2Comprehensive.Comprehensive.MD_DataIdentification", new Exists(new Finder("basicGeodataIDType")));
        rules.put("GM03_2Core.Core.CI_ResponsibleParty", new Exists(new Finder("organisationName")));

        testFile(file, Control.ISO_GM03, rules, true);
    }


    @Test
    public void transferMD_IdentifierAndScaleDenominator() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("LI_Source", new Exists(new Finder("scaleDenominator")));
        rules.put("CHE_MD_FeatureCatalogueDescription/complianceCode/Boolean", new Not(new EqualText("false")));
        rules.put("CHE_MD_FeatureCatalogueDescription/complianceCode/Boolean", new EqualText("0"));
        rules.put("CHE_MD_FeatureCatalogueDescription/includedWithDataset/Boolean", new EqualText("1"));
        rules.put("MD_BrowseGraphic", Requirement.ACCEPT);
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("TRANSFER", new Exists(new Attribute("HEADERSECTION", "SENDER", "TransformationTestSupport")));
        rules.put("GM03_2Comprehensive.Comprehensive.MD_FeatureCatalogueDescription/complianceCode", new EqualText(
                "false"));
        rules.put("GM03_2Comprehensive.Comprehensive.MD_FeatureCatalogueDescription/includedWithDataset",
                new EqualText("true"));
        rules.put("GM03_2Comprehensive.Comprehensive.MD_BrowseGraphic", Requirement.ACCEPT);
        testFile(file, Control.ISO_GM03, rules, true);
    }

    @Test
    public void import_Bug16374() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("MD_Distribution/distributor", new Exists(new Finder("distributorContact")));
        rules.put("MD_Distribution/distributor", new Exists(new Finder("distributionOrderProcess", new Exists(new Finder("fees")))));
        rules.put("CHE_MD_FeatureCatalogueDescription", new Exists(new Finder("dataModel")));
        rules.put("CHE_MD_FeatureCatalogueDescription", new Exists(new Finder("domain")));
        rules.put("CHE_MD_FeatureCatalogueDescription", new Exists(new Finder("class")));;
        rules.put("CHE_MD_FeatureCatalogueDescription", new Exists(new Finder("modelType")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        file = testFile(file, Control.ISO_GM03, ArrayListMultimap.<String, Requirement>create(), true);
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importDistributor_Bug16374() throws Throwable
    {
        File file = new File(data, "gm03/missingDistributorInfo.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("MD_Distribution/distributor", new Exists(new Finder("distributorFormat")));
        rules.put("MD_Distribution/distributor/MD_Distributor/distributorFormat", new Exists(new Finder("formatDistributor")));
        rules.put("MD_Distribution/distributor", new Exists(new Finder("distributorTransferOptions")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        file = testFile(file, Control.ISO_GM03, ArrayListMultimap.<String, Requirement>create(), true);
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importRole() throws Throwable
    {
        File file = new File(data, "gm03/role_import_failure.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("CHE_MD_Metadata", new Count(2, new Finder("contact/CHE_CI_ResponsibleParty/role")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        file = testFile(file, Control.ISO_GM03, ArrayListMultimap.<String, Requirement>create(), true);
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importConstraintsBug17465_P1() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("CHE_MD_Metadata", new Exists(new Finder("MD_Constraints")));
        rules.put("CHE_MD_Metadata", new Exists(new Finder("CHE_MD_LegalConstraints/accessConstraints")));
        rules.put("CHE_MD_Metadata", new Exists(new Finder("CHE_MD_LegalConstraints/useConstraints")));
        rules.put("CHE_MD_Metadata", new Exists(new Finder("CHE_MD_LegalConstraints/otherConstraints")));
        rules.put("CHE_MD_Metadata", new Exists(new Finder("resourceConstraints")));
        rules.put("CHE_MD_Metadata", new Exists(new Finder("MD_SecurityConstraints")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        file = testFile(file, Control.ISO_GM03, ArrayListMultimap.<String, Requirement>create(), true);
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importMaintenanceContactBug17465_P2() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("metadataMaintenance", new Exists(new Finder("contact")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        file = testFile(file, Control.ISO_GM03, ArrayListMultimap.<String, Requirement>create(), true);
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importFeatureCatalogCitation_ResponsibleParty_Bug17465_P3() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("featureCatalogueCitation/CI_Citation", new Exists(new Finder("citedResponsibleParty")));
        rules.put("featureCatalogueCitation/CI_Citation/citedResponsibleParty", new Exists(new Finder("role")));
        rules.put("featureCatalogueCitation/CI_Citation", new Exists(new Finder("identifier")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        file = testFile(file, Control.ISO_GM03, ArrayListMultimap.<String, Requirement>create(), true);
        testFile(file, Control.GM03_2_ISO, rules, true);
    }
    @Test
    public void missingCitationConformanceResult_Bug17465_P4() throws Throwable
    {
        File file = new File(data, "gm03/Bug17465_Missing_Responsible_In_FeatureCatalogCitation.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("DQ_ConformanceResult/specification/CI_Citation",
                new Exists(new Finder("title/CharacterString", new EqualText("Perfekt") )));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        file = testFile(file, Control.ISO_GM03, ArrayListMultimap.<String, Requirement>create(), true);
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importGeoreferenceableGeorectifiable17465_P2() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("CHE_MD_Metadata", new Exists(new Finder("MD_Georeferenceable")));
        rules.put("CHE_MD_Metadata", new Exists(new Finder("MD_GridSpatialRepresentation")));
        rules.put("CHE_MD_Metadata", new Exists(new Finder("MD_VectorSpatialRepresentation")));
        rules.put("CHE_MD_Metadata", new Exists(new Finder("MD_Georectified")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        file = testFile(file, Control.ISO_GM03, ArrayListMultimap.<String, Requirement>create(), true);
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void exportImportCountry() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("che:CHE_CI_Address", new Exists(new Finder("gmd:country")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("GM03_2Core.Core.CI_Address", new Exists(new Finder("country")));
        testFile(file, Control.ISO_GM03, rules, true);
    }

    @Test
    public void exportImportLinkage() throws Throwable
    {
        File file = new File(data, "gm03/bug16971.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("CHE_CI_ResponsibleParty/contactInfo/CI_Contact/onlineResource/CI_OnlineResource", new Exists(new Finder("linkage")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

    }

    @Test
    public void importExportParentResponsiblePartyCountry() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("parentResponsibleParty", new Exists(new Finder("CHE_CI_Address")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);
    }

    @Test
    public void importExportMD_Usage() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("resourceSpecificUsage", new Exists(new Finder("MD_Usage")));
        rules.put("MD_Usage", new Exists(new Finder("specificUsage")));
        rules.put("MD_Usage", new Exists(new Finder("usageDateTime")));
        rules.put("MD_Usage", new Exists(new Finder("userDeterminedLimitations")));
        rules.put("MD_Usage", new Exists(new Finder("userContactInfo")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("GM03_2Comprehensive.Comprehensive.MD_Usage", new Exists(new Finder("specificUsage")));
        rules.put("GM03_2Comprehensive.Comprehensive.MD_UsageuserContactInfo", Requirement.ACCEPT);
        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("resourceSpecificUsage", new Exists(new Finder("MD_Usage")));
        rules.put("MD_Usage", new Exists(new Finder("userContactInfo")));
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importExportAggregateInfo() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("aggregationInfo", Requirement.ACCEPT);
        rules.put("MD_AggregateInformation", Requirement.ACCEPT);
        rules.put("aggregateDataSetName", new Exists(new Finder("CI_Citation")));
        rules.put("aggregateDataSetIdentifier", new Exists(new Finder("MD_Identifier")));
        rules.put("associationType", new Exists(new Finder("DS_AssociationTypeCode")));
        rules.put("initiativeType", new Exists(new Finder("DS_InitiativeTypeCode")));
        file = testFile(file, Control.GM03_1_ISO, rules, true);
    }
    
    @Test @Ignore("I don't have time right now to get this to pass")
    public void importExportAggregateInfoFull() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        file = testFile(file, Control.GM03_1_ISO, rules, true);
        
        rules = ArrayListMultimap.create();
        rules.put("GM03_2Comprehensive.Comprehensive.aggregationInfo_MD_Identification", new Exists(new Finder("aggregationInfo")));
        rules.put("GM03_2Comprehensive.Comprehensive.MD_AggregateInformation", new Exists(new Finder("associationType")));
        rules.put("GM03_2Comprehensive.Comprehensive.MD_AggregateInformation", new Exists(new Finder("initiativeType")));
        rules.put("GM03_2Comprehensive.Comprehensive.MD_AggregateInformation", new Exists(new Finder("aggregateDataSetIdentifier")));
        rules.put("GM03_2Comprehensive.Comprehensive.CI_Citation", new Exists(new Finder("MD_AggregateInformation")));
        
        file = testFile(file, Control.ISO_GM03, rules, true);
        
        rules = ArrayListMultimap.create();
        rules.put("aggregationInfo", Requirement.ACCEPT);
        rules.put("MD_AggregateInformation", Requirement.ACCEPT);
        rules.put("aggregateDataSetName", new Exists(new Finder("CI_Citation")));
        rules.put("aggregateDataSetIdentifier", new Exists(new Finder("MD_Identifier")));
        rules.put("associationType", new Exists(new Finder("DS_AssociationTypeCode")));
        rules.put("initiativeType", new Exists(new Finder("DS_InitiativeTypeCode")));
        
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importExportUOM() throws Throwable
    {
        File file = new File(data, "gm03/AllComprehensiveAttributes.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("DQ_QuantitativeResult/valueUnit/BaseUnit/catalogSymbol", new EqualText("m"));
        rules.put("DQ_QuantitativeResult/valueUnit/BaseUnit/name", new EqualText("meter"));
        file = testFile(file, Control.GM03_1_ISO, rules, true);


        rules = ArrayListMultimap.create();
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_QuantitativeResult",
                new Exists(new Finder("valueUnit", new EqualText("m"))));
        testFile(file, Control.ISO_GM03, rules, true);
    }

    @Test
    public void transferUOM() throws Throwable
    {
        File file = new File(data, "gm03/export_Swisstopo2_Metadata_380.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("spatialResolution/MD_Resolution/distance/Distance", new Exists(new Attribute("uom")));
        testFile(file, Control.GM03_1_ISO, rules, true);
    }

    @Test
    public void distributor() throws Throwable
    {
        File file = new File(data, "gm03/bs_mit_distributorFormat.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("MD_Distribution", new Exists(new Finder("distributor")));
        rules.put("MD_Distribution", new Exists(new Finder("transferOptions")));
        testFile(file, Control.GM03_1_ISO, rules, true);
    }

    @Test
    public void exportLinkage() throws Throwable
    {
        File file = new File(data, "iso19139/linkage.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("GM03_2Core.Core.CI_ResponsibleParty", new Exists(new Finder("linkage")));
        rules.put("GM03_2Core.Core.CI_OnlineResource", new Exists(new Finder("linkage")));
        rules.put("GM03_2Core.Core.CI_OnlineResource", new Count(1, new Finder(
                "linkage/GM03_2Core.Core.PT_FreeURL/URLGroup/GM03_2Core.Core.PT_URLGroup/plainURL")));
        rules.put("GM03_2Core.Core.CI_OnlineResource", new Count(1, new Finder(
                "name/GM03_2Core.Core.PT_FreeText/textGroup/GM03_2Core.Core.PT_Group/plainText")));
        rules.put("GM03_2Core.Core.CI_ResponsibleParty", new Not(new Exists(new Finder("electronicalMailAddress"))));
        rules.put("GM03_2Core.Core.CI_ResponsibleParty", new Not(new Exists(new Finder("organisationName"))));
        rules.put("GM03_2Core.Core.CI_ResponsibleParty", new Not(new Exists(new Finder("positionName"))));
        rules.put("GM03_2Core.Core.CI_ResponsibleParty", new Not(new Exists(new Finder("organisationAcronym"))));
        rules.put("GM03_2Comprehensive.Comprehensive", new Not(new Exists(new Finder(
                "GM03_2Core.Core.CI_Telephone/CI_ResponsibleParty"))));
        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("CI_Contact/onlineResource/CI_OnlineResource", new Exists(new Finder("linkage")));
        rules.put("MD_DigitalTransferOptions/onLine/CI_OnlineResource", new Exists(new Finder("linkage")));
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importXMLBLBBOX() throws Throwable
    {
        File file = new File(data, "iso19139/XMLBLBOX.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("GM03_2Comprehensive.Comprehensive",
                new And(new Exists(new Finder("GM03_2Comprehensive.Comprehensive.DQ_ConformanceResult")),
                        new Exists(new Finder("GM03_2Comprehensive.Comprehensive.DQ_QuantitativeResult",
                                              new Exists(new Finder("valueType"))))
                ));

// TODO Find out why some of the items in the model don't seem supported by the xsd...
//        rules.put("GM03_2Comprehensive.Comprehensive.DQ_ElementevaluationProcedure", Requirement.ACCEPT);
//        rules.put("GM03_2Comprehensive.Comprehensive.DQ_ElementmeasureIdentification", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.reportDQ_DataQuality", Requirement.ACCEPT);
        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("gmd:DQ_DataQuality/gmd:scope", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:lineage", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/gmd:DQ_TemporalValidity", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency", Requirement.ACCEPT);
        Requirement hasExpectedConformanceChildren =
            new And(new Exists(new Finder("gmd:explanation")),
                    new Exists(new Finder("gmd:pass/gco:Boolean"))
            );

        Requirement hasExpectedQuantitativeChildren =
            new And(new Exists(new Finder("gmd:valueType/gco:RecordType")),
                    new Exists(new Finder("gmd:valueUnit")),
                    new Exists(new Finder("gmd:errorStatistic/gco:CharacterString")),
                    new Exists(new Finder("gmd:value/gco:Record/arbitrary/c1")),
                    new Exists(new Finder("gmd:value/gco:Record/arbitrary/another"))
                    );


        rules.put("gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency",
                   new And (new Exists(new Finder("gmd:DQ_ConformanceResult", hasExpectedConformanceChildren)),
                            new Exists(new Finder("gmd:DQ_QuantitativeResult", hasExpectedQuantitativeChildren))
                           )
                   );
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importExportDQReports() throws Throwable
    {
        File file = new File(data, "iso19139/allDQ_Reports.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_TemporalValidity", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_TemporalConsistency", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_AccuracyOfATimeMeasurement", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_QuantitativeAttributeAccuracy", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_NonQuantitativeAttributeAccuracy", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_ThematicClassificationCorrectness", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_RelativeInternalPositionalAccuracy", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_GriddedDataPositionalAccuracy", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_AbsoluteExternalPositionalAccuracy", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_TopologicalConsistency", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_FormatConsistency", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_DomainConsistency", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_ConceptualConsistency", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_CompletenessOmission", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.DQ_CompletenessCommission", Requirement.ACCEPT);

        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_TemporalValidity", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_TemporalConsistency", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_AccuracyOfATimeMeasurement", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_QuantitativeAttributeAccuracy", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_NonQuantitativeAttributeAccuracy", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_ThematicClassificationCorrectness", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_RelativeInternalPositionalAccuracy", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_GriddedDataPositionalAccuracy", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_AbsoluteExternalPositionalAccuracy", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_TopologicalConsistency", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_FormatConsistency", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_DomainConsistency", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_ConceptualConsistency", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_CompletenessOmission", Requirement.ACCEPT);
        rules.put("gmd:DQ_DataQuality/gmd:report/DQ_CompletenessCommission", Requirement.ACCEPT);

        testFile(file, Control.GM03_2_ISO, rules, true);
    }


    @Test
    public void importCitation() throws Throwable
    {
        File file = new File(data, "iso19139/missing_extent_data.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("GM03_2Comprehensive.Comprehensive.CI_Citationidentifier", new Exists(new Finder("CI_Citation")));
        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("CI_Citation", new Exists(new Finder("identifier")));
        rules.put("MD_Identifier/code", new Exists(new Finder("PT_FreeText")));
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void mergeExtentsFirstTime() throws Throwable
    {
        File file = new File(data, "iso19139/many_extent_data.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = addMergeExtentsRules();
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void mergeExtentsSecondTime() throws Throwable
    {
        File file = new File(data, "iso19139/many_extent_data.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        file = testFile(file, Control.ISO_GM03, rules, true);
        file = testFile(file, Control.GM03_2_ISO, rules, true);
        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = addMergeExtentsRules();
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void mergeExtentsAfterReusableObjectProcessAndExport() throws Throwable
    {
        File file = new File(data, "iso19139/many_extent_export_from_geocat_after_reusable_objects.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        file = testFile(file, Control.ISO_GM03, rules, true);
        testFile(file, Control.GM03_2_ISO, rules, true);
    }
    private Multimap<String, Requirement> addMergeExtentsRules() {
        Multimap<String, Requirement> rules;
        rules = ArrayListMultimap.create();
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_0", NA, 1, 0, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_1", INCLUDE, 1, 2, 1)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_2", INCLUDE, 0, 1, 1)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_3", INCLUDE, 0, 1, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_4", EXCLUDE, 0, 1, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_5", INCLUDE, 0, 1, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_6", INCLUDE, 0, 1, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_7", INCLUDE, 0, 2, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_8", EXCLUDE, 0, 2, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_9", INCLUDE, 0, 1, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_10", EXCLUDE, 0, 1, 1)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_11", EXCLUDE, 1, 0, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_12", INCLUDE, 1, 0, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_13", INCLUDE, 1, 1, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_15", INCLUDE, 1, 1, 0)));

        rules.put("identificationInfo", new Count(2, new Finder("EX_Extent/description/CharacterString", new StartsWithText("EX_11"))));
        rules.put("identificationInfo", new Count(2, new Finder("EX_Extent/description/CharacterString", new StartsWithText("EX_12"))));

        rules.put("EX_Extent", new And(new Exists(new Finder("geographicElement/EX_GeographicDescription")),
                                       new Count(1, new Finder("geographicElement"))));
        return rules;
    }

    @Test
    public void importHoles() throws Throwable
    {
        File file = new File(data, "iso19139/stackoverflow.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("Polygon", new Count(1, new Finder("exterior")));
        rules.put("Polygon", new Count(1, new Finder("interior")));
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importFormat() throws Throwable
    {
        File file = new File(data, "gm03V2/3-different-types-of-polygons.gm03.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules = ArrayListMultimap.create();
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_1", INCLUDE, 1, 1, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_2", INCLUDE, 0, 1, 0)));
        rules.put("identificationInfo", new Exists(new PolygonValidator("EX_3", INCLUDE, 1, 0, 0)));
        testFile(file, Control.GM03_2_ISO, rules, true);
    }


    @Test
    public void importExportRsIdentifier() throws Throwable
    {
        File file = new File(data, "iso19139/rs_citation_identifier.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("GM03_2Comprehensive.Comprehensive.CI_Citationidentifier", new Exists(new Finder("CI_Citation")));
        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("CI_Citation", new Exists(new Finder("identifier")));
        rules.put("identifier", new Exists(new Finder("RS_Identifier")));
        rules.put("RS_Identifier/code", new Exists(new Finder("PT_FreeText")));
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void importLineageStatement() throws Throwable
    {
        File file = new File(data, "invalid-iso19139.xml");

        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("GM03_2Core.Core.LI_Lineage", new Exists(new Finder("statement/GM03_2Core.Core.PT_FreeText")));
        file = testFile(file, Control.ISO_GM03, rules, true);

        rules = ArrayListMultimap.create();
        rules.put("LI_Lineage", new Exists(new Finder("statement")));
        testFile(file, Control.GM03_2_ISO, rules, true);
    }

    @Test
    public void transferOption() throws Throwable
    {
        File file = new File(data, "gm03/ProblematicTransferOption.xml");
        assertTrue(file.exists());
        file = TransformationTestSupport.transformGM03_1ToIso(file, outputDir);
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("GM03_2Core.Core.CI_OnlineResource", new Exists(new Finder("MD_DigitalTransferOptions")));
        testFile(file, Control.ISO_GM03, rules, true);
    }

    @Test
    public void harversterData() throws Throwable
    {
        File file = new File(data, "gm03/BL_Rept_received.xml");
        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("GM03_2Comprehensive.Comprehensive.MD_DigitalTransferOptions", new Exists(new Finder("offLine")));
        rules.put("GM03_2Comprehensive.Comprehensive.MD_Medium", new Exists(new Finder("name")));
        testFile(file, Control.GMO_1_ISO_GM03, rules, true);
    }

    @Test
    public void zonengrenzen() throws Throwable
    {
        File file = new File(data, "gm03/xMetadataxZonengrenzen.xml");

        Multimap<String, Requirement> rules = ArrayListMultimap.create();
        rules.put("LI_ProcessStep/description", Requirement.ACCEPT);
        rules.put("LI_ProcessStep/dateTime", Requirement.ACCEPT);
        File iso = testFile(file, Control.GM03_1_ISO, rules, true);

        rules.clear();
        rules.put("GM03_2Comprehensive.Comprehensive.sourceLI_Lineage/LI_Lineage", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.sourceLI_Lineage/source", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.LI_ProcessStep/description", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.LI_ProcessStep/dateTime", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.LI_ProcessStep/LI_Lineage", Requirement.ACCEPT);
        rules.put("GM03_2Comprehensive.Comprehensive.LI_Source/description", Requirement.ACCEPT);

        testFile(iso, Control.ISO_GM03, rules, true);
    }

    /**
     *
     * @param file
     *            file to test
     * @param control
     *            a contol explaining what transforms are required
     * @param validationRules
     *            the rules to test (node/node-segment to find, requirement
     *            tests to run at that node)
     * @param testValidity
     * @return file after transform
     */
    private File testFile(File file, Control control, Multimap<String, Requirement> validationRules, boolean testValidity) throws Throwable
    {

        assertTrue(file.exists());

        File transformed;

        switch (control)
        {
        case GM03_1_ISO:
        {
            transformed = TransformationTestSupport.transformGM03_1ToIso(file, outputDir, testValidity);
            break;
        }
        case GM03_2_ISO:
        {
            transformed = TransformationTestSupport.transformGM03_2toIso(file, outputDir, testValidity);
            break;
        }
        case ISO_GM03:
        {
            if (!file.getParentFile().equals(outputDir)) {
                outputDir.mkdir();
                File copied = TransformationTestSupport.copy(file, new File(outputDir, file.getName()));
                transformed = TransformationTestSupport.transformIsoToGM03(copied, outputDir, testValidity);
            } else {
                transformed = TransformationTestSupport.transformIsoToGM03(file, outputDir, testValidity);
            }
            break;
        }
        case GMO_1_ISO_GM03:
        {

            transformed = TransformationTestSupport.transformGM03_1ToIso(file, outputDir, testValidity);
            transformed = TransformationTestSupport.transformIsoToGM03(transformed, outputDir, testValidity);
            break;
        }
        default:
            throw new RuntimeException();
        }

        Element xml = Xml.loadFile(transformed);
        Collection<Entry<String, Requirement>> rules = validationRules.entries();
        StringBuilder failures = new StringBuilder();
        for (Entry<String, Requirement> entry : rules) {
            Finder finder = new Finder(entry.getKey(), entry.getValue());
            if (!finder.matches(xml) && !xml.getDescendants(finder).hasNext()) {
                failures.append("Failure with rule: " + entry.getKey() + "[" + entry.getValue() + "]");
                failures.append("\n");
            }
        }

        assertTrue("\n" + failures.toString(), failures.length() == 0);

        return transformed;
    }

    enum Control
    {
        /**
         * Indicates a transform from GM03 1.8 to ISO
         */
        GM03_1_ISO,
        /**
         * Indicates a transform from GM03 2.0 to ISO
         */
        GM03_2_ISO,
        /**
         * Indicates a transform from ISO to GM03 2.0
         */
        ISO_GM03,
        /**
         * Indicates a transform from GM03 1.8 to ISO to GM03 2.0
         */
        GMO_1_ISO_GM03
    }

    private static class Attribute implements Filter
    {
        private static final long serialVersionUID = 1L;
        private final String      _elemName;
        private final String      _attName;
        private final String      _expected;

        public Attribute(String elemName, String attName, String expectedValue)
        {
            super();
            _elemName = elemName;
            _attName = attName;
            _expected = expectedValue;
        }

        public Attribute(String attName)
        {
            this(null, attName, null);
        }

        public boolean matches(Object arg0)
        {
            if (arg0 instanceof Element) {
                Element e = (Element) arg0;
                if (_elemName!=null && !e.getName().equals(_elemName)) {
                    return false;
                }
                if (_expected == null) {
                    return e.getAttributeValue(_attName) != null;
                } else {
                    boolean result = _expected.equals(e.getAttributeValue(_attName));
                    if (_elemName != null && !result) {
                        System.out.println("Expected " + toString() + " but got " + e.getAttributeValue(_attName));
                    }
                    return result;
                }
            }
            return false;
        }

        @Override
        public String toString()
        {
            String e = _elemName == null ? "" : _elemName;
            if (_expected == null) {
                return e + "@" + _attName;
            } else {
                return e + "@" + _attName + " = " + _expected;
            }
        }

    }

    public static class Not implements Requirement
    {
        private final Requirement _req;

        public Not(Requirement req)
        {
            super();
            _req = req;
        }

        public boolean eval(Element e)
        {
            return !_req.eval(e);
        }

        @Override
        public String toString()
        {
            return "not(" + _req + ")";
        }
    }

    private static class EqualText implements Requirement
    {

        private final String _expected;

        public EqualText(String expected)
        {
            if (expected == null)
                throw new IllegalArgumentException("expected cannot be null");
            _expected = expected;
        }

        public boolean eval(Element e)
        {
            return _expected.equals(e.getText());
        }

        @Override
        public String toString()
        {
            return "text() = " + _expected;
        }
    }
    private static class StartsWithText implements Requirement
    {

        private final String _expected;

        public StartsWithText(String expected)
        {
            if (expected == null)
                throw new IllegalArgumentException("expected cannot be null");
            _expected = expected;
        }

        public boolean eval(Element e)
        {
            return e.getText()!=null && e.getText().startsWith(_expected);
        }

        @Override
        public String toString()
        {
            return "startsWith(text()) = " + _expected;
        }
    }

    private static class Count implements Requirement
    {

        private final int    _expected;
        private final Filter _filter;

        public Count(int expected, Filter filter)
        {
            this._filter = filter;
            _expected = expected;
        }

        @SuppressWarnings("rawtypes")
        public boolean eval(Element e)
        {
            Iterator descendants = e.getDescendants(_filter);
            int count = 0;
            while (descendants.hasNext()) {
                count++;
                descendants.next();
            }

            System.out.println(_filter + " " + count);

            return _expected == count;
        }

        @Override
        public String toString()
        {
            return "count[" + _filter + "] = " + _expected;
        }
    }

    private static class Exists implements Requirement
    {

        private final Filter _filter;

        public Exists(Filter filter)
        {
            this._filter = filter;
        }

        public boolean eval(Element e)
        {
            return _filter.matches(e) || e.getDescendants(_filter).hasNext();
        }

        public String toString()
        {
            return "Exists[" + _filter + "]";
        }
    }

    private static class And implements Requirement
    {

        private final Requirement[] _filters;

        public And(Requirement... filter)
        {
            this._filters = filter;
        }

        public boolean eval(Element e)
        {
            for (Requirement f : _filters) {
                if (!f.eval(e)) {
                    return false;
                }
            }
            return true;
        }

        public String toString()
        {
            return "Exists[" + Arrays.toString(_filters) + "]";
        }
    }
}
