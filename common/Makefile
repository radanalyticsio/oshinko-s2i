build: CMD=build
clean: CMD=clean

.PHONY: oshinko-cli

export GOPATH = $(CURDIR)/oshinko-cli
clonepath = $(CURDIR)/oshinko-cli/src/github.com/radanalyticsio
makepath = $(clonepath)/oshinko-cli

# At this point utils is a simple directory which is copied
# by other components, so handle it here rather than give it
# a Makefile which we would want to exclude on a copy

build: oshinko-cli
	cp $(makepath)/_output/oshinko-cli utils

clean: 
	rm -f utils/oshinko-cli
	rm -rf $(clonepath)

oshinko-cli:
	- mkdir -p $(clonepath)
	- cd $(clonepath) && git clone https://github.com/radanalyticsio/oshinko-cli
	cd $(makepath) && make build

.PHONY: oshinko-get-cluster
