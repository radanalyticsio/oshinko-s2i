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

By default the Makefile will tag the docker image as `project/daikon-pyspark`.
Edit the Makefile to modify this behavior.

To produce a builder image:

    $ make build

Examine the resulting image, for example:

    $ sudo docker run -i -t <id from the make>
    bash-4.2$ cd /opt/app-root # take a look around

## s2i bin files ##

Do not forget to look in `./.s2i/bin`. This is where the
s2i assemble and run scripts are located (save-artifacts is
present but unused).
