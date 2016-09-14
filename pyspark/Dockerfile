# radanalytics-pyspark

# The base image used here is expected to contain
# a spark installation and a python2.7 s2i assemble script
# (see https://github.com/sclorg/s2i-python-container)
FROM openshift-spark-py27-s2i

MAINTAINER Trevor McKay tmckay@redhat.com
 
ENV RADANALYTICS_PYSPARK 1.0

LABEL io.k8s.description="Platform for building a radanalytics pyspark app" \
      io.k8s.display-name="radanalytics pyspark" \
      io.openshift.expose-services="8080:http" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.openshift.tags="builder,radanalytics,pyspark"

ENV APP_ROOT /opt/app-root

# Default python file to run will be app.py but that may be
# overridden at image build time
ENV APP_FILE app.py

USER root
COPY ./utils/ $APP_ROOT/src
RUN chown -R 1001:0 $APP_ROOT/src/*

COPY ./s2i/bin/ $STI_SCRIPTS_PATH

USER 1001
CMD $STI_SCRIPTS_PATH/usage
