[![Build Status](https://travis-ci.org/radanalyticsio/oshinko-s2i.svg?branch=master)](https://travis-ci.org/radanalyticsio/oshinko-s2i)
[![Docker python build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-pyspark.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-pyspark)
[![Docker java build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-java-spark.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-java-spark)

# oshinko-s2i #
This is a place to put s2i images and utilities for Apache Spark application builders for OpenShift.

## Building the s2i images ##

The easiest way to build the s2i images is to use the makefiles provided:

    # To build all images
    $ make

    # To build images individually
    $ make -f Makefile.pyspark
    $ make -f Makefile.java
    $ make -f Makefile.scala

The default repository for the image can be set with the `LOCAL_IMAGE` var:

    $ LOCAL_IMAGE=myimage make -f Makefile.pyspark

## Remaking Docker context directories when things change

The Docker context directories are generated with the dogen tool and contain
the Docker files and artifacts needed to build the images. They are:

    * pyspark-build
    * java-build
    * scala-build

If the yaml files used by dogen change (ie image.pyspark.yaml) or the scripts
included in an image change, the Docker context directory can be regenerated this way:

    $ make -f Makefile.pyspark clean-context context

To regenerate the Docker context directory and build the image in one command:

    $ make -f Makefile.pyspark clean build

## Git pre-commit hook

The `hooks/pre-commit` hook can be installed in a local repo to
prevent commits with non-zero length tarballs in the image build
directories or to warn when changes have been made to yaml files or
scripts but the image build directories have not changed.
To install the hook locally do something like this:

    $ cd .git/hooks
    $ ln -s ../../hooks/pre-commit pre-commit

This is recommended, since the CI tests will reject a pull request
with non-zero length tarballs anyway. Save some time, install the hook.

## Using `release-templates.sh` ##

The templates included in this repository always reference the latest
[s2i images](https://hub.docker.com/u/radanalyticsio/). Those images may
change during the normal course of development.

The `release-templates.sh` script can be used to create local versions of
the templates that reference s2i images from a particular oshinko release.
You may want to use this script to guarantee that you are using a stable image.
For example:

    $ ./release-templates.sh v0.2.5

    Successfully wrote templates to release_templates/ with version tag v0.2.5

    grep radanalyticsio/radanalytics-.*spark:v0.2.5 *

    release_templates/javabuilddc.json:            "name": "radanalyticsio/radanalytics-java-spark:v0.2.5"
    release_templates/javabuild.json:              "name": "radanalyticsio/radanalytics-java-spark:v0.2.5"
    release_templates/pysparkbuilddc.json:         "name": "radanalyticsio/radanalytics-pyspark:v0.2.5"
    release_templates/pysparkbuild.json:           "name": "radanalyticsio/radanalytics-pyspark:v0.2.5"
    release_templates/scalabuilddc.json:           "name": "radanalyticsio/radanalytics-scala-spark:v0.2.5"
    release_templates/scalabuild.json:             "name": "radanalyticsio/radanalytics-scala-spark:v0.2.5"

    $ oc create -f release_templates/pysparkbuilddc.json

