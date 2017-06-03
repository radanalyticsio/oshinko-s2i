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
    curl https://archive.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-hadoop2.7.tgz | \
        tar -zx && \
    ln -s spark-2.1.0-bin-hadoop2.7 spark

RUN yum install -y golang && yum clean all

ADD . /go/src/github.com/radanalyticsio/oshinko-s2i
ADD ./common/spark-conf/* /opt/spark/conf/
ADD ./common/generate_container_user /opt/app-root/etc/

RUN cp /go/src/github.com/radanalyticsio/oshinko-s2i/pyspark/s2i/bin/* $STI_SCRIPTS_PATH && \
    chmod -R g+rw /opt/spark/conf && \
    chmod g+r /opt/app-root/etc/generate_container_user && \
    chown -R 1001:0 /opt/spark/conf && \
    chown -R 1001:0 /go/src/github.com/radanalyticsio

# Default python file to run will be app.py but that may be
# overridden at image build time
ENV GOPATH /go
ENV APP_ROOT /opt/app-root
ENV APP_FILE app.py
ENV PATH=$PATH:/opt/spark/bin
ENV SPARK_HOME=/opt/spark

USER 1001
RUN cd /go/src/github.com/radanalyticsio/oshinko-s2i/pyspark && \
    make utils && \
    cp -rp utils/* $APP_ROOT/src && \
    rm -rf /go/src/github.com/radanalyticsio/oshinko-s2i

RUN source /opt/app-root/etc/scl_enable && pip install numpy

CMD $STI_SCRIPTS_PATH/usage
