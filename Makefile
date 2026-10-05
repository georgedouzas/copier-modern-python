.PHONY: install docs checks tests tests-integration regen-fixtures changelog release

PYTHON ?= python3

install:
	@pip install --group dev

docs:
	@properdocs serve

checks:
	@uvx black --check scripts/
	@uvx ruff check scripts/
	@uvx --with types-PyYAML mypy scripts/

tests: checks
	@bats tests/test_copier.bats
	@$(PYTHON) scripts/check_pipelines.py
	@$(PYTHON) scripts/check_docs.py

tests-integration:
	@bats tests/test_integration.bats

regen-fixtures:
	@$(PYTHON) scripts/regen_fixtures.py

changelog:
	@git-changelog -T --bump=auto -o CHANGELOG.md -c angular -t keepachangelog -s feat,fix,docs,style,refactor,tests,chore

release: changelog
	$(eval version := $(shell grep -m1 -oE '^## \[[^]]+\]' CHANGELOG.md | sed 's/^## \[//;s/\]$$//'))
	@git add CHANGELOG.md
	-@pre-commit run --files CHANGELOG.md
	@git add CHANGELOG.md
	@git commit -m "docs: Update changelog for version $(version)"
	@git tag $(version)
	@git push
	@git push --tags
