# Contract: Docs Build Gate

The gate is `scripts/check_docs.py`, run by `make tests` after the golden suite and the pipeline
check. This contract is what the rest of the repository may rely on.

## Invocation

- `python3 scripts/check_docs.py` from the repository root, no arguments, no prompts (FR-007).
- `make tests` invokes it with the same `PYTHON` override the other script stages honour.

## Inputs

- The committed fixtures under `tests/expected/`. The gate lists that directory and nothing else
  to decide what to cover (FR-004).
- Each fixture's `pyproject.toml` docs group, from which the toolchain to install is derived
  (FR-013). Both the pdm and the uv declaration forms are read.
- Network and a package index on the first run. Later runs reuse the provisioner's cache.

## Behaviour

1. Discover fixtures and compute each one's docs-inputs digest.
2. Build the shared environment from the union of the docs groups.
3. For each fixture with a new digest, copy it to a temp directory and run the documentation
   build there with `PYTHONPATH=src`. A fixture whose digest was already built is recorded as
   covered by the earlier build (FR-003).
4. Collect outcomes and report.

## Outputs and exit status

- Exit 0: every covered documentation build passed. The report lists one line per fixture with
  its outcome, built or covered-by.
- Exit non-zero, documentation defect: at least one build failed. The report names each failing
  fixture and prints its captured build output (FR-005, SC-003).
- Exit non-zero, prerequisite failure: the environment could not be provisioned or the build tool
  is missing. The message names the missing prerequisite and how to get it, and no fixture is
  reported as a documentation failure (FR-008).

## Guarantees

- The repository tree is never written to: builds run in temp copies, the environment lives
  outside the tree.
- Adding or removing a fixture via `scripts/regen_fixtures.py` changes coverage with no edit to
  the gate (SC-005).
- Changing a fixture's docs dependency declaration changes what the gate installs with no edit to
  the gate, which is what lets the properdocs single-tool swap land under the gate unchanged
  (FR-012, FR-013).
