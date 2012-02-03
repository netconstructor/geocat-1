package org.fao.geonet.logos;

import jeeves.server.ConfigurationOverrides;
import jeeves.server.context.ServiceContext;
import jeeves.server.sources.http.JeevesServlet;
import org.jdom.Element;
import org.jdom.JDOMException;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServlet;
import java.io.*;
import java.nio.channels.Channels;

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
            Element logosDirElem = configXml.getChild("appHandler").getChild("logosDir");
            String logosDir;
            if (logosDirElem == null) {
                logosDir = context.getRealPath("images/logos");
            } else {
                logosDir = logosDirElem.getTextTrim();
                if (logosDir.startsWith("./")) {
                    logosDir = context.getRealPath(logosDir);
                }
            }
            System.setProperty(context.getServletContextName() + ".logos.dir", logosDir);

            return logosDir;
        } else {
            return System.getProperty("logos.dir", appDir + File.separator + "images/logos");
        }
    }

    public static byte[] loadDummyImage(String logosDir, ServletContext context, String appPath) throws IOException {
        File dummyFile = new File(logosDir, "dummy.gif");
        if (!dummyFile.exists()) {
            if(context != null) {
                dummyFile = new File(context.getRealPath("images/logos/dummy.gif"));
            } else {
                dummyFile = new File(appPath+File.separator+"images/logos/dummy.gif");
            }
        }

        if (dummyFile.exists()) {
            ByteArrayOutputStream data = new ByteArrayOutputStream();
            transferTo(dummyFile.getPath(), data);
            return data.toByteArray();
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
