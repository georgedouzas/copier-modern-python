---

description: "Task list for gating the repository's own Python"
---

# Tasks: Gate the Repository's Own Python

**Input**: Design documents from `/specs/002-gate-repo-python/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[quickstart.md](./quickstart.md)

**Tests**: The verification here is by execution, per the constitution's fourth principle. There is no
pytest suite for two scripts; the checks are the gate blocking a planted violation and passing clean.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on incomplete work)
- **[Story]**: which user story the task serves (US1, US2)
- Exact file paths in every description

## Phase 1: Setup

**Purpose**: bring the gate's configuration into the repository before pointing anything at it.

- [X] T001 Create a root `pyproject.toml` holding `[tool.black]`, `[tool.ruff]`, `[tool.ruff.lint]`, and
  `[tool.mypy]`, copied from `project/pyproject.toml.jinja` with `target-version` resolved to `py311` and
  the template's path excludes dropped, and no `[project]` table.

## Phase 2: Foundational (BLOCKING)

**Purpose**: none. This feature has no shared prerequisite beyond the config in Phase 1. The user stories
follow directly.

## Phase 3: User Story 1 — The repository holds itself to the bar it sets (P1)

**Goal**: black, ruff, and mypy run on `scripts/`, on commit and in the suite, and the scripts pass clean.

**Independent test**: plant a lint violation and a type error, confirm the commit and the suite block each,
then remove them and confirm both pass (quickstart S1 to S4).

### Make the scripts pass the gate

- [X] T002 [US1] Fix the black finding by letting black reformat `scripts/check_pipelines.py`, joining the
  split f-string it flags.
- [X] T003 [US1] Refactor `main` in `scripts/check_pipelines.py` to clear `C901`, extracting the per-file
  scan into a helper so complexity falls below the threshold by structure, not suppression.
- [X] T004 [US1] Add the scoped, reasoned ruff ignores to `pyproject.toml`: a `per-file-ignores` entry for
  `scripts/*` covering `T20` (the scripts print as their interface) and `ANN401` (a parsed YAML node is
  genuinely `Any`), each with its reason in a comment.
- [X] T005 [US1] Run `uvx black --check scripts/`, `uvx ruff check scripts/`, and
  `uvx --with types-PyYAML mypy scripts/` and confirm all three report no findings.

### Wire the gate in

- [X] T006 [P] [US1] Add black, ruff, and mypy hooks to `.pre-commit-config.yaml`, each scoped with
  `files: ^scripts/` so the gate never touches `project/` or `tests/expected/`. Add `types-PyYAML` to the
  mypy hook's `additional_dependencies`.
- [X] T007 [US1] Add a black, ruff, and mypy run over `scripts/` to the `tests` target in `Makefile`, so
  `make tests` runs the gate alongside the bats suites.
- [X] T008 [US1] Update `.github/workflows/tests.yml` so the CI job that runs `make tests` has the gate
  tools available, matching however the workflow installs its other tooling.

### Prove it

- [X] T009 [US1] Plant an unused import in a script and confirm both `pre-commit run --files <script>` and
  `make tests` fail on the ruff finding; revert and confirm both pass (quickstart S2).
- [X] T010 [US1] Plant a type error in a script and confirm `make tests` fails on mypy; revert and confirm
  it passes (quickstart S3). Plant a formatting drift and confirm black blocks it (quickstart S4).

**Checkpoint**: the gate is green on the scripts as they ship, and blocks a planted violation on commit and
in the suite. This is the MVP.

## Phase 4: User Story 2 — Findings are fixed, not silenced (P2)

**Goal**: the gate is satisfied by fixes and scoped, reasoned suppressions, never by blanket disablement.

**Independent test**: read the config and the scripts and confirm no rule is disabled wholesale, and every
suppression names its rule and reason (quickstart S6).

- [X] T011 [US2] Confirm `pyproject.toml` contains no blanket rule disablement, that the only suppressions
  are the `scripts/*` `T20` and `ANN401` per-file ignores from T004, and that each carries its reason.
- [X] T012 [US2] Confirm the `C901` finding was resolved by the T003 refactor and carries no suppression.

**Checkpoint**: the gate enforces something, because it was not made green by silencing it.

## Phase 5: Polish & Cross-Cutting

- [X] T013 Confirm the gate targets `scripts/` only: `project/` and `tests/expected/` are unreported
  (quickstart S5, FR-006).
- [X] T014 Update `CONTRIBUTING.md` so the "Working on the template" section states that the repository's
  own Python is gated by black, ruff, and mypy, run on commit and in `make tests`.
- [X] T015 Run every quickstart scenario S1 through S6, then `make tests` and `make tests-integration`, and
  confirm both are green.

## Dependencies & Execution Order

- **Setup (Phase 1)**: T001 first. Everything reads the config it creates.
- **US1 (Phase 3)**: T002 to T005 make the scripts pass, and MUST precede wiring so the gate is not wired
  red. T006 to T008 wire it in, and can follow once the scripts are clean. T009 and T010 prove it, and come
  last.
- **US2 (Phase 4)**: depends on T003 and T004 being done. It is verification, not new edits.
- **Polish (Phase 5)**: after US1.

### Within-phase notes

- T002, T003, T004 touch `check_pipelines.py` and `pyproject.toml` and are sequential, not parallel.
- T006 edits `.pre-commit-config.yaml` and can run parallel to T007's `Makefile` edit once the scripts pass.

## Implementation Strategy

**MVP is Phase 1 plus Phase 3.** That is the gate configured, the scripts passing, the gate wired into
commit and suite, and a planted violation proven to block. Phases 4 and 5 confirm the gate is honest and
document it.

The order is deliberate: make the scripts pass before wiring the gate, so `make tests` is never committed
in a red state, which the constitution's history-bisects rule requires.

## Notes on task count

15 tasks: 1 setup, 9 for US1, 2 for US2, 3 polish. Five are verifications rather than edits (T005, T009,
T010, T011, T012, T013, T015), listed as work because under the fourth principle the gate is proven by
running it, not by assuming it.
