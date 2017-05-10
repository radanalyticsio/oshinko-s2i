build: CMD=build
clean: CMD=clean

.PHONY: oshinko-cli process-driver-config

export GOPATH = $(CURDIR)/oshinko-cli
clonepath = $(CURDIR)/oshinko-cli/src/github.com/radanalyticsio
makepath = $(clonepath)/oshinko-cli

# At this point utils is a simple directory which is copied
# by other components, so handle it here rather than give it
# a Makefile which we would want to exclude on a copy

build: oshinko-cli process-driver-config
	cp $(makepath)/_output/oshinko-cli utils
	cp process-driver-config/process-driver-config utils

clean: 
	rm -f utils/oshinko-cli
	rm -f utils/process-driver-config
	rm -rf $(clonepath)

oshinko-cli:
	- mkdir -p $(clonepath)
	- cd $(clonepath) && git clone -b v0.2.1 https://github.com/radanalyticsio/oshinko-cli
	cd $(makepath) && make extended

process-driver-config:
	unset GOPATH
	cd process-driver-config && go build
