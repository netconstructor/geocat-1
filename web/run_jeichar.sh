#!/bin/sh

if [ -z "$JREBEL_HOME" ] ; then
    echo "you do not have JREBEL installed.  You need to define JREBEL_HOME"
    exit -1
fi

JREBEL_OPTS="-noverify -javaagent:$JREBEL_HOME/jrebel.jar"
DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
OVERRIDES="-Dgeonetwork.jeeves.configuration.overrides.file=/WEB-INF/override-config-jeichar.xml"
MEMORY="-XX:MaxPermSize=256m -Xmx1024M -server"
DIRS="-Dgeonetwork.lucene.dir=/tmp/gc_lucene -Dgeonetwork.data.dir=/tmp/gc_data"
#JVM_MONITORING="-Dcom.sun.management.jmxremote.port=36467 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
export GRADLE_OPTS="$JVM_MONITORING $JREBEL_OPTS $DEBUG $OVERRIDES $MEMORY $DIRS -Dfile.encoding=UTF8 -Dlog4j.debug -Dlog4j.configuration=file://`pwd`/src/main/webapp/WEB-INF/log4j-jeichar.cfg -Dproject.basedir=`pwd`"

gradle jettyRun $@