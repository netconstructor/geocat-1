.. _advanced_configuration:


.. _admin_how_to_config_db:

Configuration de la connexion à la base de données
==================================================

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



Options de configuration avancée
--------------------------------

Le pool de connexion peut également être finement configuré en utilisant les paramètres suivants :

- poolSize

- maxWait

- maxTries

- reconnectTime




Configuration avancée de l'interface
====================================

Google translation service
--------------------------


Autres options de configuration
-------------------------------


config-gui.xml

