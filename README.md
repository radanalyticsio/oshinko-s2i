[![Build Status](https://travis-ci.org/radanalyticsio/oshinko-s2i.svg?branch=master)](https://travis-ci.org/radanalyticsio/oshinko-s2i)
[![Docker python build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-pyspark.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-pyspark)
[![Docker java build](https://img.shields.io/docker/automated/radanalyticsio/radanalytics-java-spark.svg)](https://hub.docker.com/r/radanalyticsio/radanalytics-java-spark)

# oshinko-s2i #
This is a place to put s2i images and utilities for spark application builders for openshift
Look for additional README files in the subdirectories for more detail.

Add a line to the readme to create a fake PR

## common ##

Contains:

* a startup script
* a small go program that checks for the existing of a cluster and creates it if not present,
returns the spark master url 

The components of common may be used by multiple s2i images.

## pyspark ##

Contains an s2i image for pyspark applications, uses common.

## java ##

Contains an s2i image for java spark applications, uses common.

## scala ##

Contains an s2i image for Scala Spark applications, uses common.
