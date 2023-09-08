.PHONY: fmt install lint test fmt-ci lint-ci build install-dev
install: ;

install-dev:
	pip install -r requirements_dev.txt

lint:
	flake8 .

lint-ci:
	flake8 .

test:
	coverage run -m pytest -s -vv tests &&\
	coverage report -m

fmt:
	black . --target-version py311

fmt-ci:
	black --check . --target-version py311