IMAGE_NAME = project/daikon-pyspark

.PHONY: build clean push test

build: utils
	sudo docker build -t daikon-pyspark .

clean:
	sudo docker rmi daikon-pyspark
	rm -rf utils

push: build
	sudo docker tag -f daikon-pyspark $(IMAGE_NAME)
	sudo docker push $(IMAGE_NAME)

utils:
	cd ../common && make build
	cp -r ../common/utils .

test:
	docker build -t $(IMAGE_NAME)-candidate .
	IMAGE_NAME=$(IMAGE_NAME)-candidate test/run
