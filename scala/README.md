# Oshinko S2I Scala builder image with OpenJDK 8

This is a S2I builder image for Scala sbt builds.

The following environment variables can be used to influence the behaviour of this builder image:

## Build Time

* **SBT_ARGS** Arguments to use when calling sbt, replacing the default `package`.
* **SBT_ARGS_APPEND** Additional sbt arguments, useful for adding task arguments to sbt like `publish makePom`
* **ARTIFACT_COPY_ARGS** Arguments to use when copying artifacts from the output dir to the application dir. Useful to specify which artifacts will be part of the image. It defaults to jar files only (`*.jar`).
* **IVY_CLEAR_REPO** If set then the repository used by sbt is removed after the artifact is built. This is useful for keeping the created application image small, but prevents *incremental* builds. The default is `false`
* **USE_PROJECT_SBT** If set then the default version of sbt in the builder image will not be used and instead the build will defer to the version of sbt specified in the project (i.e., `project/build.properties`).
