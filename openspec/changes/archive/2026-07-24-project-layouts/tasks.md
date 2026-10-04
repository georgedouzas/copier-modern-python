---

description: "Task list for the project layouts feature"
---

# Tasks: Project Layouts

**Input**: Design documents from `/specs/001-project-layouts/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Test tasks are included and are **not optional here**. This repository's
constitution makes fixtures the specification (Principle III) and forbids establishing
behaviour by inspection (Principle IV), so fixture and harness work is part of the feature,
not an add-on.

**Organization**: Grouped by user story, so each is independently implementable and testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story the task serves (US1, US2, US3)
- Exact file paths included in every description

## Path Conventions

This is a Copier template. Two trees matter and must not be confused:

- **Template source**: `copier.yml`, `project/**` — the `.jinja` files that get rendered
- **Fixtures**: `tests/expected/**` — rendered output, regenerated never hand-edited

Paths containing `{% ... %}` are literal directory names on disk, not placeholders.

---

## Phase 1: Setup

**Purpose**: Make the freeze checkable before anything can break it.

- [X] T001 Add a `regen-fixtures` target to `Makefile` that renders all fixture combinations and rsyncs them into `tests/expected/`, replacing the ad-hoc script used during the CI work
- [X] T002 [P] Add a `scripts/check_pipelines.py` helper that loads every `tests/expected/*/**/*.yml` with a YAML parser and asserts each step name is a real mapping key, per quickstart S5
- [X] T003 Wire `scripts/check_pipelines.py` into `make tests` so structural pipeline validation runs with the fixture diff

**Checkpoint**: `make tests` now fails on a pipeline whose keys were swallowed into a script block — the defect class from the Azure `displayName` bug.

---

## Phase 2: Foundational (BLOCKING)

**Purpose**: Introduce the answer and prove it changed nothing. **No layout work may begin until T007 passes.**

- [X] T004 Add the `project_layout` question to `copier.yml` in the Project section beside `package_manager`, with `choices` of `library`, `script`, `ml` and `default: library`, per [data-model.md](./data-model.md)
- [X] T005 Add help text to `project_layout` in `copier.yml` describing each value as the kind of project it produces, not as a file tree
- [X] T006 Run `make regen-fixtures` and confirm `git diff --exit-code tests/expected/` reports no change — the question alone must not alter rendering
- [X] T007 Run `make tests` and confirm all existing fixture cases still pass

**Checkpoint (contract C7 proven)**: the library layout is frozen and the proof is a `git diff` exit code, not a review. If T006 shows any change, stop and find out why before continuing — do not regenerate the fixture to make it pass.

---

## Phase 3: User Story 1 — Choosing a layout at generation time (P1) 🎯 MVP

**Goal**: A layout choice at generation time produces a project shaped for that kind of work.

**Independent test**: Generate each layout and confirm it installs and passes its own checks and tests with no manual repair (quickstart S2).

### Derived values and gating

- [X] T008 [US1] Add the derived-value conditionals (`is_publishable`, `has_api_docs`, `has_cli`, `has_notebooks`) to `project/pyproject.toml.jinja` as documented in [data-model.md](./data-model.md), rendering identically to today on the `library` branch
- [X] T009 [US1] Make `publish_pypi` conditional in `copier.yml` with `when: "{{ project_layout != 'ml' }}"` and a default of `false` when unasked, per research R5

### Script/CLI layout

- [X] T010 [P] [US1] Add `project/src/{{python_package_import_name}}/{% if project_layout == 'script' %}cli.py{% endif %}.jinja` with a minimal working command
- [X] T011 [US1] Add a conditional `[project.scripts]` entry point and the `click` dependency to `project/pyproject.toml.jinja`, gated on `has_cli`, per research R3
- [X] T012 [P] [US1] Add a test for the generated CLI to `project/tests/test_{{python_package_import_name}}.py.jinja`, gated on `has_cli`, so the entry point is exercised rather than merely declared

### ML layout

- [X] T013 [P] [US1] Add `project/{% if project_layout == 'ml' %}notebooks{% endif %}/` with a placeholder notebook so the directory renders and has something to open
- [X] T014 [P] [US1] Add `project/{% if project_layout == 'ml' %}data{% endif %}/` with a `.gitignore` that ignores its own contents while keeping the directory tracked, per FR-019
- [X] T015 [US1] Add notebook-aware `ruff` and `coverage` configuration to `project/pyproject.toml.jinja`, gated on `has_notebooks`
- [X] T015a [US1] Add notebook tooling (`jupyter`/`ipykernel`) to the ML dependency set in `project/pyproject.toml.jinja`, gated on `has_notebooks`, so `notebooks/` is not vestigial per FR-020
- [X] T015b [P] [US1] Add `project/src/{{python_package_import_name}}/{% if project_layout == 'ml' %}flow.py{% endif %}.jinja` containing a minimal Metaflow `FlowSpec` that runs locally with no cloud account, per research R4a
- [X] T015c [US1] Add the `metaflow` dependency to `project/pyproject.toml.jinja`, gated on `has_flow`
- [X] T015d [US1] Add a test to `project/tests/test_{{python_package_import_name}}.py.jinja`, gated on `has_flow`, that executes the generated flow locally — this is what makes the dependency satisfy FR-017 rather than merely be declared
- [X] T016 [US1] Confirm no publish step renders for `ml` in any of the four pipeline templates under `project/`, and that the `release` nox session still renders (quickstart S4)

### Fixtures

- [X] T017 [P] [US1] Add a `Test script layout choice` case to `tests/test_copier.bats` comparing against `tests/expected/script-layout`
- [X] T018 [P] [US1] Add a `Test ML layout choice` case to `tests/test_copier.bats` comparing against `tests/expected/ml-layout`
- [X] T019 [US1] Run `make regen-fixtures` to create `tests/expected/script-layout/` and `tests/expected/ml-layout/` by rendering, then `make tests`
- [X] T020 [US1] Re-run `git diff --exit-code tests/expected/default/` to confirm the new layouts did not disturb the frozen library output

**Checkpoint**: three layouts render and are covered by fixtures. This is the MVP — shippable on its own.

---

## Phase 4: User Story 2 — Identical quality floor across layouts (P2)

**Goal**: The commands a user already knows still work and still mean the same thing.

**Independent test**: List and run every task for each layout; confirm names match and any difference is documented (quickstart S3).

- [X] T021 [US2] Verify the `[tool.pdm.scripts]` table renders identically across `tests/expected/default`, `script-layout` and `ml-layout`, and fix `project/pyproject.toml.jinja` if it does not (contract C2)
- [X] T022 [US2] Verify the `[tool.ruff]`, `[tool.mypy]`, `[tool.bandit]` and `[tool.interrogate]` sections are identical across layouts except for the documented notebook additions, per contract C3
- [X] T023 [US2] Add per-layout cases to `tests/test_integration.bats` that generate and run `install`, `checks`, `tests` and `docs build` for each layout (contract C1, quickstart S2)
- [X] T024 [US2] Adapt the `docs` session and `project/properdocs.yml.jinja` so the nav and `watch` paths follow the layout, keeping the session name and meaning unchanged, per research R6
- [X] T025 [US2] Gate `project/docs/generate_api.py.jinja` on `has_api_docs` so no API reference renders for `ml`, per research R6 and contract C5
- [X] T026 [US2] Extend `scripts/check_pipelines.py` to assert a publish step exists **iff** the layout is publishable and depends on the test and quality stages, per contract C4
- [X] T027 [US2] Run `make tests-integration` and confirm every layout and package-manager combination passes

**Checkpoint**: the floor is demonstrably identical, by execution rather than by claim.

---

## Phase 5: User Story 3 — Adding a further layout later (P3)

**Goal**: A maintainer can add a fourth layout without reworking the spine or disturbing shipped layouts.

**Independent test**: Follow the documented procedure to add a layout and confirm existing fixtures are unchanged.

- [X] T028 [P] [US3] Document the procedure for adding a layout in `CONTRIBUTING.md`: the answer value, the derived values, the conditional path-name convention, and the required fixture
- [X] T029 [US3] Dry-run the procedure by sketching the deferred data-engineering layout far enough to confirm no spine change is needed, then revert — recording what was learned in [research.md](./research.md)
- [X] T030 [US3] Confirm `git diff --exit-code tests/expected/` is clean after the dry-run revert

**Checkpoint**: the feature is a foundation rather than a one-off.

---

## Phase 6: Polish & Cross-Cutting

- [X] T031 [P] Update `README.md` to describe the three layouts and what each produces (FR-014, and the ⚠ item in the constitution's Sync Impact Report)
- [X] T031a [P] State in `README.md` that changing a project's layout on update is out of scope, per FR-018 — a published boundary rather than a surprise
- [X] T032 [P] Update `project/README.md.jinja` so a generated project's README reflects its own layout
- [X] T033 Verify `copier update` on a pre-feature project does not prompt for `project_layout` and does not change its kind (FR-011, quickstart S6)
- [X] T033a Verify FR-019 by adding a file under the ML fixture's `data/` and confirming version control status stays clean while the directory itself remains tracked (quickstart S7)
- [X] T034 Run every quickstart scenario S1-S8 end to end
- [X] T035 Confirm the constitution's Principle VI holds for the shipped result: every added dependency is configured, invoked by a session, and exercised by CI — specifically that `click` and `metaflow` each trace to a task that runs them (SC-008)
- [X] T036 Confirm FR-021 by generating an ML project on a machine with no cloud credentials and running its flow test — no account, server or provisioning may be required

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: no dependencies, start immediately
- **Foundational (Phase 2)**: depends on Setup. **Hard blocker** — T006 and T007 gate every later phase, by explicit instruction in the feature request
- **US1 (Phase 3)**: depends on Phase 2
- **US2 (Phase 4)**: depends on US1, since there must be layouts before their parity can be compared
- **US3 (Phase 5)**: depends on US1; independent of US2
- **Polish (Phase 6)**: depends on US1 at minimum

### Notable within-phase dependencies

- T009 before T016 — publishing must be gated before its absence can be verified
- T011 depends on T008 — the derived values must exist before they can gate anything
- T015b before T015c before T015d — the flow module exists, then the dependency that runs it, then the test that proves FR-017
- T019 after T010-T016 — fixtures are rendered from finished templates, never ahead of them
- T024 before T025 — shape the docs session before removing the API generator from it
- T036 after T015d — the local-only guarantee is verified against the same test the flow ships with

### Parallel opportunities

- T002 alongside T001
- T010, T012, T013, T014 — separate files, no shared state
- T017 and T018 — separate bats cases
- T028, T031, T032 — documentation, all independent

## Parallel Example: User Story 1

```text
# After T008 and T009 land, these four can proceed together:
T010  project/src/.../cli.py.jinja
T012  project/tests/test_....py.jinja
T013  project/{% if project_layout == 'ml' %}notebooks{% endif %}/
T014  project/{% if project_layout == 'ml' %}data{% endif %}/

# Then serialise: T011 → T015 → T016 → T019 → T020
```

## Implementation Strategy

**MVP is Phase 1 + Phase 2 + Phase 3.** That delivers the layout choice with all three
layouts rendering and covered by fixtures, and it is independently shippable.

Ship in this order, releasing at each checkpoint if desired:

1. **Phases 1-2** — the freeze proof. Valuable alone: it adds structural pipeline validation
   the repository currently lacks, and it is a no-op change to rendered output.
2. **Phase 3** — the layouts themselves. MVP.
3. **Phase 4** — parity verified by execution rather than asserted.
4. **Phases 5-6** — the foundation for the deferred data-engineering layout, plus docs.

**The order is deliberate and non-negotiable at one point**: the library-freeze proof (T006,
T007) lands before any new layout exists. Once a second layout is in the tree, a regression in
the first becomes far harder to attribute, because two things changed at once.

## Notes on task count

42 tasks: 3 setup, 4 foundational, 17 for US1, 7 for US2, 3 for US3, 8 polish. Every task names
a real path in this repository. Twelve are verifications rather than edits (T006, T007, T020,
T021, T022, T027, T030, T033, T033a, T034, T035, T036), listed as tasks deliberately — under
Principle IV, verification is work, not a formality appended to someone else's work.

The count grew from 35 after the clarification pass reopened the ML dependency decision. The
added tasks are the flow module and its test (T015b-T015d), notebook tooling (T015a), and the
verifications for the requirements the pass introduced (T031a, T033a, T036).
