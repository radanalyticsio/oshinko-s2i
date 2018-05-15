#!/bin/bash

# Regenerate all the build directories based on image.*.yaml
make clean-context
make context
make zero-tarballs

# Since scala has some deps that java and pyspark don't
# make sure they aren't in the py/java build directories.
# They shouldn't be, based on make order, but make sure.
rm -f pyspark-build/sbt-*.tgz
rm -f pyspark-build/scala-*.tgz
rm -f pyspark-py36-build/sbt-*.tgz
rm -f pyspark-py36-build/scala-*.tgz
rm -f java-build/sbt-*.tgz
rm -f java-build/scala-*.tgz

# Add any changes for a commit
git add pyspark-build
git add pyspark-py36-build
git add java-build
git add scala-build

