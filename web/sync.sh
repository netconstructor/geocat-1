#/bin/sh

function syncDir () {  
  PATTERN=$2
  if [ ! -n "$PATTERN" ] ; then
    PATTERN=*
  fi
  rm target/webapp/$1/$PATTERN
  mkdir -p target/webapp/$1
  echo "copying directory src/main/webapp/$1/$PATTERN"
  cp src/main/webapp/$1/$PATTERN target/webapp/$1
}

function syncFile () {
  echo "copying file src/main/webapp/$1"
  cp -R src/main/webapp/$1 target/webapp/$1  
}

syncDir scripts *.js
syncDir scripts/mapfishIntegration
syncDir xsl *.xsl
syncDir xsl/shared-user/
syncFile WEB-INF/overrides-config-geocat.xml
syncFile WEB-INF/override-config-jeichar.xml
syncFile geocat.css
touch target/webapp/WEB-INF/config-gui.xml