alldirs =  pyspark java scala
pushdirs = pyspark java scala

build: CMD=build
push: CMD=push
clean: CMD=clean

build: $(alldirs)
clean: $(alldirs)
push: $(pushdirs)

$(alldirs):
	cd $@; ${MAKE} $(CMD)

test-cmd: 
	hack/test-cmd.sh

.PHONY: build clean push $(alldirs) test-cmd
