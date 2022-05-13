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
