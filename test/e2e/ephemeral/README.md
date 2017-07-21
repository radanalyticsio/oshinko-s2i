# Ephemeral cluster tests

Runs a series of tests of ephemeral cluster features using
a pyspark s2i image from the local docker repository. This
is intended for testing changes to the s2i repo, so if you
want to test a pyspark s2i image from elsewhere you should
use `docker pull` to get it in the local docker first.

Note, since all of the ephemeral cluster handling is the same
in oshinko across languages (Python, Scala, Java) these tests
simply use a pyspark s2i image.  Testing this image is a valid
test of the ephemeral cluster logic shared by the Java and Scala
images.

Currently the tests are in one monolithic block but may
be broken up in the future so that individual tests may be
run.

## Based on OpenShift Command-Line Integration Test Suite

These tests are built on the OpenShift CLI test suite (code
is located in the `hack` subdirectory at the repository root). It
uses the test functions, but not the standard test suite
driver `hack/test.sh`.  This is because these tests run against
a full OpenShift cluster and the test suite uses a partial instance
created with the `openshift` binary. Consequently, some elements
have been deleted from the `hack` directory to avoid confusion.

## Assumes shell has current login to an OpenShift instance

Before you run this test, you must have done `oc login` to
an OpenShift instance.  Your user must be able to create a new
project and create a service account in that project.

If you're running against a full OpenShift instance with an integrated
registry, your user must also be able to run docker commands
and push an s2i image to the integrated registry.

If you're running against a cluster created with `oc cluster up` then
the s2i image will be referenced directly from the local host and
no push is necessary.

## Test overview

The test script will create a new project and start an S2I build using
a local pyspark s2i image and the application in the `play` subdirectory.
The resulting image will be used to spawn Spark applications, and these
applications will create clusters. The tests will operate on the applications
in various ways to test ephemeral cluster features.

If the test completes successfully, the test project will be deleted. If not,
the test project will remain and it may be helpful to look at the contents
of the project along with the logs to determine why the test failed.

The tests use a cluster configmap created from the `masterconfig` and `workerconfig`
subdirectories. The contents of these subdirectories can be modified if you want
to change the Spark configuration for the master or workers.

Likewise you can change the code in `play`, but the tests assume that the
application there accepts an argument for how long to sleep after completion.
Some of the tests count on this delay.

## Running against a full OpenShift instance

If you are running against a regular OpenShift instance you must supply
the IP address of the integrated registry as an argument, for example:

    $ ./ephemeral.sh 172.123.456.78:5000

If you do not supply the registry argument, the script will assume you
are running against an OpenShift instance created with `oc cluster up`
and will handle images differently.

## Running against OpenShift created with `oc cluster up`

This is easy, just leave off the registry argument:

    $ ./ephemeral.sh

## Environment variables you can set

* S2I_TEST_WORKERS (default is 3)

  This is the number of workers in each cluster created. Note that currently
  the reverse-proxy URL feature is turned off since it can cause the master
  UI to fail with large numbers of workers on certain hardware.

* S2I_TEST_IMAGE (default is radanylytics-pyspark)

  This is the name of the image in the local docker instance that is used
  in the S2I build

* S2I_TEST_SPARK_IMAGE (default is docker.io/tmckay/openshift-spark:term)

  This is the Apache Spark image built for OpenShift that should be used.
  Currently an image from the tmckay repository is used which includes a
  signal handler for quick termination -- a pull request is pending against
  the standard openshift-spark image and this default will be changed when
  it is merged.
