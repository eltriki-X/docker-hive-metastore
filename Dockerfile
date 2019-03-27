FROM ubuntu
LABEL authors="Bluetab"

# Prerequisites
RUN apt-get update && apt-get install -y  \
	openjdk-8-jdk-headless \
	bash \
	openssl \
	rsync \
	wget
#jdbc:sqlserver://${sqlsrv_name}.database.windows.net:1433;database=${sqldb_name};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
ARG sqlsrv_name
ARG sqldb_name
ARG UserSQL
ARG PassSQL

ENV user userhive \
    sqlsrv_name=$sqlsrv_name \
    sqldb_name=$sqldb_name \
	sqluser=$UserSQL \
    sqlpass=$PassSQL \
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64 
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
RUN apt-get clean
# Install Hadoop
ENV HADOOP_VER 2.9.1
RUN wget -O hadoop.tar.gz https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VER/hadoop-$HADOOP_VER.tar.gz && tar -xzf hadoop.tar.gz -C /usr/local/ && rm hadoop.tar.gz
RUN ln -s /usr/local/hadoop-$HADOOP_VER /usr/local/hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV HADOOP_YARN_HOME $HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV HADOOP_PREFIX $HADOOP_HOME
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
RUN sed -i '/^export JAVA_HOME/export JAVA_HOME=${JAVA_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\nexport HADOOP_PREFIX=${HADOOP_PREFIX}:' ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
# Default Conf Files
#ADD config/* $HADOOP_HOME/etc/hadoop/
#RUN sed -i "/^export JAVA_HOME/ s:.*:export JAVA_HOME=${JAVA_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\nexport HADOOP_PREFIX=${HADOOP_PREFIX}:" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
#RUN sed -i "/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop/:" $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
#WORKDIR $HADOOP_HOME
# Install Apache Hive
ENV HIVE_VER 2.3.3
RUN wget -O apache-hive.tar.gz https://archive.apache.org/dist/hive/hive-$HIVE_VER/apache-hive-$HIVE_VER-bin.tar.gz && tar -xzf apache-hive.tar.gz -C /usr/local/ && rm apache-hive.tar.gz
RUN ln -s /usr/local/apache-hive-$HIVE_VER-bin /usr/local/hive
ENV HIVE_HOME /usr/local/hive 
ENV PATH $PATH:$HIVE_HOME/bin
#RUN 
ADD sqljdbc42.jar $HIVE_HOME/lib \
ADD hive-site.xml $HIVE_HOME/conf \
ADD hive-env.sh $HIVE_HOME/conf
RUN chmod +x $HIVE_HOME/conf/hive-env.sh
RUN sed -i 's/sqlsrv_name/${sqlsrv_name}' $HIVE_HOME/conf/hive-site.xml
RUN sed -i 's/sqldb_name/${sqldb_name}' $HIVE_HOME/conf/hive-site.xml
RUN sed -i 's/sqluser/${sqluser}' $HIVE_HOME/conf/hive-site.xml
RUN sed -i 's/sqlpass/${sqlpass}' $HIVE_HOME/conf/hive-site.xml
#User: userhive
RUN useradd -m -d /${user} ${user} && \
    chown -R ${user} /${user} && \
    adduser ${user} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown -hR ${user} /usr/local/hadoop
RUN chown -hR ${user} /usr/local/hive
WORKDIR $HIVE_HOME
RUN rm -rf /var/lib/apt/lists/*
RUN mv $HIVE_HOME/lib/log4j-slf4j-impl-2.6.2.jar log4j-slf4j.backup
CMD [ "hive", "--version" ]
#CMD ["schematool -dbType mssql -initSchema --verbose"]
