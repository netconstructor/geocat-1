package jeeves.server;

import jeeves.server.sources.http.JeevesServlet;
import jeeves.utils.Xml;
import org.jdom.*;
import org.jdom.filter.Filter;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * This class assists JeevesEngine by allowing certain configurations to be overridden.
 *
 *
 * The idea is to allow configurations to have seconds overridden for a specific server deployment.
 * A common scenario is to have test and production instances with different configurations.  In both configurations
 * 90% of the configuration is the same but certain parts need to be updated.
 *
 * This class allows an override file to be specified as a system property or a servlet init parameter (jeeves.configuration.overrides.file).
 * The configuration in the override file will override settings in the "standard" loaded configuration
 * files.
 *
 * The overrides file can be a file (relative to the servlet base) or a URL
 *
 * Note:  When writing the xpath the root not should not be in the xpath and the path should not
 *        start with a /.
 *
 * The override configuration structure is an XML file as follows:
 * <pre><[[CDATA[
 * <overrides>
     <!-- properties allow some properties to be defined that will be substituted -->
     <!-- into text or attributes where ${property} is the substitution pattern -->
     <!-- The properties can reference other properties -->
     <properties>
         <fr>fr</fr>
         <lang>${fr}</lang>
         <host>localhost</host>
         <enabled>true</enabled>
         <dir>xml</dir>
     </properties>
     <!-- In this version only the file name is considered not the path.  -->
     <!-- So case conf1/config.xml and conf2/config.xml cannot be handled -->
     <file name="config.xml">
         <!-- This example will update the file attribute of the xml element with the name attribute 'countries' -->
         <replaceAtt xpath="default/gui/xml[@name = 'countries']" attName="file" value="${dir}/europeanCountries.xml"/>
         <!-- if there is no value then the attribute is removed -->
         <replaceAtt xpath="default/gui" attName="removeAtt"/>
         <!-- If the attribute does not exist it is added -->
         <replaceAtt xpath="default/gui" attName="newAtt" value="newValue"/>

         <!-- This example will replace all the xml in resources with the contained xml -->
         <replaceXML xpath="resources">
           <resource enabled="${enabled}">
             <name>main-db</name>
             <provider>jeeves.resources.dbms.DbmsPool</provider>
              <config>
                  <user>admin</user>
                  <password>admin</password>
                  <driver>oracle.jdbc.driver.OracleDriver</driver>
                  <!-- ${host} will be updated to be local host -->
                  <url>jdbc:oracle:thin:@${host}:1521:fs</url>
                  <poolSize>10</poolSize>
              </config>
           </resource>
         </replaceXML>
         <!-- This example simple replaces the text of an element -->
         <replaceText xpath="default/language">${lang}</replaceText>
         <!-- This examples shows how only the text is replaced not the nodes -->
         <replaceText xpath="default/gui">ExtraText</replaceText>
         <!-- append xml as a child to a section (If xpath == "" then that indicates the root of the document),
              this case adds nodes to the root document -->
         <addXML xpath=""><newNode/></addXML>
         <!-- append xml as a child to a section, this case adds nodes to the root document -->
         <addXML xpath="default/gui"><newNode2/></addXML>
         <!-- remove a single node -->
         <removeXML xpath="default/gui/xml[@name = countries2]"/>
         <!-- remove all matching nodes -->
         <removeXML xpath="default//toRemove"/>
     </file>
     <file name="config2.xml">
         <replaceAtt xpath="default/gui/xml[@name = 'countries']" attName="file" value="${dir}/other.xml"/>
         <replaceText xpath="default/language">de</replaceText>
     </file>
 </overrides>
 * ]]></pre>
 */
class ConfigurationOverrides {
    enum Updates {
        REPLACEATT,
        REPLACEXML,
        ADDXML,
        REMOVEXML,
        REPLACETEXT
    }
    private static String OVERRIDES_KEY="jeeves.configuration.overrides.file";
    private static String ATTNAME_ATTR_NAME="attName";
    private static String VALUE_ATTR_NAME="value";
    private static String XPATH_ATTR_NAME="xpath";
    private static String FILE_NODE_NAME ="file";
    private static String FILE_NAME_ATT_NAME ="name";
    private static Pattern PROP_PATTERN=Pattern.compile("\\$\\{(.+?)\\}");
    private static final Filter ELEMENTS_FILTER = new Filter() {
        public boolean matches(Object obj) {
            return obj instanceof Element;
        }
    };
    private static final Filter TEXTS_FILTER = new Filter() {
        public boolean matches(Object obj) {
            return obj instanceof Text;
        }
    };


    public static void updateWithOverrides(String configFile, JeevesServlet servlet, Element configRoot) throws JDOMException, IOException {
        String overrides = System.getProperty(OVERRIDES_KEY);
        if(overrides == null) {
            overrides = servlet.getInitParameter(OVERRIDES_KEY);
        }
        if(overrides == null) {
            overrides = servlet.getServletContext().getInitParameter(OVERRIDES_KEY);
        }

        if(overrides != null) {
            Element xml;
            try {
                xml = Xml.loadFile(new URL(overrides));
            } catch (MalformedURLException e) {
                InputStream is = servlet.getServletContext().getResourceAsStream(overrides);
                try {
                    xml = Xml.loadStream(is);
                } finally {
                    is.close();
                }
            }
            updateConfig(xml,new File(configFile).getName(),configRoot);
        }
    }

    /**
     * default visibility so that unit tests can be written against it
     */
    static void updateConfig(Element overrides, String fileName, Element configRoot) throws JDOMException {
        Properties properties = loadProperties(overrides);
        List<Element> files = overrides.getChildren(FILE_NODE_NAME);
        for (Element file : files) {
            String expectedfileName = file.getAttributeValue(FILE_NAME_ATT_NAME);
            if(expectedfileName.equals(fileName)) {
                List<Element> elements = file.getChildren();
                for (Element element : elements) {
                    switch (Updates.valueOf(element.getName().toUpperCase())) {
                        case ADDXML:
                            addXml(properties, element, configRoot);
                            break;
                        case REMOVEXML:
                            removeXml(properties, element, configRoot);
                            break;
                        case REPLACEXML:
                            replaceXml(properties, element, configRoot);
                            break;
                        case REPLACEATT:
                            replaceAtts(properties, element, configRoot);
                            break;
                        case REPLACETEXT:
                            replaceText(properties, element, configRoot);
                            break;
                        default:
                            throw new IllegalArgumentException(element.getName() + " is not a recognized update tag");
                    }
                }
            }
        }
    }

    private static void removeXml(Properties properties, Element elem, Element configRoot) throws JDOMException {
            String xpath = getXPath(elem);
            List<Element> matches = xpathLookup(configRoot, xpath);

            for (Element match : matches) {
                match.detach();
            }
    }

    private static void addXml(Properties properties, Element elem, Element configRoot) throws JDOMException {
            List<Content> newXml = updateProperties(properties, elem);
            String xpath = getXPath(elem);
            if(xpath.trim().equals("")) {
                configRoot.addContent(newXml);
            } else {
                List<Element> matches = xpathLookup(configRoot, xpath);
                for (Element match : matches) {
                    match.addContent(newXml);
                }
            }
    }

    private static void replaceXml(Properties properties, Element elem, Element configRoot) throws JDOMException {
            String xpath = getXPath(elem);
            List<Element> matches = xpathLookup(configRoot, xpath);
            List<Content> newXml = updateProperties(properties,elem);
            for (Element toUpdate : matches) {
                toUpdate.setContent(newXml) ;
            }
    }

    private static void replaceText(Properties properties, Element elem, Element configRoot) throws JDOMException {
            String xpath = getXPath(elem);
            List<Element> matches = xpathLookup(configRoot, xpath);
            for (Element toUpdate : matches) {
                List<Text> textContent = toList(toUpdate.getDescendants(TEXTS_FILTER));
                String text = updatePropertiesInText(properties, elem.getText());
                if(textContent.size() > 0) {
                    for (int i = 0; i < textContent.size(); i++) {
                        Text text1 =  textContent.get(i);
                        if(i==0)
                            text1.setText(text);
                        else {
                            text1.detach();
                        }
                    }
                } else {
                    toUpdate.addContent(text);
                }
            }
    }

    private static void replaceAtts(Properties properties, Element elem, Element configRoot) throws JDOMException {
            String xpath = getXPath(elem);
            List<Element> matches = xpathLookup(configRoot, xpath);
            String attName = getCaseInsensitiveAttValue(elem, ATTNAME_ATTR_NAME,true);
            String newValue = updatePropertiesInText(properties, getCaseInsensitiveAttValue(elem,VALUE_ATTR_NAME,false));
            for (Element toUpdate : matches) {
                if(newValue == null) {
                    toUpdate.removeAttribute(attName);
                } else {
                    toUpdate.setAttribute(attName, newValue);
                }
            }
    }

    private static List<Element> xpathLookup(Element configRoot, String xpath) throws JDOMException {
        return Xml.selectNodes(configRoot,xpath);
    }

    private static Properties loadProperties(Element overrides) {
        Properties properties = new Properties();
        List<Element> pElem = overrides.getChildren("properties");
        for (Element element : pElem) {
            List<Element> props = element.getChildren();
            for (Element prop : props) {
                String key = prop.getName();
                String value = prop.getTextTrim();
                properties.put(key,value);
            }
        }

        while(!resolve(properties));
        return properties;
    }

    private static String getXPath(Element elem) {
        return getCaseInsensitiveAttValue(elem,XPATH_ATTR_NAME,true);
    }

    private static String getCaseInsensitiveAttValue(Element elem,String name,boolean exceptionOnFailure) {
        List<Attribute> atts = elem.getAttributes();
        for (Attribute att : atts) {
            if(att.getName().equalsIgnoreCase(name)) {
                return att.getValue();
            }
        }
        if(exceptionOnFailure)
            throw new AssertionError(elem.getName()+" does not have a '"+name+"' attribute");
        else
            return null;
    }

    private static List<Content> updateProperties(Properties properties, Element elem) {
        Element clone = (Element) elem.clone();
        Iterator<Element> iter = clone.getDescendants(ELEMENTS_FILTER);

        List<Element> elems = toList(iter);

        for (Element next : elems) {
            List<Attribute> atts = next.getAttributes();
            for (Attribute att : atts) {
                if(!att.getName().equalsIgnoreCase(XPATH_ATTR_NAME)) {
                    String updatedValue = updatePropertiesInText(properties, att.getValue());
                    att.setValue(updatedValue);
                }
            }
        }
        Iterator<Text> iter2 = clone.getDescendants(TEXTS_FILTER);

        List<Text> textNodes = toList(iter2);

        for(Text text:textNodes) {
            String updatedText = updatePropertiesInText(properties, text.getText());
            text.setText(updatedText);
        }

        List<Content> newXml = new ArrayList<Content>(clone.getChildren());
        for (Content content : newXml) {
            content.detach();
        }

        return newXml;
    }

    private static List toList(Iterator iter) {
        ArrayList elems = new ArrayList();
        while(iter.hasNext()) {
            elems.add(iter.next());
        }
        return elems;
    }

    private static String updatePropertiesInText(Properties properties, String value) {
        if(value == null) {
            return null;
        }
        String updatedValue = value;
        Matcher matcher = PROP_PATTERN.matcher(updatedValue);
        while(matcher.find()) {
            String propKey = matcher.group(1);
            String propValue = properties.getProperty(propKey);

            if(propValue == null) {
                throw new IllegalArgumentException("Found a reference to a variable: "+propKey+" which is not a valid property.  Check the spelling");
            }
            String dataToReplace = matcher.group(0);
            updatedValue = updatedValue.replace(dataToReplace, propValue);
        }
        return updatedValue;
    }

    private static boolean resolve(Properties properties) {
        boolean finishedResolving = true;
        Set<Map.Entry<Object, Object>> entries = properties.entrySet();
        for (Map.Entry<Object, Object> entry: entries){
            String key = entry.getKey().toString();
            String value = entry.getValue().toString();
            Matcher matcher = PROP_PATTERN.matcher(value);

            if(matcher.find())
                finishedResolving = false;

            String updatedValue = updatePropertiesInText(properties, value);
            properties.put(key,updatedValue);
        }
        return finishedResolving;
    }


}
