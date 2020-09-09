allimgs =  Makefile.pyspark Makefile.java Makefile.scala Makefile.pyspark-inc Makefile.java-inc Makefile.scala-inc

# Set the S2I_TEST_IMAGE_XXX env vars so that the
# build of the local images and the tests use the
# same image name when running the test targets
S2I_TEST_IMAGE_PREFIX ?= s2i-testimage
S2I_TEST_IMAGE_PYSPARK ?= $(S2I_TEST_IMAGE_PREFIX)-pyspark
S2I_TEST_IMAGE_JAVA ?= $(S2I_TEST_IMAGE_PREFIX)-java
S2I_TEST_IMAGE_SCALA ?= $(S2I_TEST_IMAGE_PREFIX)-scala
S2I_TEST_IMAGE_PYSPARK_INC ?= $(S2I_TEST_IMAGE_PREFIX)-pyspark-inc
S2I_TEST_IMAGE_JAVA_INC ?= $(S2I_TEST_IMAGE_PREFIX)-java-inc
S2I_TEST_IMAGE_SCALA_INC ?= $(S2I_TEST_IMAGE_PREFIX)-scala-inc
S2I_K8S_LIMITED ?= false

export S2I_TEST_IMAGE_PYSPARK
export S2I_TEST_IMAGE_PYSPARK_PY36
export S2I_TEST_IMAGE_JAVA
export S2I_TEST_IMAGE_SCALA
export S2I_TEST_IMAGE_SPARKLYR
export S2I_TEST_IMAGE_PYSPARK_INC
export S2I_TEST_IMAGE_PYSPARK_PY36_INC
export S2I_TEST_IMAGE_JAVA_INC
export S2I_TEST_IMAGE_SCALA_INC
export S2I_TEST_IMAGE_SPARKLYR_INC
export S2I_K8S_LIMITED

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

clean-target:
	- rm -rf target

# If you want to use the test targets to run tests against
# a full OpenShift instance, make sure that you set the
# S2I_TEST_INTEGRATED_REGISTRY env var before running.
# Otherwise the test will assume an OpenShift instance created
# with 'oc cluster up'
test-ephemeral:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	test/e2e/run.sh ephemeral/

test-sparkk8s:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	test/e2e/run.sh templates/k8s

test-java-templates:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	# run dc, build, and builddc but skip radio because it requires a registry
	test/e2e/run.sh "(templates/java/builddc)"

test-java-radio:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	test/e2e/run.sh templates/java/radio

test-pyspark-templates:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	# run dc, build, and builddc but skip radio because it requires a registry
	test/e2e/run.sh "(templates/pyspark/builddc)"

test-pyspark-radio:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	test/e2e/run.sh templates/pyspark/radio

test-scala-templates:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
        # run dc, build, and builddc but skip radio because it requires a registry
	test/e2e/run.sh "(templates/scala/builddc)"

test-scala-radio:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	test/e2e/run.sh templates/scala/radio

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
	test/e2e/run.sh incomplete/

test-pyspark-inc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK_INC) make -f Makefile.pyspark-inc build
	test/e2e/run.sh incomplete_image/pyspark/

test-java-inc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA_INC) make -f Makefile.java-inc build
	test/e2e/run.sh incomplete_image/java/

test-scala-inc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA_INC) make -f Makefile.scala-inc build
	test/e2e/run.sh incomplete_image/scala/

test-e2e:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	test/e2e/run.sh

.PHONY: build clean clean-target push $(allimgs) test-e2e test-ephemeral test-java-templates test-pyspark-templates test-scala-templates test-templates test-pyspark-radio test-scala-radio test-java-radio
