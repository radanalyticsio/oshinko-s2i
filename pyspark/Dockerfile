# daikon-pyspark
FROM openshift-spark:latest

MAINTAINER Trevor McKay tmckay@redhat.com
 
ENV DAIKON_PYSPARK 1.0

LABEL io.k8s.description="Platform for building a daikon pyspark app" \
      io.k8s.display-name="daikon pyspark" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.openshift.tags="builder,daikon,pyspark"

ENV LD_PRELOAD=libnss_wrapper.so

USER root

ENV APP_ROOT=/opt/app-root
COPY ./utils/ $APP_ROOT
COPY ./.s2i/bin/ /usr/libexec/s2i
RUN chown -R 185:185 /opt/app-root

USER 185

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
