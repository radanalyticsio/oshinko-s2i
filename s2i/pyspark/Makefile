IMAGE_NAME = daikon-pyspark

utils/oshinko-get-cluster:
	cd ../../oshinko-get-cluster && make build
	cp ../../oshinko-get-cluster/_output/oshinko-get-cluster utils/oshinko-get-cluster
        
build: utils/oshinko-get-cluster
	sudo docker build -t $(IMAGE_NAME) .

.PHONY: test
test:
	docker build -t $(IMAGE_NAME)-candidate .
	IMAGE_NAME=$(IMAGE_NAME)-candidate test/run
