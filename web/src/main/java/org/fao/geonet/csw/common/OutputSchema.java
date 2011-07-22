package org.fao.geonet.csw.common;

import org.fao.geonet.csw.common.exceptions.InvalidParameterValueEx;

public enum OutputSchema
{
	// PMT GC2 : backported from old version
	OWN("own"), 
	GM03_PROFILE("GM03_2Record"),
	// Those are standard
	OGC_CORE("Record"), ISO_PROFILE("IsoRecord");

	//------------------------------------------------------------------------

	private OutputSchema(String schema) { this.schema = schema;}

	//------------------------------------------------------------------------

	public String toString() { return schema; }

	//------------------------------------------------------------------------
	/**
	 * Check that outputSchema is known by local catalogue instance.
	 * 
	 * TODO : register new outputSchema when profile are loaded.
	 */
	public static OutputSchema parse(String schema) throws InvalidParameterValueEx
	{
		if (schema == null)						return OGC_CORE;
		// PMT : Backport from old geocat version
		if (schema.equals(OGC_CORE.toString())) return OGC_CORE;
		if (schema.equals(ISO_PROFILE.toString())) return ISO_PROFILE;
		if (schema.equals(GM03_PROFILE.toString())) return GM03_PROFILE;
		if (schema.equals("http://www.geocat.ch/2008/gm03_2")) return GM03_PROFILE;
        if (schema.equals(OWN.toString()))		return OWN;
        //
		if (schema.equals("csw:Record"))		return OGC_CORE;
		if (schema.equals("csw:IsoRecord")) return ISO_PROFILE;
		
		if (schema.equals(Csw.NAMESPACE_CSW.getURI())) return OGC_CORE;
		if (schema.equals(Csw.NAMESPACE_GMD.getURI())) return ISO_PROFILE;

		throw new InvalidParameterValueEx("outputSchema", schema);
	}

	//------------------------------------------------------------------------

	private String schema;
}
