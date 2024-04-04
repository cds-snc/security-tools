.PHONY: fmt fmt-ci install install-dev lint lint-ci test build up shell down

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
	docker-compose -f images/cloud_asset_inventory/cloudquery/dev/docker-compose.yml build

up:
	export AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID); \
	export AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY); \
	export AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN); \
	docker-compose -f images/cloud_asset_inventory/cloudquery/dev/docker-compose.yml up -d

shell:
	docker-compose -f images/cloud_asset_inventory/cloudquery/dev/docker-compose.yml exec app bash -c "nohup /usr/local/bin/log_connections.sh > /app/outbound.log 2>&1 & /bin/bash"

down:
	docker-compose -f images/cloud_asset_inventory/cloudquery/dev/docker-compose.yml down
