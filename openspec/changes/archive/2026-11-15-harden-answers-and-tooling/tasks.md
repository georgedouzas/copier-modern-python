# Tasks

Each group lands as its own commit (or commits), with fixtures regenerated in the same commit as the
template edit they reflect, and `make tests` green after every commit.

## 1. Base and parse check

- [x] 1.1 Create the implementation branch from `main`, which already holds the `coverage.xml` fix (#9,
  PR #15 merged as `be597a1`), and verify `git log` shows `fix: Delete coverage.xml in the clean session`
  on it
- [x] 1.2 Add `scripts/check_parse.py`, which parses every `*.toml` (tomllib) and `*.py` (`ast.parse`) in every
  fixture under `tests/expected/` (YAML is already parsed by `check_pipelines.py`), and verify it
  passes on the current fixtures and fails on a fixture copy with a broken `pyproject.toml`
- [x] 1.3 Run it from `make tests` next to `check_pipelines.py`, pass `black`, `ruff` and `mypy` on it via
  `make checks`, and verify `make tests` passes

## 2. Answer validation (#7)

- [x] 2.1 Add validators in `copier.yml` for `python_package_import_name` (lowercase identifier, not a
  keyword), `python_package_distribution_name` (PEP 508 name), `author_email` and `copyright_holder_email`,
  and for the free text answers (`project_description`, `author_fullname`, `copyright_holder`: non empty, one
  line, no backslash, no `"""`), and verify each passes the existing fixtures' answers by running
  `make tests`
- [x] 2.2 Add a golden suite case that runs copier with each rejected answer from the `project-answers` spec
  (`my-pkg`, `class`, `-pkg-`, `me@localhost`, `not an email`, `Parses C:\paths.`, `Say """hi""".`, a two line
  description) and asserts copier fails, renders nothing, and prints the validator's message, and verify it
  passes
- [x] 2.3 Verify by execution that `repository_name` `My Repo-Name` with default package names generates the
  import name `my_repo_name`, and that a repository name starting with a digit fails under `--defaults` with
  the import name message

## 3. Escaping and the docstring (#6, #8, #11)

- [x] 3.1 Add `includes/quoting.jinja` with `toml_str` (also used for YAML) and `py_str` as described in the
  design, and use them for every free text answer written inside a quoted string in
  `project/pyproject.toml.jinja`, `project/properdocs.yml.jinja` and the service `app.py`
- [x] 3.2 Append a full stop to the package docstring in `__init__.py.jinja` when the description does not end
  with `.`, `?` or `!`
- [x] 3.3 Add the `...-answers-unusual` service fixture to `scripts/regen_fixtures.py` and to `fixture_data` in
  `tests/test_copier.bats`, run `make regen-fixtures`, and verify the diff only adds the new fixture (the
  existing 54 are unchanged, since `A test project.` needs no escaping)
- [x] 3.4 Verify `check_parse.py` passes on the new fixture, that its `pyproject.toml` description is
  `Kedro's "data" tool, Données`, its author `Seán O'Brien`, and its docstring ends with `Données.`
- [x] 3.5 Add an integration case that installs the unusual fixture's answers with uv, runs its checks and
  tests, and verify it passes with `make tests-integration`
- [x] 3.6 Verify by execution the spec scenarios not covered by the fixture: a description `Why not?` keeps
  its docstring unchanged, and `A "quoted" tool` generates a `pyproject.toml` that `tomllib` loads with the
  description as written, for both PDM and uv

## 4. Clean session on Windows (#14)

- [x] 4.1 In `project/noxfile.py.jinja`, skip `.venv` when running on Windows from inside it and log how to
  remove it, run `make regen-fixtures`, and verify the diff moves only the clean session of all 54 noxfiles
  plus the unusual fixture
- [x] 4.2 Verify by execution on macOS that `clean` still removes `.venv` and that `pdm install` or `uv sync`
  afterwards rebuilds it and the tests pass, for both package managers
- [x] 4.3 Add a `windows-clean` job to `.github/workflows/tests.yml` (on `windows-latest`, same triggers as
  `integration`) that generates a uv and a PDM project, installs it, creates `coverage.xml`, runs `clean`,
  and asserts `.venv` still works and `coverage.xml` is gone, and verify the workflow parses with
  `check_pipelines.py` style YAML loading

## 5. Pre-commit hooks (#10)

- [x] 5.1 Update every `rev` in `project/.pre-commit-config.yaml.jinja` to the latest release (checked with
  `gh api repos/<repo>/tags`), rename `ruff` to `ruff-check` there and in `.pre-commit-config.yaml`, and
  verify `pre-commit run --all-files` in this repository shows no legacy alias
- [x] 5.2 Enable Renovate's `pre-commit` manager in the generated `renovate.json` and group its updates
  with the development tooling, and verify the rendered file passes `npx --yes renovate-config-validator`
- [x] 5.3 Run `make regen-fixtures` and verify the diff moves only `.pre-commit-config.yaml` and
  `renovate.json` in the fixtures
- [x] 5.4 Verify by execution that a generated PDM project and a generated uv project pass
  `pre-commit run --all-files` with the new hooks, with no legacy alias reported

## 6. Action reference check (#12)

- [x] 6.1 Add `scripts/check_actions.py` as described in the design and a `check-actions` make target, and
  verify it passes on the current tree and fails naming `astral-sh/setup-uv@v10` and its file when one
  fixture is temporarily edited to pin it
- [x] 6.2 Run `make check-actions` as a step of the `tests` job in `.github/workflows/tests.yml`, and verify
  the workflow parses and passes `make check-actions` locally
- [x] 6.3 Document `make check-actions` where `CONTRIBUTING.md` lists the test commands, and verify the
  documented command runs as written

## 7. Python 3.15 by layout (#13)

- [x] 7.1 Move `project_layout` before `python_versions` in `copier.yml`, make `python_newest_supported`
  layout dependent (15, or 14 for `ml` and `dataeng`), derive the default range from it, and add the
  validator rule for a range past the layout's newest version naming that version
- [x] 7.2 Add golden suite cases for the `python-version-support` scenarios: `>=3.12` on `ml` derives up to
  3.14, `>=3.11, <3.16` on `ml` and `dataeng` is rejected naming 3.14, and the existing rejection cases still
  fail as before, and verify they pass
- [x] 7.3 Add Python 3.15 to the integration job's `setup-python` versions in `.github/workflows/tests.yml`
- [x] 7.4 Run `make regen-fixtures` and verify the diff moves only Python versions, in the 34 `library`,
  `script` and `service` fixtures plus the unusual fixture, and nothing in `ml` or `dataeng`
- [x] 7.5 Verify by execution that `make tests-integration` passes with Python 3.15 installed, including
  the library, script, service and Dockerfile cases on 3.15
- [x] 7.6 Update the default range line in `README.md` (currently `>=3.11, <3.15` by default) to state the per
  layout default and the Metaflow and Kedro blockers, and verify `make tests` (docs gate) passes

## 8. Integration

- [x] 8.1 Run `make tests` and `make tests-integration` on the final branch and verify both pass
- [x] 8.2 Run `openspec validate harden-answers-and-tooling --strict` and verify it passes

## Workflow follow-up

- Push the branch and open a PR that closes #6, #7, #8, #10, #11, #12 and #14, and supersedes PR #15 (#9).
- On GitHub, confirm the `windows-clean` job passes (this is the Windows verification of #14) and that the
  `check-actions` step runs on the PR.
- Comment on #13 that 3.15 is supported for `library`, `script` and `service`, and keep it open for `ml` and
  `dataeng` until Metaflow and Kedro support 3.15.
- Archive the change after the PR is merged.
