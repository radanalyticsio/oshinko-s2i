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
# This is a Dockerfile for the radanalyticsio/radanalytics-java-spark:1.0 image.


## START target image radanalyticsio/radanalytics-java-spark:1.0
## \
    FROM fabric8/s2i-java:2.2.0

    USER root

###### START module 'java:1.0'
###### \
        # Copy 'java' module content
        COPY modules/java /tmp/scripts/java
        # Set 'java' module defined environment variables
        ENV \
            STI_SCRIPTS_PATH="/usr/local/s2i" 
        # Custom scripts from 'java' module
        USER root
        RUN [ "sh", "-x", "/tmp/scripts/java/install" ]
###### /
###### END module 'java:1.0'

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

###### START image 'radanalyticsio/radanalytics-java-spark:1.0'
###### \
        # Copy 'radanalyticsio/radanalytics-java-spark' image general artifacts
        COPY \
            oshinko_v0.6.1_linux_amd64.tar.gz \
            /tmp/artifacts/
        # Switch to 'root' user to install 'radanalyticsio/radanalytics-java-spark' image defined packages
        USER root
        # Install packages defined in the 'radanalyticsio/radanalytics-java-spark' image
        RUN yum --setopt=tsflags=nodocs install -y tar wget rsync \
            && rpm -q tar wget rsync
        # Set 'radanalyticsio/radanalytics-java-spark' image defined environment variables
        ENV \
            APP_LANG="java" \
            APP_ROOT="/opt/app-root" \
            JBOSS_IMAGE_NAME="radanalyticsio/radanalytics-java-spark" \
            JBOSS_IMAGE_VERSION="1.0" \
            PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin" \
            RADANALYTICS_JAVA_SPARK="1.0" \
            SPARK_HOME="/opt/spark" \
            SPARK_INSTALL="/opt/spark-distro" \
            SPARK_VERSION="2.4.0" \
            STI_SCRIPTS_PATH="/usr/local/s2i" 
        # Set 'radanalyticsio/radanalytics-java-spark' image defined labels
        LABEL \
            io.cekit.version="3.6.0"  \
            io.k8s.description="Platform for building a radanalytics java spark app"  \
            io.k8s.display-name="radanalytics java_spark"  \
            io.openshift.expose-services="8080:http"  \
            io.openshift.s2i.scripts-url="image:///usr/local/s2i"  \
            io.openshift.tags="builder,radanalytics,java_spark"  \
            name="radanalyticsio/radanalytics-java-spark"  \
            version="1.0" 
###### /
###### END image 'radanalyticsio/radanalytics-java-spark:1.0'


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
    CMD ["/usr/local/s2i/usage"]
## /
## END target image