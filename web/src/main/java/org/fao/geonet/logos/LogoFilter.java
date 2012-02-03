package org.fao.geonet.logos;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;

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

    public void init(FilterConfig config) throws ServletException {
        final String appPath = config.getServletContext().getContextPath();
        logosDir = Logos.locateLogosDir(config.getServletContext(), appPath);
        try {
            defaultImage = Logos.loadDummyImage(logosDir, config.getServletContext(), appPath);
        } catch (IOException e) {
            defaultImage = new byte[0];
            e.printStackTrace();
        }
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        if(isGet(request)) {
            String[] pathSegments = ((HttpServletRequest) request).getServletPath().split("/");
            StringBuilder path = new StringBuilder(logosDir);
            path.append(File.pathSeparator);
            for (String segment : pathSegments) {
                path.append(segment);
                path.append(File.pathSeparator);
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

    private boolean isGet(ServletRequest request) {
        return ((HttpServletRequest) request).getMethod().equalsIgnoreCase("GET");
    }

    public void destroy() {
        defaultImage = null;
        logosDir = null;
    }
}
