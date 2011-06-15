package org.fao.geonet.kernel.search;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import jeeves.constants.Jeeves;
import org.apache.lucene.analysis.*;
import org.apache.lucene.analysis.de.GermanAnalyzer;
import org.apache.lucene.analysis.fr.FrenchAnalyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.analysis.standard.StandardFilter;
import org.apache.lucene.analysis.standard.StandardTokenizer;

/**
 *Geocat Specific implementation of the GeonetworkAnalyzer
 */
public class GeocatAnalyzer extends Analyzer {

    private static HashMap<String,String[]> STOP_WORDS_CACHE = new HashMap<String,String[]>();
    private String[] _stopWords;
    private static final Set<Character> STRING_TERM = new HashSet<Character>(Arrays.asList('.', '-'));
    private static final Set<Character> NUM_TERM = new HashSet<Character>(Arrays.asList('-'));

    public GeocatAnalyzer(String locale, File localeDir) throws IOException
    {
        if (locale != null) {
            File file = new File(localeDir, "stopwords/stopwords_" + locale.toLowerCase()
                    + ".txt");
            if (file.exists()) {
                _stopWords = readStopWords(locale, file);
            }
        }

        if( _stopWords == null ){
            _stopWords = defaultStopWords(locale, StandardAnalyzer.STOP_WORDS);
        }
    }

    public String[] getStopWords()
    {
        return _stopWords;
    }

    @Override
    public TokenStream tokenStream(String fieldName, Reader reader)
    {
        StandardTokenizer tokenizer = new StandardTokenizer(reader);
        TokenFilter splitter = new TokenFilter(tokenizer) {
        	int index = 0;
        	int length = 0;
        	Token current = null;
        	@Override
			public Token next(Token result) throws IOException {
        		if(current!=null) {
					current.setStartOffset(current.endOffset()+1);
					current.setEndOffset(current.termLength());
        			return nextToken();
        		}
				current = input.next(result);

				if (current == null)
					return null;

				index = 0;
				length = current.termLength();
				return nextToken();
			}
			private Token nextToken() {
				Token t = current;
                Set<Character> terminators = STRING_TERM;

                if(t.type().equals("<NUM>")) {
                    terminators = NUM_TERM;
                }
                char[] buffer = t.termBuffer();
                int i = 0;
                for (; index < length; i++, index++) {
                    char c = buffer[index];
                    if(terminators.contains(c)) {
                        t.setTermLength(i+1);
                        index++;
                        return t;
                    } else {
                        buffer[i]=c;
                    }
					t.setTermLength(i+1);
				}
				current = null;
				return t;
			}
		};
        StandardFilter standard = new StandardFilter(splitter);
        StopFilter stopFilter = new StopFilter(standard, _stopWords);
        ASCIIFoldingFilter latinFilter = new ASCIIFoldingFilter(stopFilter);
        return new LowerCaseFilter(latinFilter);
    }

    private static synchronized String[] readStopWords(String locale, File file)
            throws IOException
    {

        if(!STOP_WORDS_CACHE.containsKey(locale)) {
            Set<String> words = new HashSet<String>();
            BufferedReader reader = new BufferedReader(new FileReader(file));
            for (String line = reader.readLine(); line != null; line = reader
                    .readLine()) {
                String trimmed = line.trim();

                if (!trimmed.startsWith("#"))
                    words.add(trimmed);
            }

            String[] specialCaseWords = defaultStopWords(locale, new String[0]);

            words.addAll(Arrays.asList(specialCaseWords));

            final String[] wordArray = words.toArray(new String[words.size()]);
            STOP_WORDS_CACHE.put(locale, wordArray);
            return wordArray;
        }
        return STOP_WORDS_CACHE.get(locale);


    }

    private static String[] defaultStopWords(String locale, String[] fallback)
    {
        String[] specialCaseWords = new String[0];
        if ("fr".equalsIgnoreCase(locale) || "fra".equalsIgnoreCase(locale)) {
            specialCaseWords = FrenchAnalyzer.FRENCH_STOP_WORDS;
        }

        if ("de".equalsIgnoreCase(locale) || "deu".equalsIgnoreCase(locale)) {
            specialCaseWords = GermanAnalyzer.GERMAN_STOP_WORDS;
        }
        if (locale == null || "en".equalsIgnoreCase(locale)
                || "eng".equalsIgnoreCase(locale)) {
            specialCaseWords = StandardAnalyzer.STOP_WORDS;
        }

        if(specialCaseWords==null){
            specialCaseWords=fallback;
        }
        return specialCaseWords;
    }

}
