#######################################################################################################################################

Run Aapache Hive with Docker

## Prequirements

## Start Hive Node

```
docker service create \
	--name hive \
	--hostname hive \
	--network swarm-net \
	--replicas 1 \
	--detach=true \
	--mount type=bind,source=/etc/localtime,target=/etc/localtime \
	newnius/hive:2.3.3
```
#### Init MetaStore -- Previous step for start this command, put the correct connection string in the file "hive-site.xml"

```bash
schematool --dbType mssql --initSchema
```

#### Start MetaStore service
```bash
nohup hive --service metastore &
```

#### Validate Installation

Run `hive` to start the hive shell

If the following command is executed successfully, then the installation is fine.

```hive
CREATE TABLE pokes (foo INT, bar STRING);
```