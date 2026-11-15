## Context

See proposal.md for why. The constraints that shape the approach:

- Copier runs a question's `validator` on answers given with `--data` and on defaults under `--defaults`,
  and stops before rendering (checked with copier 9.19.1). A validator can only read answers to questions
  asked before it, so question order matters.
- When `--data` repeats a key, the last value wins (checked). The golden suite passes common answers first
  and fixture specific answers after them, so a fixture can override a common answer.
- Templates already include shared Jinja from `includes/` (the constitution partials), and `includes/` is
  outside `_subdirectory`, so it is never rendered into a project.
- The generated ruff config selects `Q` and `D` with the google convention and ignores only `Q000`. So a
  Python string with an avoidable escaped quote fails `Q003`, and a backslash in a docstring fails `D301`.
- `pdm clean` and `uv run nox -s clean` run nox from the project's `.venv`, so the code in the noxfile runs
  in an interpreter whose `sys.prefix` is inside `.venv`.
- PR #15 already fixes `coverage.xml` in the clean session. This change is built on top of it.

## Goals / Non-Goals

**Goals:**

- One place that decides how an answer is quoted for each file format, so a new interpolation cannot
  forget to escape.
- Checks that fail in `make tests` or CI for each class of bug in the issues, not only fixes for the
  instances found.

**Non-Goals:**

- A general escaping layer for every answer in every file. Only answers written inside quoted strings are
  escaped. Markdown, the LICENSE and comments take the text as written.
- Running the integration suite on Windows.

## Decisions

### Validate in `copier.yml`, escape in an include

Validators reject what no quoting can save: a backslash, a newline, `"""` (which ends a docstring) and
invalid names. Everything else is accepted and escaped where it is written. A new
`includes/quoting.jinja` holds the macros:

- `dq_escape(value)` escapes `"` as `\"`, for the inside of a TOML, YAML or JSON double quoted string, such
  as the ml notebook's title cell. `toml_str(value)` wraps it in double quotes and serves TOML and YAML.
  Backslashes need no handling since validators reject them. Non ASCII text is written as is, since TOML,
  YAML and JSON are UTF-8.
- `toml_key(value)` writes a TOML key bare when TOML allows it and quoted otherwise. The script layout uses
  `repository_name` as a key in `[project.scripts]`, which a name with a space would break, while ordinary
  names keep their current bare form.
- `py_str(value)` writes a Python literal the way `repr` would: single quotes unless the text contains
  `'` and no `"`, in which case double quotes. When it contains both, single quotes with `'` escaped, which
  `Q003` accepts since switching quotes would not avoid an escape.

Alternative considered: Jinja's `tojson`. It escapes `'`, `<`, `>` and `&` as `'` style sequences and
non ASCII text as `\uXXXX`, which is valid TOML and YAML but makes `pyproject.toml` unreadable for a
description like `Données`. Alternative considered: read the FastAPI description from package metadata at
run time. It avoids quoting but depends on the distribution name, which the `service` layout does not ask
for.

### Docstring punctuation in the template

The package docstring appends `.` when the description does not end with `.`, `?` or `!`. This also
covers a description ending with `"`, which would otherwise close the docstring early (`""""`). The text
inside the docstring needs no escaping once `\` and `"""` are rejected.

### Name validators

- Import name: `^[a-z_][a-z0-9_]*$` and not in Python's keyword list (written out in the validator, since
  Jinja cannot import `keyword`).
- Distribution name: the PEP 508 name pattern `^[A-Za-z0-9]([A-Za-z0-9._-]*[A-Za-z0-9])?$`.
- Emails: `^[^@\s]+@[^@\s]+\.[^@\s]+$`. Deliberately loose. It catches typos and placeholders, not every
  invalid address.

A repository name that derives an invalid import name (for example one starting with a digit) now fails
under `--defaults` with the validator's message, instead of rendering a broken package. The user answers
the import name explicitly.

### Layout dependent Python ceiling

`project_layout` moves before `python_versions`. The hidden `python_newest_supported` becomes
`{{ 14 if project_layout in ['ml', 'dataeng'] else 15 }}`. The default range is built from it
(`>=3.11, <3.{{ python_newest_supported + 1 }}`). The validator adds one rule: an upper bound that reaches
past `python_newest_supported` is rejected, naming the newest supported version for the layout.

Alternative considered: keep one ceiling of 3.14 for every layout until Metaflow and Kedro catch up. It
leaves three layouts a release behind for reasons that do not apply to them. The constitution allows a
matrix branch to be explicitly declined, and the spec records the blockers.

### Windows `.venv` in the clean session

The clean session skips `.venv` when `sys.platform == 'win32'` and `sys.prefix` resolves inside `.venv`,
and logs how to remove it after the task exits (`rmdir /s /q .venv` or `Remove-Item -Recurse .venv`). On
other platforms nothing changes.

Alternative considered: delete with an error handler and report failures. It still leaves a half deleted
environment, which is what the issue is about.

### Action reference check

`scripts/check_actions.py` collects every `uses: owner/repo@ref` from `.github/workflows/` and from the
workflows under `tests/expected/`, deduplicates them, and resolves each with
`git ls-remote https://github.com/owner/repo refs/tags/<ref> refs/heads/<ref>`. It needs no token and no
dependency beyond git. Local actions (`./...`) and `docker://` references are skipped. It runs as
`make check-actions`, not inside `make tests`, since it needs the network. The `tests` workflow runs it on
every push and pull request.

### Parse check for every fixture

`scripts/check_parse.py` loads every `*.toml` with `tomllib` and every `*.py` with `ast.parse`, across all
fixtures. YAML stays with `check_pipelines.py`, which already parses every YAML file. It runs in
`make tests` next to the pipeline and docs checks. This turns #6 class bugs into a test failure for every
layout and provider, not just the new fixture.

### Unusual answers fixture and rejection cases

A new fixture `layout-service-git-provider-github-package-manager-uv-answers-unusual` uses
`project_description` `Kedro's "data" tool, Données` (no full stop) and `author_fullname` `Seán O'Brien`.
The `service` layout is chosen since it is the only one that writes the description into Python code, so
one fixture exercises the TOML, YAML, docstring and `app.py` paths. `fixture_data` in the golden suite maps
the suffix to these answers. The golden suite gains a case that runs copier with each invalid answer from
the specs and asserts it fails with the validator's message. The integration suite gains a case that
installs the unusual fixture and runs its checks and tests.

### Pre-commit hooks

The generated hook revisions move to their latest releases, and `ruff` becomes `ruff-check`, in the
template and in this repository's own config. The generated `renovate.json` adds
`"pre-commit": {"enabled": true}` and a package rule grouping `pre-commit` updates with the development
tooling.

## Risks / Trade-offs

- [Moving `project_layout` before `python_versions` changes the question order] → Answers files are keyed
  by name, so `copier update` is unaffected. Only interactive users see a different order.
- [The Windows behaviour is not verified locally] → A Windows job in the `tests` workflow generates a uv
  and a PDM project, runs `clean`, and asserts `.venv` survives and the other artifacts are gone. It is a
  follow-up check that runs once the branch is on GitHub.
- [`check_actions.py` depends on GitHub being reachable] → It is a separate make target, so offline local
  runs of `make tests` are unaffected.
- [The email pattern rejects some valid addresses, such as `user@localhost`] → Accepted. Generated
  projects publish these addresses in package metadata, where a dotted domain is expected.
- [Python 3.15 for three layouts adds a version the integration CI installs] → The CI already installs
  the default range. Adding one version adds one interpreter download.
- [Renovate's `pre-commit` manager is marked beta upstream] → It only opens pull requests. A bad proposal
  fails the project's own checks before merging.

## Migration Plan

Existing projects pick up the changes through `copier update`. Their stored answers are revalidated, so a
project whose stored import name is invalid would fail the update with the validator's message. That
project could not have imported its own package, so no working project is affected.

## Open Questions

- Whether the PDM jobs in the Windows check need `pdm` installed through `pipx` or `uv tool`. Either works,
  and the choice does not change the specs.
