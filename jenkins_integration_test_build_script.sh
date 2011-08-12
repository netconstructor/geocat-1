#/bin/sh

TEST_REPORTS=/var/www/tc-geocat/htdocs/test-reports
JENKINS_COPY=/tmp/jenkins_webspecs/

set -e -x

rm -rf $JENKINS_COPY
cp -R /tmp/geocat.ch/webspecs/ $JENKINS_COPY
cd $JENKINS_COPY

WEBSPECS_CONF="-Dadmin.user=$ADMIN_USER -Dadmin.pass=$ADMIN_PASS -Dwebspecs.config=./core/src/main/resources/geocat/integration_geocat_config.properties"
SBT_OPTS="$SBT_OPTS -Dfile.encoding=UTF8 -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256m -Dsbt.log.noformat=true"
java ${SBT_OPTS} -jar ./sbt-launch.jar "core/run-test-suite"

if [ -d "$TEST_REPORTS" ]; then
	chmod -R g+w $TEST_REPORTS
  rm -rf $TEST_REPORTS
fi

mkdir -p $TEST_REPORTS
cp -R ./target/specs2-reports/* $TEST_REPORTS
cp -R ./target/specs2-reports/c2c.webspecs.suite.AllSpecs.html $TEST_REPORTS/index.html
chmod -R g+w $TEST_REPORTS
rm -rf ./target/specs2-reports
