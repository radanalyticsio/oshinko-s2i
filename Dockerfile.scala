# radanalytics-scala-spark
FROM radanalyticsio/openshift-spark

MAINTAINER Pete MacKinnon pmackinn@redhat.com
 
ENV RADANALYTICS_SCALA_SPARK 1.0

LABEL io.k8s.description="Platform for building a radanalytics Scala Spark app" \
      io.k8s.display-name="radanalytics scala_spark" \
      io.openshift.expose-services="8080:http" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.tags="builder,radanalytics,scala_spark"

USER root

RUN yum install -y epel-release tar java && \
    yum clean all

RUN cd /opt && \
    curl -L http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz  | \
        tar -zx && \
    ln -s scala-2.11.8 scala

RUN cd /opt && \
    curl -L https://dl.bintray.com/sbt/native-packages/sbt/0.13.13/sbt-0.13.13.tgz  | \
        tar -zx && \
    ln -s sbt-launcher-packaging-0.13.13 sbt

ENV SBT_OPTS "-Dsbt.global.base=/tmp/.sbt -Dsbt.ivy.home=/tmp/.ivy2 -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled"

RUN /opt/sbt/bin/sbt

RUN yum install -y golang make nss_wrapper git gcc \
    yum clean all

ENV GOPATH /go
ADD . /go/src/github.com/radanalyticsio/oshinko-s2i
ADD ./common/generate_container_user /opt/app-root/etc/

ENV APP_ROOT /opt/app-root

RUN mkdir -p /usr/local/s2i && \
    mkdir -p $APP_ROOT/src && \
    cd /go/src/github.com/radanalyticsio/oshinko-s2i/scala && \
    make utils && \
    cp utils/* $APP_ROOT/src && \
    cp s2i/bin/* /usr/local/s2i && \
    chmod a+x /usr/local/s2i/* && \
    chown -R 1001:0 $APP_ROOT && \
    chmod a+rwX -R $APP_ROOT && \
    chown -R 1001:0 /opt/spark/conf && \
    chmod g+rw -R /opt/spark/conf && \
    chown -R 1001:0 /opt/sbt/conf && \
    chmod g+rw -R /opt/sbt/conf && \
    chown -R 1001:0 /tmp/.ivy2 && \
    chmod g+rw -R /tmp/.ivy2 && \
    chown -R 1001:0 /tmp/.sbt && \
    chmod g+rw -R /tmp/.sbt && \
    rm -rf /go/src/github.com/radanalyticsio/oshinko-s2i/common/oshinko-cli

ENV PATH=$PATH:/opt/spark/bin:/opt/scala/bin:/opt/sbt/bin
ENV SPARK_HOME=/opt/spark

USER 1001
CMD /usr/local/s2i/usage
