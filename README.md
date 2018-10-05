[![Build Status](https://travis-ci.org/radanalyticsio/oshinko-s2i.svg?branch=master)](https://travis-ci.org/radanalyticsio/oshinko-s2i)
[![Docker python build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-pyspark.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-pyspark)
[![Docker python 3.6 build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-pyspark-py36.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-pyspark-py36)
[![Docker java build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-java-spark.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-java-spark)
[![Docker scala build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-scala-spark.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-scala-spark)

# todo

* add badges for inc files?
* need to add how to use get-rad-image, rad-image and resources-is.yaml, templates-is.sh
    * refer to the landing site howdoi?

# oshinko-s2i #
This is a place to put s2i images and utilities for Apache Spark application builders for OpenShift.

## Complete versus incomplete images ##

There are two types of images that can be built from this repository, `complete` and `incomplete`

Complete images include a pre-selected Apache Spark distribution that is installed when the
image is built.

Incomplete images contain radanalytics.io tooling but do not include a Spark distribution. With these
images, users can perform s2i builds and produce images with Spark distributions of
their choosing. This document includes information on how to use the incomplete images.

## Building the s2i images ##

The easiest way to build the s2i images is to use the makefiles provided:

    # To build all images
    $ make

    # To build images individually
    $ make -f Makefile.pyspark
    $ make -f Makefile.pyspark-py36
    $ make -f Makefile.java
    $ make -f Makefile.scala
    $ make -f Makefile.sparklyr
    $ make -f Makefile.pyspark-inc
    $ make -f Makefile.pyspark-py36-inc
    $ make -f Makefile.java-inc
    $ make -f Makefile.scala-inc
    $ make -f Makefile.sparklyr-inc

The default repository for the image can be overridden with the `LOCAL_IMAGE` var:

    $ LOCAL_IMAGE=myimage make -f Makefile.pyspark

## Modifying dependencies in the image yaml files

The cekit tool generates the image context directories
based on the content of the image.*.yaml files.

A script has been provided to make altering the image.*.yaml files
simpler. It handles modifying the specified versions of oshinko and Spark.
Run this for more details

    $ change-yaml.sh -h

## Remaking image context directories when things change

The image context directories are generated with the cekit tool and contain
the artifacts needed to build the images. They are:

    * pyspark-build
    * pyspark-py36-build
    * java-build
    * scala-build
    * sparklyr-build
    * pyspark-build-inc
    * pyspark-py36-build-inc
    * java-build-inc
    * scala-build-inc
    * sparklyr-build-inc

If the yaml files used by cekit change (ie image.*.yaml) or the content
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

If the actual components specified in an image.*.yaml file have changed
as opposed to only the _contents_ of existing modules, then the `target`
directory should be cleaned before generating the context directory

    $ make clean-target

To regenerate a particular context directory, like pyspark-build, do this

    $ make -f Makefile.pyspark clean-context context

To regenerate the context directory and also build the image, do this

    $ make -f Makefile.pyspark clean build

## Using incomplete images to choose an Apache Spark distribution

[This link](https://radanalytics.io/howdoi/choose-my-spark-distribution) explains how
to use radanalytics.io with a specific Spark distribution. It's a must read if you
are not familiar with the incomplete images and how to use them.

### Getting `rad-image` with R support enabled

The version of `rad-image` from radanalytics.io has generation of the R image
disabled. Do this to download `rad-image` and enable R support

    $ ./get-rad-image.sh

### Modifying templates/* with `templates-is.sh`

In addtion to `resources-is.yaml` from radanalytics.io, the templates in this repository
can be used with the imagestreams created by `rad-image` with a few changes.
Use the `templates-is.sh` script to generate modified templates in `templates-is/`

    $ ./templates-is.sh

Run `./templates-is.sh -h` for more information

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

    $ ./release-templates.sh v0.5.6

    Successfully wrote templates to release_templates/ with version tag v0.5.6

    grep radanalyticsio/radanalytics-.*:v0.5.6 *

    release_templates/javabuilddc.json:                     "name": "radanalyticsio/radanalytics-java-spark:v0.5.6"
    release_templates/javabuild.json:                     "name": "radanalyticsio/radanalytics-java-spark:v0.5.6"
    release_templates/python36builddc.json:                     "name": "radanalyticsio/radanalytics-pyspark-py36:v0.5.6"
    release_templates/python36build.json:                     "name": "radanalyticsio/radanalytics-pyspark-py36:v0.5.6"
    release_templates/pythonbuilddc.json:                     "name": "radanalyticsio/radanalytics-pyspark:v0.5.6"
    release_templates/pythonbuild.json:                     "name": "radanalyticsio/radanalytics-pyspark:v0.5.6"
    release_templates/scalabuilddc.json:                     "name": "radanalyticsio/radanalytics-scala-spark:v0.5.6"
    release_templates/scalabuild.json:                     "name": "radanalyticsio/radanalytics-scala-spark:v0.5.6"
    release_templates/sparklyrbuilddc.json:                     "name": "radanalyticsio/radanalytics-r-spark:v0.5.6"
    release_templates/sparklyrbuild.json:                     "name": "radanalyticsio/radanalytics-r-spark:v0.5.6"

    tar -czf oshinko_s2i_v0.5.6.tar.gz release_templates

    $ oc create -f release_templates/pythonbuilddc.json

## MacOS Tips

For MacOS you will also need to download these tools: gsed and truncate.
You can install these using homebrew and these commands:

```
brew install truncate
```

```
brew install gnu-sed
```
