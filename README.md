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

The default repository for the image can be overridden with the `LOCAL_IMAGE` var:

    $ LOCAL_IMAGE=myimage make -f Makefile.pyspark

## Modifying dependencies in the image yaml files

The concreate tool generates the image context directories
based on the content of the image.*.yaml files.

A script has been provided to make altering the image.*.yaml files
simpler. It handles modifying the specified versions of oshinko, spark,
scala, and sbt. Run this for more details

    $ change-yaml.sh -h

## Remaking image context directories when things change

The image context directories are generated with the concreate tool and contain
the artifacts needed to build the images. They are:

    * pyspark-build
    * java-build
    * scala-build

If the yaml files used by concreate change (ie image.*.yaml) or the content
included in an image changes (essentially anything under modules/), the
image context directories need to be rebuilt.

### Rebuilding context directories for an upstream pull request

If the changes being made are part of a PR to github.com/radanalyticsio/oshinko-s2i
then all of the build directories should be generated from scratch.
The best way to do this is with the make-build-dirs.sh script

    $ make-build-dirs.sh

This will recreate the context directories starting from a clean environment,
make sure any tarballs are truncated for github, and add all of the changes
to the commit.

### Rebuilding a particular context directory for testing/development

To regenerate a particular context directory, like pyspark-build, do this

    $ make -f Makefile.pyspark clean-context context

To regenerate the context directory and also build the image, do this

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

## MacOS Tips

For MacOS you will also need to download these tools: gsed and truncate.
You can install these using homebrew and these commands:

```
brew install truncate
```

```
brew install gnu-sed
```
