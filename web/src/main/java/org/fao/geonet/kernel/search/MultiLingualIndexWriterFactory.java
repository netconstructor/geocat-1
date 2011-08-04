package org.fao.geonet.kernel.search;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.Term;

/* Lucene only allows one IndexWriter to be open at a time.  
   However, multiple threads can use this single IndexWriter.  
   This class manages a global IndexWriter and uses reference counting to 
   determine when it can be closed.  */

public class MultiLingualIndexWriterFactory {
	
	protected Map<String,LuceneIndexWriterFactory> _writer = new HashMap<String,LuceneIndexWriterFactory>();
	private PerFieldAnalyzerWrapper _analyzer;
	private LuceneConfig _luceneConfig;
	private MultiLingualIndexSupport _support; 
	
	public MultiLingualIndexWriterFactory(File luceneDir, PerFieldAnalyzerWrapper analyzer, LuceneConfig luceneConfig) {
		_support = new MultiLingualIndexSupport(luceneDir);
		_analyzer = analyzer;
		_luceneConfig = luceneConfig;
		String[] locales = _support.listLocales();
		for (String locale : locales) {
			File indexDir = _support.luceneDir(locale);
			LuceneIndexWriterFactory fac = new LuceneIndexWriterFactory(indexDir, _analyzer, _luceneConfig);
			_writer.put(locale.toLowerCase(), fac);
        }
	}

	public synchronized void openWriter() throws Exception {
		for(LuceneIndexWriterFactory fac: _writer.values()) {
			fac.openWriter();
		}
	}

	public synchronized boolean isOpen() {
		boolean open = false;
		for(LuceneIndexWriterFactory fac: _writer.values()) {
			open |= fac.isOpen();
		}
        return open;
	}

	public synchronized void closeWriter() throws Exception {
		for(LuceneIndexWriterFactory fac: _writer.values()) {
			fac.closeWriter();
		}
	}

	public synchronized void commit() throws Exception {
		for(LuceneIndexWriterFactory fac: _writer.values()) {
			fac.commit();
		}
	}
		
	public void addDocument(String locale, Document doc) throws Exception {
		LuceneIndexWriterFactory fac = _writer.get(locale.toLowerCase());
		if(fac == null) {
			File dir = _support.luceneDir(locale.toLowerCase());
			fac = new LuceneIndexWriterFactory(dir, _analyzer, _luceneConfig);
			fac.openWriter();
			_writer.put(locale.toLowerCase(), fac);
		}
		fac.addDocument(doc);
	}

	public void deleteDocuments(Term term) throws Exception {
		for(LuceneIndexWriterFactory fac: _writer.values()) {
			fac.deleteDocuments(term);
		}
	}
	
	public void optimize() throws Exception {
		for(LuceneIndexWriterFactory fac: _writer.values()) {
			fac.optimize();
		}
	}


	
}
