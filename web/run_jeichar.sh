#!/bin/sh

if [ -z "$JREBEL_HOME" ] ; then
    echo "you do not have JREBEL installed.  You need to define JREBEL_HOME"
    exit -1
fi

JREBEL_OPTS="-noverify -javaagent:$JREBEL_HOME/jrebel.jar"
DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
OVERRIDES="-Djeeves.configuration.overrides.file=/WEB-INF/override-config-jeichar.xml"
MEMORY="-XX:MaxPermSize=256m -Xmx1024M -server"
DIRS="-Dgeonetwork.lucene.dir=/tmp/gc_lucene -Dgeonetwork.data.dir=/tmp/gc_data"
export MAVEN_OPTS="$JREBEL_OPTS $DEBUG $OVERRIDES $MEMORY $DIRS -Dfile.encoding=UTF8 "

mvn compile test jetty:run -Penv-dev -Dmaven.test.skip=true