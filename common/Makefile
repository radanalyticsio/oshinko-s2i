build: CMD=build
clean: CMD=clean

OSHINKO_RELEASE=v0.3.1

# At this point utils is a simple directory which is copied
# by other components, so handle it here rather than give it
# a Makefile which we would want to exclude on a copy
build: oshinko_linux_amd64
	cp oshinko_linux_amd64/oshinko utils

clean: 
	rm -f utils/oshinko
	rm -rf oshinko_linux_amd64
	rm -f oshinko_$(OSHINKO_RELEASE)_linux_amd64.tar.gz
 
oshinko_linux_amd64:
	rm -f oshinko_$(OSHINKO_RELEASE)_linux_amd64.tar.gz
	curl -L https://github.com/radanalyticsio/oshinko-cli/releases/download/$(OSHINKO_RELEASE)/oshinko_$(OSHINKO_RELEASE)_linux_amd64.tar.gz | tar -zx
