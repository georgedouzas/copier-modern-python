# Phase 0 Research: Gate the Repository's Own Python

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-08-02

Phase 0 ran the tools against the scripts before any plan was written, so the plan is grounded in the real
findings rather than a guess, as Principle IV requires.

## R1: Where the configuration lives

**Decision**: a new root `pyproject.toml` holding `[tool.black]`, `[tool.ruff]`, and `[tool.mypy]`, with no
`[project]` table.

**Rationale**: the constitution's Code Conventions require a recurring rule to be configured once in
`pyproject.toml`, and the Toolchain section names `pyproject.toml` as the config home. A standalone
`ruff.toml` or `setup.cfg` would contradict what the repository states. black, ruff, and mypy all read
`[tool.*]` tables from `pyproject.toml` whether or not a `[project]` table is present, so the repository
gets its config home without pretending to be a package.

**Alternatives considered**: standalone `ruff.toml` plus `mypy.ini`. Rejected as contradicting the
constitution's own rule about where configuration lives.

## R2: Which configuration the tools use

**Decision**: copy the `[tool.black]`, `[tool.ruff]`, `[tool.ruff.lint]`, and `[tool.mypy]` blocks from the
template's `project/pyproject.toml.jinja`, resolving the one templated value (`target-version` to `py311`)
and dropping the excludes that name paths this repository does not have.

**Rationale**: the feature exists to hold the repository to the bar it sets for generated projects. Using a
different, laxer configuration than the one it ships would defeat the point. The template's ruff `select`
is the strict ruleset, black is line length 120 with string normalization skipped, and mypy warns on
unused ignores and shows error codes.

## R3: The black finding

**Decision**: let black reformat the one line it flags.

**Finding**: black joins a split f-string in `check_pipelines.py` that fits within 120 characters onto one
line. It is a pure formatting change with no behavioral effect.

## R4: The mypy finding

**Decision**: nothing to fix. mypy passes clean once `types-PyYAML` is available for the `yaml` import.

**Finding**: `mypy --strict` reports no issues in either script. The scripts already carry complete type
annotations, so the type discipline the constitution asks for is already met.

## R5: The ruff findings

**Decision**: eight findings of three kinds, each resolved per the Code Conventions.

- **`C901`, `check_pipelines.main` is too complex (13 > 10)**: fixed at the source. The per-file scan is
  extracted from `main` into a helper, which is the change the Control Flow convention asks for and lowers
  the complexity below the threshold honestly.
- **`T20`, print found (five times)**: suppressed for `scripts/`, with a reason. The scripts are
  command-line tools whose output is their stdout. print is the interface, not debug noise a logger should
  replace.
- **`ANN401`, dynamically typed `Any` (twice) in `check_pipelines.py`**: suppressed for `scripts/`, with a
  reason. The two helpers walk a parsed YAML document of arbitrary shape, where a node may be a mapping, a
  sequence, or a scalar. `Any` is the honest annotation, and a recursive alias would still collapse to
  `Any` at the leaves.

**Alternatives considered**: suppressing `C901` alongside the other two. Rejected, because the complexity
is a real smell that a small refactor removes, and the Code Conventions ask for the fix rather than the
silence when the fix is cheap.

## Open questions carried into implementation

None. The findings are known, the resolutions are decided, and mypy already passes.
