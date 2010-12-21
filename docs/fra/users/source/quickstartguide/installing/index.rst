.. _installing:

Installation
============

Nouvelle version - nouvelles fonctionnalités
--------------------------------------------


.. figure:: Home_page_s.png

    *Standard home page of GeoNetwork opensource*


Version 2.7
```````````

- Editeur

 - Publication dans GeoServer

- Administration

 - Chargement de thésaurus par URL
 
 - Gestion des logos
 

Version 2.6 (Septembre 2010)
````````````````````````````

- Recherche

 - Migration Intermap vers OpenLayers/GeoExt
 
- Développement

 - Migration Maven


Version 2.5 (Mai 2010)
``````````````````````

- Recherche & indexation

 - Z39.50 SRU
 
 - Recherche temporelle
 
 - Analyse des types de documents MIME

 - Amélioration des performances
 
 - Export CSV
 
 - Affichage des liens
 
- Edtition

 - Vue INSPIRE
 
 - Saisie multilingue
 
 - Mise à jour des enfants
 
 - Calcul des emprises à partir des mots clés
 
 - Cartographie dynamique pour la saisie des emprises
 
 - Assistant de saisie des projections
 
 - Assistant pour la saisie des mots clés
 
 - Amélioration du rapport de validation
 
 - Gestion des relations entre métadonnées de données et métadonnées de services
 
 - Support ISO19110
 
- Administration

 - Configuration des catégories
 
 - MEF 2


Version 2.4 (juillet 2009)
``````````````````````````


- Recherche & indexation
 
 - Panier de sélection

 - Critères de recherche INSPIRE

 - Impression PDF des résultats

 - Amélioration des performances

 - Amélioration du protocole OGC CSW 2.0.2

- Edition
 
 - Editeur de métadonnées Ajax

 - Opération de mise à jour en masse

- Administration

 - Authentification Shibboleth

  - Enregistrement libre des utilisateurs


Version 2.3
```````````

- Support ISO19119

  
Où télécharger le programme d'installation ?
--------------------------------------------

Vous trouverez les différentes version de GeoNetwork sur le dépôt SourceForge.net http://sourceforge.net/projects/geonetwork/files/.

Utiliser l'installer multi plate-forme (.jar) si vous souhaitez l'installer sur un autre système que Windows.

Pré-requis système
------------------


GeoNetwork est multi plate-forme. Il fonctionne sous **MS Windows**, **Linux** ou **Mac OS X** .

Pré-requis système :

**Processeur** : 1 GHz ou sup

**Mémoire (RAM)** : 512 MB ou sup

**Espace disque** : 100 MB minimum. Cependant, il est recommandé d'avoir un 250 MB disponible. 
L'espace est essentiellement consommé lors de l'ajout de données aux métadonnées.

**Autres logiciels** : 

- `Java Runtime Environment <http://www.oracle.com/technetwork/java/index.html>`_ (JRE 1.5.0 ou sup). 

- Jetty ou Apache Tomcat ou tout autre container Java

- une base de données compatible JDBC (McKoi, MySQL, Postgres, PostGIS, Oracle, SQLServer).

Autres logiciels
````````````````

Ces logiciels ne sont pas nécessaire pour le fonctionnement de GeoNetwork mais peuvent être utilisé en complément :

#. `Druid <http://druid.sourceforge.net/>`_ to inspect the database

#. `Luke <http://www.getopt.org/luke/>`_ to inspect the Lucene index



Navigateurs supportés
`````````````````````

GeoNetwork devrait fonctionner normalement avec les navigateurs suivant :

#. Firefox v1.5 ou sup
#. Internet Explorer v7 ou sup
#. Safari v3 ou sup
#. Chrome
#. Opera



Comment installer GeoNetwork ?
------------------------------

Avant d'installer GeoNetwork, vérifier que les pré-requis sont disponibles et en particulier vérifier que Java Runtime Environment est disponible.




Avec Windows
````````````

Si vous utilisez Windows, les étapes sont les suivantes :

1. Double cliquer sur **geonetwork-install-x.y.z.exe** pour lancer l'installation de GeoNetwork opensource
2. Suivre les instructions à l'écran
3. Après l'installation, un menu 'GeoNetwork' est ajouté dans le menu principal de Windows
4. Cliquer Start\>Programs\>GeoNetwork opensource\>Start server pour lancer Geonetwork opensource Web server (ie. Jetty par défaut).
5. Cliquer Start\>Programs\>Geonetwork opensource\>Open GeoNetwork opensource pour ouvrir votre navigateur sur la page d'accueil de GeoNetwork, ou lancer votre navigateur sur la page `http://localhost:8080/geonetwork/ <http://localhost:8080/geonetwork/>`_

.. figure:: installer.png

   *Installer*

.. figure:: install_packages.png

   *Sélection des modules*


Installer multi plate-forme
```````````````````````````

L'installer (un fichier .jar) doit démarrer avec un simple double clic. 
En cas d'échec, le menu contextuel peut vous proposer une option pour l'ouvrir avec la version de Java installée sur votre machine.
Si cela ne fonctionne toujours pas, il est possible de lancer l'installation en ligne de commande. Pour cela, ouvrir un terminal, aller dans le répertoire où l'installer se trouve, puis lancer l'installer.


:: 

    cd /repertoire/de/telechargement/de/l/installer
    java -jar geonetwork-install-x.y.z.jar


Suivre les instructions à l'écran.


A la fin de l'installation il est possible de sauvegarder le fichier de configuration de l'installation.

.. figure:: install_script.png
   
   

Installation en ligne de commande sans interface graphique
``````````````````````````````````````````````````````````

Le plus simple en cas d'absence d'interface graphique sur le serveur est de faire une installation standard sur une machine puis de copier l'ensemble du répertoire sur le serveur.

Sinon, il est possible de réaliser une installation en ligne de commande

::

    java -jar geonetwork-install-x.y.z.jar install.xml
    [ Starting automated installation ]
    [ Starting to unpack ]
    [ Processing package: Core (1/3) ]
    [ Processing package: Sample metadata (2/3) ]
    [ Processing package: GeoServer web map server (3/3) ]
    [ Unpacking finished ]
    [ Writing the uninstaller data ... ]
    [ Automated installation done ]

Pour activer le mode trace ajouter le paramètre *-DTRACE=true*::

  java -DTRACE=true -jar geonetwork-install-x.y.z.jar

