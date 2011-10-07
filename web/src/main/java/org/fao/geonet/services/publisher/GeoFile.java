//=============================================================================
//===	Copyright (C) 2010 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================
package org.fao.geonet.services.publisher;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collection;
import java.util.Enumeration;
import java.util.LinkedList;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;

/**
 * Instances of this class represent geographic files. A geographic file can be
 * a ZIP file including ESRI Shapefiles and GeoTIFF files, or an individual
 * GeoTIFF file.
 * 
 * @author Éric Lemoine, Camptocamp France SAS
 * @author Francois Prunayre
 */
public class GeoFile {
	private ZipFile zipFile = null;
	private File file = null;

	/**
	 * Constructs a <code>GeoFile</code> object from a <code>File</code> object.
	 * 
	 * @param f
	 *            the file from wich the <code>GeoFile</code> object is
	 *            constructed
	 * @throws IOException
	 *             if an input/output exception occurs while opening a ZIP file
	 */
	GeoFile(File f) throws IOException {
		file = f;
		try {
			zipFile = new ZipFile(file);
		} catch (ZipException e) {
			zipFile = null;
		}
	}

	/**
	 * Returns the names of the vector layers (Shapefiles) in the geographic
	 * file.
	 * 
	 * @param onlyOneFileAllowed
	 *            Return exception if more than one shapefile found
	 * 
	 * @return a collection of layer names
	 * @throws IllegalArgumentException
	 *             If more than on shapefile is found and onlyOneFileAllowed is
	 *             true or if Shapefile name is not equal to zip file base name
	 */
	public Collection<String> getVectorLayers(boolean onlyOneFileAllowed) {
		LinkedList<String> layers = new LinkedList<String>();
		if (zipFile != null) {
			for (Enumeration e = zipFile.entries(); e.hasMoreElements();) {
				ZipEntry ze = (ZipEntry) e.nextElement();
				String fileName = ze.getName();
				if (fileIsShp(fileName)) {
					String base = getBase(fileName);

					if (onlyOneFileAllowed) {
						if (layers.size() > 1)
							throw new IllegalArgumentException(
									"Only one shapefile per zip is allowed. "
											+ layers.size()
											+ " shapefiles found.");

						if (base.equals(getBase(file.getName()))) {
							layers.add(base);
						} else
							throw new IllegalArgumentException(
									"Shapefile name ("
											+ base
											+ ") is not equal to ZIP file name ("
											+ file.getName() + ").");
					} else {
						layers.add(base);
					}
				}
			}
		}

		return layers;
	}

	/**
	 * Returns the names of the raster layers (GeoTIFFs) in the geographic file.
	 * 
	 * @return a collection of layer names
	 */
	public Collection<String> getRasterLayers() {
		LinkedList<String> layers = new LinkedList();
		if (zipFile != null) {
			for (Enumeration e = zipFile.entries(); e.hasMoreElements();) {
				ZipEntry ze = (ZipEntry) e.nextElement();
				String fileName = ze.getName();
				if (fileIsGeotif(fileName)) {
					layers.add(getBase(fileName));
				}
			}
		} else {
			String fileName = file.getName();
			if (fileIsGeotif(fileName)) {
				layers.add(getBase(fileName));
			}
		}
		return layers;
	}

	/**
	 * Returns a file for a given layer, a ZIP file if the layer is a Shapefile,
	 * a GeoTIFF file if the layer is a GeoTIFF.
	 * 
	 * @param id
	 *            the name of the layer, as returned by the getVectorLayer and
	 *            getRasterLayers methods
	 * @return the file
	 * @throws IOException
	 *             if an input/output exception occurs while constructing a ZIP
	 *             file
	 */
	public File getLayerFile(String id) throws IOException {
		File f = null;
		if (zipFile != null) {
			ZipOutputStream out = null;
			byte[] buf = new byte[1024];
			for (Enumeration e = zipFile.entries(); e.hasMoreElements();) {
				ZipEntry ze = (ZipEntry) e.nextElement();
				String baseName = getBase(ze.getName());
				if (baseName.equals(id)) {
					if (out == null) {
						f = File.createTempFile("layer_", ".zip");
						out = new ZipOutputStream(new FileOutputStream(f));
					}
					InputStream in = zipFile.getInputStream(ze);
					out.putNextEntry(new ZipEntry(ze.getName()));
					int len;
					while ((len = in.read(buf)) > 0) {
						out.write(buf, 0, len);
					}
					out.closeEntry();
					in.close();
				}
			}
			if (out != null) {
				out.close();
			}
		} else {
			f = file;
		}
		return f;
	}

	private static String getExtension(String fileName) {
		return fileName.substring(fileName.lastIndexOf(".") + 1,
				fileName.length());
	}

	private String getBase(String fileName) {
		return fileName.substring(0, fileName.lastIndexOf("."));
	}

	private Boolean fileIsShp(String fileName) {
		String extension = getExtension(fileName);
		return extension.equalsIgnoreCase("shp");
	}

	public static Boolean fileIsGeotif(String fileName) {
		String extension = getExtension(fileName);
		return extension.equalsIgnoreCase("tif")
				|| extension.equalsIgnoreCase("tiff")
				|| extension.equalsIgnoreCase("geotif")
				|| extension.equalsIgnoreCase("geotiff");
	}

	public static Boolean fileIsECW(String fileName) {
		String extension = getExtension(fileName);
		return extension.equalsIgnoreCase("ecw");
	}

	public static Boolean fileIsRASTER(String fileName) {
		return fileIsGeotif(fileName) || fileIsECW(fileName);
	}
};
