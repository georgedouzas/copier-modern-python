# Implementation Plan: Fixture Tests Build the Docs

**Branch**: `003-fixture-docs-build` | **Date**: 2026-10-04 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-fixture-docs-build/spec.md`

## Summary

Add a docs build gate to the per-push fixture suite: a new `scripts/check_docs.py`, run by
`make tests`, builds the documentation of every committed fixture with `properdocs build` in one
shared uv-provisioned environment and fails naming any fixture whose docs do not build. In the
same feature, generated projects stop enumerating the mkdocs plugin stack and declare properdocs
as their single documentation tool, with the gate as the regression net for the swap. The swap is
blocked on a properdocs release that carries the stack, so the work is phased: the gate lands
first, the swap lands when the release exists.

## Technical Context

**Language/Version**: Python 3.11+ for `scripts/check_docs.py`, bash for `Makefile` wiring

**Primary Dependencies**: uv (provisions the shared docs environment, already a `make checks` and
CI prerequisite), properdocs and the fixtures' `docs` groups (installed into that environment,
derived from the fixtures per FR-013), stdlib `tomllib` for reading both dependency declaration
forms

**Storage**: none, builds run in temp copies of fixtures, the environment lives outside the tree

**Testing**: `make tests` (golden bats suite, `check_pipelines.py`, then the new gate), seeded
defect validation per [quickstart.md](quickstart.md), `make tests-integration` untouched

**Target Platform**: macOS and Linux developer machines, ubuntu-latest CI (fixtures job)

**Project Type**: Copier template repository, the deliverable is a test gate plus template edits

**Performance Goals**: `make tests` under 10 minutes warm locally, under 15 minutes in CI
(SC-004). Measured basis: about 1.5 s environment install warm, 0.3 to 0.5 s per fixture build,
55 fixtures, so the gate costs about a minute warm (research R4)

**Constraints**: non-interactive (FR-007), network only for toolchain provisioning with a
prerequisite-failure message when absent (FR-008), repository tree never written during builds

**Scale/Scope**: 55 committed fixtures today, all covered, duplicates skipped by docs-inputs
digest (FR-003, currently vacuous per research R4)

## Constitution Check

*GATE: evaluated against constitution v2.0.1 before Phase 0, re-checked after Phase 1 design.*

- **I. The Generated Project Is the Product**: PASS. The feature verifies the product's docs
  build, closing the gap where a render passed while the generated docs were broken. The
  single-tool swap is judged by generated projects still building their docs, enforced by the
  gate (FR-012).
- **II. Matrix Parity**: PASS. The gate covers every fixture, so every branch of layout,
  provider, and package manager is built. The swap edits both package manager branches of the
  `docs` group in the same change.
- **III. Fixtures Are the Specification**: PASS. The gate derives its fixture set by listing
  `tests/expected/` and its toolchain from fixture `pyproject.toml` files, restating nothing.
  The swap regenerates fixtures in the same commit as the template edit.
- **IV. Verify by Execution**: PASS. The gate is execution by definition. The plan's own claims
  were established by running builds (research R2 to R4), including the falsified assumption
  about package manager docs identity.
- **V. Honest, Conventional History**: PASS. The work splits into separate commits: the gate
  (`feat`), the badge and dependency swap with regenerated fixtures (`feat` or `refactor`), docs
  updates (`docs`).
- **VI. Current Tooling, Deliberately Chosen**: PASS with a note. The swap replaces an enumerated
  plugin stack with properdocs owning it, and the commit body must state how it earns its place.
  The gate integrates into `make tests` and CI, so the new check actually runs. The swap is
  blocked on an external properdocs release and MUST NOT merge before it, otherwise generated
  projects fail Principle I.
- **Template Contract**: PASS. Task interface unchanged (the gate joins the existing `tests`
  entry point per FR-006), release topology untouched, configuration stays in `pyproject.toml`.
- **Development Workflow**: PASS. `make tests` remains the pre-commit gate, with the docs gate
  inside it.

No violations. Complexity Tracking stays empty.

## Project Structure

### Documentation (this feature)

```text
specs/003-fixture-docs-build/
├── plan.md              # This file
├── research.md          # Phase 0 output, decisions R1 to R6
├── data-model.md        # Phase 1 output, gate entities
├── quickstart.md        # Phase 1 output, validation scenarios
├── contracts/
│   └── docs-build-contract.md
└── tasks.md             # Phase 2 output (/speckit-tasks, not created here)
```

### Source Code (repository root)

```text
Makefile                          # tests target gains the docs gate stage
scripts/
├── check_pipelines.py            # existing pattern the gate follows
└── check_docs.py                 # NEW: the docs build gate (contract above)
project/
├── pyproject.toml.jinja          # swap: docs groups collapse to properdocs, both pm branches
└── README.md.jinja               # swap: docs badge names properdocs
pyproject.toml                    # swap: repo's own dev group follows the single-tool rule
tests/expected/                   # regenerated whenever the swap lands
.github/workflows/tests.yml       # unchanged, fixtures job already installs uv and runs make tests
```

**Structure Decision**: single repository, two implementation phases. Phase A adds
`scripts/check_docs.py` and the Makefile stage, touching no template file, so it can merge alone.
Phase B performs the properdocs swap across `project/pyproject.toml.jinja`,
`project/README.md.jinja`, and the repository's own `pyproject.toml`, regenerates fixtures, and
relies on Phase A's gate for FR-012. Phase B is blocked on the properdocs release named in
research R2.

## Complexity Tracking

No constitution violations to justify.
