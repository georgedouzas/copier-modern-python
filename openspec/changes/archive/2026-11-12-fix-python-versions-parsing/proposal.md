# Proposal

## Why

The `python_versions` answer accepts only one input shape, `>=3.X, <3.Y`, and handles every other
shape badly. A range with no upper bound, such as `>=3.12`, and a compatible-release range, such as
`~=3.12`, crash generation with `TypeError: 'Undefined' object cannot be interpreted as an integer`.
A valid range with a patch component, such as `>=3.11.0`, fails validation with the false message
"Minimum version is Python 3.11". A user who types a reasonable answer gets a traceback or a wrong
error, and no project.

## What Changes

- The `python_versions` question states the accepted forms in its help text and rejects every other
  form with a message that names them, so no answer reaches rendering and crashes it.
- A lower bound with a patch component, such as `>=3.11.0`, is accepted and read as its minor version.
- A range with no upper bound, such as `>=3.12`, is accepted. Its supported versions run from the lower
  bound up to the newest Python minor version the template supports.
- The supported versions are derived from the answer in one place, and the four templates that need
  them, `noxfile.py`, `pyproject.toml` classifiers and tool targets, and the GitHub `ci.yml`, read that
  one result instead of each repeating the parsing.

## Out of Scope

- Changing the default range. The change `update-python-support-range` owns that.
- Making the non-GitHub pipelines read the supported versions. The change
  `fix-provider-ci-python-version` owns that and builds on the derived versions this change adds.
- Accepting exclusion specifiers such as `!=3.12` or exact pins such as `==3.12`. They are rejected
  with a clear message.

## Matrix

The parsing feeds `noxfile.py` and `pyproject.toml` for every layout, git provider, and package
manager, and the GitHub `ci.yml` for every layout and package manager. All branches move together
because they read the same derived value. For the default answer the rendered output is identical to
today's, so no fixture changes unless the derivation itself changes whitespace.

## Capabilities

### New Capabilities

- `python-version-support`: how the generator takes the supported Python range, validates it, and
  derives the list of Python versions a generated project declares and tests against.

### Modified Capabilities

None.

## Impact

- `copier.yml`: the `python_versions` question, its validator, and a new computed value holding the
  derived versions.
- `project/noxfile.py.jinja`, `project/pyproject.toml.jinja`, and the GitHub `ci.yml.jinja`: replace
  their copies of the parsing with the computed value.
- `tests/expected/`: regenerated, with no diff expected for the default answer.
