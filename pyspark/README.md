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

## sample template ##

The pyspark.json template is an example of how to use this
builder image in a template which can be launched from the
openshift console.

## s2i bin files ##

Do not forget to look in `./.s2i/bin`. This is where the
s2i assemble and run scripts are located (save-artifacts is
present but unused).
