LOCAL_IMAGE=radanalytics-pyspark

# If you are going to push the built image to a registry
# using the "push" make target then you should replace
# "project" with an appropriate path for your registry and/or project
PUSH_IMAGE=project/radanalytics-pyspark

.PHONY: build clean push test

build: utils
	sudo docker build -t $(LOCAL_IMAGE) .

clean:
	sudo docker rmi $(LOCAL_IMAGE)
	rm -rf utils

push: build
	sudo docker tag -f $(LOCAL_IMAGE) $(PUSH_IMAGE)
	sudo docker push $(PUSH_IMAGE)

utils:
	cd ../common && make build
	cp -r ../common/utils .

test:
	docker build -t $(PUSH_IMAGE)-candidate .
	IMAGE_NAME=$(PUSH_IMAGE)-candidate test/run
