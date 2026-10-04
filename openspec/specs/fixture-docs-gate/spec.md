# fixture-docs-gate Specification

## Purpose

Prove, on every push, that every committed fixture's documentation actually builds, closing the
gap where a template change renders valid output whose docs no longer build.

## Requirements

### Requirement: The fixture suite builds the docs

The fixture test suite MUST build the documentation of every committed fixture with
`properdocs build --strict` and fail when any covered build fails. Strict mode is deliberate: the
defects the tool reports as warnings, a navigation entry pointing at a missing page among them,
are exactly the silent breakage the gate exists to catch. The gate runs as a stage of
`make tests`, after the golden suite and the pipeline check, and MUST run non-interactively.

#### Scenario: A docs-breaking change

- **WHEN** a template change makes a generated project's documentation build fail while still
  rendering valid output
- **THEN** `make tests` fails, naming each broken fixture and printing its captured build output

#### Scenario: A clean tree

- **WHEN** every covered documentation build passes
- **THEN** the gate reports one outcome line per fixture and exits zero

### Requirement: Coverage derives from the fixtures

The gate MUST discover its fixture set by listing `tests/expected/` and MUST derive the toolchain
it installs from the docs dependency groups the fixtures themselves declare, restating neither.
Builds run in one shared environment provisioned by uv, in temporary copies of the fixtures, with
`PYTHONPATH=src`, and never write to the repository tree.

#### Scenario: A fixture is added

- **WHEN** the fixture regeneration script adds or removes a fixture
- **THEN** the gate's coverage follows with no edit to the gate

#### Scenario: Docs dependencies change

- **WHEN** a fixture's docs dependency declaration changes
- **THEN** the gate installs the new toolchain with no edit to the gate

### Requirement: Docs-identical fixtures build once

Fixtures whose docs inputs, the docs configuration, the docs pages, the sources, and the included
prose files, hash identically MUST be built once, with later ones reported as covered by the
fixture that built.

#### Scenario: A duplicate configuration

- **WHEN** two fixtures have byte-identical docs inputs
- **THEN** the first builds and the second is reported as covered by it

### Requirement: Prerequisite failures are legible

A missing prerequisite, uv absent, a too-old Python, or an unreachable package index, MUST fail
with a message naming the prerequisite and how to get it, and MUST NOT be reported as a
documentation defect.

#### Scenario: uv is missing

- **WHEN** the gate runs on a machine without uv
- **THEN** it exits non-zero naming uv and where to install it, with no fixture reported as a
  docs failure

### Requirement: The suite stays practical

The fixture suite including the docs gate MUST complete in under 15 minutes in CI on every push
and under 10 minutes warm locally, so it remains the default pre-commit gate.

#### Scenario: Warm local run

- **WHEN** `make tests` runs with a warm uv cache
- **THEN** the docs gate adds on the order of a minute, not tens of minutes
