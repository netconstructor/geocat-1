#/bin/sh

function syncDir () {  
  rm -rf target/webapp/$1
  mkdir -p target/webapp/$1
  echo "copying directory src/main/webapp/$1"
  cp -R src/main/webapp/$1/* target/webapp/$1
}

function syncFile () {
  echo "copying file src/main/webapp/$1"
  cp -R src/main/webapp/$1 target/webapp/$1  
}

syncFile xsl/banner.xsl
syncFile xsl/geocat.xsl
syncFile xsl/mapfish_includes.xsl
syncDir scripts/mapfishIntegration
syncFile WEB-INF/overrides-config-geocat.xml
syncFile WEB-INF/override-config-jeichar.xml
syncFile geocat.css
touch target/webapp/WEB-INF/config-gui.xml