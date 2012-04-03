#!/bin/sh

#~ if [ -z "$JREBEL_HOME" ] ; then
    #~ echo "you do not have JREBEL installed.  You need to define JREBEL_HOME"
    #~ exit -1
#~ fi

#~ JREBEL_OPTS="-noverify -javaagent:$JREBEL_HOME/jrebel.jar"
DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
OVERRIDES="-Dgeonetwork.jeeves.configuration.overrides.file=/WEB-INF/override-config-fvanderbiest.xml"
MEMORY="-XX:MaxPermSize=256m -Xmx1024M -server"
DIRS="-Dgeonetwork.dir=/tmp/gc_data"
export MAVEN_OPTS="$JREBEL_OPTS $DEBUG $OVERRIDES $MEMORY $DIRS -Dfile.encoding=UTF8 -Dlog4j.debug"

cd ../jeeves 
mvn3 install -Dmaven.test.skip && cd ../web && mvn3 jetty:run -Penv-dev,widgets-tab $@