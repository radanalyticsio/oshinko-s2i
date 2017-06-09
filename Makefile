alldirs =  pyspark java scala
pushdirs = pyspark java scala

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

test-cmd: 
	cd pyspark; LOCAL_IMAGE=$(S2I_TEST_IMAGE) make build
	test/cmd/ephemeral/ephemeral.sh $$REGISTRY

.PHONY: build clean push $(alldirs) test-cmd
