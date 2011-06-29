#!/bin/sh

if [ -z "$JREBEL_HOME" ] ; then
    echo "you do not have JREBEL installed.  You need to define JREBEL_HOME"
    exit -1
fi

JREBEL_OPTS="-noverify -javaagent:$JREBEL_HOME/jrebel.jar"
export MAVEN_OPTS="$JREBEL_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005 -Djeeves.configuration.overrides.file=/WEB-INF/override-config-jeichar.xml"

mvn compile test jetty:run