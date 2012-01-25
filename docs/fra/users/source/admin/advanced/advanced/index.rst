.. _advanced_configuration:
.. include:: ../../../substitutions.txt
.. _admin_how_to_config_db:

Configurer la base de données
=============================

Le catalogue utilise par défaut la base de données (ie. `H2 <http://www.h2database.com/>`_).

Les bases de données actuellement supportées sont les suivantes 
 (ordre alphabétique):

* DB2
* H2
* Mckoi
* MS SqlServer 2008
* MySQL
* Oracle
* PostgreSQL (ou PostGIS)


Configuration simple
--------------------

La connexion à la base de données est définie dans la section *<resources>* du fichier *web/geonetwork/WEB-INF/config.xml*.

Modifier l'attribut *enable* pour activer l'une des connexions. Il n'est pas possible d'activer deux connexions.::

	<resource enabled="true">
		...
		
Une fois activé, configurer :
 
- l'utilisateur, 

- le mot de passe

- le driver (utiliser les exemples fournis dans le fichier)

- l'url de connexion


Exemple d'une configuration pour utiliser PostGIS::

		<resource enabled="true">
			<name>main-db</name>
			<provider>jeeves.resources.dbms.DbmsPool</provider>
			<config>
				<user>www-data</user>
				<password>www-data</password>
				<driver>org.postgresql.Driver</driver>
				<url>jdbc:postgis://localhost:5432/geonetwork</url>
			</config>
		</resource>



Pool de connexions
------------------

Le catalogue supporte 2 types de pool de connexion:

* Jeeves DbmsPool
* `Apache DBCP pool <http://commons.apache.org/dbcp/>`_ (recommandé à partir des versions 2.7.x)

Les paramètres suivants permettent une configuration fine du pool:

* poolSize
* maxTries
* maxWait


.. TODO Add more details about poolsize, maxWait, ...




Drivers JDBC
````````````
Les fichiers jar des drivers JDBC  doivent être dans le répertoire **GEONETWERK_INSTALL_DIR/WEB-INF/lib**. 
Pour les bases de données Open Source, comme MySQL et PostgreSQL, ces fichiers sont déjà installés. 
Pour les bases de données commerciales, il est nécessaire de télécharger ces fichiers manuellement. Celà est lié aux licences.

* `DB2 driver JDBC <https://www-304.ibm.com/support/docview.wss?rs=4020&uid=swg27016878>`_
* `MS Sql Server driver JDBC <http://msdn.microsoft.com/en-us/sqlserver/aa937724>`_
* `Oracle driver JDBC <http://www.oracle.com/technetwork/database/features/jdbc/index-091264.html>`_


Créer et initialiser les tables
```````````````````````````````


Depuis la version 2.6.x, |project_name| dispose d'un **mécanisme de création et migration de la base de données automatique** au démarrage.
Si les tables ne sont pas présentes dans la base de données, le script de création est lancé.

Ensuite, |project_name| vérifie la version de la base de données correspond à la version de l'application
en vérifiant les valeurs dans la table *Settings* du paramètre *version*.

Une autre alternative est de lancer manuellement les scripts SQL: 

* Création : **GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/create/**
* Données initiales : **GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/data/**
* Migration :  **GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/migrate/**

Exemple d'exécution pour DB2::

        db2 create db geonet
        db2 connect to geonet user db2inst1 using mypassword
        db2 -tf GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/create/create-db-db2.sql > res1.txt
        db2 -tf GEONETWERK_INSTALL_DIR/WEB-INF/classes/setup/sql/data/data-db-default.sql > res2.txt
        db2 connect reset

Après exécution, vérifier **res1.txt** et **res2.txt**.


.. note::

    Problèmes connus avec DB2. Il est possible d'obtenir l'erreur suivante au premier lancement.

        DB2 SQL error: SQLCODE: -805, SQLSTATE: 51002, SQLERRMC: NULLID.SYSLH203

    Solution 1 : installer la base manuellement.
    Solution 2 : supprimer la base, la recréer puis localiser le fichier db2cli.lst dans le répertoire d'installation de DB2, puis exécuter :

        db2 bind @db2cli.lst CLIPKG 30




Personnaliser l'interface
=========================

Service de traduction Google
----------------------------

Dans le fichier config-gui.xml modifier la section::

            <!-- 
                Google translation service (http://code.google.com/apis/language/translate/overview.html):
                Set this parameter to "1" to activate google translation service.
                Google AJAX API Terms of Use http://code.google.com/apis/ajaxlanguage/terms.html
                
                WARNING: "The Google Translate API has been officially deprecated as of May 26, 2011...
                the number of requests you may make per day will be limited and 
                the API will be shut off completely on December 1, 2011".
              -->
             <editor-google-translate>1</editor-google-translate>


.. _how_to_config_edit_mode:

Configurer les vues en mode édition
-----------------------------------

Dans le fichier config-gui.xml, il est possible de définir les modes disponibles en édition::

  <metadata-tab>
    <simple flat="true"  default="true"/>
    <advanced/><!-- This view should not be removed as this is the only view to be able to edit all elements defined in a schema. -->
    <iso/>
    <fra/>
    <!-- This view display all INSPIRE recommended elements
    in a view : 
    * In flat mode, define which non existing children of the exception must be displayed (using ancestorException)
    * or which non existing element must be displayed (using exception)
    -->
    <inspire flat="true">
       <ancestorException for="EX_TemporalExtent,CI_Date,spatialResolution"/>
       <exception for="result,resourceConstraints,pointOfContact,hierarchyLevel,couplingType,operatesOn,distributionInfo,onLine,identifier,language,characterSet,topicCategory,serviceType,descriptiveKeywords,extent,temporalElement,geographicElement,lineage"/>
    </inspire> 
    <xml/>
  </metadata-tab>


L'attribut **flat** permet de n'afficher que les éléments existants.
Mettre les éléments non souhaités en commentaire.


Autres options de configuration
-------------------------------


Voir le fichier config-gui.xml.

Optimiser la configuration pour les catalogues volumineux
---------------------------------------------------------

Quelques conseils à prendre en compte pour les catalogues volumineux à partir de 20 000 fiches :

#. **Disque** : Le catalogue utilise une base de données pour le stockage mais utilise 
   un moteur de recherches reposant sur Lucene. Lucene est très rapide et le restera 
   y compris pour des catalogues volumineux à condition de lui fournir des disques rapides 
   (eg. SSD – utiliser la variable de configuration de l'index pour placer uniquement l'index 
   sur le disque SSD, si vous ne pouvez placer toute l'application dessus), 
   de la mémoire (16Gb+) et des CPU dans un environnement 64bits. 
   Par exemple, les phases de moissonnage nécessitent de nombreux accès disques 
   lors de la mise à jour de l'index. Privilégier des disques rapides dans ce cas là.

#. **Base de données** : Privilégier l'utilisation du couple PostgreSQL + PostGIS car 
   l'index spatial au format ESRI Shapefile sera moins performant dans les phases d'indexation
   et de recherche lorsque le nombre de fiches sera important.

#. **CPU** : Depuis septembre 2011, les actions d'indexations et opérations massives 
   peuvent être réparties sur plusieurs processus. Ceci est configurable à partir de
   la configuration du système. Une bonne pratique est de fixer la valeur 
   fonction du nombre de processeurs ou core de la machine.

#. **Base de données / taille du pool** : Ajuster la valeur de la taille du pool fonction
   du nombre de moissonnages pouvant être lancés en parallèle, du nombre d'actions massives
   et du nombre d'utilisateurs simultannés. Plus la taille du pool est importante, moins
   le temps d'attente pour récupérer une connexion libre sera long (le risque de timeout sera également moindre).

#. **Nombre de fichiers ouverts** : La plupart des systèmes d'exploitation limite le nombre 
   de fichiers ouverts. Lors de forte charge de mise à jour de l'index, le nombre
   de fichiers ouverts peut être source d'erreur. Modifier la configuration du
   système en conséquence  (eg. ulimit -n 4096).

#. **Mémoire** : La consigne ici est d'allouer le maximum de mémoire fonction de la machine

#. **Créer un catalogue de plus d'1 million d'enregistrements** : Le catalogue crée
   dans le répertoire DATA un répertoire par fiche contenant lui-même 2 
   répertoires public et private. Il est possible que le nombre maximum d'inode soit
   alors atteint, le système retournant alors des erreurs du type 'out of space' bien que
   le système dispose de place disponible. Le nombre d'inode ne peut être modifié dynamiquement 
   après création du système de fichier. Il est donc important de penser à fixer
   la valeur lors de la création du système de fichier. Une valeur de 5 fois 
   (voire 10 fois) le nombre de fiches prévues devrait permettre de
   stocker le répertoire DATA sur ce système de fichier.
