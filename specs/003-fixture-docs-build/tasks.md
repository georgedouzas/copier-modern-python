# Tasks: Fixture Tests Build the Docs

**Input**: Design documents from `/specs/003-fixture-docs-build/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/docs-build-contract.md,
quickstart.md

**Tests**: the gate is itself a test, and the constitution demands verification by execution, so
each story carries explicit verify-by-execution tasks instead of unit test tasks.

**Organization**: tasks are grouped by user story. The stories share one script, so US2 and US3
build on US1 rather than running fully independently. US4 is additionally blocked on an external
properdocs release (research R2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependencies)
- **[Story]**: which user story this task belongs to (US1, US2, US3, US4)

## Phase 1: Setup

**Purpose**: a verified green baseline, so every later failure is attributable to this feature.

- [X] T001 Run `make tests` on the clean tree and confirm the golden suite and
      `scripts/check_pipelines.py` pass, recording the wall-clock time as the pre-feature
      baseline for SC-004

---

## Phase 2: Foundational

No foundational tasks. The feature adds one self-contained script plus template edits, and the
repository's conventions, Makefile stages, and CI job already exist.

---

## Phase 3: User Story 1 - A docs-breaking change fails the fixture tests (Priority: P1) 🎯 MVP

**Goal**: `make tests` builds the documentation of every committed fixture and fails naming any
fixture whose docs do not build, per [contracts/docs-build-contract.md](contracts/docs-build-contract.md).

**Independent Test**: seed a defect that renders fine but cannot build (quickstart "Validate a
docs defect is caught"), run `make tests`, observe the named failure, revert, observe green.

### Implementation for User Story 1

- [X] T002 [US1] Implement fixture discovery and docs dependency-group parsing in
      `scripts/check_docs.py`: list `tests/expected/`, read each fixture's `pyproject.toml` with
      `tomllib`, extract the `docs` group from `[tool.pdm.dev-dependencies]` (pdm fixtures) and
      `[dependency-groups]` (uv fixtures), and compute the union of requirements (FR-004, FR-013)
- [X] T003 [US1] Implement shared environment provisioning in `scripts/check_docs.py`: create one
      venv outside the repository tree with `uv venv` and `uv pip install` of the union, and
      report a missing `uv` or a failed install as a prerequisite failure naming what to install,
      distinct from a documentation defect (FR-008, research R4, R5)
- [X] T004 [US1] Implement the build loop in `scripts/check_docs.py`: copy each fixture to a temp
      directory, run `properdocs build` there with `PYTHONPATH=src` (research R3), capture stdout
      and stderr, print one outcome line per fixture, print each failing fixture's name and
      output, and exit non-zero on any failure (FR-001, FR-005, FR-007)
- [X] T005 [US1] Add the gate as the final stage of the `tests` target in `Makefile`, invoked as
      `$(PYTHON) scripts/check_docs.py` after `scripts/check_pipelines.py` (FR-006)
- [X] T006 [US1] Run `make checks` and fix any black, ruff, or mypy finding in
      `scripts/check_docs.py`, honouring the constitution's Code Conventions (no explanatory
      comments, errors built in a variable then raised, guard clauses)
- [X] T007 [US1] Verify by execution: run `make tests` on the clean tree and confirm the gate
      reports every fixture and passes
- [X] T008 [US1] Verify by execution: seed the missing-page defect in
      `project/properdocs.yml.jinja` per quickstart.md, run `make regen-fixtures` then
      `make tests`, confirm the gate fails naming the affected fixtures with the build error,
      then revert `project/properdocs.yml.jinja` and `tests/expected/` and confirm green
      (SC-001, SC-003)

**Checkpoint**: the MVP. Every fixture's docs build gates every push.

---

## Phase 4: User Story 2 - Every distinct documentation configuration is covered (Priority: P2)

**Goal**: coverage provably spans every docs-affecting branch, duplicates are skipped by
identity, and new fixtures are picked up with zero edits.

**Independent Test**: break one branch-specific docs input (ml notebooks, license-none), confirm
only that branch's fixtures fail. Add a fixture directory, confirm it is covered unedited.

### Implementation for User Story 2

- [X] T009 [US2] Implement the docs-inputs digest in `scripts/check_docs.py`: hash each fixture's
      `properdocs.yml`, `docs/`, `src/`, `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, and
      `notebooks/` (paths relative to the fixture root), build the first fixture per digest, and
      report later ones as covered-by with the builder's name (FR-002, FR-003, data-model.md)
- [X] T010 [US2] Verify by execution: seed a defect inside the ml-only branch of
      `project/properdocs.yml.jinja` (the notebooks nav entry), regenerate, run `make tests`,
      confirm only ml fixtures fail, then revert and confirm green
- [X] T011 [US2] Verify by execution: seed a defect inside the `copyright_license != "None"`
      branch of `project/properdocs.yml.jinja` (the license nav entry), regenerate, run
      `make tests`, confirm the license-none fixture passes while others fail, then revert
- [X] T012 [US2] Verify by execution: copy an existing fixture to a scratch name under
      `tests/expected/`, run `python3 scripts/check_docs.py`, confirm the copy is reported as
      covered-by its docs-identical original with no edit to the gate, then delete the copy
      (SC-005, FR-003's skip path exercised)

**Checkpoint**: branch coverage and zero-edit pickup are demonstrated, not assumed.

---

## Phase 5: User Story 3 - The suite stays practical to run on every change (Priority: P3)

**Goal**: the gate holds SC-004's time bounds and fails legibly when prerequisites are missing.

**Independent Test**: time `make tests` locally and in CI, and run the gate with uv hidden.

### Implementation for User Story 3

- [X] T013 [US3] Measure a warm `make tests` locally, confirm under 10 minutes (research R4
      predicts about a minute for the gate), and record the measurement for the commit body
      (SC-004)
- [X] T014 [US3] Verify by execution: run `PATH=/usr/bin:/bin python3 scripts/check_docs.py` and
      confirm the output names uv as the missing prerequisite and how to get it, with no fixture
      reported as a documentation failure (FR-008)
- [ ] T015 [US3] Push the feature branch and confirm the fixtures job in
      `.github/workflows/tests.yml` runs the gate on the push and completes within 15 minutes
      (SC-004), with no workflow edit needed since the job already installs uv

**Checkpoint**: the gate is cheap enough to stay in the default pre-commit path.

---

## Phase 6: User Story 4 - The docs stack is declared as one tool (Priority: P4)

**Goal**: generated projects and the repository declare properdocs as the single documentation
tool, with the US1 gate proving the swap changes nothing (FR-012).

**⚠️ BLOCKED**: T016 must pass before any other task in this phase. Research R2: properdocs 1.6.7
does not carry the plugin stack, and merging the swap before a release that does would break
every generated project's docs build, violating Principle I.

**Independent Test**: grep the regenerated fixtures for mkdocs in dependency declarations and
badges, and run `make tests`.

### Implementation for User Story 4

- [ ] T016 [US4] Confirm on PyPI that a properdocs release carries the documentation stack
      (theme, mkdocstrings, gen-files, literate-nav, section-index, gallery, coverage, callouts,
      markdown-exec, jupyter) as dependencies or an extra, record the version and whether jupyter
      is included, and stop this phase if no such release exists
- [ ] T017 [P] [US4] Collapse the `docs` groups in `project/pyproject.toml.jinja` to the single
      properdocs requirement at the version from T016, in both the `[tool.pdm.dev-dependencies]`
      and the uv `[dependency-groups]` branches, keeping a separate ml-only jupyter requirement
      only if T016 found jupyter excluded (FR-009)
- [ ] T018 [P] [US4] Replace the mkdocs material badge with a properdocs badge in
      `project/README.md.jinja` (FR-010)
- [ ] T019 [P] [US4] Apply the single-tool rule to the repository's own `[dependency-groups]` in
      `pyproject.toml`, removing the enumerated mkdocs packages properdocs now carries (FR-011)
- [ ] T020 [US4] Run `make regen-fixtures` and confirm `git diff tests/expected/` moves only
      `pyproject.toml` and `README.md` files (Development Workflow rule on fixture movement)
- [ ] T021 [US4] Verify by execution: run `make tests` and confirm every docs build still passes
      against the collapsed declaration with `scripts/check_docs.py` unedited (FR-012, FR-013,
      SC-006), and run
      `grep -rn mkdocs tests/expected/*/pyproject.toml tests/expected/*/README.md`
      expecting no match (SC-007)
- [ ] T022 [US4] Run `make tests-integration`, mandatory because `project/pyproject.toml.jinja`
      changed, and confirm every layout's generated toolchain still passes

**Checkpoint**: generated projects name one documentation tool, and nothing about their docs
build changed.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T023 [P] Describe the docs gate where the repository documents its own suites, which
      turned out to be `CONTRIBUTING.md` rather than `README.md`, whose Testing section covers
      generated projects, so T023 and T024 landed as one `CONTRIBUTING.md` change
- [X] T024 [P] Update `CONTRIBUTING.md` where it describes `make tests`, adding the docs gate
      stage and the first-run network note
- [ ] T025 Run the whole of quickstart.md end to end as the feature's final validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none.
- **US1 (Phase 3)**: after Setup. T002 → T003 → T004 (one file, in dependency order) → T005 →
  T006 → T007 → T008.
- **US2 (Phase 4)**: after US1, since T009 edits the same script and T010 to T012 exercise it.
- **US3 (Phase 5)**: after US1. Independent of US2, so it can interleave with Phase 4.
- **US4 (Phase 6)**: after US1 (the gate is its regression net) and after the external properdocs
  release (T016). Independent of US2 and US3. May land in a later release than Phases 3 to 5.
- **Polish (Phase 7)**: T023 and T024 after US1, final wording after whichever later phases have
  landed. T025 last.

### Parallel Opportunities

- T017, T018, T019 touch three different files and can run in parallel once T016 passes.
- T023 and T024 touch different files and can run in parallel.
- US3's T013 and T014 can run while US2 is in progress.

### Commit Split (Principle V)

- US1 plus its verification: `feat: Gate the fixtures' docs builds in the test suite`.
- US2's digest and verifications: part of the US1 commit if landed together, otherwise its own
  `tests:` commit.
- US4: one `feat:` commit for the template swap with regenerated fixtures, one `refactor:` commit
  for the repository's own dependency group.
- Polish: `docs:` commits.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1, then Phase 3 in task order.
2. Stop at the T008 checkpoint: the docs gate is live on every push, and the feature already
   delivers its core value.

### Incremental Delivery

1. US1 → gate live (MVP, releasable).
2. US2 → coverage semantics proven, digest skip path in place (releasable).
3. US3 → time bounds and prerequisite messaging confirmed (releasable).
4. US4 → waits for the properdocs release, lands under the gate whenever that ships.
5. Polish → documentation reflects whatever has landed.
