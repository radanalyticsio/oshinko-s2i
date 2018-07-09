allimgs =  Makefile.pyspark Makefile.pyspark-py36 Makefile.java Makefile.scala

# Set the S2I_TEST_IMAGE_XXX env vars so that the
# build of the local images and the tests use the
# same image name when running the test targets
S2I_TEST_IMAGE_PREFIX ?= s2i-testimage
S2I_TEST_IMAGE_PYSPARK ?= $(S2I_TEST_IMAGE_PREFIX)-pyspark
S2I_TEST_IMAGE_PYSPARK_PY36 ?= $(S2I_TEST_IMAGE_PREFIX)-pyspark-py36
S2I_TEST_IMAGE_JAVA ?= $(S2I_TEST_IMAGE_PREFIX)-java
S2I_TEST_IMAGE_SCALA ?= $(S2I_TEST_IMAGE_PREFIX)-scala
export S2I_TEST_IMAGE_PYSPARK
export S2I_TEST_IMAGE_PYSPARK_PY36
export S2I_TEST_IMAGE_JAVA
export S2I_TEST_IMAGE_SCALA

build: CMD=build
push: CMD=push
clean: CMD=clean
context: CMD=context
clean-context: CMD=clean-context
zero-tarballs: CMD=zero-tarballs

build: $(allimgs)
clean: $(allimgs)
push: $(allimgs)
context: $(allimgs)
clean-context: $(allimgs)
zero-tarballs: $(allimgs)

$(allimgs):
	${MAKE} -f $@ $(CMD)

# If you want to use the test targets to run tests against
# a full OpenShift instance, make sure that you set the
# S2I_TEST_INTEGRATED_REGISTRY env var before running.
# Otherwise the test will assume an OpenShift instance created
# with 'oc cluster up'
test-ephemeral:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	test/e2e/run.sh "(ephemeral|incomplete)"

test-java-templates:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	test/e2e/run.sh templates/java

test-java-radio:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	test/e2e/run.sh templates/java/radio

test-pyspark-templates:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	test/e2e/run.sh templates/pyspark-py27

test-pyspark-radio:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	test/e2e/run.sh templates/pyspark-py27/radio

test-pyspark-py36-templates:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK_PY36) make -f Makefile.pyspark-py36 build
	test/e2e/run.sh templates/pyspark-py36

test-scala-templates:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	test/e2e/run.sh templates/scala

test-scala-radio:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	test/e2e/run.sh templates/scala/radio

test-scala-dc:
	# pick up build and builddc tests along with dc
	# separate this from radio for travis sake (try to get time below 50 minutes)
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	test/e2e/run.sh "(templates/scala/build|templates/scala/dc)"

test-templates:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	test/e2e/run.sh templates

test-operations:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	test/e2e/run.sh operations

test-incomplete:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	test/e2e/run.sh incomplete

test-e2e:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	test/e2e/run.sh

.PHONY: build clean push $(allimgs) test-e2e test-ephemeral test-java-templates test-pyspark-templates test-pyspark-py36-templates test-scala-templates test-templates test-pyspark-radio test-scala-radio test-java-radio
