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
	@TERM=$${TERM:-dumb} bats --formatter pretty tests/test_copier.bats
	@$(PYTHON) scripts/check_pipelines.py
	@$(PYTHON) scripts/check_docs.py
	@echo "tests OK: golden suite, pipeline check, and docs gate all passed"

tests-integration:
	@TERM=$${TERM:-dumb} bats --formatter pretty tests/test_integration.bats
	@echo "tests-integration OK: every integration case passed"

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
