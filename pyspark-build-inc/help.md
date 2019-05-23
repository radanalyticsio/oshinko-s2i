# radanalyticsio/radanalytics-pyspark

## Description




## Environment variables

### Informational

These environment variables are defined in the image.

__APP_LANG__
>"python"

__APP_ROOT__
>"/opt/app-root"

__JBOSS_IMAGE_NAME__
>"radanalyticsio/radanalytics-pyspark"

__JBOSS_IMAGE_VERSION__
>"1.0"

__PATH__
>"/opt/app-root/src/.local/bin/:/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin"

__PYTHONPATH__
>"/opt/spark/python"

__RADANALYTICS_PYSPARK__
>"1.0"

__SPARK_HOME__
>"/opt/spark"

__SPARK_INSTALL__
>"/opt/spark-distro"


### Configuration

The image can be configured by defining these environment variables
when starting a container:



## Labels

__io.cekit.version__
> 2.2.7

__io.k8s.description__
> Platform for building a radanalytics Python 2.7 pyspark app

__io.k8s.display-name__
> radanalytics pyspark

__io.openshift.expose-services__
> 8080:http

__io.openshift.s2i.scripts-url__
> image:///usr/libexec/s2i

__io.openshift.tags__
> builder,radanalytics,pyspark

__name__
> radanalyticsio/radanalytics-pyspark

__org.concrt.version__
> 2.2.7

__version__
> 1.0


