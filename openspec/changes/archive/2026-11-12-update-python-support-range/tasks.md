# Tasks

## 1. Find the supported range by execution

- [x] 1.1 With `fix-python-versions-parsing` applied, set the default to `>=3.11, <3.15` and the newest
  supported minor version to 14, run `make tests-integration` with 3.11 to 3.14 installed, and record
  each layout's result.
- [x] 1.2 Fix any failure caused by template code in a separate `fix:` commit with its own fixtures, and
  rerun the failing layout to verify.
  No failure needed a fix. Every layout passed the integration suite on 3.11 to 3.14.
- [x] 1.3 Repeat with `>=3.11, <3.16` and 15. If a layout fails on a third-party dependency, keep the
  range at `<3.15` and record the dependency and its tracking issue in the proposal.
  Done. The ml layout fails on Metaflow and the dataeng layout on Kedro, so the range stays at `<3.15`.

## 2. Move the default and CI

- [x] 2.1 Set the `python_versions` default and the newest supported minor version in `copier.yml` to the
  range task 1 established, and verify a default generation's `pyproject.toml` declares it.
- [x] 2.2 Add the new versions to the integration job's `python-version` list in
  `.github/workflows/tests.yml`, and parse the workflow with PyYAML to verify the list matches the range.
- [x] 2.3 State the supported range in `README.md` and verify the README matches `copier.yml`.

## 3. Fixtures and suites

- [x] 3.1 Run `make regen-fixtures` and confirm the diff moves only in the classifiers, the nox
  `PYTHON_VERSIONS`, and the GitHub CI version lists, plus the pipeline interpreters if
  `fix-provider-ci-python-version` has landed.
- [x] 3.2 Run `make tests` and `make tests-integration` and confirm both are green.
  `make tests` passed after the final edit. `make tests-integration` passed 10 of 10 in task 1.1 on the
  same template content, `>=3.11, <3.15` with 14 as the newest supported version.
