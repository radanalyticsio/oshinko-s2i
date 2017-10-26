alldirs =  pyspark java scala
pushdirs = pyspark java scala

# Set the S2I_TEST_IMAGE_XXX env vars so that the
# build of the local images and the tests use the
# same image name when running the test targets
S2I_TEST_IMAGE_PREFIX ?= s2i-testimage
S2I_TEST_IMAGE_PYSPARK ?= $(S2I_TEST_IMAGE_PREFIX)-pyspark
S2I_TEST_IMAGE_JAVA ?= $(S2I_TEST_IMAGE_PREFIX)-java
S2I_TEST_IMAGE_SCALA ?= $(S2I_TEST_IMAGE_PREFIX)-scala
export S2I_TEST_IMAGE_PYSPARK
export S2I_TEST_IMAGE_JAVA
export S2I_TEST_IMAGE_SCALA

build: CMD=build
push: CMD=push
clean: CMD=clean

build: $(alldirs)
clean: $(alldirs)
push: $(pushdirs)

$(alldirs):
	cd $@; ${MAKE} $(CMD)

# If you want to use the test targets to run tests against
# a full OpenShift instance, make sure that you set the
# S2I_TEST_INTEGRATED_REGISTRY env var before running.
# Otherwise the test will assume an OpenShift instance created
# with 'oc cluster up'
test-ephemeral:
	cd pyspark; LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make build
	test/e2e/run.sh "(ephemeral|incomplete)"

test-java-templates:
	cd java; LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make build
	test/e2e/run.sh templates/java

test-java-radio:
	cd java; LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make build
	test/e2e/run.sh templates/java/radio

test-pyspark-templates:
	cd pyspark; LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make build
	test/e2e/run.sh templates/pyspark

test-pyspark-radio:
	cd pyspark; LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make build
	test/e2e/run.sh templates/pyspark/radio

test-scala-templates:
	cd scala; LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make build
	test/e2e/run.sh templates/scala

test-scala-radio:
	cd scala; LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make build
	test/e2e/run.sh templates/scala/radio

test-templates:
	cd pyspark; LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make build
	cd java; LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make build
	cd scala; LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make build
	test/e2e/run.sh templates

test-e2e:
	cd pyspark; LOCAL_IMAGE=$(S2I_TEST_IMAGE_PYSPARK) make build
	cd java; LOCAL_IMAGE=$(S2I_TEST_IMAGE_JAVA) make build
	cd scala; LOCAL_IMAGE=$(S2I_TEST_IMAGE_SCALA) make build
	test/e2e/run.sh

.PHONY: build clean push $(alldirs) test-e2e test-ephemeral test-java-templates test-pyspark-templates test-scala-templates test-templates test-pyspark-radio test-scala-radio test-java-radio
