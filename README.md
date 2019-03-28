##############################################################################

Run Aapache Hive with Docker

## Prequirements

Script that replace variable to connection string --> rep_hive-site.sh
Build Dockerfile:
```bash

docker build -t ubuntu/hivehadoop -f Dockerfile .

```
#### Init MetaStore

```bash
docker run \
-e sql_srv=MiServidorSQL \
-e sql_dbs=MiBBDD_SQL \
-e sqluser=MiUsuarioSeguro \
-e sqlpass=MiContraseñaSegura \
ubuntu/hive_hadoop
schematool -dbType mssql -initSchema

```
#### Start MetaStore service
```bash
nohup hive --service metastore &
```
