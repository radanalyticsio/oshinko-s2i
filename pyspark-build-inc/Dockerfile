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
# This is a Dockerfile for the radanalyticsio/radanalytics-pyspark-inc:1.0 image.


## START target image radanalyticsio/radanalytics-pyspark-inc:1.0
## \
    FROM centos/python-36-centos7:latest

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

###### START module 'pyspark:1.0'
###### \
        # Copy 'pyspark' module content
        COPY modules/pyspark /tmp/scripts/pyspark
        # Set 'pyspark' module defined environment variables
        ENV \
            APP_LANG="python" \
            APP_ROOT="/opt/app-root" \
            PATH="/opt/app-root/src/.local/bin/:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin" \
            PYTHONPATH="/opt/spark/python" \
            RADANALYTICS_PYSPARK="1.0" 
        # Custom scripts from 'pyspark' module
        USER root
        RUN [ "sh", "-x", "/tmp/scripts/pyspark/install" ]
###### /
###### END module 'pyspark:1.0'

###### START image 'radanalyticsio/radanalytics-pyspark-inc:1.0'
###### \
        # Copy 'radanalyticsio/radanalytics-pyspark-inc' image general artifacts
        COPY \
            oshinko_v0.6.1_linux_amd64.tar.gz \
            /tmp/artifacts/
        # Switch to 'root' user to install 'radanalyticsio/radanalytics-pyspark-inc' image defined packages
        USER root
        # Install packages defined in the 'radanalyticsio/radanalytics-pyspark-inc' image
        RUN yum --setopt=tsflags=nodocs install -y java-1.8.0-openjdk \
            && rpm -q java-1.8.0-openjdk
        # Set 'radanalyticsio/radanalytics-pyspark-inc' image defined environment variables
        ENV \
            APP_LANG="python" \
            APP_ROOT="/opt/app-root" \
            JBOSS_IMAGE_NAME="radanalyticsio/radanalytics-pyspark-inc" \
            JBOSS_IMAGE_VERSION="1.0" \
            PATH="/opt/app-root/src/.local/bin/:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin" \
            PYTHONPATH="/opt/spark/python" \
            RADANALYTICS_PYSPARK="1.0" \
            SPARK_HOME="/opt/spark" \
            SPARK_INSTALL="/opt/spark-distro" 
        # Set 'radanalyticsio/radanalytics-pyspark-inc' image defined labels
        LABEL \
            io.cekit.version="3.6.0"  \
            io.k8s.description="Platform for building a radanalytics Python 3.6 pyspark app"  \
            io.k8s.display-name="radanalytics pyspark-inc"  \
            io.openshift.expose-services="8080:http"  \
            io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"  \
            io.openshift.tags="builder,radanalytics,pyspark"  \
            name="radanalyticsio/radanalytics-pyspark-inc"  \
            version="1.0" 
###### /
###### END image 'radanalyticsio/radanalytics-pyspark-inc:1.0'


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