.. _schemaPlugins:

Schema Plugins
==============

A schema in GeoNetwork is a directory with stylesheets, XML schema 
descriptions (XSDs) and other information necessary for GeoNetwork to index, 
view and possibly edit content from XML metadata records. 

To be used in GeoNetwork, a schema 
directory can be placed in `INSTALL_DIR/web/geonetwork/xml/schemas`. Schemas 
in this directory are built-in schemas. The contents of these schemas are 
parsed during GeoNetwork initialization. If valid, they will be available for 
use when GeoNetwork starts up.

Schemas can also added to GeoNetwork dynamically if a zip archive of the 
schema directory is created and then uploaded to GeoNetwork in one of following
ways using functions in the Administration menu:

#. Server file path (specified using file chooser)
#. HTTP URL (eg. http://somehost/somedirectory/iso19139.mcp.zip)
#. As an online resource attached to an iso19139 metadata record

When schemas are added to GeoNetwork dynamically, they are stored in the directory specified in `INSTALL_DIR/web/geonetwork/WEB-INF/config.xml`. By default, this is `INSTALL_DIR/web/geonetwork/schemaPlugins`.

Contents of a GeoNetwork schema
```````````````````````````````

When installed, a GeoNetwork schema is a directory.

The following subdirectories can be present:

- **convert**: (*Mandatory*) Directory of XSLTs to convert metadata from or to this schema. This could be to convert metadata to other schemas or to convert metadata from other schemas and formats to this schema. Eg. ``convert/oai_dc.xsl``
- **loc**: (*Optional*) Directory of localized information: labels, codelists or schema specific strings. Eg. ``loc/en/codelists.xml``
- **present**: (*Mandatory*) contains XSLTs for presenting metadata in the viewer/editor and in response to CSW requests for brief, summary and full records.
- **process**: (*Optional*) contains XSLTs for processing metadata elements by metadata suggestions mechanism (see **suggest.xsl** below).
- **sample-data**: (*Mandatory*) Sample metadata for this schema. The metadata samples are in MEF format so that samples can have thumbnails or browse graphics as well as online resources.
- **schema**: (*Optional*) Directory containing the official XSDs of the metadata schema. If the schema is described by a DTD then this directory is optional. Note that schemas described by a DTD cannot be edited by GeoNetwork.
- **templates**: (*Optional*) Directory containing template and subtemplate metadata records for this schema. Template metadata records are usually metadata records with the set of elements (and content) that will be used for a specific purpose. Eg. iso19139.mcp schema has a 'Minimum Element' template that has the mandatory elements for the schema and a example of the content that is expected. 

The following stylesheets can be present:

- **extract-date-modified.xsl**: (*Mandatory*) Extract the date of modification from the metadata record.
- **extract-gml.xsl**: (*Mandatory*) Extract the spatial extent from the metadata record as a GML GeometryCollection element.
- **extract-thumbnails.xsl**: (*Optional*) Extract the browse graphic/thumbnail from the metadata record. 
- **extract-uuid.xsl**: (*Mandatory*) Extract the UUID of the metadata record.
- **index-fields.xsl**: (*Mandatory*) Index the metadata record content in Lucene. Creates the Lucene document used by GeoNetwork to index the metadata record content.
- **schematron-rules-*.xsl**: (*Optional*) XSLT created from schematron rules when building the schema plugin (see schematrons directory).
- **set-thumbnail.xsl**: (*Optional*) Set the browse graphic/thumbnail in the metadata record.
- **set-uuid.xsl**: (*Optional*) Set the UUID of the metadata record.
- **suggest.xsl**: (*Optional*) XSLT run by metadata suggestions service. The XSLT contains processes that can be registered and run on different elements of a metadata record. eg. expand keyword field with comma separated content into multiple keyword fields. See http://trac.osgeo.org/geonetwork/wiki/proposals/MetadataEditorSuggestion for more info.
- **unset-thumbnail.xsl**: (*Optional*) Remove the browse graphic/thumbnail from the metadata record.
- **update-child-from-parent-info.xsl**: (*Optional*) XSLT to specify which elements in a child record are updated from a parent record. Used to manage hierarchical relationships between metadata records.
- **update-fixed-info.xsl**: (*Optional*) XSLT to update 'fixed' content in metadata records.

The following configuration files can be present:

- **oasis-catalog.xml**: (*Optional*) An oasis catalog describing any mappings that should be used for this schema eg. mapping URLs to local copies such as schemaLocations eg. http://www.isotc211.org/2005/gmd/gmd.xsd is mapped to ``schema/gmd/gmd.xsd``. Path names used in the oasis catalog are relative to the location of this file which is the schema directory.
- **schema.xsd**: (*Optional*) XML schema directory file that includes the XSDs used by this metadata schema. If the schema uses a DTD then this file should not be present. Metadata records from schemas that use DTDs cannot be edited in GeoNetwork.
- **schema-ident.xml**: (*Mandatory*) XML file that contains the schema name, identifier, version number and details on how to recognise metadata records that belong to this schema. This file has an XML schema definition in `INSTALL_DIR/web/geonetwork/xml/validation/schemaPlugins/schema-ident.xsd` which is used to validate it when the schema is loaded.
- **schema-substitutes.xml**: (*Optional*) XML file that redefines the set of elements that can be used as substitutes for a specific element.
- **schema-suggestions.xml**: (*Optional*) XML file that tells the editor which child elements of a complex element to automatically expand in the editor. 

To help in understanding what each of these components is and what is required, we will now give a step-by-step example of how to build a schemaPlugin for GeoNetwork.


Preparation
```````````

In order to create a schema plugin for GeoNetwork, you should check out the schemaPlugins directory from the GeoNetwork sourceforge subversion repository. You can do this by installing subversion on your workstation and then executing the following command:

::

  svn co https://geonetwork.svn.sourceforge.net/svnroot/geonetwork/schemaPlugins/trunk schemaPlugins


This will create a directory called schemaPlugins with some GeoNetwork schema plugins in it. To work with the example shown here, you should create your new schema plugin in a subdirectory of this directory.


Example - ISO19115/19139 Marine Community Profile (MCP)
```````````````````````````````````````````````````````

The Marine Community Profile (MCP) is a profile of ISO19115/19139 developed for and with the Marine Community. The profile extends the ISO19115 metadata standard and is implemented using an extension of the XML implementation of ISO19115 described in ISO19139. Both the ISO19115 metadata standard and its XML implementation, ISO19139, are available through ISO distribution channels.

The documentation for the Marine Community Profile can be found at http://www.aodc.gov.au/files/MarineCommunityProfilev1.4.pdf. The implementation of the Marine Community Profile as XML schema definitions is based on the approach described at https://www.seegrid.csiro.au/wiki/AppSchemas/MetadataProfiles. The XML schema definitions (XSDs) are available at the URL http://bluenet3.antcrc.utas.edu.au/mcp-1.4. 

Looking at the XML schema definitions, the profile adds a few new elements to the base ISO19139 standard. So the basic idea in defining a plugin Marine Community Profile schema for GeoNetwork is to use as much of the basic ISO19139 schema definition supplied with GeoNetwork as possible.

We'll now describe in basic steps how to create each of the components of a plugin schema for GeoNetwork that implements the MCP. 

Creating the schema-ident.xml file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now we need to provide the information necessary to identify the schema and metadata records that belong to the schema. The schema-ident.xml file for the MCP is as follows:

::

  <?xml version="1.0" encoding="UTF-8"?>
  <schema xmlns="http://geonetwork-opensource.org/schemas/schema-ident" 
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
          .....>
    <name>iso19139.mcp</name>
    <id>19c9a2b2-dddb-11df-9df4-001c2346de4c</id>
    <version>1.5</version>
    <schemaLocation>
      http://bluenet3.antcrc.utas.edu.au/mcp 
      http://bluenet3.antcrc.utas.edu.au/mcp-1.5-experimental/schema.xsd 
      http://www.isotc211.org/2005/gmd 
      http://www.isotc211.org/2005/gmd/gmd.xsd 
      http://www.isotc211.org/2005/srv 
      http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd
    </schemaLocation>
    <autodetect xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp" 
                xmlns:gmd="http://www.isotc211.org/2005/gmd" 
                xmlns:gco="http://www.isotc211.org/2005/gco">
      <elements>
        <gmd:metadataStandardName>
          <gco:CharacterString>
            Australian Marine Community Profile of ISO 19115:2005/19139
          </gco:CharacterString>
        </gmd:metadataStandardName>
        <gmd:metadataStandardVersion>
          <gco:CharacterString>MCP:BlueNet V1.5</gco:CharacterString>
        </gmd:metadataStandardVersion>
      </elements>
    </autodetect>
  </schema>

Each of the elements is as follows:

- **name** - the name by which the schema will be known in GeoNetwork. If the schema is a profile of a base schema already added to GeoNetwork then the convention is to call the schema <base_schema_name>.<namespace_of_profile>.
- **id** - a unique identifier for the schema.
- **version** - the version number of the schema. Multiple versions of the schema can be present in GeoNetwork.
- **schemaLocation** - a set of pairs, where the first member of the pair is a namespace URI and the second member is the official URL of the XSD. The contents of this element will be added to the root element of any metadata record displayed by GeoNetwork as a schemaLocation/noNamespaceSchemaLocation attribute, if such as attribute does not already exist. It will also be used whenever an official schemaLocation/noNamespaceSchemaLocation is required (eg. in response to a ListMetadataFormats OAI request). 
- **autodetect** - contains elements (with content) that must be present in any metadata record that belongs to this schema. This is used during schema detection whenever GeoNetwork receives a metadata record of unknown schema.

After creating this file you can validate it manually using the XML schema definition (XSD) in `INSTALL_DIR/web/geonetwork/xml/validation/schemaPlugins/schema-ident.xsd`. This XSD is also used to validate this file when the schema is loaded.

At this stage, our new GeoNetwork plugin schema for MCP contains:

::

   schema-ident.xml


Creating the schema directory and schema.xsd file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The schema and schema.xsd components are used by the GeoNetwork editor and validation functions.

GeoNetwork's editor uses the XSDs to build a form that will not only order the elements in a metadata document correctly but also offer options to create any elements that are not in the metadata document. The idea behind this approach is twofold. Firstly, the editor can use the XML schema definition rules to help the user avoid creating a document that is structurally incorrect eg. missing mandatory elements or elements not ordered correctly. Secondly, the same editor code can be used on any XML metadata document with a defined XSD.

If you are defining your own metadata schema then you can create an XML schema document using the XSD language. The elements of the language can be found online at http://www.w3schools.com/schema/ or you can refer to a textbook such as Priscilla Walmsley's Definitive XML Schema (Prentice Hall, 2002). GeoNetwork's XML schema parsing code understands almost all of the XSD language with the exception of redefine, any and anyAttribute (although the last two can be handled under special circumstances).

In the case of the Marine Commuity Profile, we are basically defining a number of extensions to the base standard ISO19115/19139. These extensions are defined using the XSD extension mechanism on the types defined in ISO19139. The following snippet shows how the Marine Community Profile extends the gmd:MD_Metadata element to add a new element called revisionDate:
 
::

  <xs:schema targetNamespace="http://bluenet3.antcrc.utas.edu.au/mcp" 
             xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp" .....>

  ....

  <xs:element name="MD_Metadata" substitutionGroup="gmd:MD_Metadata" 
                                 type="mcp:MD_Metadata_Type"/>

  <xs:complexType name="MD_Metadata_Type">
    <xs:annotation>
      <xs:documentation>
       Extends the metadata element to include revisionDate
      </xs:documentation>
    </xs:annotation>
    <xs:complexContent>
      <xs:extension base="gmd:MD_Metadata_Type">
        <xs:sequence>
          <xs:element name="revisionDate" type="gco:Date_PropertyType" 
                      minOccurs="0"/>
        </xs:sequence>
        <xs:attribute ref="gco:isoType" use="required" 
                      fixed="gmd:MD_Metadata"/>
      </xs:extension>
    </xs:complexContent>
  </xs:complexType>

  </xs:schema>

In short, we have defined a new element mcp:MD_Metadata with type mcp:MD_Metadata_Type, which is an extension of gmd:MD_Metadata_Type. By extension, we mean that the new type includes all of the elements of the old type plus one new element, mcp:revisionDate. A mandatory attribute (gco:isoType) is also attached to mcp:MD_Metadata with a fixed value set to the name of the element that we extended (gmd:MD_Metadata).

By defining the profile in this way, it is not necessary to modify the underlying ISO19139 schemas. So the schema directory for the MCP essentially consists of the extensions plus the base ISO19139 schemas. One possible directory structure is as follows: 

::

  extensions  gco  gmd  gml  gmx  gsr  gss  gts  resources  srv  xlink

The extensions directory contains a single file mcpExtensions.xsd, which imports the gmd namespace. The remaining directories are the ISO19139 base schemas. 

The schema.xsd file, which is the file GeoNetwork looks for, will import the mcpExtensions.xsd file and any other namespaces not imported as part of the base ISO19139 schema. It is shown as follows:

::

 <xs:schema targetNamespace="http://bluenet3.antcrc.utas.edu.au/mcp" 
            elementFormDefault="qualified"
         xmlns:xs="http://www.w3.org/2001/XMLSchema" 
         xmlns:mcp="http://bluenet3.antcrc.utas.edu.au/mcp"
         xmlns:gmd="http://www.isotc211.org/2005/gmd"
         xmlns:gmx="http://www.isotc211.org/2005/gmx"
         xmlns:srv="http://www.isotc211.org/2005/srv">
   <xs:include schemaLocation="schema/extensions/mcpExtensions.xsd"/>
   <!-- this is a logical place to include any additional schemas that are 
        related to ISO19139 including ISO19119 -->
   <xs:import namespace="http://www.isotc211.org/2005/srv" 
              schemaLocation="schema/srv/srv.xsd"/>
   <xs:import namespace="http://www.isotc211.org/2005/gmx" 
              schemaLocation="schema/gmx/gmx.xsd"/>
 </xs:schema>

At this stage, our new GeoNetwork plugin schema for MCP contains:

::

   schema-ident.xml  schema.xsd  schema


Creating the extract-... XSLTs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

GeoNetwork needs to extract certain information from a metadata record and translate it into a common, simplified XML structure that is independent of the metadata schema. Rather than do this with Java coded XPaths, XSLTs are used to process the XML and return the common, simplified XML structure.

The four xslts we'll create are:

- **extract-date-modified.xsl** - this XSLT processes the metadata record and extracts the date the metadata record was last modified. For the MCP, this information is held in the mcp:revisionDate element which is a child of mcp:MD_Metadata. The easiest way to create this for MCP is to copy extract-date-modified.xsl from the iso19139 schema and modify it to suit the MCP namespace and to use mcp:revisionDate in place of gmd:dateStamp.
- **extract-gml.xsl** - this XSLT processes the metadata record and extracts the spatial extent as a gml GeometryCollection element. The gml is passed to geotools for insertion into the spatial index (either a shapefile or a spatial database). For ISO19115/19139 and profiles, this task is quite easy because spatial extents (apart from the bounding box) are encoded as gml in the metadata record. Again, the easiest way to create this for the MCP is to copy extract-gml.xsd from the iso19139 schema ad modify it to suit the MCP namespace.

An example bounding box fragment from an MCP metadata record is:

::

  <gmd:extent>
    <gmd:EX_Extent>
      <gmd:geographicElement>
        <gmd:EX_GeographicBoundingBox>
          <gmd:westBoundLongitude>
            <gco:Decimal>112.9</gco:Decimal>
          </gmd:westBoundLongitude>
          <gmd:eastBoundLongitude>
            <gco:Decimal>153.64</gco:Decimal>
          </gmd:eastBoundLongitude>
          <gmd:southBoundLatitude>
            <gco:Decimal>-43.8</gco:Decimal>
          </gmd:southBoundLatitude>
          <gmd:northBoundLatitude>
            <gco:Decimal>-9.0</gco:Decimal>
          </gmd:northBoundLatitude>
        </gmd:EX_GeographicBoundingBox>
      </gmd:geographicElement>
    </gmd:EX_Extent>
  </gmd:extent>

Running extract-gml.xsl on the metadata record that contains this XML will produce:

::

  <gml:GeometryCollection xmlns:gml="http://www.opengis.net/gml">
    <gml:Polygon>
      <gml:exterior>
        <gml:LinearRing>
          <gml:coordinates>
            112.9,-9.0, 153.64,-9.0, 153.64,-43.8, 112.9,-43.8, 112.9,-9.0
          </gml:coordinates>
        </gml:LinearRing>
      </gml:exterior>
    </gml:Polygon>
  </gml:GeometryCollection>

If there is more than one extent in the metadata record, then they should also appear in this gml:GeometryCollection element.

To find out more about gml, see Lake, Burggraf, Trninic and Rae, "GML Geography Mark-Up Language, Foundation for the Geo-Web", Wiley, 2004.

Finally, a note on projections. It is possible to have bounding polygons in an MCP record in a projection other than EPSG:4326. GeoNetwork transforms all projections known to GeoTools (and encoded in a form that GeoTools understands) to EPSG:4326 when writing the spatial extents to the shapefile or spatial database.

- **extract-uuid.xsl** - this XSLT processes the metadata record and extracts the identifier for the record. For the MCP and base ISO standard, this information is held in the gmd:fileIdentifier element which is a child of mcp:MD_Metadata.

These xslts can be tested by running them on a metadata record from the schema. You should use the saxon xslt processor. For example:

::

  java -jar INSTALL_DIR/web/geonetwork/WEB-INF/lib/saxon-9.1.0.8b-patch.jar 
       -s testmcp.xml -o output.xml extract-gml.xsl


At this stage, our new GeoNetwork plugin schema for MCP contains:

::

   extract-date-modified.xsl  extract-gml.xsd   extract-uuid.xsl
   schema-ident.xml  schema.xsd  schema


Creating the localized strings in the loc directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The loc directory contains localized strings specific to this schema, arranged by language abbreviation in sub-directories.

You should provide localized strings in whatever languages you expect your schema to be used in.

Localized strings for this schema can be used in the presentation xslts and
schematron error messages. For the presentation xslts:

 - general localized strings should be in loc/<language_abbreviation>/strings.xml eg. loc/en/strings.xml
 - codelists for controlled vocabulary fields should be in loc/<language_abbreviation>/codelists.xml eg. loc/en/codelists.xml
 - label strings that replace XML element names with more intelligible/alternative phrases and rollover help strings should be in loc/<language_abbreviation>/labels.xml eg. loc/en/labels.xml. Note that because the MCP is a profile of ISO19115/19139 and we have followed the GeoNetwork naming convention for profiles, we need only include the labels that are specific to the MCP in the labels.xml file. Other labels will be retrieved from the base schema iso19139.

At this stage, our new GeoNetwork plugin schema for MCP contains:

::

   extract-date-modified.xsl  extract-gml.xsd  extract-uuid.xsl 
   loc  present  schema-ident.xml  schema.xsd  schema


Creating the presentations xslts in the present directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


At this stage, our new GeoNetwork plugin schema for MCP contains:


::

   extract-date-modified.xsl  extract-gml.xsd  extract-uuid.xsl  
   loc  present  schema-ident.xml  schema.xsd  schema


Creating the index-fields.xsl to index content from the metadata record
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This XSLT indexes the content of elements in the metadata record. The essence of this XSLT is to select elements from the metadata record and map them to lucene index field names. The lucene index field names used in GeoNetwork are as follows:

===========================  ===========================================================================
Lucene Index Field Name      Description
===========================  ===========================================================================
abstract                     Metadata abstract                                                          
any                          Content from all metadata elements (for free text)                         
changeDate                   Date that the metadata record was modified                             
createDate                   Date that the metadata record was created                              
denominator                  Scale denominator in data resolution                                                   
download                     Does the metadata record have a downloadable resource attached?  (0 or 1)
digital                      Is the metadata record distributed/available in a digital format?  (0 or 1)
eastBL                       East bounding box longitude                                       
keyword                      Metadata keywords                                                 
metadataStandardName         Metadata standard name                                            
northBL                      North bounding box latitude                                       
operatesOn                   Uuid of metadata record describing dataset that is operated on by a service            
orgName                      Name of organisation listed in point-of-contact information                            
parentUuid                   Uuid of parent metadata record                                                         
paper                        Is the metadata record distributed/available in a paper format?  (0 or 1)
protocol                     On line resource access protocol                                  
publicationDate              Date resource was published                                  
southBL                      South bounding box latitude                                       
spatialRepresentationType    vector, raster, etc                                               
tempExtentBegin              Beginning of temporal extent range                                                     
tempExtentEnd                End of temporal extent range                                                     
title                        Metadata title                                                    
topicCat                     Metadata topic category                                           
type                         Metadata hierarchy level (should be dataset if unknown)                           
westBL                       West bounding box longitude                                                       
===========================  ===========================================================================

For example, here is the mapping created between the metadata element mcp:revisionDate and the lucene index field changeDate:

::

   <xsl:for-each select="mcp:revisionDate/*">
     <Field name="changeDate" string="{string(.)}" store="true" index="true"/>
   </xsl:for-each>

Notice that we are creating a new XML document. The Field elements in this document are used by GeoNetwork to create a Lucene document object for indexing (see the SearchManager class in the GeoNetwork source).

Once again, because the MCP is a profile of ISO19115/19139, it is probably best to modify index-fields.xsl from the schema iso19139 to handle the namespaces and additional elements of the MCP.

At this stage, our new GeoNetwork plugin schema for MCP contains:

::

   extract-date-modified.xsl  extract-gml.xsd  extract-uuid.xsl  
   index-fields.xsl  loc  present  schema-ident.xml  schema.xsd  schema


Creating the sample-data directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is a simple directory. Put MEF files with sample metadata in this directory. Make sure they have a `.mef` suffix. 

A MEF file is a zip archive with the metadata, thumbnails, file based online resources and an info file describing the contents. The contents of a MEF file are discussed in more detail in the next section of this manual. 

Sample data in this directory can be added to the catalog using the Administration menu.

At this stage, our new GeoNetwork plugin schema for MCP contains:

::

   extract-date-modified.xsl  extract-gml.xsd  extract-uuid.xsl  
   index-fields.xsl  loc  present  sample-data schema-ident.xml  schema.xsd  
   schema


Creating schematrons to describe MCP conditions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Schematrons are rules that are used to check conditions and content in the metadata record as part of the two stage validation process used by GeoNetwork.

Schematron rules are created in the schematrons directory that you checked out earlier - see `Preparation` above.

At this stage, our new GeoNetwork plugin schema for MCP contains:

::

   extract-date-modified.xsl  extract-gml.xsd  extract-uuid.xsl  
   index-fields.xsl  loc  present  sample-data schema-ident.xml  schema.xsd
   schema


Adding the components necessary to create and edit MCP metadata
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

So far we have added all the components necessary for GeoNetwork to identify, view and validate MCP metadata records. Now we will add the remaining components necessary to create and edit MCP metadata records. 

We'll start with the XSLTs that set the content of various elements in the MCP metadata records.

~~~~~~~~~~~~~~~~~~~~~
Creating set-uuid.xsl 
~~~~~~~~~~~~~~~~~~~~~

- **set-uuid.xsl** - this XSLT takes as a parameter the UUID of the metadata record and writes it into the appropriate element of the metadata record. For the MCP this element is the same as the base ISO schema (called iso19139 in GeoNetwork), namely gmd:fileIdentifier. However, because the MCP uses a different namespace on the root element, this XSLT needs to be modified.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Creating the extract, set and unset thumbnail XSLTs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If your metadata record can have a thumbnail or browse graphic link, then you will want to add XSLTs that extract, set and unset this information so that you can use the GeoNetwork thumbnail editing interface.

The three XSLTs that support this interface are:

- **extract-thumbnails.xsl** - this XSLT extracts the thumbnails/browse graphics from the metadata record, turning it into generic XML that is the same for all metadata schemas. The elements need to have content that GeoNetwork understands. The following is an example of what the thumbnail interface for iso19139 expects (we'll duplicate this requirement for MCP):

::

  <gmd:graphicOverview>
    <gmd:MD_BrowseGraphic>
      <gmd:fileName>
        <gco:CharacterString>bluenet_s.png</gco:CharacterString>
      </gmd:fileName>
      <gmd:fileDescription>
        <gco:CharacterString>thumbnail</gco:CharacterString>
      </gmd:fileDescription>
      <gmd:fileType>
        <gco:CharacterString>png</gco:CharacterString>
      </gmd:fileType>
    </gmd:MD_BrowseGraphic>
  </gmd:graphicOverview>
  <gmd:graphicOverview>
    <gmd:MD_BrowseGraphic>
      <gmd:fileName>
        <gco:CharacterString>bluenet.png</gco:CharacterString>
      </gmd:fileName>
      <gmd:fileDescription>
        <gco:CharacterString>large_thumbnail</gco:CharacterString>
      </gmd:fileDescription>
      <gmd:fileType>
        <gco:CharacterString>png</gco:CharacterString>
      </gmd:fileType>
    </gmd:MD_BrowseGraphic>
  </gmd:graphicOverview> 


When extract-thumbnails.xsl is run, it creates a small XML hierarchy from this information which looks something like the following:

::

   <thumbnail>
     <large>
       bluenet.png
     </large>
     <small>
       bluenet_s.png
     </small>
   </thumbnail>
		
- **set-thumbnail.xsl** - this XSLT does the opposite of extract-thumbnails.xsl. It takes the simplified, common XML structure used by GeoNetwork to describe the large and small thumbnails and creates the elements of the metadata record that are needed to represent them. This is a slightly more complex XSLT than extract-thumbnails.xsl because the existing elements in the metadata record need to be retained and the new elements need to be created in their correct places.
- **unset-thumbnail.xsl** - this XSLT targets and removes elements of the metadata record that describe a particular thumbnail. The remaining elements of the metadata record are retained.

Because the MCP is a profile of ISO19115/19139, the easiest path to creating these XSLTs is to copy them from the iso19139 schema and modify them for the changes in namespace required by the MCP.
	
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Creating the update-... XSLTs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **update-child-from-parent-info.xsl** - this XSLT is run when a child record needs to have content copied into it from a parent record. It is an XSLT that changes the content of a few elements and leaves the remaining elements untouched. The behaviour of this XSLT would depend on which elements of the parent record will be used to update elements of the child record.
- **update-fixed-info.xsl** - this XSLT is run after editing to fix certain elements and content in the metadata record. For the MCP there are a number of actions we would like to take to 'hard-wire' certain elements and content. To do this the XSLT the following processing logic: 

::
   
  if the element is one that we want to process then 
    add a template with a match condition for that element and process it
  else copy the element to output

Because the MCP is a profile of ISO19115/19139, the easiest path to creating this XSLT is to copy update-fixed-info.xsl from the iso19139 schema and modify it for the changes in namespace required by the MCP and then to include the processing we want.

A simple example of MCP processing is to make sure that the gmd:metadataStandardName and gmd:metadataStandardVersion elements have the content needed to ensure that the record is recognized as MCP. To do this we can add two templates as follows:

::

  <xsl:template match="gmd:metadataStandardName" priority="10">
    <xsl:copy>
      <gco:CharacterString>Australian Marine Community Profile of ISO 19115:2005/19139</gco:CharacterString>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:metadataStandardVersion" priority="10">
    <xsl:copy>
      <gco:CharacterString>MCP:BlueNet V1.5</gco:CharacterString>
    </xsl:copy>
  </xsl:template>

Processing by update-fixed-info.xsl can be enabled/disabled using the `Automatic Fixes` check box in the System Configuration menu. By default, it is enabled.

Some important tasks handled in upgrade-fixed-info.xsl: 

- creating URLs for metadata with attached files (eg. onlineResources with 'File for download' in iso19139)
- setting date stamp/revision date
- setting codelist URLs to point to online ISO codelist catalogs
- adding default spatial reference system attributes to spatial extents

A specific task required for the MCP update-fixed-info.xsl was to automatically create an online resource with a URL pointing to the metadata.show service with parameter set to the metadata uuid. This required some changes to the update-fixed-info.xsl supplied with iso19139. In particular:

- the parent elements may not be present in the metadata record
- processing of the online resource elements for the metadata point of truth URL should not interfere with other processing of online resource elements

Rather than describe the individual steps required to implement this and the decisions required in the XSLT language, take a look at the update-fixed-info.xsl already present for the MCP schema in the iso19139.mcp directory and refer to the dot points above.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Creating the templates directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is a simple directory. Put XML metadata files to be used as templates in this directory. Make sure they have a `.xml` suffix. Templates in this directory can be added to the catalog using the Administration menu.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Editor behaviour: Adding schema-suggestions.xml and schema-substitutes.xml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **schema-suggestions.xml** - The default behaviour of the GeoNetwork advanced editor when building the editor forms is to show elements that are not in the metadata record as unexpanded elements. To add these elements to the record, the user will have to click on the '+' icon next to the element name. This can be tedious especially as some metadata standards have elements nested in others (ie. complex elements). The schema-suggestions.xml file allows you to specify elements that should be automatically expanded by the editor. An example of this is the online resource information in the ISO19115/19139 standard. If the following XML was added to the schema-suggestions.xml file:

::

  <field name="gmd:CI_OnlineResource">
    <suggest name="gmd:protocol"/>
    <suggest name="gmd:name"/>
    <suggest name="gmd:description"/>
  </field>

The effect of this would be that when an online resource element was expanded, then input fields for the protocol (a drop down/select list), name and description would automatically appear in the editor.

Once again, a good place to start when building a schema-suggestions.xml file for the MCP is the schema-suggestions.xml file for the iso19139 schema.

- **schema-substitutes.xml** - Recall from the 'Schema and schema.xsd' section above, that the method we used to extend the base ISO19115/19139 schemas is to extend the base type, define a new element with the extended base type and allow the new element to substitute for the base element. So for example, in the MCP, we want to add a new resource constraint element that holds Creative Commons and other commons type licensing information. This requires that the MD_Constraints type be extended and a new mcp:MD_Commons element be defined which can substitute for gmd:MD_Constraints. This is shown in the following snippet of XSD:

::

  <xs:complexType name="MD_CommonsConstraints_Type">
    <xs:annotation>
      <xs:documentation>
        Add MD_Commons as an extension of gmd:MD_Constraints_Type
      </xs:documentation>
    </xs:annotation>
    <xs:complexContent>
      <xs:extension base="gmd:MD_Constraints_Type">
        <xs:sequence minOccurs="0">
          <xs:element name="jurisdictionLink" type="gmd:URL_PropertyType" minOccurs="1"/>
          <xs:element name="licenseLink" type="gmd:URL_PropertyType" minOccurs="1"/>
          <xs:element name="imageLink" type="gmd:URL_PropertyType" minOccurs="1"/>
          <xs:element name="licenseName" type="gco:CharacterString_PropertyType" minOccurs="1"/>
          <xs:element name="attributionConstraints" type="gco:CharacterString_PropertyType" minOccurs="0" maxOccurs="unbounded"/>
          <xs:element name="derivativeConstraints" type="gco:CharacterString_PropertyType" minOccurs="0" maxOccurs="unbounded"/>
          <xs:element name="commercialUseConstraints" type="gco:CharacterString_PropertyType" minOccurs="0" maxOccurs="unbounded"/>
          <xs:element name="collectiveWorksConstraints" type="gco:CharacterString_PropertyType" minOccurs="0" maxOccurs="unbounded"/>
          <xs:element name="otherConstraints" type="gco:CharacterString_PropertyType" minOccurs="0" maxOccurs="unbounded"/>
        </xs:sequence>
        <xs:attribute ref="mcp:commonsType" use="required"/>
        <xs:attribute ref="gco:isoType" use="required" fixed="gmd:MD_Constraints"/>
      </xs:extension>
    </xs:complexContent>
  </xs:complexType>

  <xs:element name="MD_Commons" substitutionGroup="gmd:MD_Constraints" type="mcp:MD_CommonsConstraints_Type"/>

For MCP records, the GeoNetwork editor will show a choice of elements from the substitution group for gmd:MD_Constraints when adding 'Resource Constraints' to the metadata document. This will now include mcp:MD_Commons. 

.. figure:: Editor-Constraints-Choices.png

Note that by similar process, two other elements, now deprecated in favour of MD_Commons, were also added as substitutes for MD_Constraints. If it was necessary to constrain the choices shown in this menu, say to remove the deprecated elements and limit the choices to just legal, security and commons, then this can be done by the following piece of XML in the schema-substitutes.xml file:

::

  <field name="gmd:MD_Constraints">
    <substitute name="gmd:MD_LegalConstraints"/>
    <substitute name="gmd:MD_SecurityConstraints"/>
    <substitute name="mcp:MD_Commons"/>
  </field>
  
The result of this change is shown below.

.. figure:: Editor-Constraints-Choices-Modified.png

Once again, a good place to start when building a schema-substitutes.xml file for the MCP is the schema-substitutes.xml file for the iso19139 schema.


Adding components to support conversion of metadata records to other schemas
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Creating the convert directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the new GeoNetwork plugin schema is to support on the fly translation of metadata records to other schemas, then the convert directory should be created and populated with appropriate XSLTs.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Supporting OAIPMH conversions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The OAIPMH server in GeoNetwork can deliver metadata records from any of the schemas known to GeoNetwork. It can also be configured to deliver schemas not known to GeoNetwork if an XSLT exists to convert a metadata record to that schema. The file `INSTALL_DIR/web/geonetwork/WEB-INF/config-oai-prefixes.xml` describes the schemas (known as prefixes in OAI speak) that can be produced by an XSLT.
A simple example of the content of this file is shown below:

::

  <schemas>
    <schema prefix="oai_dc" nsUrl="http://www.openarchives.org/OAI/2.0/" 
            schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc.xsd"/>
  </schemas> 

In the case of the prefix oai_dc shown above, if an XSLT called oai_dc.xsl exists in the convert directory of a GeoNetwork schema, then records that belong to this schema will be transformed and included in OAIPMH requests for the oai_dc prefix.

To add oai_dc support for the MCP, the easiest method is to copy oai_dc.xsl from the convert directory of the iso19139 schema and modify it to cope with the different namespaces and additional elements of the MCP.
