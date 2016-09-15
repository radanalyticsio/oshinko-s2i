# radanalytics_pyspark #

This is a builder image for a pyspark application. It is
meant to be used in an openshift project which contains
an oshinko rest controller.

The base image specified in the Dockerfile is expected
to be a python2.7 s2i image with openshift-spark installed.

The final image will have spark installed along with user
specified pyspark source, a startup script and associated
utilities to create a cluster and launch the application.
See `../common/README.md` for details on the startup script
that this image uses.

## producing a build image ##

To produce a builder image:

    $ make build

To print usage information for the builder image:

    $ sudo docker run -t <id from the make>

To poke around inside the builder image:

    $ sudo docker run -i -t <id from the make>
    bash-4.2$ cd /opt/app-root # take a look around

To tag and push a builder image:

    $ sudo make push

By default this will tag the image as `project/radanalytics-pyspark`,
edit the Makefile and change `PUSH_IMAGE` to control this.

## sample templates ##

There are a number of templates here that can be used
as is or as examples for launching pyspark applications
with this builder image:

* pysparkbuild.json creates a buildconfig and imagestream with user source
* pysparkjob.json creates a job using an existing imagestream
* pysparkdc.json creates a deploymentconfig using an existing imagestream
* pysparkbuilddc.json creates a buildconfig, imagestream, and deploymentconfig with user source

To upload any of these templates to the current project so that
they can be accessed from the Openshift console:

    $ oc create -f <filename>

To launch a template from the oc commandline, process the template with
required and optional parameters specified and then pipe to create.
Examine the template to see the parameter list. For example:

    $ oc process -f pysparkdconly.json -v IMAGE=mypysparkimage,APPLICATION_NAME=myapp,APP_ARGS="these are args" | oc create -f -

## note on webhook secrets in sample templates ##

The buildconfigs in the sample templates set up github and generic webhook
triggers so that builds can be started when new source is pushed (github) or based
on some other criteria (generic). For reference, a github webhook trigger in
JSON looks like this:

    {
        "type": "GitHub",
        "github": {
            "secret": "mysecretvalue"
        }
    },


The webhooks require that a secret value be specified which becomes part of the
URL used in the trigger. The purpose of the secret value is to ensure uniqueness
in the URL to prevent others from triggering the build. Since the standard URL
used by OpenShift includes the namespace name and buildconfig name, these sample
templates simply reuse the ${APPLICATION_NAME} value as the secret.

To change this behavior, simply edit the pysparkbuild.json and/or the
pysparkbuilddc.json and set the webook secret values to some other string value.
To eliminate webhook triggers completely, simply remove the webhook trigger
sections completely.

See the OpenShift documentation for more information on
webhook triggers.

## s2i bin files ##

Do not forget to look in `./s2i/bin`. This is where the
s2i run and usage scripts are located. The other s2i
scripts are inherited from the python2.7 s2i base image.
