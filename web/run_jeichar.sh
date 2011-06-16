#!/bin/sh

export MAVEN_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005 -Djeeves.configuration.overrides.file=/WEB-INF/override-config-jeichar.xml"

mvn jetty:run