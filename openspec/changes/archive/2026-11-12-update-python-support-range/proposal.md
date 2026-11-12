# Proposal

## Why

The default `python_versions` answer is `>=3.11, <3.14`, so a project generated with defaults declares,
classifies, and tests against Python 3.11 to 3.13 only. Python 3.14 has been released for a year and
Python 3.15 is released too, with 3.15.2 current. The template already fixed a 3.14 incompatibility in
the generated docs script, which shows users run it on 3.14, but nothing tests that they can. The
integration CI job installs only 3.11, 3.12, and 3.13, so a regression on a newer Python reaches users
before it reaches CI.

## What Changes

- The default range moves to include every released Python minor version on which every layout passes
  the integration suite. The target is `>=3.11, <3.16`. If a layout's dependencies do not yet support
  3.15, the default stops at `<3.15` and the blocker is recorded.
- The template's newest supported minor version, the hidden value that `fix-python-versions-parsing`
  adds for open upper bounds, moves with the default.
- The integration CI job installs every version in the new default range.
- The README states the supported range.

## Outcome: 3.15 Is Held Back

Every layout passed the integration suite on 3.11 to 3.14 with no template change, so the default moves to
`>=3.11, <3.15`. On 3.15 the library, script, and service layouts pass, and two layouts fail on the latest
releases of a third-party dependency, so the default stops before 3.15.

- ml: Metaflow 2.19.41 vendors a `typing_extensions` that reads `typing.no_type_check_decorator`, which
  Python 3.15 removed, so importing the flow raises `AttributeError`. Metaflow declares support up to 3.13
  and has no open issue for 3.15.
- dataeng: Kedro 1.8.0 raises `KedroPythonVersionWarning` on 3.15, which the generated pytest configuration
  turns into an error. Kedro declares support up to 3.14 and tracks 3.15 in kedro-org/kedro#5851.

The next range change can add 3.15 once both release support.

## Out of Scope

- Dropping Python 3.11. It is supported upstream until October 2027.
- The parsing and validation of the answer, owned by `fix-python-versions-parsing`, which this change
  depends on.
- The repository's own Python, which the `repo-python-gate` change pinned to its own target.

## Matrix

The default range reaches every layout, git provider, and package manager through `requires-python`,
the classifiers, the nox sessions, and every CI file. All branches move together. Every layout is run by
the integration suite on the new range before the default changes.

## Capabilities

### New Capabilities

- `python-version-support`: the default range and how it is kept current. The capability is introduced
  by `fix-python-versions-parsing`, which archives first, so this change adds requirements to it.

### Modified Capabilities

None.

## Impact

- `copier.yml`: the `python_versions` default and the newest supported minor version.
- `.github/workflows/tests.yml`: the integration job's Python versions.
- `README.md`: the supported range.
- `tests/expected/`: every fixture's classifiers, nox versions, and GitHub CI version lists change.
