# radanalytics-scala-spark

## Description




## Environment variables

### Informational

These environment variables are defined in the image.

__APP_LANG__
>"scala"

__APP_ROOT__
>"/opt/app-root"

__PATH__
>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin:/opt/scala/bin:/opt/sbt/bin"

__SBT_OPTS__
>"-Dsbt.global.base=/tmp/.sbt/0.13 -Dsbt.ivy.home=/tmp/.ivy2 -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled"

__SPARK_HOME__
>"/opt/spark"


### Configuration

The image can be configured by defining these environment variables
when starting a container:



## Labels

__io.cekit.version__
> 2.1.4

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
> https://archive.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz

__org.concrt.version__
> 2.1.4


