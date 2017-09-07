[![Build Status](https://travis-ci.org/radanalyticsio/oshinko-s2i.svg?branch=master)](https://travis-ci.org/radanalyticsio/oshinko-s2i)
[![Docker python build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-pyspark.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-pyspark)
[![Docker java build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-java-spark.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-java-spark)

# oshinko-s2i #
This is a place to put s2i images and utilities for Spark application builders for OpenShift.
Look for additional README files in the subdirectories for more detail.

## common ##

Contains:

* default Spark configuration files
* an application startup script in `utils/start.sh`
* utilities used by `start.sh` (process-driver-config, generate_container_user)

The components of common may be used by multiple s2i images.

## pyspark ##

Contains an s2i image for pyspark applications and some templates, uses common.

## java ##

Contains an s2i image for java spark applications and some templates, uses common.

## scala ##

Contains an s2i image for Scala Spark applications and some templates, uses common.

## Using `release-templates.sh` ##

The templates included in this repository with each image always reference
the latest [s2i images](https://hub.docker.com/u/radanalyticsio/). Those images may
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

