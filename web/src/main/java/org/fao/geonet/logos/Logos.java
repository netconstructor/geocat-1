package org.fao.geonet.logos;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.channels.Channels;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.ServletContext;

import jeeves.server.ConfigurationOverrides;
import jeeves.server.context.ServiceContext;
import jeeves.utils.BinaryFile;
import jeeves.utils.Log;

import org.apache.commons.io.IOUtils;
import org.fao.geonet.constants.Geonet;
import org.jdom.Element;

/**
 * Utility methods for managing images that are site dependent.  In other words that can be added to or modified by Geonetwork and therefore should not be overwritten
 * if the geonetwork webapp is redeployed.
 * 
 * User: jeichar
 * Date: 1/17/12
 * Time: 5:51 PM
 */
public class Logos {

    /**
     * Find the configured directory containing logos.  The directory the logos are located in depends on 
     * the configuration of dataImagesDir in the config.xml.  
     * 
     * (Overrides will be applied so the actual config can be in overrides)
     * 
     * @return locateDataImagesDir(...) + FS + "logos"
     */
    public static String locateLogosDir(ServiceContext context) {
        ServletContext servletContext = null;
        if (context.getServlet() != null) {
            servletContext = context.getServlet().getServletContext();
        }
        return locateLogosDir(servletContext, context.getAppPath());
    }

    /**
     * Find the configured directory containing logos.  The directory the logos are located in depends on 
     * the configuration of dataImagesDir in the config.xml.  
     * 
     * (Overrides will be applied so the actual config can be in overrides)
     * 
     * @return locateDataImagesDir(...) + FS + "logos"
     */
    public static String locateLogosDir(ServletContext context, String appDir) {
        String path = locateDataImagesDir(context,appDir)+File.separator+"logos";
        File file = new File(path);
        if(!file.exists() && !file.mkdirs()) {
            throw new AssertionError("Unable to create the logos directory. Permissions problem? "+path);
        }
        return path;
    }
    
    /**
     * Find the configured directory containing harvester logos.  The directory the logos are located in depends on 
     * the configuration of dataImagesDir in the config.xml.  
     * 
     * (Overrides will be applied so the actual config can be in overrides)
     * 
     * @return locateDataImagesDir(...) + FS + "harvesting"
     */
    public static String locateHarvesterLogosDir(ServiceContext context) {
        ServletContext servletContext = null;
        if (context.getServlet() != null) {
            servletContext = context.getServlet().getServletContext();
        }
        return locateHarvesterLogosDir(servletContext, context.getAppPath());
    }
    
    /**
     * Find the configured directory containing harvester logos.  The directory the logos are located in depends on 
     * the configuration of dataImagesDir in the config.xml.  
     * 
     * (Overrides will be applied so the actual config can be in overrides)
     * 
     * @return locateDataImagesDir(...) + FS + "harvesting"
     */
    public static String locateHarvesterLogosDir(ServletContext context, String appDir) {
        String path = locateDataImagesDir(context,appDir)+File.separator+"harvesting";
        File file = new File(path);
        if(!file.exists() && !file.mkdirs()) {
            throw new AssertionError("Unable to create the harvester logos directory. Permissions problem? "+path);
        }
        return path;
    }

    /**
     * The root of the "data" images.  A Data image is an image that is dependent on the webapplication instance.  They are the 
     * images that change from installation to installation like logos and harvester logos.  
     * 
     * The directory is configured by config.xml and the configuration overrides.  See the information on configuration overrides for methods
     * of configuring them.
     * 
     * @return the root of data images.  Subdirectories such as logos and harvesting likely contain the actual images
     */
    public static String locateDataImagesDir( ServiceContext context) {
        ServletContext servletContext = null;
        if (context.getServlet() != null) {
            servletContext = context.getServlet().getServletContext();
        }
        return locateDataImagesDir(servletContext, context.getAppPath()); 
    }

    /**
     * The root of the "data" images.  A Data image is an image that is dependent on the webapplication instance.  They are the 
     * images that change from installation to installation like logos and harvester logos.  
     * 
     * The directory is configured by config.xml and the configuration overrides.  See the information on configuration overrides for methods
     * of configuring them.
     * 
     * @return the root of data images.  Subdirectories such as logos and harvesting likely contain the actual images
     */
    public static String locateDataImagesDir( ServletContext context, String appDir ) {
        if (context != null) {
            Element configXml = ConfigurationOverrides.loadXmlFileAndUpdate("/WEB-INF/config.xml", context);
            @SuppressWarnings("unchecked")
            List<Element> logosDirElem = configXml.getChild("appHandler").getChildren("param");
            String imagesDir = null;
            for(Element e : logosDirElem) {
                if(e.getAttributeValue("name").equalsIgnoreCase("dataImagesDir")) {
                    imagesDir = e.getAttributeValue("value");
                    break;
                }
            }
            if (imagesDir == null) {
                imagesDir = context.getRealPath("images");
            } 
            System.setProperty(context.getServletContextName() + "data.images.dir", imagesDir);
            File file = new File(imagesDir);
            if(!file.exists() && !file.mkdirs()) {
                throw new AssertionError("Unable to create the base data images directory. Permissions problem? "+imagesDir);
            }

            return imagesDir;
        } else {
            return System.getProperty("data.images.dir", appDir + File.separator + "images");
        }
    }

    /**
     * Load a data image.  The "imagesDir" will first be searched for the logo, then the context then finally the appPath+FS+filename.  if the image
     * is not in imagesDir but is found in one of the other locations it will be copied to imagesDir for future use.  
     * 
     * Use case of this copying is the default harvesting logos are shipped with the webapp and when used they are copied to the imagesDir so that the imagesDir contain
     * all relevant images.  This allow system administrators to ignore the images in the webapp and only configure/backup images in the logos directory.
     * 
     * @param imagesDir Should be {@link #locateDataImagesDir(ServiceContext)}.  This is added as a parameter because it takes time to look up the imagesDir.  
     *                          for performance reasons a caller can cache imagesDir.  If null the imagesDir will be looked up. 
     * @param context the context for finding the image if the image is not in imagesDir. (may be null)
     * @param appPath the fallback if images dir and context cannot be used to lookup the imagesDir (or if context is null which is permitted)
     * @param filename the file to look up.  will normally contains a prefix like logos/ or harvesting/
     * @param defaultValue the image to return if unable to find the actual image
     * @return the bytes of the actual image or defaultValue
     * 
     */
    static byte[] loadImage(String imagesDir, ServletContext context, String appPath, String filename, byte[] defaultValue) throws IOException {
        String imagesDirConcrete = imagesDir;
        if(imagesDirConcrete == null) {
            imagesDirConcrete = locateDataImagesDir(context, appPath);
        }
        File file = locateImage(imagesDirConcrete, context, appPath, filename);

        if (file.exists()) {
            try {
                ByteArrayOutputStream data = new ByteArrayOutputStream();
                transferTo(file, data, true);
                return data.toByteArray();
            } catch (IOException e) {
                Log.warning(Geonet.LOGOS, "Unable to find image "+filename);
                return defaultValue;
            }
        }
        return defaultValue;
    }

    /**
     * Load a data image.  The "imagesDir" ({@link #locateDataImagesDir(ServletContext, String)} will first be searched for the logo, then the context then finally the appPath+FS+filename.  if the image
     * is not in imagesDir but is found in one of the other locations it will be copied to imagesDir for future use.  
     * 
     * Use case of this copying is the default harvesting logos are shipped with the webapp and when used they are copied to the imagesDir so that the imagesDir contain
     * all relevant images.  This allow system administrators to ignore the images in the webapp and only configure/backup images in the logos directory.
     * 
     * @param context a possible null context for trying to find the images dir and the logos within the webapp.  If null system properties will be used to try and find
     *                the configuration overrides and appPath will be used to find the logos within the webapp
     * @param appPath fallback if the context is not available
     * @param filename the file to look up.  will normally contains a prefix like logos/ or harvesting/
     * @param defaultValue the image to return if unable to find the actual image
     * @return the bytes of the actual image or defaultValue
     */
    public static byte[] loadImage(ServletContext context, String appPath, String filename, byte[] defaultValue) throws IOException {
        return loadImage(null, context,appPath, filename, defaultValue);
    }

    private static File locateImage( String imagesDir, ServletContext context, String appPath, String filename ) throws IOException {
        File file = new File(imagesDir, filename);
        file.getParentFile().mkdirs();
        if (!file.exists()) {
            File webappCopy;
            if(context != null) {
                webappCopy = new File(context.getRealPath("images/"+filename));
            } else {
                webappCopy = new File(appPath, "images/"+filename);
            }
            if(webappCopy.exists()) {
                transferTo(webappCopy, new FileOutputStream(file), true);
            }
        }
        return file;
    }

    private static void transferTo(File path, OutputStream out, boolean close) throws IOException {
        final FileInputStream fileInputStream = new FileInputStream(path);
        try {
            fileInputStream.getChannel().transferTo(0, Long.MAX_VALUE, Channels.newChannel(out));
        } finally {
            IOUtils.closeQuietly(fileInputStream);
            if(close) IOUtils.closeQuietly(out);
        }
    }
    

    //---------------------------------------------------------------------------
    /**
     * Copy the logo from icon to logos/destName+extension.  The destName should not have the 
     * file extension.
     *  
     * @param context a possibly null context for searching for the source icon
     * @param icon a relative path from images directory ({@linkplain #locateDataImagesDir(ServiceContext)}) for example harvesting/defaultHarvester.gif
     * @param destName the name of the final image (in logos directory) so just the name.  
     */
    public static void copyLogo(ServiceContext context, String icon, String destName)
    {
        ServletContext servletContext = null;
        if (context.getServlet() != null) {
            servletContext = context.getServlet().getServletContext();
        }
        String appDir = context.getAppPath();

        File des = null;
        try
        {
            File src = Logos.locateImage(Logos.locateDataImagesDir(context), servletContext, appDir, icon);
            
            int extIdx = src.getName().lastIndexOf('.');
            String extension = src.getName().substring(extIdx);
            des = new File(Logos.locateLogosDir(context),destName+extension);
            
            FileInputStream  is = new FileInputStream (src);
            FileOutputStream os = new FileOutputStream(des);

            BinaryFile.copy(is, os, true, true);
        }
        catch (IOException e)
        {
            //--- we ignore exceptions here, just log them

            context.warning("Cannot copy icon -> "+ e.getMessage());
            context.warning(" (C) Source : "+ icon);
            context.warning(" (C) Destin : "+ des);
        }
    }

    //---------------------------------------------------------------------------
    /**
     * copy the "unknown" logo to the logos directory for the name 
     * @param context a possibly null context for searching for the unknown icon
     * @param destName the filename prefix to copy the unknown logo to.
     */
    public static void copyUnknownLogo(ServiceContext context, String destName)
    {
        copyLogo(context, "unknown-logo.gif", destName);
    }

    /**
     * List all the files in the provided logosDir (eg. "logos", "harvesting").
     * 
     * Searches {@linkplain #locateDataImagesDir(ServiceContext)/logosDir} and appPath/images/logosDir 
     * and adds all the files that are found.  However logos found in {@linkplain #locateDataImagesDir(ServiceContext)/logosDir}
     * have precedence over logos found in appPath/images/logosDir.  A logo will only be listed once based on its name. 
     * 
     * The search is not recursive.
     * 
     * @param context  a possibly null context for searching for the source icon
     * @param logosDir the directory to search.  It should not have the images prefix.  it should just be the relative name like: "logos" or "harvesting"
     * @param iconFilter the file filter for selecting the files in the listing
     * @return all files in {@linkplain #locateDataImagesDir(ServiceContext)/logosDir} and appPath/images/logosDir that match the iconFitler (and are not the
     * same logo based on its filename (not path)
     */
    public static Set<File> listFiles( ServiceContext context, String logosDir, FileFilter iconFilter ) {
        File dir = new File(locateDataImagesDir(context), logosDir);
        File webappDir = new File(context.getAppPath(), "images"+File.separator+logosDir);
        HashSet<String> names = new HashSet<String>();
        HashSet<File> result = new HashSet<File>();
        
        addFiles(iconFilter, dir, names, result);
        addFiles(iconFilter, webappDir, names, result);
        
        return result;
    }

    private static void addFiles( FileFilter iconFilter, File webappDir, HashSet<String> names, HashSet<File> result ) {
        File[] files;
        files = webappDir.listFiles(iconFilter);
        if(files!=null) {
            for( File file : files ) {
                if(!names.contains(file.getName())) {
                    result.add(file);
                    names.add(file.getName());
                }
            }
        }
    }

}
