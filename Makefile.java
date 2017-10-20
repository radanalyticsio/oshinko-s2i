LOCAL_IMAGE ?= radanalytics-java-spark

# If you are going to push the built image to a registry
# using the "push" make target then you should replace
# "project" with an appropriate path for your registry and/or project
PUSH_IMAGE=project/radanalytics-java-spark

DOCKERFILE_CONTEXT=java-build

.PHONY: build clean push

build: $(DOCKERFILE_CONTEXT)/Dockerfile
	docker build --pull -t $(LOCAL_IMAGE) $(DOCKERFILE_CONTEXT)

clean:
	-docker rmi $(LOCAL_IMAGE) $(PUSH_IMAGE)
	-rm $(DOCKERFILE_CONTEXT)/Dockerfile

push: build
	docker tag $(LOCAL_IMAGE) $(PUSH_IMAGE)
	docker push $(PUSH_IMAGE)

$(DOCKERFILE_CONTEXT)/Dockerfile:
	docker run -it --rm -v `pwd`:/tmp jboss/dogen:latest /tmp/image.java.yaml /tmp/$(DOCKERFILE_CONTEXT)
