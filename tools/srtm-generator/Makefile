default: 
	python3 script.py

fmt:
	black . $(ARGS)

install:
	pip3 install --user -r requirements.txt

lint:
	pylint script.py

test:
	python -m pytest -s -vv tests

.PHONY: \
	fmt \
	install	\
	lint \
	test