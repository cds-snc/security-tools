.PHONY: fmt fmt-ci install install-dev lint lint-ci test build-cq run-cloud-query

fmt:
	black .

fmt-ci:
	black --check .

install:
	pip3 install --user -r requirements.txt

install-dev:
	pip3 install --user -r requirements_dev.txt

lint:
	flake8 .

lint-ci: lint

test:
	pytest -s -vv .

build:
	docker-compose -f images/cloudquery/dev/docker-compose.yml build

up:
	export AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID); \
	export AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY); \
	export AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN); \
	docker-compose -f images/cloudquery/dev/docker-compose.yml up -d

shell:
	docker-compose -f images/cloudquery/dev/docker-compose.yml exec app /bin/bash

down:
	docker-compose -f images/cloudquery/dev/docker-compose.yml down

.PHONY: build up shell down