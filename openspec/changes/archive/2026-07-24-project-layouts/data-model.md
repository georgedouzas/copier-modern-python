# Phase 1 Data Model: Project Layouts

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-07-24

The "data" of a Copier template is its answer set and the rendering decisions derived from
it. This document defines the new answer, its derived values, and the rules that constrain
them.

## Entity: Layout

A kind of project the generator can produce. Represented by the `project_layout` answer.

| Field | Value |
| ----- | ----- |
| Answer key | `project_layout` |
| Type | `str` (Copier `choices`) |
| Values | `library`, `script`, `ml` |
| Default | `library` |
| Asked | Always, in the Project section beside `package_manager` |

### Values

| Value | Help text intent | Publishable | Source shape |
| ----- | ---------------- | ----------- | ------------ |
| `library` | Importable package distributed to others | Yes | `src/<pkg>/` |
| `script` | Command line tool with an entry point | Yes | `src/<pkg>/` + `cli.py` |
| `ml` | Experiments and models, notebooks alongside code | No | `src/<pkg>/` + `flow.py`, `notebooks/`, `data/` |
| `dataeng` | Pipelines that move and shape data | No | `src/<pkg>/` + `pipeline.py`, `conf/`, `data/` |
| `service` | A web API you deploy and run | No | `src/<pkg>/` + `app.py` |

`dataeng` and `service` shipped after the first three, added under FR-012 without changing them —
the procedure US3 anticipated, exercised for real. `dataeng` is built on Kedro with telemetry
declined (research R8 resolved), `service` on FastAPI.

### Validation rules

- **VR-001**: `project_layout` MUST be one of the three values. Copier enforces this via
  `choices`.
- **VR-002**: `library` MUST be the default, so accepting all defaults reproduces today's
  output (FR-002).
- **VR-003**: A layout MUST NOT alter the task interface beyond the documented per-layout
  session applicability below (FR-006).

## Derived values

Values computed from `project_layout` rather than asked. These are the rendering decisions;
keeping them named and in one place is what stops the conditionals sprawling.

| Derived value | Rule | Governs |
| ------------- | ---- | ------- |
| `is_publishable` | `project_layout not in ['ml', 'dataeng', 'service']` | Whether `publish_pypi` is asked at all |
| `has_cli` | `project_layout == 'script'` | Whether `cli.py` and `[project.scripts]` render |
| `include_dockerfile` | asked; defaults to `project_layout in ['dataeng', 'service']` | Whether a `Dockerfile` and `.dockerignore` render. A real question, not a derived value: deployed layouts default it on, any layout can opt in. |
| `has_notebooks` | `project_layout == 'ml'` | Whether `notebooks/` and `data/` render, whether notebook tooling is declared (FR-020), and whether lint/coverage carry notebook rules |
| `has_flow` | `project_layout == 'ml'` | Whether `flow.py` and the workflow dependency render (research R4a). Kept separate from `has_notebooks` so a future layout can take one without the other |

`has_api_docs` was planned and then dropped: it was true for every layout, because every layout
exposes an importable package. See research R6. A derived value that never varies is a
conditional waiting to be mis-set, not an abstraction.

## Relationships to existing answers

| Existing answer | Interaction |
| --------------- | ----------- |
| `publish_pypi` | Gains `when: "{{ project_layout != 'ml' }}"`, default `false` when not asked. Resolves the spec's contradictory-answer edge case by never posing it (R5). |
| `python_package_distribution_name` | Already `when: "{{ publish_pypi }}"`; inherits the above transitively, no change needed. |
| `python_package_import_name` | Unchanged. Every layout has an importable package, including `ml`. |
| `git_provider` | Orthogonal. Every layout must render against all four values (FR-005). |
| `package_manager` | Orthogonal. Every layout must render against both values (FR-005). |

## State transitions

The only transition is `copier update` on an existing project.

- **ST-001**: A project generated before this feature has no `project_layout` in its
  `.copier-answers.yml`. Copier applies the default, `library`, which renders what the
  project already has. It therefore updates cleanly without re-answering and without
  changing kind (FR-011).
- **ST-002**: Changing `project_layout` on an existing project via `copier update` is **out
  of scope**. It is not forbidden, but it is not supported or tested; the result is whatever
  Copier's diff produces. Recorded so the omission is deliberate rather than discovered.

## Session applicability matrix

The task interface (FR-006). Every session exists for every layout unless stated; this table
is the documentation FR-006 requires for any difference.

| Session | library | script | ml | Note |
| ------- | ------- | ------ | -- | ---- |
| `clean` | ✅ | ✅ | ✅ | |
| `formatting` | ✅ | ✅ | ✅ | |
| `checks` | ✅ | ✅ | ✅ | Same strictness everywhere (FR-007) |
| `tests` | ✅ | ✅ | ✅ | |
| `docs` | ✅ | ✅ | ✅ | Same name and meaning; nav content differs (R6) |
| `changelog` | ✅ | ✅ | ✅ | |
| `release` | ✅ | ✅ | ✅ | Present everywhere; publish step absent for `ml` (R5) |

**Zero sessions are absent for any layout.** The differences are in what `docs` renders and
whether `release` ends in a publish, both of which are content differences inside a shared
session rather than a hole in the interface.
