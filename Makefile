all: build-5.6-onbuild

build-5.6:
	docker build -t index.xxxxx.com/php:5.6-apache 5.6

build-5.6-onbuild: build-5.6
	docker build -t index.xxxxx.com/php:5.6-apache-onbuild 5.6/onbuild

publish: build-5.6-onbuild
	docker push index.xxxxx.com/php:5.6-apache
	docker push index.xxxxx.com/php:5.6-apache-onbuild
