#!/bin/bash

# Get rid of spark url artifact and md5
sed '\@url:.*https://archive.apache.org/@,+1d' $1 > $2

# Get rid of spark distro label
sed -i '\@name:.*"io.radanalytics.sparkdistro"@,+1d' $2

# Get rid of spark module install
sed -i '\@- name: spark$@d' $2
