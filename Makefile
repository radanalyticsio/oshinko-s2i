alldirs = common pyspark java scala
pushdirs = pyspark java scala

build: CMD=build
push: CMD=push
clean: CMD=clean

build: $(alldirs)
clean: $(alldirs)
push: $(pushdirs)

$(alldirs):
	cd $@; ${MAKE} $(CMD)

.PHONY: build clean push $(alldirs)
