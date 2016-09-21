# radanalytics-pyspark
FROM centos/python-27-centos7:latest

MAINTAINER Trevor McKay tmckay@redhat.com
 
ENV RADANALYTICS_PYSPARK 1.0

LABEL io.k8s.description="Platform for building a radanalytics pyspark app" \
      io.k8s.display-name="radanalytics pyspark" \
      io.openshift.expose-services="8080:http" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.openshift.tags="builder,radanalytics,pyspark"

USER root
RUN yum install -y tar java && \
    yum clean all

RUN cd /opt && \
    curl https://dist.apache.org/repos/dist/release/spark/spark-2.0.0/spark-2.0.0-bin-hadoop2.7.tgz | \
        tar -zx && \
    ln -s spark-2.0.0-bin-hadoop2.7 spark

ENV PATH=$PATH:/opt/spark/bin
ENV SPARK_HOME=/opt/spark

# Default python file to run will be app.py but that may be
# overridden at image build time
ENV APP_ROOT /opt/app-root
ENV APP_FILE app.py

COPY ./utils/ $APP_ROOT/src
RUN chown -R 1001:0 $APP_ROOT/src/*

COPY ./s2i/bin/ $STI_SCRIPTS_PATH

USER 1001
CMD $STI_SCRIPTS_PATH/usage
