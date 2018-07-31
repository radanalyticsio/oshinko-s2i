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
# This is a Dockerfile for the radanalyticsio/radanalytics-sparklyr:1.0 image.

FROM rimolive/r-34-centos7:latest

# Environment variables
ENV JBOSS_IMAGE_NAME="radanalyticsio/radanalytics-sparklyr" \
    JBOSS_IMAGE_VERSION="1.0" \
    PATH="/opt/app-root/src/.local/bin/:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin" \
    SPARK_HOME="/opt/spark" \
    APP_ROOT="/opt/app-root" \
    APP_LANG="r" 

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      architecture="x86_64"  \
      com.redhat.component="radanalyticsio-radanalytics-sparklyr-docker"  \
      io.k8s.description="Platform for building a radanalytics sparklyr app" \
      io.k8s.display-name="radanalytics sparklyr" \
      io.openshift.expose-services="8080:http" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.openshift.tags="builder,radanalytics,sparklyr" \
      io.radanalytics.sparkdistro="https://archive.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz" \
      org.concrt.version="1.4.1"


USER root


# Install required RPMs and ensure that the packages were installed
RUN yum install -y  java-1.8.0-openjdk \
    && yum clean all && \
    rpm -q  java-1.8.0-openjdk

# Add all artifacts to the /tmp/artifacts
# directory
COPY \
    spark-2.3.0-bin-hadoop2.7.tgz \
    oshinko_v0.5.4_linux_amd64.tar.gz \
    /tmp/artifacts/

# Add scripts used to configure the image
COPY modules /tmp/scripts

# Custom scripts
USER root
RUN [ "bash", "-x", "/tmp/scripts/common/install" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/sparklyr/install" ]

USER root
RUN rm -rf /tmp/scripts
USER root
RUN rm -rf /tmp/artifacts

USER 185



CMD ["/usr/local/s2i/usage"]
