.. _history:

Historique
==========

Qu'est ce que GeoNetwork opensource ?
-------------------------------------

GeoNetwork opensource est un système de gestion de données géographiques basé sur les standards.
Il est conçu pour permettre l'accès aux bases de données géoréférencées et aux produits cartographiques 
à partir d'une variété de fournisseurs de données via leur description, également appelée métadonnées. 
Il permet les échanges d'information et le partage entre les organisations et leur public, 
en utilisant le capacités et la puissance de l'Internet. 

Le système fournit à une large communauté d'utilisateurs un accès facile et rapide
aux données et services spatiaux disponibles, ainsi qu'aux cartes thématiques pour 
aider à la découverte d'information et à la prise de décision.
 
L'objectif principal du logiciel est d'accroître la collaboration au sein et entre les organisations 
afin de réduire les doublons, améliorer l'information (cohérence, qualité) pour améliorer 
l'accessibilité d'une grande variété d'informations géographiques avec les informations associées,
organisées et documentées de façon standard et uniforme .



Principales caractéristiques :

- Des recherches locales et distribuées

- Le téléchargement de données, documents, PDF et tout autre contenu

- Une carte interactive qui permet la combinaison des couches diffusées par les services WMS

- L'édition en ligne des métadonnées par un système de modèles

- Le moissonnage et la synchronisation des métadonnées entre catalogues distribués

- Groupes et gestion des utilisateurs


Histoire et évolution
---------------------

Le premier prototype du catalogue GeoNetwork a été développé par la FAO en 2001 
pour archivee et publier les données géographiques produites dans l'organisation. 
Ce prototype a été bâti sur les expériences au sein et en dehors de l'organisation. 
Il a utilisé le contenu des métadonnées disponibles dans les systèmes existants 
en le transformant en ce qui n'était alors qu'un projet de
norme sur les métadonnées, l'ISO 19115. Plus tard, une autre agence de l'ONU, le Programme
Alimentaire mondial (PAM) a rejoint le projet et a contribué à la première version du logiciel qui 
a été publié en 2003. Le système était basé sur le DIS (Draft International Standard) de l'ISO19115
et intégré le module InterMap pour la carte interactive. 
Les recherches distribués était possible en utilisant la norme Z39.50.
A ce moment, il a été décidé de distribuer GeoNetwork en tant que logiciel libre afin de 
permettre à l'ensemble de la communauté géospatiale aux utilisateurs de bénéficier des
résultats de développement et de contribuer à l'avancement du projet.


Conjointement avec l'UNEP, la FAO a élaboré une deuxième version
en 2004. La nouvelle version permet aux utilisateurs de travailler avec plusieurs normes de métadonnées (ISO
19115, FGDC et Dublin Core) de manière transparente. Elle a également permis la mise en 
place de mécanisme de moissonnage et l'amélioration de la fiabilité lors de
recherche dans plusieurs catalogues.


En 2006, l'équipe de GeoNetwork a élaboré un DVD contenant le
la version 2.0.3 de GeoNetwork et le meilleur des logiciels opensource dans le domaine de
la géomatique. Le DVD a été produit et distribué en version imprimée à plus de trois
mille personnes.

Ensuite, les standards ISO ISO19139/119 pour les métadonnées de données et services ont été ajouté.
GeoNetwork a été l'implémentation opensource de référence pour le protocol OGC CSW 2.0.2 profile ISO.
Pour améliorer les échanges, de multiples protocoles de moissonnage sont disponibles : OAI-PMH, ESRI ArcSDE, 
CSW, Z39.50, OGC WxS, WFS, Système de fichier, Serveur WebDav.


Depuis 2009, des travaux ont également permis à GeoNetwork de prendre en compte les recommandations de la
directive INSPIRE en mettant en place des mécanismes avancés de validation, la saisie de métadonnées
en mode multilingue, la gestion des thésaurus au format SKOS tel que GEMET ou AGROVOC.


GeoNetwork opensource est le résultat du travail de nombreux contributeurs avec le soutient
entre autres, des agences des nations unies (FAO, OCHA, CSI-GCRAI, UNEP, ...), 
l'Agence spatiale européenne (ESA), le CSIRO, le BRGM, Swisstopo, GeoNovum, ... 



GeoNetwork et sa communauté Open Source
---------------------------------------

La communauté des utilisateurs et des développeurs du logiciel GeoNetwork a augmenté
de façon spectaculaire depuis la sortie de la version 2.0 en Décembre 2005.
À l'heure actuelle, les listes de diffusion des utilisateurs et développeurs comptent
respectivement plus de 600 et 300 abonnés. L'abonnement à ces listes est ouverte à tous. 

`Les archives des listes de diffusion <http://osgeo-org.1803224.n2.nabble.com/GeoNetwork-opensource-f2013073.html>`_ 
constituent une source importante d'information. Les membres fournissent des informations, des traductions, 
de nouvelles fonctionnalités, des rapports de bugs, des correctifs et des
instructions pour le projet dans son ensemble. Bâtir une communauté d'utilisateurs et
de développeurs est l'un des plus grands défis pour un projet opensource. Ce
processus repose sur la participation active et les interactions entre ses
membres. Elle s'appuie également sur la confiance et le fonctionnement de manière transparente,
en définissant les objectifs généraux, les priorités et les orientations à long terme
du projet. Un certain nombre de mesures ont été prises par l'équipe du projet afin de
faciliter ce processus.



Conseil consultatif (Advisory Board) et Comité de pilotage (PSC)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

La création d'un Conseil consultatif de GeoNetwork a été mis en place lors de
l'atelier de 2006 à Rome. Un plan de travail est présenté et discuté annuellement;


En 2006, le Conseil consultatif du projet a décidé de proposer la
projet GeoNetwork opensource à l'incubation de l'
`Open Source Geospatial Foundation (OSGeo) <http://www.osgeo.org>`_.
Aujourd'hui, GeoNetwork est un projet de l'OSGeo.


Le Comité de pilotage de GeoNetwork (PSC) coordonne la direction générale,
les cycles de publication, la documentation pour le projet de GeoNetwork. 
En outre, la PSC s'occupe de l'assistance aux utilisateurs en général, 
il accepte et approuve les correctifs de la communauté GeoNetwork et
votes sur des questions diverses :

- tout ce qui peut causer des problèmes de compatibilité descendante.

- l'ajout de quantités importantes de nouveau code.

- les modifications de l'API.

- la définition de la gouvernance.

- lors de la sortie de nouvelle version.

- tout ce qui pourrait être sujet à controverse.

- ajouter un nouveau membre à la CFP

- ajouter un nouveau participant au dépôt de code



Le comité de pilotage est actuellement composé des personnes suivantes :

- Jeroen Ticheler

- Andrea Carboni

- Patrizia Monteduro

- Emanuele Tajariol

- Francois Prunayre
 
- Simon Pigot

- Archie Warnock



Contributeurs anciens et actuels
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Les développeurs actifs sur le trunk sont les suivants :

- Archie Warnock	

- Emanuele Tajariol	

- Francois Prunayre	

- Heikki Doeleman	

- Jeroen Ticheler	

- Jose Garcia	

- Mathieu Coudert	

- Roberto Giaccio	

- Simon Pigot	



`D'autres contributeurs <http://trac.osgeo.org/geonetwork/wiki/committer_list>`_ sont égalements actifs dans les bacs à sables du projet.



Sites web
~~~~~~~~~

Deux sites Web publics ont été créés :

- un pour les utilisateurs : http://geonetwork-opensource.org

- un pour les développeurs : http://trac.osgeo.org/geonetwork 

Les deux sont maintenus par des membres de confiance de la communauté. Ils offrent l'accès
à la documentation, les rapports de bugs, le suivi, le wiki, .... Une
partie de la communauté se connecte via Internet Relay Chat (IRC) sur le canal ``irc://irc.freenode.net/geonetwork``.
Cependant la majorité des dialogues a lieu sur
`la liste utilisateur <https://lists.sourceforge.net/mailman/listinfo/geonetwork-users>`_ et 
`la liste développeur <https://lists.sourceforge.net/mailman/listinfo/geonetwork-devel>`_


Code source
~~~~~~~~~~~

Le code source est accessible sur `SourceForge.net <http://sourceforge.net/projects/geonetwork>`_.

Documentation
~~~~~~~~~~~~~


La documentation est écrite dans le format reStructuredText et utilise `Sphinx <http://sphinx.pocoo.org>`_
pour la diffusion dans différents formats (e.g. HTML et
PDF).


