FROM ubuntu:latest
LABEL authors="Bluetab"
#########################
# Prerequisites
RUN apt-get update && apt-get install -y  \
        openjdk-8-jdk-headless \
        bash \
        openssl \
        rsync \
        wget
# jdbc:sqlserver://sql_srv.windows.net:1433;database=sql_dbs;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
ENV user userhive
ENV sql_srv servidorsql
ENV sql_dbs bbddsql
ENV sqluser usuario
ENV sqlpass password
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
RUN apt-get clean
#########################
# Install Hadoop
ENV HADOOP_VER 2.9.1
RUN wget -O hadoop.tar.gz https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VER/hadoop-$HADOOP_VER.tar.gz && \
    tar -xzf hadoop.tar.gz -C /usr/local/ && rm hadoop.tar.gz
RUN ln -s /usr/local/hadoop-$HADOOP_VER /usr/local/hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin 
ENV HADOOP_PREFIX $HADOOP_HOME 
ENV HADOOP_COMMON_HOME $HADOOP_HOME 
ENV HADOOP_HDFS_HOME $HADOOP_HOME 
ENV HADOOP_MAPRED_HOME $HADOOP_HOME 
ENV HADOOP_YARN_HOME $HADOOP_HOME 
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop 
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
#    HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
WORKDIR $HADOOP_HOME/etc/hadoop
RUN sed -ie "/^export JAVA_HOME/ s:.*:export JAVA_HOME=${JAVA_HOME}\nexport HADOOP_HOME=${HADOOP_HOME}\nexport HADOOP_PREFIX=${HADOOP_PREFIX}:" hadoop-env.sh
RUN sed -ie "/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop/:" hadoop-env.sh

WORKDIR $HADOOP_HOME
#########################
# Install Apache Hive
ENV HIVE_VER 2.3.3
RUN wget -O apache-hive.tar.gz https://archive.apache.org/dist/hive/hive-$HIVE_VER/apache-hive-$HIVE_VER-bin.tar.gz && tar -xzf apache-hive.tar.gz -C /usr/local/ && rm apache-hive.tar.gz
RUN ln -s /usr/local/apache-hive-$HIVE_VER-bin /usr/local/hive
ENV HIVE_HOME /usr/local/hive
ENV PATH $PATH:$HIVE_HOME/bin
#########################
#RUN 
ADD sqljdbc42.jar $HIVE_HOME/lib 
ADD hive-site.xml $HIVE_HOME/conf 
ADD hive-env.sh $HIVE_HOME/conf
ADD rep_hive-site.sh $HIVE_HOME/conf
RUN chmod +x $HIVE_HOME/conf/hive-env.sh
RUN chmod +x $HIVE_HOME/conf/rep_hive-site.sh
RUN rm -rf /var/lib/apt/lists/*
RUN mv $HIVE_HOME/lib/log4j-slf4j-impl-2.6.2.jar log4j-slf4j.backup
#####################
#User: userhive
RUN useradd -m -d /${user} ${user} 
RUN chown -hR ${user} /${user} 
RUN adduser ${user} sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown -hR ${user} /usr/local/hadoop
RUN chown -hR ${user} /usr/local/hive
WORKDIR $HIVE_HOME
ENTRYPOINT ["./conf/rep_hive-site.sh"]

#CMD [ "hive", "--version" ]
#CMD ["schematool -dbType mssql -initSchema --verbose"]
