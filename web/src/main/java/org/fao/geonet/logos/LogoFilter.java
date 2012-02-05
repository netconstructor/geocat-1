package org.fao.geonet.logos;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

/**
 * Servlet for serving up logos.  This solves a largely historical issue because
 * logos are hardcoded across the application to be in /images/logos.  However this
 * is often not desirable.  They would be better to be in the datadirectory and thus
 * possibly outside of geonetwork (allowing easier upgrading of geonetwork etc...)
 *
 * User: jeichar
 * Date: 1/17/12
 * Time: 4:03 PM
 */
public class LogoFilter implements Filter {
    private static final int FIVE_DAYS = 60*60*24*5;
    private String logosDir;
    private byte[] defaultImage;
    private FilterConfig config;
    private byte[] favicon;
    private ServletContext servletContext;
    private String appPath;

    public void init(FilterConfig config) throws ServletException {
        this.config = config;
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        if(isGet(request)) {
            synchronized(this) {
                if(logosDir == null) {
                    initFields();
                }
            }
            String servletPath = ((HttpServletRequest) request).getServletPath();
            List<String> pathSegments = new ArrayList<String>(Arrays.asList(servletPath.split("/")));

            Iterator<String> iter = pathSegments.iterator();

            StringBuilder path = new StringBuilder();

            // dropped is only incremented when non-empty segment is dropped
            int dropped = 0;
            while(iter.hasNext()) {
                String segment = iter.next();
                if(segment.trim().isEmpty()) continue;
                if(dropped < 2 && (segment.equalsIgnoreCase("images")
                        || segment.equalsIgnoreCase("logos"))) {
                    // do nothing we don't want to include images and logos
                } else {
                    path.append(segment);
                    path.append(File.separator);
                }
                dropped ++;
            }

            path.deleteCharAt(path.length() - 1);
            String filename = path.toString();
            int extIdx = filename.lastIndexOf('.');
            String ext;
            if(extIdx > 0) {
                ext = filename.substring(extIdx);
            } else {
                ext = "gif"; 
            }
            HttpServletResponse httpServletResponse = (HttpServletResponse)response;
            httpServletResponse.setContentType("image/"+ext);
            httpServletResponse.addHeader("Cache-Control", "max-age="+FIVE_DAYS+", public");
            if(filename.equals("favicon.gif")) {
                httpServletResponse.setContentLength(favicon.length);
                
                response.getOutputStream().write(favicon);
            } else {
                byte[] loadImage = Logos.loadImage(logosDir, servletContext, appPath, filename, defaultImage);
                httpServletResponse.setContentLength(loadImage.length);
                response.getOutputStream().write(loadImage);
            }

        }
    }

    private void initFields() {
        servletContext = config.getServletContext();
        appPath = servletContext.getContextPath();
        logosDir = Logos.locateLogosDir(config.getServletContext(), appPath);
        defaultImage = Logos.loadImage(logosDir, config.getServletContext(), appPath, "dummy.gif", new byte[0]);
        favicon = Logos.loadImage(logosDir, config.getServletContext(), appPath, "favicon.gif", defaultImage);
    }

    private boolean isGet(ServletRequest request) {
        return ((HttpServletRequest) request).getMethod().equalsIgnoreCase("GET");
    }

    public void destroy() {
        defaultImage = null;
        logosDir = null;
    }
}
