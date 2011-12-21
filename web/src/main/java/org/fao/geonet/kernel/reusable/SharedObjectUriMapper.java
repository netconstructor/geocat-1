package org.fao.geonet.kernel.reusable;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jeeves.xlink.URIMapper;

public class SharedObjectUriMapper implements URIMapper {
    Pattern idExtractor = Pattern.compile("(.*?)\\?.*?(id=[^&]+).*");
    Pattern thesaurusExtractor = Pattern.compile(".*(thesaurus=[^&]+).*");
    
    public String map( String uri ) {
        if (uri.contains("/xml.user.get?")) {
            Matcher userIdMatcher = idExtractor.matcher(uri);
            userIdMatcher.matches();
            return userIdMatcher.group(1)+"?"+userIdMatcher.group(2);
        } else if (uri.contains("/xml.keyword.get?")) {
            Matcher idMatcher = idExtractor.matcher(uri);
            idMatcher.matches();

            Matcher thesaurusMatcher = thesaurusExtractor.matcher(uri);
            thesaurusMatcher.matches();
            
            return idMatcher.group(1)+"?"+idMatcher.group(2)+"&"+thesaurusMatcher.group(1);
        }
        return uri;
    }

}
