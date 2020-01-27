# radanalytics-scala-spark

## Description




## Environment variables

### Informational

These environment variables are defined in the image.

__APP_LANG__
>"scala"

__APP_ROOT__
>"/opt/app-root"

__JBOSS_IMAGE_NAME__
>"radanalytics-scala-spark"

__JBOSS_IMAGE_VERSION__
>"1.0"

__PATH__
>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin:/opt/scala/bin:/opt/sbt/bin"

__SBT_OPTS__
>"-Dsbt.global.base=/tmp/.sbt/0.13 -Dsbt.ivy.home=/tmp/.ivy2 -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled"

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
> Platform for building a radanalytics Scala Spark app

__io.k8s.display-name__
> radanalytics scala_spark

__io.openshift.expose-services__
> 8080:http

__io.openshift.s2i.scripts-url__
> image:///usr/libexec/s2i

__io.openshift.tags__
> builder,radanalytics,scala_spark

__io.radanalytics.sparkdistro__
> https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz

__name__
> radanalytics-scala-spark

__org.concrt.version__
> 2.2.7

__version__
> 1.0


