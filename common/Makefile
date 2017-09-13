build: CMD=build
clean: CMD=clean

.PHONY: process-driver-config

OSHINKO_RELEASE=v0.2.6

# At this point utils is a simple directory which is copied
# by other components, so handle it here rather than give it
# a Makefile which we would want to exclude on a copy
build: oshinko_linux_amd64 process-driver-config
	cp oshinko_linux_amd64/oshinko utils
	cp process-driver-config/process-driver-config utils

clean: 
	rm -f utils/oshinko
	rm -f utils/process-driver-config
	rm -rf oshinko_linux_amd64
	rm -f oshinko_$(OSHINKO_RELEASE)_linux_amd64.tar.gz
 
oshinko_linux_amd64:
	rm -f oshinko_$(OSHINKO_RELEASE)_linux_amd64.tar.gz
	curl -L https://github.com/radanalyticsio/oshinko-cli/releases/download/$(OSHINKO_RELEASE)/oshinko_$(OSHINKO_RELEASE)_linux_amd64.tar.gz | tar -zx

process-driver-config:
	unset GOPATH
	cd process-driver-config && go build
