================================================================================
===
=== GeoNetwork 2.6.4: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- #456 Catalan translation, thanks Montserrat Marco Sabaté.
- #462: Load wms in map viewer for service metadata
- #463: Update Web Map Viewer OpenLayers to 2.10
- CSW Server configuration: use textarea for abstract and increase field size
  (label) in CswServerCapabilitiesInfo table
- Set WMC panel layout
- Added verbose protocol list for online resources (metadata editor)
- Turkish translation, thanks to the Turkish Kadastro (TKGM)
- #491: Custom ElementSet in CSW 2.0.2
- INSPIRE schematron fixes integrated from trunk
- CSW INSPIRE capabilities document updated to 1.0 xsd (scenario 2). Default
  values in capabilities_inspire.xml for TemporalReference, MetadataDate,
  SpatialDataServiceType, etc require user customization for his catalog

--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------

- #299: Catch all empty elements with gco:nilReason=missing attribute to avoid
  large blank spaces in metadata views.
- #395: Use proxy configuration for built in proxy in GeoNetwork. Thanks schaubr
  for patch
- Fix for ticket #435 - thanks to Craig Jones, IMOS/eMii and Andrew Walsh, AODN
- #467: Search by abstract in Dublin Core doesn't find results
- #473: Left-column disappearing. Disabled scroll effect
- #476: Improvements to GeoNetworkAnalyzer
- Restore ending wildcard. Related to #476.
- Fix #478. Thanks Justin Rowles
- Fix resumptionToken handling in OAI-PMH harvester: backporting #7189
- OAIPHM havester fix for Until date, the From date value was used instead
- #492 : CSW 2.0.2 ElementName processing broken
- #503 Security hole in metadata insert
- Metadata insert, fixes when validation option is selected:
  1) validate xsd and schematron, both in copy&paste and file upload options
  2) show schematron report with errors (if any)
- Fix for save template display order

================================================================================
===
=== GeoNetwork 2.6.3: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------

- #422 : 26x numeric fields range query bug
- #376 : Configurable stopwords fixes
- Tokenize responsiblePartyRole field to allow case insensitive searches
- Unification of INSPIRE GEMET thesaurus path for schematron rules and indexing
  of INSPIRE themes
- xml.user.metadata service changed to use Lucene instead of SQL

================================================================================
===
=== GeoNetwork 2.6.2: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------

- Be sure id is an integer when creating SQL query. Thanks Pierre Mauduit
- Fix download with special character
- Protect code in getMetadataFromIndex if createDate or changeDate are null (for
  example, if created/harvested invalid metadata without this fields)
- Removed Download link (doesn't work within release documentation unless
  generic)
- Use permanent redirect instead of temporal redirect to avoid some issues when
  running with Apache proxy
- XSL processor configuration
- Fix #387 : GN vulnerable to other application's TransformerFactory
- Fix #397 : Thesaurus name after adding keyword
- Fix #398 : INSPIRE keywords not multilingual
- Fix #399 : Map in editor does not work correctly
- Fix #400 : Security hole in GeoNetwork -- search for owner
- Fix #413 : Fix typo in SQL scripts
- Fix #415 : Simple numeric indexing

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------
- 2.6.x documentation updates
- Added documentation for ArcSDE harvester
- ArcSDE harvester documentation update
- GN logo points to http://geonetwork-opensource.org
- Improved documentation
- Improved pdf search print layout
- Removed InterMap log removal
- Small GUI improvements in search form
- Update version number in installer
- Updated Russian language files (thanks Irina Romanova)
- Updated documentation license
- Updated navigation for documentation
- Updated sql files for 2.6.2
- #376 : Configurable stopwords
- #391 Metadata Notifications to Remote Targets
- #407 : Option to discard invalid harvested metadata
- #410 : My Metadata function
- #411 : INSPIRE - support for CSW LANGUAGE parameter
- #412 : Add isPublishedToAll to geonet:info

================================================================================
===
=== GeoNetwork 2.6.1: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------
- Exclude some substitutions which prevent the vertical extent element from
  being fully expanded
- Fix migration scripts from 2.4.3 to 2.6.0
- Fix search using INSPIRE annex
- Typo fix for German language
- Added support for sqlserver database. Thanks to Mikael Elmquist for provide
  sql files
- Add in xslt converters for DIF to ISO and Thredds
- Missing xslt to convert netcdf CDM coords to ISO keywords
- Fix harvesting a OAI set whose name contains a "-". Thanks Tim Proescholdt
- Fix #335: Max number of children displayed in relation panel. Added from and
  to parameters to allow paging in related records if needed
- Fix #339: Wildcard search broken
- Fix #337: Metadata indexing uses old INSPIRE setting
- Fix #343: CSW / iso19110 / exception when requesting ISO19139 output
- Fix #344: bad schema error when using XSL on import. Thanks murrayking
- Fix #345: Changed postgres driver version to be compatible with Java 1.5
- Fix #346: Javascript error when setting "singleTile: true" for a WMS layers in
  Map viewer
- Fix #347: Fix thesaurus directory removed by maven
- Fix #348: ArcSDE Harvester. Javascript error accessing config panel
- Fix #354: XSL error message in WMC to Iso19139 transformation
- Fix #357: Use geometry parameter in GUI search for bounding boxes, instead of
  lucene bbox fields. Fixed also Disjoint spatial filter
- Fix #364: CSW queryables, added support for INSPIRE ResponsiblePartyRole and
  fix for ResourceIdentifier
- Fix #365: Allow to configure LDAP uid attribute name
- Fix #366: Add contextual label translation allowing to use full xpath for
  elements in metadata editor
- Fix #367: Not possible to search on Subject queryable for a value that
  includes spaces
- Fix #371: Tooltips in System Configuration have disappeared

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------
- Added support for OpenLayers Map config options in map viewer
- Service to retrieve the metadata owned by a user
- Use redirect for login and logout services to show in browser address bar the
  url of main page, after login/logout

================================================================================
===
=== GeoNetwork 2.6.0: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------
- Fix for windows installer
- Included developer docs in installer and fixed links in index files
- Updated images and content in user manual (getting started section)
- Fix #311: For FGDC metadata the lat/lon values for the CSW response are
  concatenated instead of separated by a space (Thanks Marten Hogeweg)
- Fix #309: Open the CSV in a new page 
  Could not reproduce the dissapear of left menu. But seem better open CSV in a
  new window instead of repacing application window
- Fix #308: No result for "export as TXT" for templates
- Fix #303 : Invalid character when connecting to external database (Thanks to
  zoerb).
- Add missing data file for PostGIS.
- Fix to use proxy config in GetRecordsByIdRequest
- Fix #293: Fix for queries with AS clause in MySql. Thanks Justin Rowles for
  patch
- Fix #307: Use default OL cursors to avoid ServiceNotFoundEx exceptions in GN
  when using IE (IE doesn't resolve correctly cursor image url)
- Fix #319: Calendar buttons dont show the calendar in metadata editor after
  click on Check or Save button
- OGC harvester / Improve distribution info section for WMS service metadata.
- Included disclaimer window for WMS services in map viewer
- Fix to solve about some responses are cut when returned to the client
- Fix #320 typo
- Fix #304 WFS harvesting improvement.
- Fix #306 opener ref not used in trunk.
- xalan is not longer supported
- Fix #275: Image not showing
  The logo image for the GeoNetwork site was only created the first time when
  the database was initialized. 
  If the application was updated with a new version (images/logos folder only
  contains dummy.gif logo then) and preserving the database, the logo was not
  created again.
  Changed to check always in startup if logo for GeoNetwork site exists, if not
  then creates it
- Fix #320: parse and use mapSearch layers setting
  1) Map search uses custom layers if defined in config-gui.xml
  (mapSearch/layers). If not defined this section, uses layers defined for map
  viewer (mapViewer/layers)
  2) Use mapOptions hash, when initializing search maps
- Fix #323: Scrollbar in IE8
  Also happened in other browsers
- Zoom to region in search map, when selecting a region in combo list
- Protect resetInspireOptions method if inspire search panel is not enabled
- Fixes for thredds harvester - include validator precond, missing gif and
  recognition for thredds harvester Include baseUrl in geonet:info for scripts
  that don't have /root/gui info
  Include opendap-2.1 jar needed for thredds harvester
- Fix #328 LDAP DN Problem. Thanks to JoshVote for the fix.
- Fix remove uploaded file bug
- Fix #330 Improve validation report layout. Thanks Justin Rowles. 
- Fix #334 Web Map Viewer boudingbox taken from /root/gui/config/mapViewer
  subtree (Thanks Landry Breuil)

fixes in 2.6.0-1

- Fix migration scripts from 2.4.3 to 2.6.0
- Exclude some substitutions which prevent the vertical extent element from
  being fully expanded

================================================================================
===
=== GeoNetwork 2.6.0RC2: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------

- Fix #223: manage parameter names from capabilities document in
  case-insensitive manner
- Fix #246: Simplify metadata view. Restored old layout to show metadata.
- Fix #257: Release the screen overlay in metadata editor when an error happen
  saving the metadata
- Fix #265: Fix for mis-aligned options in opera and IE
- Fix #271: CSW parent identifier field. Thanks Jürgen Weichand.
- Fix #272. Removing last element in simple mode.
- Fix #273: Update rss panel after delete metadata records
- Fix #276: Export as CSV issues
- Fix #278: Check online source already exist. Copy full distribution section
  content before update. Thanks Sylvain for testing.
- Fix #279: All maps are using same background layers. Harmonize size of all
  bbox inputs in edit and view mode.
- Fix #280: Alignment, highlighted, etc issues in metadata edit
- Fix #286: After click Metadata button in search results, editing a metadata
  show advanced edit instead of previously selected.
- Fix #288: Show number of records to delete in massive delete confirm message
- Fix #290: Improvements in export selection to pdf
- Fix #291: Menu "Actions on selection" issues
- Fix #292: Don't show the download button if the download link is empty
- Fix #294: Security hole in GeoNetwork search
- Fix #295: Calendar << and < buttons are not visible (blue on blue). Thanks
  Justin Rowles for patch
- Fix #296: Data rating window position
- Fix #301: Update saxon to fix JIT bug (also introduce 9.1.0.8b) 
- Fix #302: Include jdbm jar for JZKit3/Z3950 server
- OGC WMS Harvester / fix malformed URL. Add serviceType lucene field.
- Fix INSPIRE theme thesaurus name according to RDF file available in SVN
  utility folder.
- User manual updates
- Do not display translation tools icon if no other language declared.
- Fix selected group in advanced search

================================================================================
===
=== GeoNetwork 2.6.0RC1: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------
- Fix for #263: Screen refresh not working
- Fix #266: Show alert if click on "Add templates" button and no selected
  templates. Remove from admin interface iso19115 templates.
- Fix for #267: Page coming up blank afer delete
- Fix for #268: Mis-aligned result in search
- Fix for #259: Fix for templates menu in administration
- #255: Fixed help links
- Fix for #265: Scroll-bar appearing when probably shouldn't
- #244: Update popup position always to work correctly when the window is
  resized
  Fixes for IE. Thanks to Jürgen Seib for reporting
- Fix GAST, "back to normal" since maven migration. Thanks to Jesse Eichar for
  his contribution.
- Map viewer: save map state in cookies (layers config and extent)
- Removed xlink:href attribute to link service and dataset in OGC WxS harvester
  which interact with XLink resolver. 
  Only uuidref attribute is used to navigate between records.
- Return all bboxes in brief formatting.
- Fix #250: Removing old thumbnail for OGC harvester.
- Fix #251. Xml search service does not use default param and does not keep any
  search results in session. Make it behave more like the main search service.
- Fix PDF print #252. Missing class due to wrong dependency version. Fix pdf
  selection and present print action.
- #244: Fix position of Other actions panel
- #253: User interface aligment issues in Opera and IE
- Replaced TRUNCATE with DELETE commands for Oracle data script.
- Removed optimization of updatePopularity in thread code.
- Update popularity also for harvested metadata.
- Fix CSV search broken by XSL output declaration in main.xsl.
- Fixes in LuceneQueryBuilder class
- Fix #249. Only one call to topDocs could be made on a TopFieldCollector.
- Speed up YUI compression excluding unnecessary JS files.
- Administration option to load metadata samples

================================================================================
===
=== GeoNetwork 2.6.0RC0: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------
- Fix #146: Illegal character handling not robust
- Fix #170: Store more than one record in user session. Thanks Simon.
- Fix #202 to get "Not" and "PropertyIsNotEqualTo" filters work correctly
- Fix #218: Check privileges before exporting private data in MEF1 and MEF2
  export.
- Fix #219: Sample lacks download button
- Fix #224. For each outputFormat provided by WFS server add an OnlineSource?
  link to allow download of features.
- Fix #225: Add OpenSearch suggestion support.
- Fix #228: Add search criteria for revision, publication, creation date. 
- Fix #237: Replace Intermap with OpenLayers
- Fix #241: support for IPv6
- Fix #247: org.apache.lucene.store.AlreadyClosedException occurs for concurrent
  CSW getRecords requests
- Fix #248: CSW: Provide configurable limit on records examined for
  getcapabilities keywords and getdomain propertyname
- Fix #249: CSW / GetRecords / results_with_summary : empty results
- CSW: Implement reprojection of geometries in ogc:Filter to WGS84, add missing
  Equals filter and 
  Within filter does within, make sure filter-to-lucene.xsl doesn't try to handle
  ogc:Not over spatial expressions
- CSW and Search: Change IndexReader handling in LuceneSearcher and
  CatalogSearcher
- Z3950: Don't add collections from GeoNetwork Z server if it isn't enabled
- Include mime type in Lucene index.

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------
- GAST changes to use sql data files instead of ddf files
- Maven migration
- English documentation ported into reStructuredText format.

================================================================================
===
=== GeoNetwork 2.4.3 minor bug fix release: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------
- INSPIRE support, including a specific search form (disabled by default, enable
  in the System preferences panel)
- CSW ISO profile updates and test suite
- GeoServer upgrade to v2.0.1 with the REST API and SLD Styler included
- Search speed improvements (more to come in v2.6.0, due in August 2010!)
- Added Portuguese language and improvements for others

================================================================================
===
=== GeoNetwork 2.4.2 minor bug fix release: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------

- 158: CSW harvesting. Send preferred outputSchema from Capabilties in requests
- 155: CSW harverting only supports 2.0.2 servers 
- 156:Proxy server is not used for all CSW harvesting operations (also fixed
  OGCWXS harvester)
- Fix for ticket 125: Increase perfomance of showing metadata executing increase
  popularity asynchronously
- Fixed keyword identifier with no #. See #147.
- Close existing Lucene searcher. Fixed type issue.
- Case insensitive UUID handling
- Fixed bad attribute name. Thanks Richard Walker.
- Fixed javascript error with IE8 (#145). Thanks to Christopher and Andrew.
- Fixed UUID generation when inserting metadata with option : "Generate UUID ..."
  (#144).
- updated change log
- Inline documentation

================================================================================
===
=== GeoNetwork 2.4.1 minor bug fix release: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------

- Corrected Dutch translation
- Fixed force rebuild index on startup.
- Fixed hardcoded english strings in javascript. Use the translate(tagName)
  function and the js attribute in loc file now.
- Added login support for CSW operations from CSW test page to easily test
  transactions.
- Translation fix. Thanks Jean Pommier.
- Added doc to disabled caching and use Saxon.
- #141 Fixed XSL compilation error for RSS services (due to additional bracket).
  Thanks to Roger and Jean.
- Fixed typo in codelists (#140).
- Fixed category search menu. See #139
- Fixed keyword autocompletion. Thanks Richard Walker. #134

================================================================================
===
=== GeoNetwork 2.4.0 Final: List of changes (See also changes 2.4.0.txt)
===
================================================================================
--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Added MD5 checksum creation to installer build process
- Alter sections of manual that describe system configuration to include
- Bring fgdc thumbnail handling into line with ISO (ie. add thumbnail
  upload/button to editor)
- bulk import.
- Capabilities_Filter section is mandatory
- CSW / Fix fallback to POST method if existing.
- csw:csw-2.0.2-GetCapabilities-tc7.1 and ...-tc7.2 
- details on shibboleth and reorganisation for authentication.
- Documentation updates related to System configuration
- Enhancement - ticket #131 - add thumbnail display for fgdc metadata
- Fix bug with permissions when GN in Z server role
- Fix for Oracle SQL create database script
- Fix includes in summary/brief metadata returned by z3950 so that they work
  with saxon
- Fix links to manual.pdf
- Fixed checkBoxAsBoolean for multiple checkboxes, thanks FXP
- Folder related to Jeeves
- folder related to xslt caching
- For type gco:Boolean use a checkbox control in the editor. If user checks /
  unchecks the box, the value of a hidden input is set to true or false
  respectively.
- group authentication options to include self-registration, clarify choices
- Handle <image type="unknown" ..> links to thumbnails from all standards by
  scaling down
- harvest from geonetwork node wasn't updating thumbnails
- harvested records should not be synced by metadata sync in gast
- Make sure gast picks up xslt transformer factory choices from services
- Minor fix required to pass two tests from OGC CSW 2.0.2 test suite
- modalbox fixes including tabbing between form fields
- Prevent confusing error caused by attempting to add a thumbnail with empty
  filename
- Remove unnecessary include which caused saxon to return an error when doing
- Remove unused xalan namespace from xslt
- removing geonetwork APIs from SVN
- Show thumbnail for fgdc in full metadata view but not in embedded view
- Small documentation updates to trunk
- Tidy validation error/no-error reporting and fix ticket #127
- updated, synchronized files for all languages

================================================================================
===
=== GeoNetwork 2.4.x RC2: List of changes (See also changes 2.4.0RC2.txt)
===
================================================================================
--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------
- improve french translation (merge from geocat.ch and GeoSource, Thanks Annina 
  and Etienne)
- improve CSW dc mapping response for service metadata in ISO or ISO profil
- harvesting / OGC-WxS harvester set coupledResource elements and not only 
  operatesOn.
- admin / misc styling fix (admin css, missing localised string mainly in JS 
  alert, sorting list). 
- admin / make common templates for metadata import and batch import forms.
- admin / if no templates available, display message rather than an empty list.
- admin, search / if no categories, hide option and set default option to none 
  (to be continued). Some users are not using categories at all.
- add some FIXME to be discussed for cleaning. Mainly in XSL templates and 
  localised stuff in JS. In JS, it could be better to create an array of 
  localised string needed in JS files. This could allow to make a better 
  separation with JS and XSL files (ie. remove all JS from XSL files) and call 
  this array to retrieve localised string from JS.
- edit / edit buttons : localisation and truncate title if larger than XX
  character.
- Do not capitalize all element name to avoid Point Of Contact. Fixe capitalize 
  in localisation files if needed.
- import / Add batch MEF import
- edit / sort enumeration (eg. in ISO topic category and service direction)
 
--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------

- Add support for proxies to OAI and OGC (thumbnail) harvesters
- Delete public/private resources after MEF backup in both Delete and
  MassiveDelete
- Fix bug in metadata copy/paste reported by Heikki (Ticket 104)
- Add results page for metadata batch import and metadata copy/paste
- csw / SummaryComparator should not trigger exception when numeric comparison 
  occurs on wrong data type (eg. scale denominator). Those values are pushed to 
  the bottom of the list.
- edit / Use new layout for gmd:MD_Metadata/gmd:Contact
- edit / When duplicating metadata only groupOwner could be set (not a multiple
  select box)
- Fix some JS error for non escaped character in localised file (french mainly).

================================================================================
===
=== GeoNetwork 2.4.x RC1: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Allow Featured map result to be limited to a specified bounding box (global is
  default)
  
- Fix to prevent Stack Overflow when validating large metadata documents
  The setting now defaults to 2 megabyte (-Xss2M) but should be increased even 
  further (to -Xss10M or even -Xss20M for very large metadata documents)
  (thanks to Richard Fozzard)
  
- Updated German translation (thanks to David Arndt)

- Updated French translation (thanks to Etienne)

- Fixed bug #90 and #91 - Thanks to Tom Kralidis

- Fixed missing loc file for csw:records.

- Ensure that Metadata.data column is of type longtext for MySQL. Thanks to Tom.

- WebDAV harvesting improvements

- ArcSDE metadata harvesting

- import cleanup

================================================================================
===
=== GeoNetwork 2.4.x RC0: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Known issues
--------------------------------------------------------------------------------

- On some Windows systems, installing in the default Program files folder causes
  a stylesheet compilation error. The workaround is to install in a directory
  without spaces in the folder names. E.g. in c:\geonetwork

- In Postgresql an error occurs related to type casting while migrating from 
  version 2.0.3. Using the older version of the jdbc driver version 7.4 seems 
  to resolve this problem for Postgres v7 and v8.x. The old driver can be found 
  at http://jdbc.postgresql.org/download.html#archived

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Added russian translation (Thanks to Igor V. Burago) #93

- Improve CSW 2.0.2 ISO Profil support
  (http://trac.osgeo.org/geonetwork/wiki/CSW202Improvements)

- Added import XML/MEF file
  (http://trac.osgeo.org/geonetwork/wiki/MetadataImport)

- Added SelectionManager
  (http://trac.osgeo.org/geonetwork/wiki/SelectionManager)

- Ajax Editor Controls and other Editor Enhancements  
  (http://trac.osgeo.org/geonetwork/wiki/AjaxEditorControlsAndValidation)

- More operations on a selected set of metadata records 
  (http://trac.osgeo.org/geonetwork/wiki/MoreMassiveOperations)

- Improve user interface for file upload/download
  (http://trac.osgeo.org/geonetwork/wiki/FileUploadAndDownload)

- Restore editing rights and ownership enhancements
  (http://trac.osgeo.org/geonetwork/wiki/Permissions)
  
- User Self-Registration Service
  (http://trac.osgeo.org/geonetwork/wiki/SelfRegistration)
  option to Administration->System Configuration to enable/disable
  UserSelfRegistration

- Add Shibboleth as an authentication option
  (http://trac.osgeo.org/geonetwork/wiki/ShibbolethAuth)

- Upgraded GeoServer to version 1.7.3

- Upgraded Jetty servlet container to version 6.1.14

- Moved data folder out of WEB-INF folder to ./data in the root of the
  application

- Added multilingual support in installer

- Added french translation of the documentation

- Added file system harvester to harvest metadata from local directory (from the
  server perspective)

- Added ArcSDE harvester to harvest metadata from an ArcSDE geodatabase 
  (requires dummy library to be replaced with ESRI Java API to work)

- Added support for printing search result in PDF format 
  (http://trac.osgeo.org/geonetwork/wiki/PrintPdf)

- Added support to harvest the OGC:GetCapabilities (WMS, WFS, WCS and WPS)
  documents to produce metadata for services and layers/featuretypes/coverages
  in ISO19139/119 format (http://trac.osgeo.org/geonetwork/wiki/ISO19119impl)

--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------


================================================================================
===
=== GeoNetwork 2.2.0 Final: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Known issues
--------------------------------------------------------------------------------

- On some Windows systems, installing in the default Program files folder causes
  a stylesheet compilation error. The workaround is to install in a directory
  without spaces in the folder names. E.g. in c:\geonetwork

- In Postgresql an error occurs related to type casting while migrating from 
  version 2.0.3. Using the older version of the jdbc driver version 7.4 seems 
  to resolve this problem for Postgres v7 and v8.x. The old driver can be found 
  at http://jdbc.postgresql.org/download.html#archived

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Sample metadata is now an option in the package selection panel

- The commandline installation using the install script generated by the
  installer is working again.
  
- Upgraded IzPack version. Debug information using -DTRACE=true now available
  (see documentation on "Commandline installation").
  
- Presentation updates for embedded metadata show.

- Simplification of the presentation of the metadata using 'fieldset' instead of

  dotted lines to display metadata blocks

- upgraded Jeeves and related commons-fileupload-1.2.1.jar

- Label updates for French and English

- Updated map services list

- Start GeoNetwork headless (prevent pop-up Java windows)

- Improved JavaDoc

- GAST: Changed the delete table order to respect constraints

--------------------------------------------------------------------------------
--- Bug fixes
--------------------------------------------------------------------------------

- Fix for internet exploder upload problem

- GAST: Fix the way the metadata owner is calculated during migration

================================================================================
===
=== GeoNetwork 2.2.0 RC2: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- New
--------------------------------------------------------------------------------

- Migration of all documentation into DocBook based on the Apache Velocity 
  DocBook framework. All documentation is now written in DocBook format and 
  build into HTML and PDF output using Ant.
  
- RESTful URL to metadata resources using URLs formatted as:
	http://mysite.org/geonetwork?uuid=xxx-xxx-xxx
	
- uuid can be used to show a record. This is now used for RSS feeds, KML, latest
  updates and searches
  
- Added Social Bookmarking links to delicious, digg, stumbleupon and facebook
  (not visible for resources on local machine (localhost, 127.0.0.1)

- Added Send by email link for metadata records
  (not visible for resources on local machine (localhost, 127.0.0.1)
  
- Add push pins with comments on InterMap. The markers can be edited and are
  stored in GeoRSS format within the Web Map Context document and in the HTML
  email users can send to friends.
  
- Add and remove parent - child relations between metadata records. (No GUI is 
  provided with this service and the functionality relates to the already 
  existing xml.relation.get search function)
  
- Added local GeoServer link to InterMap default list of map servers.

- Added support for PHRASE, OR and WITHOUT queries (for now hidden in search 
  form, but can easily be made visible)
      
--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Improved RSS feeds on search and latest updates are consolidated 
  (use same templates for output of items)
  
- Updates to documentation

- Improved error reporting in AJAX interface

- Minor translation updates

- Improved email message send out by InterMap with Web Map Context document

- language support and simplified messaging to the validation output

- Changed startup scripts for Windows to hide (or allow to hide) the dos window.

- GeoRSS opens in new browser window

- Added SMTP port to WMC mail function

- Hide sub-template elements (option and title) for 2.2RC2

- Add debug parameter to avoid popup alerts on InterMap for operational 
  deployments.
  
- Renamed gast startup files. Makes it slightly easier to run 
  start-geonetwork.sh from terminal on a *NIX machine.
  
- Small updates in shortcut menus

- Added a docs context as part of the Jetty configuration.

- Added "label for" for checkbox elements to be able to check boxes when 
  clicking the label
  
- Added some gml labels for nicer display and editing.

- Upgrade Lucene to version 2.3.0

- Change of content type for RSS services

- Automatically open the map viewer when a WMC context is given in the URL.

- Updated help on Localization interface

- Cleanup OnlineResources display to prevent display of download and interactive
  map buttons when no URL is actually found in the metadata
  
- Added warning & help to the categories and groups admin forms

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Fixed geographic search (communication between small map AoI and dropdown 
  list, added User defined as an option to dropdown)
  
- Fix problem retrieving string from editor.xml that causes internet exploder 
  to choke on tooltips for elements without a help string
  
- Retrieve the keywords relevant to the record in preparing brief summary xml

- Fix for the info request to a WMS service

- Feedback fix (feedback was not processed by application)

- Fixes for attributeGroup inheritance and automatic srsName. Added support for 
  the srsName attribute in gml featuretypes for display and editing the Extent 
  as an EX_BoundingPolygon.

- Fixed #55 adding an observer for Enter key on main.home page

- Fixed #44 switch lower/upper corners of geokeywords
  
- MySQL longtext fix to avoid truncated metadata records

- Initial minimap extent is now set to the union of the bboxes of all the 
  displayed layers.

- Ensure UUIDs are stored in lower case

- Copy attributes before inserting new fileIdentifier element

- Fix for IE: clicking on a marker now opens its info panel.

- Fixed: Layer list not displayed in IE.

--------------------------------------------------------------------------------
--- Known issues
--------------------------------------------------------------------------------

- default settings reset function in advanced search not in synch with 
  application defaults (fixed for Final Release)

- Namespace issue for some labels in languages other than English in 
  ISO19115/19139 (fixed for Final Release)

- Some missing labels for Dublin Core fields in languages other than English 
  (fixed for Final Release)

================================================================================
===
=== GeoNetwork 2.2.0 RC1: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Removed version number from image for easy maintenance

- Updated and new logos for different harvesting types

- Added a default bounding box to the DC template

- Added description that suggests how to fill in the bounding box in DC

- Slightly improved the content type filter, removing the list box with unusual 
  content types (protocols)
  
- Aligned default values with interface for content types

- Added extra debug logging, Added JavaDoc comments to Search constants, 
	Rearranged constants, Added comments to Lucene index files
	
- Build file for docbook documentation

InterMap:

- Add the Extension element only when needed to Web Map Context

- Temporary paths are now relative to the intermap servlet directory or 
  absolute to the file system

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Fix to allow search for all metadata in the catalog, including those that do 
  not contain a bounding box. Now the BBOX and region code are not included in 
  the query when the Region field is set to '- Any -'  
  
- Skip alphanumeric validation to ensure all type of servlet names are allowed
  e.g. mysub/geonetwork or just /

================================================================================
===
=== GeoNetwork 2.2.0 RC0: List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- New
--------------------------------------------------------------------------------

- Added User Quick Start Guide in pdf form

- Added direct link to open WMS services in Google Earth

- Added schematron validation

- Added OAI-PMH server protocol

- Added OAI-PMH harvesting type

- Added 'portal.get' and 'portal.sources' services

- GAST : Added console logging

- Added search criteria for downloadable and interactive maps

- Added text only search results for low bandwitdh connections 

- Added metadata popularity concept (used to sort search results)

- Added metadata rating system (used to sort search results). It is possible
  to rate remote metadata harvested using the geonetwork's harvesting type.

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Added new link following Atom / RSS type of structures

- Removed Oracle JDBC driver due to license incompatibility. 
  Driver can be downloaded from Oracle Technology Network by the user.
  
- All headers of Java classes have been checked and GNU-GPL license and 
  copyright statements have been added where missing.
  
- GeoRSS output for search and latest updates have been harmonized. 
  Both now support georss:box, georss:point or georss:where with a gml:Envelope
  output for the geo part.
  
- Added mapServer.xml configuration files that were missing in SVN, but were 
  in the release.
 
- Added 'sources' to search summary

- Now the mef.export service is accessible to users. Export is limited by
  metadata privileges.

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Fixed the date range search in advanced search

- Fixed transfer ownership bug: the target group was not properly set

- GAST : Fixed path in the migration procedure. Added the possibility to migrate
  GeoNetworks running on Tomcat.

- LDAP : passwords are now scrambled. Avoided admin login

- Editor : Fixed upload bug

- Fixed bug in privileges management : it was not possible to clear privileges
  for administrators and reviewer that were metadata owners

- Fixed NullPointerException in HTTP transaction handler in InterMap

- Fixed Windows installation problem with incorrect JRE requirements on install
  of the version that includes a JRE
  
- Fixed appearing and then disappearing metadata display in IE7

- Fixed some bugs to geonetwork 2.0 harvesting type

- Fixed thumbnails display on metadata harvested from a geonetwork 2.0 node

-----------------------------------------------------------
--- Known issues
-----------------------------------------------------------

- Some of the metadata display links do not open as embedded view while they
  should

- The Map Viewer "Add note" function is not fully functional yet

- The overview map does not automatically refresh when adding a new layer from
  the metadata

================================================================================
===
=== GeoNetwork 2.1.0 Final : List of changes
===
================================================================================
--------------------------------------------------------------------------------
--- New
--------------------------------------------------------------------------------

- Added portal.opensearch service to allow search from client supporting
  OpenSearch.org spec.

- Added xml.region.get service to retrieve Bounding Box given a region id

- Intermap: added "export PDF" feature.

- Intermap: added "refresh" button.

- Intermap: added layers are hilited in green.

- Intermap: AOI can now be deleted on minimap by pressing the AOI button
  when it's already selected.

- GeoNetwork added the AJAX advanced search.

- Added possibility to specify proxy's credentials

- Included a version of GeoServer with Blue marble and country boundaries base
  layers

- Handling interactive maps for metadata with OnlineResources holding
  getCapabilities WMS servers.

- Build tools for Windows native installer (win and *nix, macosx cleaned up)

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Intermap: added interaction with region selection dropdown list. Overview map
  zooms to AoI and keeps AoI set
  
- AJAX based default and advanced search interfaces added and navigation
  improved

- Intermap: when adding layers, the server list is now created on server via
  XSL, and no longer via JS on client.

- Intermap: the layer list is now created on server via XSL, and no longer
  via JS on client.

- Intermap: new icon for "add layer" button.

- Intermap: disabled scriptaculous effects under IE.

- Intermap: when there is only one layer, it has no "delete" button.

- Intermap: removed many unused JS functions.

- Improved both admin's guide and server reference manuals.

- Small georss fixes

- Legends in InterMap integrated in GUI

- Fixes to presentation of recent additions and categories using AJAX

- InterMap: Improved computation of scalebar lenght via Haversine formula.

- Some toolbar and legend improvements, including icon updates and additions

- Improved default and advanced search forms

- Improved presentation of beginPosition and endPosition fields in iso19139
  editor (have calendars)

- Home link always goes to homepage

- Map can now be resized by dragging its lower-right corner.

- Improved readability of the "loading map" message.

- Version and release numbers are <maintained> in this build file now!! 
  And still stored in the server.prop file.
  
- Moved Readme panel to the end of the installer and removed post install panel.

- Updated readme.html content

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Intermap: fixed duplicated TempFiles class.

- Intermap: fixed map reaspect (North Pole is not at 180 lat degrees).

- Intermap: up and down buttons in layer list now work.

- Fixed bug with character encoding when editing metadata

- Small fixes to the sample metadata for ISO19115/19139

- Removed invalid URLs from online resources in 19139 templates

- Fixed localization of the AJAX services

- Fixed Chinese localization

- Fix iso19115 packages for iso19139 - add contentInfo and extensionInfo

- The zoombox is now bound inside the map.

================================================================================
===
=== GeoNetwork 2.1.0 RC : List of changes
===
================================================================================

- Added simple LDAP authentication

- Added possibility to install sample metadata during installation

- Added WebDAV harvesting type

- Added mysql jdbc driver

- Finished Intermap integration

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Removed useless thumbnail in the coords box

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Fixed start-geonetwork.bat script

- Fixed bug during resource download. A missing 'host' or 'from' parameter 
  caused an exception

- Fixed bug in CSW harvesting: the privilege rows were pointing to webdav code

- Harvesting of type=geonetwork: changed radio buttons to dropdown list due to
  usual problems with IE

- Harvesting: fixed 'deactivate' message and 'run' button behaviour when the
  server is restarted and services now are not allowed.

- Fixed thumbnail in default view

================================================================================
===
=== GeoNetwork 2.1.0 beta5 : List of changes
===
================================================================================

- Added the concept of metadata owner. This avoids a bug with the search: if
  all privileges where removed the metadata got lost because the search was no
  able to retrieve it.

- Added documentation for new xml.schema.info service

- Added 'users' section in xml.info service

- Added 'cache=yes|no' attribute to Jeeves's services to allow data caching

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Moved schema labels and help strings into the proper schema folder

- In metadata.show and metadata.edit there are tooltips for elements instead of
  opening a separate window

- Removed EDIT and ADMIN privileges. Added the concept of metadata 'reviewer'.
  Adjusted all search and access policies.

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Fixed portal.search.present service: parameters where not pipelined

- Fixed path in csw start scripts

- Fixed password length in Users table

- Fixed logo image in search results with intermap

- Fixed query for featured metadata in the main page. It had some problems with
  PostgreSQL.

- Fixed bug when inserting a new user: the password was not scrambled

- Jeeves : removed path in file upload

- Fixed wrong table name when deleting harvesting nodes

- Fixed Ajax pages with IE (more or less)

- Fixed bug with MEF import: private data was not imported

- Fixed bug with data upload: if the browser was IE and the server was running
  on linux the upload file name contained the file path

- Fixed a bug in user creation page: it was not possible to create
  administrators

- Fixed a nasty bug in the editor that caused a stack overflow with date
  and thesaurusName elements.

================================================================================
===
=== GeoNetwork 2.1.0 beta4 : List of changes
===
================================================================================

- Added metadata backup on delete

- Added harvesting of CSW nodes

- Added Oracle JDBC driver 10g

- Merged Intermap

- Added 'xml.relation.get' service and 'Relations' table to support relations
  between metadata.

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Now UUIDs are varchar(250). This is necessary because some uuids could not
  be well formed.

- Now the server starts even if the Z39.50 port is already used. In that case,
  Z39.50 server will be disabled.

- MEF import: now if the uuid is missing, it is correctly stored inside the
  metadata

- MEF export: changed skipUUID default to false

- MEF format: added siteName

- xml.info : now returned groups are only those visible to the user

- xml.forward : changed structure to allow authentication

- Updated documentation.

- Now it is possible to search multiple keywords and categories in the server.
  Fields are specified using multiple key-value pairs (like
  category=aaa&category=bbb).
  Fields are put in OR form.

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Fixed missing scriptaculous inclusion in 'metadata.edit' and prototype
  inclusion in other pages.

================================================================================
===
=== GeoNetwork 2.1.0 beta3 : List of changes
===
================================================================================

- Added possibility to harvest old geonetwork 2.0 nodes

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Passwords are now encrypted using a SHA-1 algorithm

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Lucene search: fixed a possible race bug when metadata are deleted

- Fixed code compilation on computer with encoding different than ISO-8859

- Fixed namespace declaration for CSW requests returning FGDC metadata

- Changed label's length to varchar(96). There were some language descriptions
  that were beyond length 64.

- Fixed prototype inclusion bug. It was not possible to create new metadata

================================================================================
===
=== GeoNetwork 2.1.0 beta2 : List of changes
===
================================================================================

- GAST : Added migration code to migrate an old geonetwork installation

- GAST : Added conversion code from iso19115 to iso19139

- Added jdbc driver for postgresql

- Added confirmation dialog to GAST during database setup

- Added a sample group

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- User administration: now the group list is not shown if the choosen profile is
  'Administrator'

- Z39.50 : repositories.xml and schema-mappings.xml files are now processed at
  startup and do not required variable substitution anymore.

- AccessManager : now the allowed operations are read from the database

- Substituted proprietary cos.jar with jakarta commons fileupload

- Removed useless link to dc:identifier when showing dublin core metadata

- Main page/recent additions : now all groups visible to the user are considered

- Removed 'siteId' option to batch import. Files that do not end with '.xml' are
  skipped during import.

- Now it is possible to remove categories and groups when they have fkey
  relationships. Affected metadata are now reindexed.

- User add form : added alert if no group is selected, highlithed mandatory
  fields

- Metadata privileges : added a button to set all privileges all at once.

- Metadata creation and duplication: changed groups's combobox to a list

- ISO19139: Changed 'language' element to a char 3 code. Added a dropdown to the

  editor to choose the language. Updated migration stylesheets from 19115 ->
  19139

- ISO19139: Fixed TopicCategoryCode. It is not a codelist

- ISO19139: Changed dateTime element to date+time to allow validation.

- Massive Javascript refactoring to accomodate new harvesting needs

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Fixed NullPointerException with Tomcat

- Fixed validation bug using Java 1.5 facilities. Fixed iso19139 schema also

- Fixed fkey constraint violation when removing harvesting nodes

- Fixed an exception raised when changing user information

- Fixed bug in metadata.admin.form : now only groups visible to the user are
  returned

- Fixed bug in the editor : on Windows machines, CR/LF were doubled on saving

- GAST: resources were not properly aborted

- GAST: fixed missing 'gmd:' prefix when migrating metadata 19115 -> 19139

- User's form: the group's name was not localized

- Forced the 'gmd' prefix to iso 19139 metadata to both xml insert and batch
  import

- Fixed bug with metadata xml insert: 'title' is no longer mandatory if the
  kind is not subtemplate. Added some javascript to show/hide the title
  textfield.

- Fixed bug with MEF exports that caused corrupted files on Windows machines

- Localization form : fixed bug when saving region labels

- Z39.50 is now working

================================================================================
===
=== GeoNetwork 2.1.0 beta1 : List of changes
===
================================================================================

- Added GAST application

- Added form to localize entities

- Added possibility to create thumbnails from [Geo]Tiff images

- Added a user's guide

- Added MEF file format and related import/export facilities

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Installer simplified: options moved to GAST

- Added the installer data files to the installer packages

- Used proxy in xml.forward service and during harvesting.

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Exceptions : fixed a bug during stacktrace generation 

- [bug:1655563] Fixed bug with IPv6 loopback

- Fixed bug when indexing metadata: an error on indexing due to
  corrupted metadata is now ignored. This allows the system to boot.

- Fixed bug when removing data files: now it is possible to remove
  the entry from the metadata even when the files are not there.

- Fixed security bug in service xml.metadata.get

- Fixed bug with templates that were not shown

- Fixed bug when changing the user's password. It seems that the 'update()' 
  function has a different sematic if called inside the 'onClick' attribute

- Fixed wrong behaviour of 'back' button in categories/groups/users

- Fixed some bugs with Z39.50. Now, it should work.

================================================================================
===
=== GeoNetwork 2.1.0 alpha2 : List of changes
===
================================================================================

- Added metadata rating information (Score for Lucene)

- Added SOAP support to CSW. Updated test application to use SOAP.
  Used HTTP client library from Jakarta.

- Finished harvesting code for type=GeoNetwork 

- Added SQL script for PostgreSQL to the installer

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Removed file regions.xml and fixed lucene and Z39.50 searchers. This fixes a
  Z39.50 exception too.

- Removed 'delete', 'privileges' and 'categories' buttons for harvested metadata

- CS/W : now the host and port parameters for the capabilities XML are taken
  from the system config.

- Moved many of the istaller parameters to the web interface

- Changed the metadata root element from 'DS_DataSet' to 'MD_Metadata'

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Fixed bug with advanced search: the results were wrong if bounds were not
  specified

- Harvesting : fixed an exception raised when adding new nodes

================================================================================
===
=== GeoNetwork 2.1.0 alpha1 : List of changes
===
================================================================================

- Added Lucene FuzzyQuery support

- Added catalogue services for the web 2.0.1

- Added ISO19115 CSW 2.0.1 output stylesheets (thanks to Steven Smolders/Stefaan
  Desender)

- Added RSS search services

- Added chinese localization (thanks to Enri Zhou)

- Added log4j to both jeeves and geonetwork

- Logs moved into jetty/log folder. Now old logs are archived

- Added web/WEB-INF/db/data.tgz. This is an empty McKoi database ready for use,
  very usefull to users that do a cvs checkout/update: simply unpack where it
  is.

- Added localization of categories, groups, regions, operations and profiles

- Added an Ajax wen interface to configure harvesting

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Removed uuid-2.1.0.jar: used java 1.5 builtin UUID class

- Removed jaxen: used java 1.5 classes

- Increased connection pool to 10 connection to allow harvesting tasks

- Added more information to users (email, address, organisation etc...)

- Fixed the metadata-util.xsl stylesheet so that GeoNetwork can run on Java 1.6
  (thanks to Andrew Davie)

- Added 'author' to the RoleCd codelist

- Harvesting engine totally rewritten to provide more flexibility

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Now the search engine works with Chinese language (thanks to Enri Zhou)

- Fixed bug with user list: if the user is an Administrator but with id other
  than 1 only a subset of the groups where shown

- Fixed bug with thumbnails stylesheet: now the 'back' button is correctly
  shown

- Fixed validation bug when adding a new metadata

- Fixed problem with IPv6 protocol: geonetwork was unable to handle the 
  0:0:0:0:0:0:0:1 local address.

- Fixed a security hole: using sql injection was possible to login into
  geonetwork

- Fixed "Services is not a subcontext" exception with Z39.50

- Added reconnection patch for MySQL (thanks to Enri Zhou)

- Fixed a security hole in user management : a user admin could gain admin
  privileges

================================================================================
===
=== GeoNetwork 2.0.2 : List of changes
===
================================================================================

- Removed bug in showing metadata with multiline fields (fields containing
  CR-LF)

- Possibly fixed nasty bug in validation on Windows PCs

- Added bounding box and interval fields in search form to session

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- List of user: now administrators cannot remove themselves. This prevent some
  inconsistencies like the user being logged in and not existing into the
  database.

- Asked confirmation when deleting users

- Now it is not possible to edit metadata which source is different from the
  site id

- Now thumbnails button in editing is shown only for iso19115 metadata

- FGDC metadata abstract is now a textarea in editing

- User administration : now the group list is always visible

- Allowed several administrators

- Added GeoRSS button to the recent additions

- Included MySQL and Oracle JDBC drivers for easy installation on these
  databases.
  The warning to put JDBC drivers in place during the installation has been
  removed.

- Thumbnails are now shown for harvested data (there is a link to the remote
  site)

- Added jdbc drivers for mysql and oracle

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- A user can duplicate metadata only if he has the proper privilege 
  ('metadata.duplicate.form')

- maxClauses parameters in Lucene BooleanQuery constructor is now 16384 instead
  of the default of 1024

- Fixed bug with the mckoi's activator. Now installing a DBMS other than McKoi
  works fine.

================================================================================
===
=== GeoNetwork 2.0.1 : List of changes
===
================================================================================

- to be added...

================================================================================
===
=== GeoNetwork 2.0.0 final : List of changes
===
================================================================================

- Added french and spanish translations

- Added option to save installation settings for re-installing from the command
  line

- Added an About page to the site

- Added the SiteID on the about and links page. Useful for administrators that 
  want to set up harvesting

- Added email and description editing to the group list editor

- Added possibility to have multiple inheritance to user profiles

- Added email notification to a group administrator when a user downloads a
  resource

--------------------------------------------------------------------------------
--- Changes
--------------------------------------------------------------------------------

- Now information about possible operations on each metadata take into account 
  the user's profile and not only the metadata privileges

- Modified search button

- Updated feedback link on homepage

- Updated links on links page

- Some clean ups to the setup table's record

- debug mode is set to be off by default

- updated the user-input.xml and user-input-integrated.xml
  to accept: jetty port, public host, puplic port

- changed installer/xsl/config.xsl: added entries for public host & port

- changed installer/xsl/jetty.xsl and installer/xsl/jetty-integrated.xsl
  to reflect the port choosen in the installer

- upgraded migration procedure to fix the links for the resources

- upgraded the setup procedure: now all metadata are read and saved
  in order to update the resources' links.

--------------------------------------------------------------------------------
--- Bugs fixed
--------------------------------------------------------------------------------

- Fixed bug in the editor: the template property was not saved

- Fixed bug that caused the editor to open a  different window pressing "Save"
  and the other buttons, if "Check" was pressed before

- Fixed Interactive button on search results page to correctly open a WMS in 
  InterMap opensource

- Download link on metadata page checked for dynamic privilege instead of
  download privilege

- Now the feedback email is correctly sent

- Fixed a bug in the installer: the stylesheet for the config.xml file changed
  the config for all resources instead of the enabled one.

- Fixed problems with profiles combobox into the user admin form

- Fixed bug on startup: metadata were always reindexed

- Fixed bug in the editor: online resources fields were not shown up  

- Fixed bug with the distTranOp field: the onLineSrc fields were not shown

================================================================================
===
=== GeoNetwork RC2 : List of changes
===
================================================================================

- Added an alpha release of the CSW specification (not usable, work in
  progress).

================================================================================
=== Changes
================================================================================

- Upgraded Jetty to 5.1.5 RC2

- Transformed "save & check" in "check". Now opens a different window with
  diagnostic

- Removed thumbnails handling in simple editor

- Put "Template" checkbox together with the edit buttons at the top

- Bug [1308077] : Moved the xml insert privileges from the 'UserAdmin' to the 
  'Editor' profile

================================================================================
=== Bugs fixed
================================================================================

- Fixed bug with config.xml. The oracle resource was enabled instead of the
  McKoi one. This fixes bugs [1349939] and [1349849].

- Fixed bug [1314928] : oracle returns "1.0" instead of "1". This caused some
  problems.

- Fixed some bugs with the MySql database schema (converted some varchars to
  text)

================================================================================
===
=== GeoNetwork RC1 : List of changes
===
================================================================================

- Added migration procedure

- Added periodic metadata harvesting on file system

- Added "last results" button

- Added empty templated for DC and FGDC

================================================================================
=== Changes
================================================================================

- Search for templates is hidden to simple registerd users (only allow from
  editors up)

- Moved login info to the righ

- Metadata: put show and edit buttons also at the top

- Now it is possible to turn a metadata into a template and viceversa

================================================================================
=== Bugs fixed
================================================================================

- If no feature maps are available, nothing is displayed in the home page

- Fixed bug with "&" in names and metadata in xml form

- FGDC metadata standard Field 'accconst' was not displayed right

- Fixed metadata preview from a remote server

- Fixed some empty tabs in the editor (the (+) button was not shown)

- "search for templates" flag was not saved in the session

- Add button generated wrong link in Dublin Core editing

================================================================================
===
=== GeoNetwork beta 4 : List of changes
===
================================================================================

================================================================================
=== Changes
================================================================================

- Removed the 'Administrator' profile from the user edit form. This allows only
  one administrator for each geonetwork installation
  
================================================================================
=== Bugs fixed
================================================================================

- Fixed a nasty bug with groups privileges. The administrator was not able to
  see metadata created by himself
  
- Fixed bug in the user edit form. Now groups are hidden only when editing the
  administrator
  
================================================================================
===
=== GeoNetwork beta 3 : List of changes
===
================================================================================

- Added text at the end of the installer explaining how to start the system

- Added a 'Geonetwork' menu  in the OS 'application' menu

- Added possibility to have a user administrator
  - Added UserAdmin profile
	- Filtered profile combobox : removed "Guest" profile and listed only profiles
	  that are equal to or lower than the creating user 
	
- Added a form to easily add and remove thumbnails

- Added the possibility to specify a metadata template during search.
  Removed templates from normal search results and on the main page
  (latest updates)

================================================================================
=== Changes
================================================================================

- Removed unused namespaces from the DC sample data

- Used UUID in harvesting procedure and changed parameters format

- Upgraded Jetty to version 5.1.5rc1

- Removed last line in "links" page (contact and feedback)

- Now feedback is not saved into the db

- The 'delete' privilege has been merged to the 'edit' one. Added the 'notify'
  privilege.

- Harvesting procedure : if the username/password fields are missing (or empty)
  no login is performed on the remote site

- Editing a user : now the group list is not shown if the user is an
  administrator

- Grouped metadata dirs to handle large set of metadata

- Removed "AdvancedEditor" profile. Allowed services moved "UserAdmin"

- Installer : added some defaults. The user's password now must be at least 6
  chars

- Changes to the database
	- Renamed field "sourceId" to "sourceUri" in table "Metadata"
	- Removed table "Feedback"
   - Added unique to the name of users, groups, categories
		
================================================================================
=== Bugs fixed
================================================================================

- Fixed feedback link in main page

- Fixed bug : was not possible to remove privileges from group 2 ("Editors")

- Fixed slash on Windows start/stop scripts. Added STOP_PORT variable

- Fixed stylesheets update-fixed-info.xsl for ISO and DC

- Fixed buttons' style on forms

- Fixed nasty bug on Z39.50

- Fixed '+' bug on ISO codelists

- Fixed bug with idCitation/resRefDate

- PostionName is now displayed in editing mode

- Fixed namespaces in xml editing

- Fixed some issues with the dublin core

- Bug fixed : metadata with empty thumbails generated exceptions on search
  results
 
- Fixed index.html : now the small "GeoNetwork" text is not displayed

- Fixed validation bug when saving a metadata using the xml text view

- Fixed servlet name in res.xsl stylesheet

- Fixed bug : emails were not sent to the mail account specified during the
  installation. 

================================================================================
===
=== GeoNetwork beta 2 : List of changes
===
================================================================================

- Added a form to remove old, empty metadata
  An empty metadata has been defined as follow:
   - it is not a template
	 - it is local (its source == to the geonetwork site id)
	 - the difference between the last change date and the creation date (in
	   minutes) is less than a given difference
	 - it has no operations associated to the internet group

- Added a button to create a metadata from a template
  Added a form (in administration) to create a metadata from a template
  
- Added an UUID to metadata when creating it from a template, from the xml
  import or from the batch import forms.

- Improved ISO editor stylesheet

- Added upload features to the ISO editor

- Added a popup to place a keyword in ISO19115 editor

- Added a popup to place a bounding box in ISO19115 editor

- Added the possibility to change the password and some other information

- Improved handling of help XML information

- Added the possibility to change the number of hits per page in the search form

- Added a XML editing page with validation

================================================================================
=== Changes
================================================================================

- Metadata batch import form:
  Now the user can see only the groups he belongs to.

- Changes to the database (installer data files adjusted as needed):
  - Table Metadata: added "uuid"
	- Table Groups  : added "description", "email", "referrer"

- Fixed some initial data in the installer

- Added 2 FAO's metadata with thumbnails. This gives the featured map on the 
  main page and metadata with thumbnails on the search results.

- The harvesting procedure now stores the uuid got from the remote site

- Creation of a new metadata ('create' button, xml insert/import): 
  - privileges belonging to the 'internet' group are removed. This is related
	  to the 'search for empty/unused metadata' functionality.
	- privileges belonging to the 'intranet' group are removed.
	- the group that is adding the metadata has all privileges on it
	- privileges associated to other groups are copied from the DefaultOper table

- Changed behavior of back button in the editor to go back to editing mode, and 
  improved diagnostic message

- Make sure that adding or removing items moves to the same page point in the 
  browser

================================================================================
=== Bugs fixed
================================================================================

- Search results : fixed metadata logos and added the possibility to have a
  personal logo

- The "UserGroups" data file was missing. The provided one binds the
  administrator to groups 0,1,2

- Fixed bug with the '+' button on element 'OnLineRes'

- Fixed a nasty bug in the editor: now after an error it is possible to save 
  the metadata
  
- Minor bugs have been fixed.

- Now trying Z39.50 search without search criteria or with no server selected
  shows an alert

- Thumbnails of harvested metadata are read from the source site

================================================================================
=== Known bugs
================================================================================

- The stylesheets to store the UUID need to be fixed for the dublin core and
  fgdc metadata schema
  
- Some metadata elements don't get displayed (like those inside the OnLineRes) 
 
- The editor does not preserve namespaces during xml editing

- The search shows the templates too.

- The feedback link is broken and some items on the links page are not shown
  correctly
