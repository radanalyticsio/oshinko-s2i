build:
	tools/build.sh build

clean:
	rm -rf _output

install:
	tools/build.sh install

test:
	tools/build.sh test

# INFO(elmiko) commenting these out for the time being as we have done
# custom hacks to the Godep.json and vendor directory in order to build
# properly against openshift. 05-26-2016
deps:
	export GO15VENDOREXPERIMENT=1 ; godep save ./...
