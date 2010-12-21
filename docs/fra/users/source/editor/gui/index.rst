.. _editor_gui:

L'interface d'édition
=====================

Le choix d'un standard
----------------------


Les modèles de saisie
---------------------


Les vues
--------

Les vues disponibles dans l'éditeur peuvent être configurée (TODO add admin link).
Elles sont fonctions du standard de métadonnée utilisé. Les vues pour une métadonnée
en ISO sont différentes d'une métadonnée en dublin core.

La description ci-dessous présente les vues pour les métadonnées au format ISO.

La vue par défaut
`````````````````
La vue par défaut présente l'ensemble des champs remplis dans la fiche ou le modèle
utilisé. Elle permet d'avoir une vision simple de la métadonnée par contre il
ne sera pas possible de saisir des éléments non visible. Il faut alors passer
dans un autre mode, en général le mode avancé. 

L'ordre des champs suit le modèle ISO.

Cette vue est également disponible pour les autres standards.


La vue INSPIRE ou vue découverte
````````````````````````````````
Cette vue a été mise en place en ayant pour objectif d'organiser l'éditeur
tel que présenté dans les régles d'implémentation sur les métadonnées
de la directive INSPIRE.


La vue ISO
``````````
Les 3 onglets core, minimum et all reprennent les groupes d'information définis
par la norme ISO.

L'ordre des champs suit le modèle ISO.

La vue complète
```````````````

Cette vue permet de visualiser et éditer **l'ensemble** des descripteurs 
du standard de la métadonnée. Les onglets correspondent aux grandes sections
de l'ISO.


  .. figure:: advancedView.png

  *Vue complète*


La vue XML
``````````


La **Vue XML** montre l'ensemble du contenu de la
métadonnée dans la structure hiérarchique d'origine; La structure XML est
composée de balises, à chacune des balises doit correspondre une balise fermée. Le contenu est entièrement placé entre les
deux balises:

::

  <gmd:language>
    <gco:CharacterString>eng</gco:CharacterString>
  </gmd:language>



Cependant, l'utilisation de la vue XML requiert une connaissance minimale du
langage XML.

  .. figure:: xmlView1.png

  *Vue XML*




Barre de menu
-------------

TODO : Sauvegarde ...



