package org.fao.xsl;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.util.List;

import jeeves.utils.Xml;

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
