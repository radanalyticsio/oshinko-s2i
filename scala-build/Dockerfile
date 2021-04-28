# Copyright 2019 Red Hat
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


## START target image radanalytics-scala-spark:1.0
## \
    FROM radanalyticsio/s2i-scala-container:latest

    USER root

###### START module 'common:1.0'
###### \
        # Copy 'common' module general artifacts
        COPY \
            oshinko_v0.6.1_linux_amd64.tar.gz \
            /tmp/artifacts/
        # Copy 'common' module content
        COPY modules/common /tmp/scripts/common
        # Switch to 'root' user to install 'common' module defined packages
        USER root
        # Install packages defined in the 'common' module
        RUN yum --setopt=tsflags=nodocs install -y wget \
            && rpm -q wget
        # Set 'common' module defined environment variables
        ENV \
            APP_ROOT="/opt/app-root" \
            SPARK_INSTALL="/opt/spark-distro" 
        # Custom scripts from 'common' module
        USER root
        RUN [ "sh", "-x", "/tmp/scripts/common/install" ]
###### /
###### END module 'common:1.0'

###### START module 'spark:1.0'
###### \
        # Copy 'spark' module general artifacts
        COPY \
            spark-3.0.1-bin-hadoop3.2.tgz \
            /tmp/artifacts/
        # Copy 'spark' module content
        COPY modules/spark /tmp/scripts/spark
        # Switch to 'root' user to install 'spark' module defined packages
        USER root
        # Install packages defined in the 'spark' module
        RUN yum --setopt=tsflags=nodocs install -y wget \
            && rpm -q wget
        # Set 'spark' module defined environment variables
        ENV \
            PATH="/opt/app-root/src/.local/bin/:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin" \
            SPARK_HOME="/opt/spark" \
            SPARK_INSTALL="/opt/spark-distro" 
        # Custom scripts from 'spark' module
        USER root
        RUN [ "sh", "-x", "/tmp/scripts/spark/install" ]
###### /
###### END module 'spark:1.0'

###### START module 'scala:1.0'
###### \
        # Copy 'scala' module content
        COPY modules/scala /tmp/scripts/scala
        # Custom scripts from 'scala' module
        USER root
        RUN [ "sh", "-x", "/tmp/scripts/scala/install" ]
###### /
###### END module 'scala:1.0'

###### START image 'radanalytics-scala-spark:1.0'
###### \
        # Copy 'radanalytics-scala-spark' image general artifacts
        COPY \
            spark-3.0.0-bin-hadoop3.2.tgz \
            oshinko_v0.6.1_linux_amd64.tar.gz \
            /tmp/artifacts/
        # Switch to 'root' user to install 'radanalytics-scala-spark' image defined packages
        USER root
        # Install packages defined in the 'radanalytics-scala-spark' image
        RUN yum --setopt=tsflags=nodocs install -y git \
            && rpm -q git
        # Set 'radanalytics-scala-spark' image defined environment variables
        ENV \
            APP_LANG="scala" \
            APP_ROOT="/opt/app-root" \
            JBOSS_IMAGE_NAME="radanalytics-scala-spark" \
            JBOSS_IMAGE_VERSION="1.0" \
            PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin:/opt/scala/bin:/opt/sbt/bin" \
            SBT_OPTS="-Dsbt.global.base=/tmp/.sbt/0.13 -Dsbt.ivy.home=/tmp/.ivy2 -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled" \
            SPARK_HOME="/opt/spark" \
            SPARK_INSTALL="/opt/spark-distro" 
        # Set 'radanalytics-scala-spark' image defined labels
        LABEL \
            io.cekit.version="3.6.0"  \
            io.k8s.description="Platform for building a radanalytics Scala Spark app"  \
            io.k8s.display-name="radanalytics scala_spark"  \
            io.openshift.expose-services="8080:http"  \
            io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"  \
            io.openshift.tags="builder,radanalytics,scala_spark"  \
            io.radanalytics.sparkdistro="https://archive.apache.org/dist/spark/spark-3.0.0/spark-3.0.0-bin-hadoop3.2.tgz"  \
            name="radanalytics-scala-spark"  \
            version="1.0" 
###### /
###### END image 'radanalytics-scala-spark:1.0'


    # Switch to 'root' user and remove artifacts and modules
    USER root
    RUN [ ! -d /tmp/scripts ] || rm -rf /tmp/scripts
    RUN [ ! -d /tmp/artifacts ] || rm -rf /tmp/artifacts

    # Clear package manager metadata
    RUN yum clean all && [ ! -d /var/cache/yum ] || rm -rf /var/cache/yum

    # Define the user
    USER 185
    # Define entrypoint
    ENTRYPOINT ["/opt/app-root/etc/bootstrap.sh"]
    # Define run cmd
    CMD ["/usr/libexec/s2i/usage"]
## /
## END target image