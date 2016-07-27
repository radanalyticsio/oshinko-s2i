# daikon_pyspark #

This is a builder image for a pyspark application. It is
meant to be used in an openshift project which contains
an oshinko rest controller.

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

    $ make push

By default this will tag the image as `project/daikon-pyspark`,
edit the Makefile and change the `IMAGE_NAME` to control this.

## sample templates ##

There are a number of templates here that can be used
as is or as examples for launching pyspark applications
with this builder image:

* pysparkbuildonly.json creates an imagestream with user source
* pysparkjob.json creates an imagestream and then launches a job
using the imagestream
* pysparkdc.json creates an imagestream and then launches a
deploymentconfig using the imagestream
* ppysparkjobonly.json launches a job using the specified image
* pysparkdconly.json launches a deploymentconfig using the
specified image

To upload any of these templates to the current project so that
they can be accessed from the Openshift console:

    $ oc create -f <filename>

To launch a template from the oc commandline, process the template with
required and optional parameters specified and then pipe to create.
Examine the template to see the parameter list. For example:

    $ oc process -f pysparkdconly.json -v IMAGE=mypysparkimage,APPLICATION_NAME=myapp,APP_ARGS="these are args" | oc create -f -

## s2i bin files ##

Do not forget to look in `./.s2i/bin`. This is where the
s2i assemble and run scripts are located (save-artifacts is
present but unused).
