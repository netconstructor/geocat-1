.. _introduction:

Introduction aux métadonnées
============================

Qu'est ce qu'une métadonnée ?
-------------------------------

Les métadonnées sont généralement définies comme “données sur les données” ou "information sur les données".
Les métadonnées sont une liste structurée d'information qui décrivent les données ou les services
(incluant les données numériques ou non) stockés dans les systèmes d'information.
Les métadonnées peuvent contenir une brève description sur le contenu, les objectifs,
la qualité et la localisation de la donnée ainsi que les informations relatives à sa création.

Quels sont les standards sur les métadonnées ?
----------------------------------------------

Pour les gestionnaires de données, les standards sur les métadonnées
décrivent le format d'échange et le contenu
pour décrire leurs données ou services. Ceci permet aux utilisateurs d'évaluer la pertinence
des données par rapport à leurs besoins.

Les standards fournissent un ensemble commun de descripteurs et leur définition.

Pourquoi avons nous besoin de standards ?
-----------------------------------------

L'utilisation de standards permet aux utilisateurs d'avoir une terminologie
commune permettant la réalisation de recherche efficace pour la découverte des données
dans les catalogues. Les métadonnées reposant sur les standards
permettent d'avoir un même niveau d'information et d'éviter la perte
de connaissance sur les données.

Les standards pour les métadonnées géographiques
------------------------------------------------

Les principaux standards sont les suivants :
- ISO19139/119
- FGDC, le standard de métadonnée adopté par les Etats-Unis / Federal
Geographic Data Committee
- Dublin Core

GeoNetwork supporte `d'autres standards <appendix/format/index.html>`_

Les données géographiques sont souvent produites par des organisations ou des indépendants
et peuvent répondre aux besoins de différents types d'utilisateurs (opérateurs SIG,
analyse d'image, politiques, ...). Une documentation adéquate sur les données
aide à mieux définir la pertinence de ces informations pour la production, l'utilisation
et la mise à jour.

L'ISO définit en détail comment décrire les ressources dans le domaine de l'information
géographique tel que les données ou les services. Ce standard précise les descripteurs
obligatoires et conditionels. Il s'applique aux séries de données, aux données, aux
objets géographiques ainsi qu'à leurs propriétés. Bien que
l'ISO 19115:2003 ai été conçu pour les données numériques, ces principes peuvent
être étendus à d'autres type de ressources tel que les cartes, graphiques,
documents ou données non géographiques.

Le format d'échange de l'ISO19115:2003 est XML. GeoNetwork
utilise ISO Technical Specification 19139/119 Geographic information - Metadata -
XML schema implementation pour l'encodage XML de l'ISO19115.

Les profiles de métadonnées
---------------------------

GeoNetwork supporte plusieurs profiles de métadonnées. Les profiles peuvent prendre la forme
de modèle ou templates qu'il est possible de créer via l'éditeur.
En utilisant la vue avancée de l'éditeur, potentiellement l'ensemble des éléments sont accessibles
à l'utilisateur.

Le support d'extensions ou de profil spécifique peut également être mis en place
par des développeurs connaissant les langages XML/XSL.

Les profiles actuellements supportés sont listés `ici <appendix/format/index.html>`_.

Ces profiles sont disponibles dans les projets Bluenet, geocat.ch et GéoSource. 


