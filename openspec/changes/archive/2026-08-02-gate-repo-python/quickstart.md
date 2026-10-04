# Quickstart: Validating the Gate on the Repository's Own Python

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

How to prove the gate blocks bad changes and passes the code that ships. These are validation scenarios,
not implementation steps.

## Prerequisites

- `uvx` available, or black, ruff, and mypy on `PATH`.
- A clean working tree.

## S1: The scripts pass the gate today (SC-002)

```bash
make tests
```

**Expected**: the bats suites pass as before, and the new black, ruff, and mypy run over `scripts/` reports
no findings. This is the gate green on the code that ships.

## S2: A lint violation is blocked (SC-001)

```bash
# add an unused import to a script, then:
git add scripts/regen_fixtures.py && git commit -m "tests: probe"   # blocked by the pre-commit ruff hook
make tests                                                          # also blocked by the suite
```

**Expected**: both the commit and `make tests` fail on the ruff finding. Reverting the change lets both
pass.

## S3: A type error is blocked (SC-001)

```bash
# assign a str to an int-typed variable in a script, then run:
make tests
```

**Expected**: `make tests` fails on the mypy error. Reverting lets it pass.

## S4: A formatting drift is blocked

```bash
# reflow a line in a script so it no longer matches black, then:
make tests
```

**Expected**: `make tests` fails on the black check. Running the formatter, or reverting, lets it pass.

## S5: The gate does not touch templates or fixtures (FR-006)

```bash
ruff check tests/expected/ 2>&1 | tail -1   # not part of the gate; the gate targets scripts/ only
```

**Expected**: the gate configured for this repository runs only over `scripts/`. Rendered fixtures under
`tests/expected/` and the `.jinja` templates under `project/` are never reported on, so a generated
project's own style choices are not judged by this repository's gate.

## S6: Suppressions are scoped and reasoned (SC-004)

```bash
grep -n "noqa\|per-file-ignores\|ignore =" pyproject.toml scripts/*.py
```

**Expected**: no blanket rule disablement. The only suppressions are the `T20` and `ANN401` per-file
ignores for `scripts/`, each carrying its reason in `pyproject.toml`.

## Definition of done

S1 through S6 pass, and `make tests` and `make tests-integration` are green.
