# Tasks

## 1. Reproduce the failures

- [x] 1.1 Generate with `>=3.12`, `~=3.12`, `>=3.11.0, <3.14`, and `>=4.0` on an unmodified checkout and
  record the crash or false message for each, confirming the defects predate the change.

## 2. Validation and derivation in copier.yml

- [x] 2.1 Add the hidden `python_newest_supported` question set to the newest minor version the
  template supports today, and verify it does not appear in a generated `.copier-answers.yml`.
- [x] 2.2 Rewrite the `python_versions` validator to the accepted forms, the 3.11 minimum, and the
  non-empty check, and update its help text to name the forms. Verify each rejected answer from the spec
  scenarios fails at the question with the expected message and no traceback.
- [x] 2.3 Add the hidden `python_test_versions` question that derives the version list, and verify by
  generating with each accepted answer from the spec scenarios that the rendered lists match.

## 3. Consumers read the derived versions

- [x] 3.1 Replace the parsing in `project/noxfile.py.jinja` with `python_test_versions`, and verify
  `PYTHON_VERSIONS` in a generated project matches the spec scenarios.
- [x] 3.2 Replace both copies in `project/pyproject.toml.jinja`, the classifiers and the black and ruff
  targets, and verify a project generated with `>3.11, <=3.13` gets classifiers for 3.12 and 3.13 and
  `py312` targets.
- [x] 3.3 Replace the copy in the GitHub `ci.yml.jinja`, and parse the rendered workflow with PyYAML to
  verify the `python-version` lists and the docs matrix match the derived versions.

## 4. Fixtures and the generated project

- [x] 4.1 Run `make regen-fixtures` and confirm the diff under `tests/expected/` is empty for the default
  answer, or moves only in whitespace the derivation explains.
- [x] 4.2 Generate a library project with `>=3.12` and run its `checks` and `tests` sessions, verifying
  the open-upper-bound project works with no manual repair.
- [x] 4.3 Run `make tests` and confirm it is green.
