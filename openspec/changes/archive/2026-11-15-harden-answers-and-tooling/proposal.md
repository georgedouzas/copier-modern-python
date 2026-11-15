## Why

Nine open issues (#6 to #14) share one root cause. The template trusts its answers and its pinned versions
without checking them, so a reasonable answer or an upstream release can produce a project that does not
parse, does not pass its own checks, or ships a workflow that cannot start. The test suite only renders
well formed answers, which is why none of these were caught. Release 2.2.0 shipping `setup-uv@v10`, a tag
that does not exist, showed the cost.

## What Changes

- **Answers are validated (#7).** `python_package_import_name` must be a valid lowercase Python identifier
  that is not a keyword. `python_package_distribution_name` must be a valid distribution name. The two email
  answers must look like an email address. Free text answers (`project_description`, `author_fullname`,
  `copyright_holder`) must be a single line without a backslash.
- **Answers are escaped where they are pasted (#6).** Every free text answer written inside a quoted string
  in `pyproject.toml`, `properdocs.yml`, `app.py` or the package docstring is escaped for that quote style,
  so a `"` or `'` in an answer generates a project whose files parse.
- **The package docstring always passes D415 (#8).** When the description does not end with `.`, `?` or
  `!`, the docstring gets a full stop. `pyproject.toml` and the docs keep the description as written.
- **The clean session deletes `coverage.xml` (#9).** Already implemented in PR #15 (`fix/clean-coverage-xml`).
  This change records it in the specs and builds on it.
- **The clean session handles `.venv` on Windows (#14).** When `clean` runs from the project's own
  environment on Windows, it leaves `.venv` in place and says how to remove it, instead of silently leaving a
  half deleted environment. Other platforms keep removing `.venv`.
- **Generated pre-commit hooks start current and stay current (#10).** The hook versions in the generated
  `.pre-commit-config.yaml` move to their latest releases. The generated `renovate.json` enables Renovate's
  `pre-commit` manager. The `ruff` hook id becomes `ruff-check`, in the template and in this repository.
- **Every pinned action version is checked (#12).** A new script resolves each `uses: owner/repo@ref` in
  this repository's workflows and in the rendered fixtures against GitHub, and CI runs it.
- **Python 3.15 is supported where the layout allows it (#13).** The newest supported Python becomes
  layout dependent: 3.15 for `library`, `script` and `service`, 3.14 for `ml` and `dataeng` until Metaflow and
  Kedro support 3.15. The `project_layout` question moves before `python_versions` so the default can follow
  it. A range that reaches past the layout's newest supported version is rejected with a message naming the
  blocker.
- **Unusual answers are tested (#11).** A new golden fixture renders with awkward answers (quotes,
  apostrophes, non ASCII text, no full stop). A parse check loads every TOML, YAML and Python file in every
  fixture. New golden cases assert that invalid answers are rejected. One integration case installs the
  awkward fixture and runs its checks and tests.

## Capabilities

### New Capabilities

- `project-answers`: which answers the generator accepts, how it rejects the rest, and how accepted answers
  are written into generated files so the project parses and passes its checks.
- `project-clean`: what the generated `clean` task removes, including `coverage.xml` and `.venv`, and how
  it behaves when it cannot remove the environment it runs from.

### Modified Capabilities

- `repo-dependency-updates`: generated pre-commit hooks start current and are tracked by Renovate, and every
  pinned action reference must resolve, enforced by a check in CI.
- `python-version-support`: the newest supported Python depends on the layout, the default range follows
  it, and ranges past it are rejected.

## Impact

- `copier.yml`: new validators, question order (`project_layout` before `python_versions`), layout
  dependent `python_newest_supported` and default range.
- Templates: `project/pyproject.toml.jinja`, `project/properdocs.yml.jinja`,
  `project/src/{{python_package_import_name}}/__init__.py.jinja`, the service `app.py`, `project/noxfile.py.jinja`,
  `project/.pre-commit-config.yaml.jinja`, the generated `renovate.json`.
- Repository: `.pre-commit-config.yaml`, `.github/workflows/tests.yml`, new `scripts/check_actions.py`,
  `scripts/check_pipelines.py` (or a new parse check), `scripts/regen_fixtures.py`, `tests/test_copier.bats`,
  `tests/test_integration.bats`, `Makefile`.
- Fixtures: all 54 change (pre-commit hooks), the 34 `library`, `script` and `service` fixtures change
  further (Python 3.15), and one new fixture is added.
- Matrix: every layout, every git provider and both package managers are affected by the answer handling,
  the clean session and the pre-commit hooks. Python 3.15 applies to `library`, `script` and `service` and is
  explicitly declined for `ml` and `dataeng`. The Windows `.venv` behaviour applies to both package managers.
  The action check applies to the GitHub provider only, since the other providers pin images, not actions.

## Out of scope

- Validating `repository_name`, `author_username` or `repository_namespace`. Their rules differ per git
  provider (Azure DevOps allows spaces in repository names).
- Keeping the pre-commit hook versions equal to the tool versions the nox `checks` session installs.
  Renovate keeps both current, but they are not locked together.
- Python 3.15 for `ml` and `dataeng`. Issue #13 stays open for them until Metaflow and Kedro release support.
- Running the full integration suite on Windows. Only the `clean` behaviour gets a Windows check.
- Releasing 2.2.1, which already happened.
