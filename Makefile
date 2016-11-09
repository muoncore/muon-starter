
run: docker-run

NPMCORGIS := sendgrid notifications user-list scan-list ui scheduler
CLJCORGIS := scanner
.PHONY: all test $(NPMCORGIS) $(CLJCORGIS)

$(NPMCORGIS):
	$(MAKE) -C $@

$(CLJCORGIS):
	$(MAKE) -C $@

stop: docker-stop
clean: docker-stop
	docker-compose down

test: build docker-run test-smoke test-events

build: $(NPMCORGIS) $(CLJCORGIS) docker
	$(MAKE) -C test

# Local test commands

test-smoke:
	cd test/ && npm run smoke

test-events:
	cd test/ && npm run event

# Docker control

docker:
	docker-compose build --no-cache

docker-test: init build docker docker-run
	-docker-compose run test
	docker-compose down

molecule:
	docker-compose up -d rabbitmq
	sleep 8
	docker-compose up -d photon
	docker-compose up -d molecule-ui

docker-run: docker-starter
	docker-compose up -d rabbitmq
	sleep 8
	docker-compose up -d ui

docker-starter:
	docker-compose up -d rabbitmq
	sleep 8
	docker-compose up -d photon
	sleep 8

docker-stop:
	docker-compose stop

init:
	rm -rf test-results
	mkdir -p test-results

redeploy: build dockerclean docker docker-run

dockerclean:
	docker-compose down
	docker-compose rm -f --all
	-./cleancontainers.sh
