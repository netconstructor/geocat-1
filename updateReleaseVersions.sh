#!/bin/bash

# Usage to create 2.6.2 release version from 2.6.2-SNAPSHOT
# In root folder of branch code: ./updateReleaseVersion.sh 2.6.2

version="$1"

# Update version in sphinx doc files
sed -i .bak  "s/${version}-SNAPSHOT/${version}/g" docs/eng/users/source/conf.py 
sed -i .bak  "s/${version}-SNAPSHOT/${version}/g" docs/eng/developer/source/conf.py

# Update version pom files
find . -name pom.xml -exec sed -i .bak "s/${version}-SNAPSHOT/${version}/g" {} \;