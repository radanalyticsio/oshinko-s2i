build: CMD=build
clean: CMD=clean

.PHONY: oshinko-clix process-driver-config

export GOPATH = $(CURDIR)/oshinko-cli
clonepath = $(CURDIR)/oshinko-cli/src/github.com/radanalyticsio
makepath = $(clonepath)/oshinko-cli

# At this point utils is a simple directory which is copied
# by other components, so handle it here rather than give it
# a Makefile which we would want to exclude on a copy

build: oshinko-clix process-driver-config
	cp $(makepath)/_output/oshinko-clix utils
	cp process-driver-config/process-driver-config utils

clean: 
	rm -f utils/oshinko-clix
	rm -f utils/process-driver-config
	rm -rf $(clonepath)

oshinko-clix:
	- mkdir -p $(clonepath)
	- cd $(clonepath) && git clone https://github.com/radanalyticsio/oshinko-cli
	cd $(makepath) && make build-extended

process-driver-config:
	unset GOPATH
	cd process-driver-config && go build
