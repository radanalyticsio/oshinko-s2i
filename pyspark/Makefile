IMAGE_NAME = project/radanalytics-pyspark

.PHONY: build clean push test

build: utils
	sudo docker build -t radanalytics-pyspark .

clean:
	sudo docker rmi radanalytics-pyspark
	rm -rf utils

push: build
	sudo docker tag -f radanalytics-pyspark $(IMAGE_NAME)
	sudo docker push $(IMAGE_NAME)

utils:
	cd ../common && make build
	cp -r ../common/utils .

test:
	docker build -t $(IMAGE_NAME)-candidate .
	IMAGE_NAME=$(IMAGE_NAME)-candidate test/run
