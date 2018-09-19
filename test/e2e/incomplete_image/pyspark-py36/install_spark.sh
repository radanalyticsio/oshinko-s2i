#!/bin/bash

# Define a bunch of functions and set a bunch of variables
TEST_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i/test/e2e')
source $TEST_DIR/common
source $TEST_DIR/incomplete_image/common

$TEST_DIR/resources/sparkinputs.sh

PYSPARK_DIR=$(readlink -f `dirname "${BASH_SOURCE[0]}"` | grep -o '.*/oshinko-s2i')/templates
RESOURCE_DIR=$TEST_DIR/resources

# Set up a template to read our incomplete image
cp  $PYSPARK_DIR/python36builddc.json $RESOURCE_DIR/python36builddc.json
fix_template $RESOURCE_DIR/python36builddc.json radanalyticsio/radanalytics-pyspark-py36 $S2I_TEST_IMAGE_PYSPARK_PY36_INC

# Set up a template to read from an imagestream for our completed image
cp  $PYSPARK_DIR/python36builddc.json $RESOURCE_DIR/python36builddc-is.json
fix_template_for_imagestream $RESOURCE_DIR/python36builddc-is.json radanalyticsio/radanalytics-pyspark-py36 pyspark-py36-inc:latest

os::test::junit::declare_suite_start "install_spark"

echo "++ build_md5"
build_md5 pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

# if our md5 build worked, we have a completed image stream so try
# a basic app with it
echo "++ run_completed_app"
oc create configmap clusterconfig --from-literal=sparkimage=radanalyticsio/openshift-spark-py36 &>/dev/null
run_completed_app $RESOURCE_DIR/python36builddc-is.json https://github.com/radanalyticsio/s2i-integration-test-apps clusterconfig

echo "++ build_md5 (md5 deleted)"
md5=$(find $RESOURCE_DIR/spark-inputs -name "*.md5")
rm $md5
skip_app=true
build_md5 pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

echo "++ build_bad_md5"
mv $RESOURCE_DIR/spark-inputs/$(basename $md5 .md5).bad $md5
build_bad_md5 pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC
rm $md5

echo "++ build_from_directory"
build_from_directory pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

echo "++ tarball_no_submit"
tarball_no_submit pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

echo "++ directory_no_submit"
directory_no_submit pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

echo "++ build_bad_tarball"
build_bad_tarball pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

echo "++ build_env_var"
build_env_var pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

echo "++ already_installed"
already_installed pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

echo "++ bad_submit"
bad_submit pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

echo "++ copy_nocopy"
copy_nocopy pyspark-py36-inc $S2I_TEST_IMAGE_PYSPARK_PY36_INC

echo "++ run_incomplete_app"
run_incomplete_app $RESOURCE_DIR/python36builddc.json https://github.com/radanalyticsio/s2i-integration-test-apps

os::test::junit::declare_suite_end
