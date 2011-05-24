package jeeves.server;


import static org.junit.Assert.*;
import jeeves.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.junit.Test;

import java.io.IOException;
import java.util.List;

public class ConfigurationOveridesTest {

    @Test
    public void updateConfig() throws JDOMException, IOException {
        ClassLoader classLoader = getClass().getClassLoader();
        Element config = Xml.loadFile(classLoader.getResource("test-config.xml"));
        Element config2 = (Element) Xml.loadFile(classLoader.getResource("test-config.xml")).clone();
        Element overrides = Xml.loadFile(classLoader.getResource("config-overrides.xml"));
        ConfigurationOverrides.updateConfig(overrides,"config.xml", config);
        ConfigurationOverrides.updateConfig(overrides,"config2.xml", config2);

        assertLang("fr",config);
        assertLang("de", config2);

        assertEquals("xml/europeanCountries.xml", Xml.selectString(config,"default/gui/xml[@name = 'countries']/@file"));
        assertEquals("xml/other.xml", Xml.selectString(config2,"default/gui/xml[@name = 'countries']/@file"));

        assertTrue(Xml.selectNodes(config,"default/gui/@removeAtt").isEmpty());
        assertEquals(1,Xml.selectNodes(config,"default/gui/@newAtt").size());
        assertEquals("newValue",Xml.selectString(config,"default/gui/@newAtt"));

        assertEquals(1,Xml.selectElement(config,"resources").getChildren().size());
        assertEquals(1,Xml.selectNodes(config,"resources/resource/config/url").size());
        assertEquals("jdbc:oracle:thin:@localhost:1521:fs",Xml.selectElement(config,"resources/resource/config/url").getTextTrim());

        assertTrue(Xml.selectNodes(config,"*//toRemove").isEmpty());
        assertTrue(Xml.selectNodes(config,"*//gui/xml[@name = countries2]").isEmpty());
        assertEquals(1, Xml.selectNodes(config,"newNode").size());
        assertEquals(1, Xml.selectNodes(config,"default/gui").size());

        assertEquals(1, Xml.selectNodes(config,"default/gui/text()").size());
        assertEquals("ExtraText", Xml.selectString(config,"default/gui/text()"));
    }

    private void assertLang(String expected, Element config) throws JDOMException {
        List<Element> lang = Xml.selectNodes(config,"*//language");
        assertEquals(1,lang.size());
        assertEquals(expected, lang.get(0).getTextTrim());
    }
}
