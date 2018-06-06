#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common

SCRIPT_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"`)
source $SCRIPT_DIR/../../builddc

RESOURCE_DIR=$TEST_DIR/resources
set_template $RESOURCE_DIR/oshinko-scala-spark-build-dc.json
set_git_uri https://github.com/radanalyticsio/tutorial-sparkpi-scala-akka
set_worker_count $S2I_TEST_WORKERS
set_fixed_app_name scala-build
set_app_main_class io.radanalytics.examples.akka.sparkpi.WebServerHttpApp

# Need a little preamble here to read the resources.yaml, create the scala template, and save
# it to the resources directory
set +e
if [ -f "$RESOURCE_DIR"/resources.yaml ]; then
    echo Using local resources.yaml
    oc create -f $RESOURCE_DIR/resources.yaml &> /dev/null
else
    echo Using https://radanalytics.io/resources.yaml
    oc create -f https://radanalytics.io/resources.yaml &> /dev/null
fi

oc export template oshinko-scala-spark-build-dc -o json > $RESOURCE_DIR/oshinko-scala-spark-build-dc.json
fix_template $RESOURCE_DIR/oshinko-scala-spark-build-dc.json radanalyticsio/radanalytics-scala-spark:stable $S2I_TEST_IMAGE_SCALA
set -e

function test_ivy_perms {
    set_defaults
    set_app_file scala-spark-webapp_2.11-0.1.jar
    SPARK_OPTIONS=" --packages com.typesafe.akka:akka-http_2.11:10.0.9,com.typesafe.akka:akka-http-xml_2.11:10.0.9,com.typesafe.akka:akka-stream_2.11:2.5.3 --conf spark.jars.ivy=/tmp/.ivy2"
    run_app
    os::cmd::try_until_text "oc log dc/$APP_NAME" "Press RETURN to stop"
    os::cmd::expect_success_and_not_text "oc log dc/$APP_NAME" "Permission denied"
    cleanup_app
}

os::test::junit::declare_suite_start "$MY_SCRIPT"

echo "++ test_ivy_perms"
test_ivy_perms

os::test::junit::declare_suite_end
