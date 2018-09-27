# radanalyticsio/radanalytics-java-spark

## Description




## Environment variables

### Informational

These environment variables are defined in the image.

__APP_LANG__
>"java"

__APP_ROOT__
>"/opt/app-root"

__PATH__
>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin"

__RADANALYTICS_JAVA_SPARK__
>"1.0"

__SPARK_HOME__
>"/opt/spark"

__SPARK_VERSION__
>"2.3.0"

__STI_SCRIPTS_PATH__
>"/usr/local/s2i"


### Configuration

The image can be configured by defining these environment variables
when starting a container:



## Labels

__io.cekit.version__
> 2.1.4

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
> https://archive.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz

__org.concrt.version__
> 2.1.4


