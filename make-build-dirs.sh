#!/bin/bash

# Regenerate all the build directories based on image.*.yaml
make clean-context
make context
make zero-tarballs

# Add any changes for a commit
git add pyspark-build
git add pyspark-py36-build
git add java-build
git add scala-build
git add sparklyr-build

