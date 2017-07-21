alldirs =  pyspark java scala
pushdirs = pyspark java scala

# Set the S2I_TEST_IMAGE env var so that the
# build of the pyspark s2i image and the
# tests use the same image name when running
# the test-cmd target
S2I_TEST_IMAGE ?= pyspark-s2i-testimage
export S2I_TEST_IMAGE

build: CMD=build
push: CMD=push
clean: CMD=clean

build: $(alldirs)
clean: $(alldirs)
push: $(pushdirs)

$(alldirs):
	cd $@; ${MAKE} $(CMD)

# If you want to use the test-cmd target to run tests against
# a full OpenShift instance, make sure that you set the
# REGISTRY env var before running 'make test-cmd'.
# Otherwise the test will assume an OpenShift instance created
# with 'oc cluster up'
test-e2e: 
	cd pyspark; LOCAL_IMAGE=$(S2I_TEST_IMAGE) make build
	test/e2e/run.sh

.PHONY: build clean push $(alldirs) test-cmd
