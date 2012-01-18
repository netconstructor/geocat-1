.. _adv_configuration:

Advanced configuration
======================


.. _adv_configuration_larger_catalogs:

Advanced configuration for larger catalogs
------------------------------------------

There are a number of steps you must consider if you are going to use GeoNetwork for catalogs with 20,000 
or more metadata records:


#. **Consider the hardware you have available** GeoNetwork uses a database as a transactional store and does 
   all metadata searches using Lucene. Lucene is very fast and will remain fast for large catalogs if you supply 
   fast disk (solid state disk is best by far), lots of memory/RAM (16Gb+) and multiple processors as part of a 64bit 
   environment. Linux is probably the best operating system to take advantage of such an environment.

#. **Use PostGIS (Postgres+PostGIS) as your database** GeoNetwork has to build a spatial index containing all 
   metadata bounding boxes and polygons, in order to support spatial queries for the Catalog Services Web (CSW) 
   interface eg. select all metadata records that intersect a search polygon. By default GeoNetwork uses a 
   shapefile but the shapefile quickly becomes costly to maintain during reindexing usually after the number 
   of records in the catalog exceeds 20,000. If you select PostGIS as your database, GeoNetwork will build the 
   spatial index in a PostGIS table (called spatialindex). The spatialindex table in PostGIS is much faster to 
   reindex. But more importantly, if appropriate database hardware and configuration steps are taken, it should 
   also be faster to query than the shapefile when the number of records in the catalog becomes very large.

#. **Consider the Java heap space** Typically as much memory as you can give GeoNetwork is the answer here. 
   If you have a 32bit machine then you are stuck below 2Gb (or maybe a little higher with some hacks). A 64bit machine 
   is best for large catalogs. Jetty users can set the Java heap space in `INSTALL_DIR/bin/start-geonetwork.sh` (see 
   the -Xmx option: eg. -Xmx4g will set the heap space to 4Gb on a 64bit machine). Tomcat users can set an environment 
   variable JAVA_OPTS eg. export JAVA_OPTS="-Xmx4g"

#. **Consider the number of processors you wish to allocate to GeoNetwork** GeoNetwork 2.8 allows you to use 
   more than one system processor (or core) to speed up reindexing and batch operations on large numbers of metadata 
   records. The records to be processed are split into groups with each group assigned to an execution thread. 
   You can specify how many threads can be used in the system configuration menu. A reasonable value for the 
   number of threads is the number of processors or cores you have allocated to the GeoNetwork Java Virtual 
   Machine (JVM) or just the number of processors on the machine that you have dedicated to GeoNetwork.

#. **Consider the number of database connections to be allocated to GeoNetwork** GeoNetwork uses 
   and reuses a pool of database connections. This is configured in `INSTALL_DIR/web/geonetwork/WEB-INF/config.xml`. 
   To arrive at a reasonable number for the pool size is not straight forward. You need to consider 
   the number of concurrent harvesters you will run, the number of concurrent batch import and batch 
   operations you expect to run and the number of concurrent users you are expecting to arrive. 
   The default value of 10 is really only for small sites. The more connections you can allocate, the less 
   time your users and other tasks will spend waiting for a free connection.

#. **Consider the maximum number of files your system will allow any process to have open** Most operating 
   systems will only allow a process to open a limited number of files. If you are expecting a large number 
   of records to be in your catalog then you should change the default value to something larger (eg. 4096) 
   as the lucene index in GeoNetwork will occasionally require large numbers of open files during reindexing. 
   In Linux this value can be changed using the ulimit command (ulimit -a typically shows you the current setting). 
   Find a value that suits your needs and add the appropriate ulimit command (eg. ulimit -n 4096) to the 
   GeoNetwork startup script to make sure that the new limit is used when GeoNetwork is started.

#. **Raise the stack size limit for the postgres database** Each process has some memory allocated as a stack. 
   The stack is used to store process arguments and variables as well as state when functions are called. 
   Most operating systems limit the size that the stack can grow to. With large catalogs and spatial searches, 
   very large SQL queries can be generated on the PostGIS spatial index table. This can cause postgres to 
   exceed the process stack size limit (typically 8192k on smaller machines). You will know when this 
   happens because a very long SQL query will be output to the GeoNetwork log file prefixed with a cryptic 
   message something along the lines of::
        
        java.util.NoSuchElementException: Could not acquire 
        feature:org.geotools.data.DataSourceException: Error Performing SQL query: SELECT .........
        
   In Linux the stack size can be changed using the ulimit command (ulimit -a typically shows you 
   the current setting). You will need to choose a value and set it (eg. ulimit -s 262140) in the 
   shell startup script of the postgres user (eg. .bashrc if using the bash shell). The setting may 
   also need to be added to the postgres config - see "max_stack_depth" in the postgresql.conf file for 
   your system. You may also have to enable to postgres user to change the stack size in `/etc/security/limits.conf`. 
   After this has been done, restart postgres.

#. **If you need to support a catalog with more than 1 million records** GeoNetwork creates a 
   directory for each record that in turn contains a `public` and a `private` directory for holding 
   attached data and thumbnails. These directories are in the GeoNetwork `data` directory - 
   typically: `INSTALL_DIR/web/geonetwork/WEB-INF/data`. This can exhaust the number of inodes 
   available in a Linux file system (you will often see misleading error reports saying that 
   the filesystem is 'out of space' - even though the filesystem may have lots of freespace). 
   Check this using `df -i`. Since inodes are allocated statically when the filesystem is created 
   for most common filesystems (including extfs4), it is rather inconvenient to have to backup all 
   your data and recreate the filesystem! So if you are planning a large catalog with over 1 million 
   records, make sure that you create a filesystem on your machine with the number of inodes set to at 
   least 5x (and to be safe 10x) the number of records you are expecting to hold and let 
   GeoNetwork create its `data` directory on that filesystem.


.. _adv_configuration_overriddes:

Overrides configuration
-----------------------

  .. TODO
  
  
.. _adv_configuration_lucene:

Lucene configuration
--------------------

`Lucene <http://lucene.apache.org/java/docs/index.html>`_ is the search engine used by GeoNetwork. All Lucene configuration 
is defined in WEB-INF/config-lucene.xml.

Add a search field
~~~~~~~~~~~~~~~~~~

Indexed fields are defined on a per schema basis on the schema folder (eg. xml/schemas/iso19139) in index-fields.xsl file.
This file define for each search criteria the corresponding element in a metadata record. For example, indexing the title
of an ISO19139 record::

                <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/
                                       gmd:citation/gmd:CI_Citation/
                                       gmd:title/gco:CharacterString">
                    <Field name="mytitle" string="{string(.)}" store="true" index="true"/>
                </xsl:for-each>

Usually, if the field is only for searching and should not be displayed in search results the store attribute could 
be set to false. 

Once the field added to the index, user could query using it as a search criteria in the different kind
of search services. For example using::

    http://localhost:8080/geonetwork/srv/en/q?mytitle=africa

If user wants this field to be tokenized, it should be added to the tokenized section of config-lucene.xml::

  <tokenized>
    <Field name="mytitle"/>
    
    
If user wants this field to be returned in search results for the search service, then the field should be added to 
the Lucene configuration in the dumpFields section::

    <dumpFields>
      <field name="mytitle" tagName="mytitle"/>

Boosting documents and fields
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Document and field boosting allows catalogue administrator to be able to customize default Lucene scoring
in order to promote certain types of records.

A common use case is when the catalogue contains lot of series for aggregating datasets. 
Not promoting the series could make the series "useless" even if those records contains important content.
Boosting this type of document allows to promote series and guide the end-user from series to related records (through 
the relation navigation).

In that case, the following configuration allows boosting series and minor importance of records part of a series::

  <boostDocument name="org.fao.geonet.kernel.search.function.ImportantDocument">
    <Param name="fields" type="java.lang.String" value="type,parentUuid"/>
    <Param name="values" type="java.lang.String" value="series,NOTNULL"/>
    <Param name="boosts" type="java.lang.String" value=".2F,-.3F"/>
  </boostDocument>
  

The boost is a positive or negative float value.

This feature has to be used by expert users to alter default search behavior scoring according 
to catalogue content. It needs tuning and experimentation to not promote too much some records.
During testing, if search results looks different while being logged or not, it could be relevant
to ignore some internal fields in boost computation which may alter scoring according to current user. 
Example configuration::

 <fieldBoosting>
   <Field name="_op0" boost="0.0F"/>
   <Field name="_op1" boost="0.0F"/>
   <Field name="_op2" boost="0.0F"/>
   <Field name="_dummy" boost="0.0F"/>
   <Field name="_isTemplate" boost="0.0F"/>
   <Field name="_owner" boost="0.0F"/>
 </fieldBoosting>


Boosting search results
~~~~~~~~~~~~~~~~~~~~~~~

By default Lucene compute score according to search criteria
and the corresponding result set and the index content.
In case of search with no criteria, Lucene will return top docs
in index order (because none are more relevant than others).

In order to change the score computation, a boost function could
be define. Boosting query needs to be loaded in classpath.
A sample boosting class is available. RecencyBoostingQuery will promote recently modified documents::

    <boostQuery name="org.fao.geonet.kernel.search.function.RecencyBoostingQuery">
      <Param name="multiplier" type="double" value="2.0"/>
      <Param name="maxDaysAgo" type="int" value="365"/>
      <Param name="dayField" type="java.lang.String" value="_changeDate"/>
    </boostQuery>


 