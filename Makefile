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

build-cq: 
	docker build --build-arg CONFIG_FILE=config.yml -f images/cloud_asset_inventory/cloudquery/Dockerfile -t cq images/cloud_asset_inventory/cloudquery

build-dev-cq:
	docker build --build-arg CONFIG_FILE=config.yml -f images/cloud_asset_inventory/cloudquery/dev/Dockerfile -t cq-dev images/cloud_asset_inventory/cloudquery/dev

run-dev-cloud-query:
	docker-compose -f images/cloud_asset_inventory/cloudquery/dev/docker-compose.yml up -d app

stop-dev-cloud-query:
	docker-compose -f images/cloud_asset_inventory/cloudquery/dev/docker-compose.yml down