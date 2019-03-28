#!/bin/bash
cd $HIVE_HOME/conf/
sed -i 's|sql_srv|'"$sql_srv"'|g' hive-site.xml
sed -i 's|sql_dbs|'"$sql_dbs"'|g' hive-site.xml
sed -i 's|sqluser|'"$sqluser"'|g' hive-site.xml
sed -i 's|sqlpass|'"$sqlpass"'|g' hive-site.xml
exec "$@"
