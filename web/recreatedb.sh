#!/bin/sh
set +x
DB=$1

export PG_PASSWORD="www-data"
dropdb $DB
createdb -O www-data $DB -T template_postgis

psql -d $DB -c "ALTER TABLE geometry_columns OWNER TO \"www-data\";"
psql -d $DB -c "ALTER TABLE spatial_ref_sys OWNER TO \"www-data\";"

for f in `ls sql/*.sql` ; do psql -f $f -d $DB -U www-data > /dev/null; done

psql -f geometry_columns.sql -d $DB -U www-data > /dev/null
