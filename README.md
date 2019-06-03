##############################################################################

Run Apache Hive with Docker

## Prequirements

Script that replace variable to connection string --> rep_hive-site.sh
Build Dockerfile:
```bash

docker build -t ubuntu/hivehadoop -f Dockerfile .

```
#### Init MetaStore

```bash
docker run -it \
-e sql_srv=MySQLServer \
-e sql_dbs=MyDB\
-e sqluser=MyUserName \
-e sqlpass=MyPassword \
ubuntu/hivehadoop \
schematool -dbType mssql -initSchema

```
#### Start MetaStore service
```bash
nohup hive --service metastore &
```
