# radanalytics-java-spark
FROM fabric8/s2i-java

MAINTAINER Trevor McKay tmckay@redhat.com
 
ENV RADANALYTICS_JAVA_SPARK 1.0

LABEL io.k8s.description="Platform for building a radanalytics java spark app" \
      io.k8s.display-name="radanalytics java_spark" \
      io.openshift.expose-services="8080:http" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.tags="builder,radanalytics,java_spark"

USER root

RUN yum install -y epel-release tar java && \
    yum clean all

RUN cd /opt && \
    curl https://dist.apache.org/repos/dist/release/spark/spark-2.1.0/spark-2.1.0-bin-hadoop2.7.tgz | \
        tar -zx && \
    ln -s spark-2.1.0-bin-hadoop2.7 spark

RUN yum install -y golang make nss_wrapper git gcc \
    yum clean all

ENV GOPATH /go
ADD . /go/src/github.com/radanalyticsio/oshinko-s2i

ENV APP_ROOT /opt/app-root

RUN mkdir -p $APP_ROOT/src && mkdir $APP_ROOT/etc && \
    cd /go/src/github.com/radanalyticsio/oshinko-s2i/java && \
    make utils && \
    cp utils/* $APP_ROOT/src && \
    cp generate_container_user $APP_ROOT/etc && \
    chown -R 1001:0 $APP_ROOT && \
    chmod a+rwX -R $APP_ROOT && \
    cp s2i/bin/* /usr/local/s2i && \
    chown -R 1001:0 /opt/spark/conf && \
    chmod g+rw -R /opt/spark/conf && \
    rm -rf /go/src/github.com/radanalyticsio/oshinko-s2i/common/oshinko-cli

ENV PATH=$PATH:/opt/spark/bin
ENV SPARK_HOME=/opt/spark

USER 1001
CMD /usr/local/s2i/usage
