# radanalyticsio/radanalytics-java-spark

## Description




## Environment variables

### Informational

These environment variables are defined in the image.

__APP_LANG__
>"java"

__APP_ROOT__
>"/opt/app-root"

__JBOSS_IMAGE_NAME__
>"radanalyticsio/radanalytics-java-spark"

__JBOSS_IMAGE_VERSION__
>"1.0"

__PATH__
>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin"

__RADANALYTICS_JAVA_SPARK__
>"1.0"

__SPARK_HOME__
>"/opt/spark"

__SPARK_INSTALL__
>"/opt/spark-distro"

__SPARK_VERSION__
>"2.4.5"

__STI_SCRIPTS_PATH__
>"/usr/local/s2i"


### Configuration

The image can be configured by defining these environment variables
when starting a container:



## Labels

__io.cekit.version__
> 2.2.7

__io.k8s.description__
> Platform for building a radanalytics java spark app

__io.k8s.display-name__
> radanalytics java_spark

__io.openshift.expose-services__
> 8080:http

__io.openshift.s2i.scripts-url__
> image:///usr/local/s2i

__io.openshift.tags__
> builder,radanalytics,java_spark

__io.radanalytics.sparkdistro__
> https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz

__name__
> radanalyticsio/radanalytics-java-spark

__org.concrt.version__
> 2.2.7

__version__
> 1.0


