#!/bin/bash

# Regenerate all the build directories based on image.*.yaml
make clean-target
make clean-context
make context
make zero-tarballs

# Add any changes for a commit
git add pyspark-build
git add java-build
git add scala-build
git add pyspark-build-inc
git add java-build-inc
git add scala-build-inc
