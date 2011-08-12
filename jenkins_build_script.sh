#!/bin/bash

fileExists () {
  if [ ! -f $1 ]; then 
    echo "file does not exist: '$1'"
    exit 1
  fi
}
dirExists () {
  if [ ! -d $1 ]; then 
    echo "dir does not exist: '$1'"
    exit 1
  fi
}

set -e -x

geocat_ch_deploy_url=https://svn.bgdi.admin.ch/tc-geocat/trunk/geocat.ch.deploy
geocat_ch_deploy_dir=/var/www/tc-geocat/private/geocat.ch.deploy

# FIXME if we configure the Subversion username/password in Jenkins then we don't need the following
svn_auth="--no-auth-cache --username jenkin-ro --password phioyohb"

if [ -f ${geocat_ch_deploy_dir}/.svn ] ; then
	cd ${geocat_ch_deploy_dir}
	svn ${svn_auth} update
else
	svn ${svn_auth} checkout ${geocat_ch_deploy_url} ${geocat_ch_deploy_dir}
	cd ${geocat_ch_deploy_dir}
fi

./deploy.to.localhost.sh all

if [ -f "/tmp/gc_deploy_failure" ]; then
  exit 1
fi

fileExists /srv/tomcat/geocat/private/geocat/data/codelist/external/thesauri/_none_/gemet.rdf
fileExists /srv/tomcat/geocat/private/geocat/data/codelist/external/thesauri/_none_/inspire.rdf
fileExists /srv/tomcat/geocat/private/geocat/data/codelist/local/thesauri/_none_/geocat.ch.rdf
fileExists /srv/tomcat/geocat/private/geocat/data/codelist/local/thesauri/_none_/non_validated.rdf
fileExists /srv/tomcat/geocat/private/geocat/override-config.xml
dirExists /srv/tomcat/geocat/private/geoserver
