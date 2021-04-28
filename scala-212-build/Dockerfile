# Copyright 2017 Red Hat
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ------------------------------------------------------------------------
#
# This is a Dockerfile for the radanalytics-scala-spark:1.0 image.

FROM registry.origin.paas.eniro/manyana/s2i-scala-2.12:latest

USER root


# Install required RPMs and ensure that the packages were installed
RUN yum install -y git \
    && yum clean all && rm -rf /var/cache/yum \
    && rpm -q git


# Add all artifacts to the /tmp/artifacts
# directory
COPY \
    spark-2.4.4-bin-without-hadoop-scala-2.12.tgz \
    oshinko_v0.6.1_linux_amd64.tar.gz \
    /tmp/artifacts/


# Environment variables
ENV \
    APP_LANG="scala" \
    APP_ROOT="/opt/app-root" \
    JBOSS_IMAGE_NAME="radanalytics-scala-spark-212" \
    JBOSS_IMAGE_VERSION="1.0" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin:/opt/scala/bin:/opt/sbt/bin" \
    SBT_OPTS="-Dsbt.global.base=/tmp/.sbt/1.0 -Dsbt.ivy.home=/tmp/.ivy2 -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled" \
    SPARK_HOME="/opt/spark" \
    SPARK_INSTALL="/opt/spark-distro" 

# Labels
LABEL \
      io.cekit.version="2.2.7"  \
      io.k8s.description="Platform for building a radanalytics Scala Spark app"  \
      io.k8s.display-name="radanalytics scala_spark_212"  \
      io.openshift.expose-services="8080:http"  \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"  \
      io.openshift.tags="builder,radanalytics,scala_spark"  \
      io.radanalytics.sparkdistro="https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-without-hadoop-scala-2.12.tgz"  \
      name="radanalytics-scala-spark-212"  \
      org.concrt.version="2.2.7"  \
      version="1.0" 

# Add scripts used to configure the image
COPY modules /tmp/scripts

# Custom scripts
USER root
RUN [ "bash", "-x", "/tmp/scripts/common/install" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/spark/install" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/scala/install" ]

USER root
RUN rm -rf /tmp/scripts
USER root
RUN rm -rf /tmp/artifacts

ENV HADOOP_VERSION="2.8.5"
ENV HADOOP_HOME /opt/hadoop-${HADOOP_VERSION}
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/etc/hadoop
ENV PATH ${HADOOP_HOME}/bin:$PATH
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_DIST_CLASSPATH ${HADOOP_HOME}/etc/hadoop:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/hdfs:${HADOOP_HOME}/share/hadoop/hdfs/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/yarn/lib/*:${HADOOP_HOME}/share/hadoop/yarn/*:${HADOOP_HOME}/share/hadoop/mapreduce/lib/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/contrib/capacity-scheduler/*.jar

USER root
RUN wget http://apache.mirrors.spacedump.net/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -O /opt/hadoop-${HADOOP_VERSION}.tar.gz
RUN cd /opt && tar -zxvf hadoop-${HADOOP_VERSION}.tar.gz && cd
RUN rm -rf ${HADOOP_HOME}/share/doc

USER 185

ENTRYPOINT ["/opt/app-root/etc/bootstrap.sh"]

CMD ["/usr/libexec/s2i/usage"]

