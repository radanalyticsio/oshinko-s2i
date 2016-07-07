# s2i-test
FROM centos:latest

MAINTAINER Trevor McKay tmckay@redhat.com
 
ENV DAIKON_PYSPARK 1.0

LABEL io.k8s.description="Platform for building a daikon pyspark app" \
      io.k8s.display-name="daikon pyspark" \
      io.openshift.expose-services="8080:http" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.openshift.tags="builder,daikon,pyspark"

#############
# This is a duplicate of what the base openshift spark 2 image does
# When we have a well-known docker registry location for the spark
# image we can change the base image and remove these instructions

RUN yum install -y epel-release tar java && \
    yum clean all

RUN cd /opt && \
    curl https://dist.apache.org/repos/dist/release/spark/spark-2.0.0-preview/spark-2.0.0-preview-bin-hadoop2.7.tgz | \
        tar -zx && \
    ln -s spark-2.0.0-preview-bin-hadoop2.7 spark

# SPARK_WORKER_DIR defaults to SPARK_HOME/work and is created on
# Worker startup if it does not exist. instead of making SPARK_HOME
# world writable, create SPARK_HOME/work.
RUN mkdir /opt/spark/work && chmod a+rwx /opt/spark/work

# when the containers are not run w/ uid 0, the uid may not map in
# /etc/passwd and it may not be possible to modify things like
# /etc/hosts. nss_wrapper provides an LD_PRELOAD way to modify passwd
# and hosts.
RUN yum install -y nss_wrapper && yum clean all
ENV LD_PRELOAD=libnss_wrapper.so
ENV PATH $PATH:/opt/spark/bin

##############

ENV APP_ROOT=/opt/app-root
COPY ./utils/ $APP_ROOT

COPY ./.s2i/bin/ /usr/libexec/s2i

RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
