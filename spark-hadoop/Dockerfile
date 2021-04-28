FROM registry.origin.paas.eniro/manyana/radanalytics-scala-212-spark

USER root

ENV HADOOP_HOME /opt/hadoop-${HADOOP_VERSION}
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/etc/hadoop
ENV PATH ${HADOOP_HOME}/bin:$PATH
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_DIST_CLASSPATH ${HADOOP_HOME}/etc/hadoop:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/hdfs:${HADOOP_HOME}/share/hadoop/hdfs/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/yarn/lib/*:${HADOOP_HOME}/share/hadoop/yarn/*:${HADOOP_HOME}/share/hadoop/mapreduce/lib/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/contrib/capacity-scheduler/*.jar

COPY hadoop-${HADOOP_VERSION}.tar.gz /opt
RUN cd /opt && tar -zxvf hadoop-${HADOOP_VERSION}.tar.gz && cd
RUN rm -rf ${HADOOP_HOME}/share/doc

USER 185

ENTRYPOINT ["/opt/app-root/etc/bootstrap.sh"]

CMD ["/usr/libexec/s2i/usage"]
