# repo-python-gate Specification

## Purpose

Hold the repository's own Python, the scripts under `scripts/`, to the same bar the template
ships to generated projects, so the repository practices what it generates.

## Requirements

### Requirement: The scripts are gated

Formatting, linting, and type checking MUST run on the scripts under `scripts/`, with black,
ruff, and mypy reading the same configuration the template ships for a generated project.

#### Scenario: A violation blocks

- **WHEN** a script under `scripts/` violates formatting, a lint rule, or type checking
- **THEN** `make checks` fails, and `make tests`, which runs it first, fails with it

### Requirement: The gate runs on commit and in CI

The gate MUST run locally on commit through pre-commit, scoped to `scripts/`, and in the
repository's test suite, so a violation blocks the commit, the suite, and CI.

#### Scenario: Commit with a finding

- **WHEN** a commit touches a script with a finding
- **THEN** the pre-commit hooks reject the commit

### Requirement: Scope excludes rendered and templated code

The gate MUST NOT run on the `.jinja` templates under `project/` or on the rendered output under
`tests/expected/`, because the first is not Python the repository authors as Python and the
second is generated output.

#### Scenario: Template edits

- **WHEN** a `.jinja` template or a fixture changes
- **THEN** the gate does not evaluate it

### Requirement: Configuration lives in one place

The gate's configuration MUST live in the repository's `pyproject.toml`. A finding on a script is
fixed at the source. A suppression is permitted only as a justified one-off naming its rule code
and reason, and a rule that is a matter of taste is configured once rather than suppressed
repeatedly.

#### Scenario: A recurring suppression

- **WHEN** the same suppression would recur across the scripts
- **THEN** the rule is configured once in `pyproject.toml` as a scoped ignore instead
