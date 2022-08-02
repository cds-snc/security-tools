install:
	pip install --user -r requirements.txt

install-dev:
	pip install --user -r requirements_dev.txt

lint:
	python -m flake8 .

lint-ci: lint

format:
	black .
	make lint

fmt-ci:
	black --check .

migrate:
	python craft migrate

reset:
	python craft migrate:reset

serve:
	python craft serve

test:
	python craft migrate -c testing &&\
	APP_ENV=testing coverage run -m pytest -s -vv tests &&\
	coverage report -m

.PHONY: install install-dev lint lint-ci format fmt-ci migrate reset serve test
