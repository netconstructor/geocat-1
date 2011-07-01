#!/bin/sh﻿

dropdb geocat2_trunk
createdb -O www-data geocat2_trunk -T template_postgis

psql -d geocat2_trunk -c "ALTER TABLE geometry_columns OWNER TO \"www-data\";"
psql -d geocat2_trunk -c "ALTER TABLE spatial_ref_sys OWNER TO \"www-data\";"

for f in `ls sql/*.sql` ; do psql -f $f -d geocat2_trunk -U www-data > /dev/null; done

psql -f geometry_columns.sql -d geocat2_trunk -U www-data > /dev/null