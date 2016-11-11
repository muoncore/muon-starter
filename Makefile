
run: docker-run

.PHONY: all

stop: docker-stop
clean: docker-stop
	docker-compose down

build: docker

# Docker control
docker: init
	docker-compose build --no-cache
	docker-compose pull

docker-run: init
	docker-compose up -d rabbitmq
	sleep 8
	docker-compose up -d

init:
	-docker network create muon

docker-stop:
	docker-compose stop

redeploy: build docker docker-run

dockerclean:
	docker-compose down
	docker-compose rm -f --all
	docker-compose pull
