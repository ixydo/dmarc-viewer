.PHONY: build
build:
	docker-compose build --force-rm --pull

stop:
	docker-compose stop

clean:
	docker-compose rm

run:
	docker-compose up -d
