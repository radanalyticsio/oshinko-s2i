build: CMD=build
clean: CMD=clean

# At this point utils is a simple directory which is copied
# by other components, so handle it here rather than give it
# a Makefile which we would want to exclude on a copy

build: oshinko-get-cluster
	cp oshinko-get-cluster/_output/oshinko-get-cluster utils

clean: oshinko-get-cluster
	rm -f utils/oshinko-get-cluster

oshinko-get-cluster:
	cd $@; ${MAKE} $(CMD)

.PHONY: oshinko-get-cluster
