package org.fao.geonet.logos;

import jeeves.server.ConfigurationOverrides;
import jeeves.server.context.ServiceContext;
import jeeves.server.sources.http.JeevesServlet;
import jeeves.utils.Log;

import org.fao.geonet.constants.Geonet;
import org.jdom.Element;
import org.jdom.JDOMException;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServlet;
import java.io.*;
import java.nio.channels.Channels;
import java.util.Iterator;
import java.util.List;

/**
 * Utility methods for managing logos
 * User: jeichar
 * Date: 1/17/12
 * Time: 5:51 PM
 */
public class Logos {

    public static String locateLogosDir(ServiceContext context) {
        ServletContext servletContext = null;
        if (context.getServlet() != null) {
            servletContext = context.getServlet().getServletContext();
        }
        return locateLogosDir(servletContext, context.getAppPath());
    }

    public static String locateLogosDir(ServletContext context, String appDir) {
        if (context != null) {
            Element configXml = ConfigurationOverrides.loadXmlFileAndUpdate("/WEB-INF/config.xml", context);
            List<Element> logosDirElem = configXml.getChild("appHandler").getChildren("param");
            String logosDir = null;
            for(Element e : logosDirElem) {
                if(e.getAttributeValue("name").equalsIgnoreCase("logosDir")) {
                    logosDir = e.getAttributeValue("value");
                    break;
                }
            }
            if (logosDirElem == null) {
                logosDir = context.getRealPath("images/logos");
            } 
            System.setProperty(context.getServletContextName() + ".logos.dir", logosDir);
            new File(logosDir).mkdirs();
            return logosDir;
        } else {
            return System.getProperty("logos.dir", appDir + File.separator + "images/logos");
        }
    }

    public static byte[] loadImage(String logosDir, ServletContext context, String appPath, String filename, byte[] defaultValue) {
        File dummyFile = new File(logosDir, filename);
        if (!dummyFile.exists()) {
            if(context != null) {
                dummyFile = new File(context.getRealPath("images/logos/"+filename));
            } else {
                dummyFile = new File(appPath, "images/logos/"+filename);
            }
        }

        if (dummyFile.exists()) {
            try {
            ByteArrayOutputStream data = new ByteArrayOutputStream();
            transferTo(dummyFile.getPath(), data);
            return data.toByteArray();
            } catch (IOException e) {
                Log.warning(Geonet.LOGOS, "Unable to find logo "+filename);
                return defaultValue;
            }
        }
        return new byte[0];
    }

    static void transferTo(String path, OutputStream out) throws IOException {
        final FileInputStream fileInputStream = new FileInputStream(path);
        try {
            fileInputStream.getChannel().transferTo(0, Long.MAX_VALUE, Channels.newChannel(out));
        } finally {
            fileInputStream.close();
        }
    }
}
