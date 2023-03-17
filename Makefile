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
	docker build -f images/cloud_asset_inventory/cloudquery/Dockerfile -t cq images/cloud_asset_inventory/cloudquery

run-cloud-query:
	docker run \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
		-e AWS_DEFAULT_REGION="ca-central-1" \
		--network=security-tools_devcontainer_default \
		cq
		sync --log-console --log-level debug /config.yml
