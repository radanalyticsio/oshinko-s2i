LOCAL_IMAGE ?= radanalytics-java-spark

# If you are going to push the built image to a registry
# using the "push" make target then you should replace
# "project" with an appropriate path for your registry and/or project
PUSH_IMAGE=project/radanalytics-java-spark

DOCKERFILE_CONTEXT=java-build

.PHONY: build push clean clean-context context zero-tarballs

build: $(DOCKERFILE_CONTEXT)
	docker build --pull -t $(LOCAL_IMAGE) $(DOCKERFILE_CONTEXT)

push: build
	docker tag $(LOCAL_IMAGE) $(PUSH_IMAGE)
	docker push $(PUSH_IMAGE)

clean: clean-context
	-docker rmi $(LOCAL_IMAGE) $(PUSH_IMAGE)

clean-context:
	-rm -f $(DOCKERFILE_CONTEXT)/Dockerfile
	-rm -rf $(DOCKERFILE_CONTEXT)/scripts

context: $(DOCKERFILE_CONTEXT)

$(DOCKERFILE_CONTEXT): $(DOCKERFILE_CONTEXT)/Dockerfile $(DOCKERFILE_CONTEXT)/scripts

$(DOCKERFILE_CONTEXT)/Dockerfile $(DOCKERFILE_CONTEXT)/scripts:
	docker run -it --rm -v `pwd`:/tmp jboss/dogen:latest /tmp/image.java.yaml /tmp/$(DOCKERFILE_CONTEXT)

zero-tarballs:
	-truncate -s 0 $(DOCKERFILE_CONTEXT)/*.tgz
	-truncate -s 0 $(DOCKERFILE_CONTEXT)/*.tar.gz
