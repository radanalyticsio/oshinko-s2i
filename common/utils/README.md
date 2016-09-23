# start.sh #

A common startup script for radanalytics spark applications.
This script is meant to be used in a container launched
from openshift and expects arguments specified through
environment variables (which should be set in the 
corresponding template used for launch and/or the
specific image).

## overview ##

This script will contact the oshinko rest server to check
if a cluster of the specified name exists. If the cluster
does not exist, it will be created (currently with a fixed
size of a single master and three workers). The url of the
spark master will be determined in either case and the
specified user application file will be launched using
spark-submit.

Currently the script will sleep forever in a loop after submitting
the spark application to prevent the process from exiting if the
APP_EXIT environment variable is unset or set to "false". This is
to prevent a deploymentconfig from restarting the spark application
after it completes (in general, a deploymentconfig may not be the
best choice of openshift object for submitting a spark application
intended to run once to completion).

## environment variables ##

The start.sh script expects the following environment variables:

+ APP_ROOT -- path of the application root directory. In the standard s2i
images, this will be /opt/app-root. Application source will be located at
$APP_ROOT/src, and start.sh may reference scripts in $APP_ROOT/etc. *required*

+ OSHINKO_CLUSTER_NAME -- the name of the cluster to use for this application, *required*

+ OSHINKO_REST -- the ip address of the oshinko rest server, *optional*. If this is not
specified then the container's environment will be searched to determine the address
of an oshinko rest server running in the same namespace.

+ APP_MAIN_CLASS -- this is the name of the main class that spark-submit will launch. *Required*
for java and scala applications but not for pyspark.

+ APP_FILE -- this is the name of the JAR or python file in APP_ROOT that will be passed to
spark-submit, *required*

+ APP_ARGS -- arguments to pass to the spark application, *optional* (depends on the application)

+ SPARK_OPTIONS -- additional options to pass to spark-submit, *optional*. These options should
not contain **--master** or **--class**.

* FROM_DEPLOYMENTCONFIG -- set this variable to any value ("true" would be fine) when the container
running the spark application is created by a deploymentconfig. This prevents the start.sh script
from exiting after the spark application completes.
