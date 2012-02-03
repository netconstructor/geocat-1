package org.fao.geonet.logos;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
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
    private String logosDir;
    private byte[] defaultImage;
    private FilterConfig config;

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

            StringBuilder path = new StringBuilder(logosDir);
            path.append(File.separator);

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
            File file = new File(path.toString());
            if(!file.exists()) {
                response.getOutputStream().write(defaultImage);
            } else {
                Logos.transferTo(path.toString(), response.getOutputStream());
            }

        }
    }

    private void initFields() {
        final String appPath = config.getServletContext().getContextPath();
        logosDir = Logos.locateLogosDir(config.getServletContext(), appPath);
        try {
            defaultImage = Logos.loadDummyImage(logosDir, config.getServletContext(), appPath);
        } catch (IOException e) {
            defaultImage = new byte[0];
            e.printStackTrace();
        }        
    }

    private boolean isGet(ServletRequest request) {
        return ((HttpServletRequest) request).getMethod().equalsIgnoreCase("GET");
    }

    public void destroy() {
        defaultImage = null;
        logosDir = null;
    }
}
