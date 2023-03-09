.PHONY: fmt fmt-ci install install-dev lint lint-ci test

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
	docker build -f images/cloud_asset_inventory/cartography/Dockerfile -t cartography images/cloud_asset_inventory/cartography

run-cartography:
	docker run \
		--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		--env AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
		--env AWS_DEFAULT_REGION="ca-central-1" \
		--env NEO4J_URI=bolt://host.docker.internal:7687 \
		--env NEO4J_USER=neo4j \
		--env NEO4J_SECRETS_PASSWORD=localpassword \
		--env LOCAL=true \
		--env AWS_ACCOUNT=034163289675 \
		--env AWS_CONFIG_FILE=/config/role_config \
		cartography