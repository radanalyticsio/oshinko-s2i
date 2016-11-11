# oshinko-s2i #
This is a place to put s2i images and utilities for spark application builders for openshift
Look for additional README files in the subdirectories for more detail.

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
