allimgs =  Makefile.pyspark Makefile.pyspark-py36 Makefile.java Makefile.scala Makefile.sparklyr Makefile.pyspark-inc Makefile.pyspark-py36-inc Makefile.java-inc Makefile.scala-inc Makefile.sparklyr-inc

# Set the S2I_TEST_IMAGE_XXX env vars so that the
# build of the local images and the tests use the
# same image name when running the test targets
S2I_TEST_IMAGE_PREFIX ?= s2i-testimage
S2I_TEST_IMAGE_PYSPARK ?= $(S2I_TEST_IMAGE_PREFIX)-pyspark
S2I_TEST_IMAGE_PYSPARK_PY36 ?= $(S2I_TEST_IMAGE_PREFIX)-pyspark-py36
S2I_TEST_IMAGE_JAVA ?= $(S2I_TEST_IMAGE_PREFIX)-java
S2I_TEST_IMAGE_SCALA ?= $(S2I_TEST_IMAGE_PREFIX)-scala
S2I_TEST_IMAGE_SPARKLYR ?= $(S2I_TEST_IMAGE_PREFIX)-sparklyr
S2I_TEST_IMAGE_PYSPARK_INC ?= $(S2I_TEST_IMAGE_PREFIX)-pyspark-inc
S2I_TEST_IMAGE_PYSPARK_PY36_INC ?= $(S2I_TEST_IMAGE_PREFIX)-pyspark-py36-inc
S2I_TEST_IMAGE_JAVA_INC ?= $(S2I_TEST_IMAGE_PREFIX)-java-inc
S2I_TEST_IMAGE_SCALA_INC ?= $(S2I_TEST_IMAGE_PREFIX)-scala-inc
S2I_TEST_IMAGE_SPARKLYR_INC ?= $(S2I_TEST_IMAGE_PREFIX)-sparklyr-inc
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

test-sparklyr-dc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SPARKLYR) make -f Makefile.sparklyr build
	test/e2e/run.sh templates/sparklyr/dc/

test-sparklyr-build:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SPARKLYR) make -f Makefile.sparklyr build
	test/e2e/run.sh templates/sparklyr/build/

test-sparklyr-builddc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SPARKLYR) make -f Makefile.sparklyr build
	test/e2e/run.sh templates/sparklyr/builddc/

test-templates:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SPARKLYR) make -f Makefile.sparklyr build
	test/e2e/run.sh templates

test-operations:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	test/e2e/run.sh operations

test-incomplete:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	test/e2e/run.sh incomplete/

test-pyspark-inc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK_INC) make -f Makefile.pyspark-inc build
	test/e2e/run.sh incomplete_image/pyspark-py27/

test-pyspark-py36-inc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK_PY36_INC) make -f Makefile.pyspark-py36-inc build
	test/e2e/run.sh incomplete_image/pyspark-py36/

test-java-inc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA_INC) make -f Makefile.java-inc build
	test/e2e/run.sh incomplete_image/java/

test-scala-inc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA_INC) make -f Makefile.scala-inc build
	test/e2e/run.sh incomplete_image/scala/

test-sparklyr-inc:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SPARKLYR_INC) make -f Makefile.sparklyr-inc build
	test/e2e/run.sh incomplete_image/sparklyr/

test-e2e:
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make -f Makefile.pyspark build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make -f Makefile.java build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make -f Makefile.scala build
	LOCAL_IMAGE=$(S2I_TEST_IMAGE_SPARKLYR) make -f Makefile.sparklyr build
	test/e2e/run.sh

.PHONY: build clean clean-target push $(allimgs) test-e2e test-ephemeral test-java-templates test-pyspark-templates test-pyspark-py36-templates test-scala-templates test-templates test-pyspark-radio test-scala-radio test-java-radio
