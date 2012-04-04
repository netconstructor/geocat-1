package org.fao.xsl;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.util.List;

import jeeves.utils.Xml;

import org.fao.geonet.constants.Geocat;
import org.fao.geonet.util.XslUtil;
import org.jdom.Element;
import org.jdom.Namespace;
import org.junit.Test;

public class CharacterStringToLocalisedTest {

    @Test
    public void convertCharacterstrings() throws Exception {
        String pathToXsl = TransformationTestSupport.geonetworkWebapp+"/xsl/characterstring-to-localisedcharacterstring.xsl";
        String testData = "/data/iso19139/contact_with_linkage.xml";
        Element data = TransformationTestSupport.transform(getClass(), pathToXsl, testData );

        assertNoLocalisationString(data, "gmd:language");
        assertLocalisationString(data, ".//che:CHE_CI_ResponsibleParty/gmd:organisationName");
        assertLocalisationString(data, ".//che:CHE_CI_ResponsibleParty/che:organisationAcronym");
        assertLocalisationURL(data, ".//che:CHE_CI_ResponsibleParty//gmd:linkage");
        assertNoLocalisationString(data, ".//che:CHE_CI_ResponsibleParty//gmd:electronicMailAddress");
        assertNoLocalisationString(data, "./gmd:dataSetURI");

        assertNoLocalisationString(data, ".//gmd:distributionFormat//gmd:name");
        assertNoLocalisationString(data, ".//gmd:distributionFormat//gmd:version");
    }
    @Test
    public void convertGmdLinkageIncorrectlyEmbeds() throws Exception
    {
        String pathToXsl = TransformationTestSupport.geonetworkWebapp+"/xsl/characterstring-to-localisedcharacterstring.xsl";

        Element testData = Xml.loadString(
                "<gmd:linkage xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:che=\"http://www.geocat.ch/2008/che\" xmlns:gml=\"http://www.opengis.net/gml\" xmlns:gco=\"http://www.isotc211.org/2005/gco\" xmlns:gmd=\"http://www.isotc211.org/2005/gmd\" xsi:type=\"che:PT_FreeURL_PropertyType\">" +
                "<gmd:URL>http://wms.geo.admin.ch/?lang=de&amp;</gmd:URL>" +
                "<che:PT_FreeURL><che:URLGroup><che:LocalisedURL locale=\"#FR\">http://wms.geo.admin.ch/?lang=fr&amp;</che:LocalisedURL></che:URLGroup></che:PT_FreeURL>" +
                "</gmd:linkage>", false);

        Element transformed = Xml.transform(testData, pathToXsl);
        
        assertEquals(1, transformed.getChildren("PT_FreeURL", XslUtil.CHE_NAMESPACE).size());
        assertEquals(1, transformed.getChildren().size());
        assertEquals(2, transformed.getChild("PT_FreeURL", XslUtil.CHE_NAMESPACE).getChildren("URLGroup", XslUtil.CHE_NAMESPACE).size());
    }
    private void assertNoLocalisationString(Element data, String baseXPath) throws Exception {
        assertNoLocalisation(data, baseXPath, "gmd:PT_FreeText", "gco:CharacterString");
    }
    private void assertLocalisationString(Element data, String baseXPath) throws Exception {
        assertLocalisation(data, baseXPath, "gmd:PT_FreeText", "gco:CharacterString", "gmd:PT_FreeText_PropertyType");
    }
    private void assertNoLocalisationURL(Element data, String baseXPath) throws Exception {
        assertNoLocalisation(data, baseXPath, "che:LocalisedURL", "gmd:URL");
    }
    private void assertLocalisationURL(Element data, String baseXPath) throws Exception {
        assertLocalisation(data, baseXPath, "che:LocalisedURL", "gmd:URL", "che:PT_FreeURL_PropertyType");
    }
    
    private void assertNoLocalisation(Element data, String baseXPath, String multiple, String single) throws Exception {
        assertEquals(0, Xml.selectNodes(data, baseXPath+"//"+multiple).size());
        assertFalse(Xml.selectNodes(data, baseXPath+"//"+single).isEmpty());
    }

    private void assertLocalisation(Element data, String baseXPath, String multiple, String single,String attribute) throws Exception {
        List<Element> e = (List<Element>)Xml.selectNodes(data, baseXPath);
        for (Element elem : e) {
            assertEquals(attribute, elem.getAttributeValue("type", Namespace.getNamespace("http://www.w3.org/2001/XMLSchema-instance")));
        }
        assertEquals(0, Xml.selectNodes(data, baseXPath+"//"+single).size());
        assertFalse(Xml.selectNodes(data, baseXPath+"//"+multiple).isEmpty());
    }

}
