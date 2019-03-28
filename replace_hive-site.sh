#!/bin/bash

sed -i 's/sql_srv/'"$sql_srv"'/g' $HIVE_HOME/hive-site.xml
sed -i 's/sql_dbs/'"$sql_dbs"'/g' $HIVE_HOME/hive-site.xml
sed -i 's/sqluser/'"$sqluser"'/g' $HIVE_HOME/hive-site.xml
sed -i 's/sqlpass/'"$sqlpass"'/g' $HIVE_HOME/hive-site.xml
exec "$@"
