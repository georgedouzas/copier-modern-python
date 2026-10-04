# Implementation Plan: Gate the Repository's Own Python

**Branch**: `002-gate-repo-python` | **Date**: 2026-08-02 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-gate-repo-python/spec.md`

Stand up black, ruff, and mypy on the repository's own Python, the two scripts under `scripts/`, wired
into `.pre-commit-config.yaml` and the `make tests` suite so a violation blocks the commit and the suite.
The configuration lives in a new root `pyproject.toml`, and each tool uses the same configuration the
template ships for a generated project, because the constitution requires tool configuration to live once
in `pyproject.toml` and the point of the feature is to hold the repository to the bar it sets. All three
tools are scoped to `scripts/`, so the `.jinja` templates and the rendered fixtures are untouched.

Running the tools now, before writing this plan, established the real work.

- **black** with the template's config reformats one line in `check_pipelines.py`, joining a split f-string
  that fits within 120 characters.
- **mypy** with `types-PyYAML` already passes clean, so the scripts are well typed.
- **ruff** under the template's ruleset reports eight findings of three kinds. The plan resolves each in
  line with the Code Conventions: refactor the one genuine complexity finding, and justify the two that
  are correct as written.

## Technical Context

**Language/Version**: Python, the repository's own scripts run on 3.11 or newer.

**Primary Dependencies**: the gate tools, black, ruff, and mypy, plus `types-PyYAML` for the one
third-party import. The scripts themselves import only the standard library and PyYAML.

**Storage**: N/A.

**Testing**: the existing `bats` golden and integration suites, which this feature extends by adding the
gate to the `make tests` target.

**Project Type**: a Copier template repository. Its own Python is two standalone scripts, not a package.

**Performance Goals**: the gate adds a second or two to `make tests`, which is acceptable next to the
fixture render it already runs.

**Constraints**: the gate MUST run only on `scripts/`, never on `project/` or `tests/expected/` (FR-006).

**Scale/Scope**: two files, 310 lines.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

This feature exists because the repository fails its own constitution today. The check names where.

| Principle | Assessment |
| --------- | ---------- |
| IV. Automated Quality Gates | **Currently violated, and this feature is the remediation.** The constitution states formatting, linting, and static type checking as a non-negotiable gate. The repository runs none of it on its own Python. Closing that gap is the whole feature. |
| Code Conventions | The scripts are checked against the conventions the constitution states. black proves the formatting discipline, mypy the type discipline, ruff the lint discipline. The findings are fixed at the source, and the two that are correct as written carry a scoped, reasoned suppression, exactly as the Comments & Suppressions convention allows. |
| III. Fixtures Are the Specification | Untouched, and protected. FR-006 keeps the gate off `tests/expected/`, so the gate never reports on generated output the repository does not author. |
| I, II, V, VI | Not engaged by this change. |

**Result**: no unjustified violation. The one active principle, IV, is the reason the feature exists, and
the plan satisfies it. The scoped ruff suppressions are recorded in Complexity Tracking below.

## Project Structure

### Documentation (this feature)

```text
specs/002-gate-repo-python/
├── plan.md              # This file
├── research.md          # Phase 0 output: the ruff and mypy findings and how each is resolved
├── quickstart.md        # Phase 1 output: how to prove the gate blocks and passes
├── checklists/
│   └── requirements.md  # Written by /speckit-specify
└── tasks.md             # Phase 2 output (/speckit-tasks, not created here)
```

data-model.md and contracts/ are not produced. This feature has no data entities and no external
interface. It is internal tooling.

### Source Code (repository root)

```text
pyproject.toml            # NEW: holds [tool.black], [tool.ruff], and [tool.mypy], the gate's config home
.pre-commit-config.yaml   # + black, ruff, and mypy hooks, scoped to ^scripts/
Makefile                  # `tests` target gains a black, ruff, and mypy run over scripts/ before the bats run
scripts/
├── regen_fixtures.py     # conformance fix: none beyond the shared config
└── check_pipelines.py    # conformance fix: black reformat one line; refactor main() to clear C901; scoped ignores for T20, ANN401
```

**Structure Decision**: the gate configuration lives in a new root `pyproject.toml`. The constitution's
Code Conventions require a recurring rule to be configured once in `pyproject.toml`, and the Toolchain
section names `pyproject.toml` as the config home, so a standalone `ruff.toml` would contradict what the
repository states. The file holds `[tool.black]`, `[tool.ruff]`, and `[tool.mypy]`, copied from the
template's own `project/pyproject.toml.jinja` so the repository is checked by the same configuration it
ships, with no `[project]` table because the repository is not a distributed package. All three tools are
pointed at `scripts/` and nothing else.

## Complexity Tracking

Two ruff rules are suppressed for `scripts/` rather than obeyed, each because the code is correct as
written. These are the justified one-offs the Code Conventions permit, configured once in `pyproject.toml`
rather than scattered inline.

| Suppression | Why the code is right | Simpler alternative rejected because |
| ----------- | --------------------- | ------------------------------------ |
| `T20` (print) on `scripts/` | The scripts are command-line tools whose output is their stdout. print is the interface, not debug noise. | A logger would add ceremony to a script whose entire job is to print progress and findings to a person running it. |
| `ANN401` (`Any`) in `check_pipelines.py` | The functions walk a parsed YAML document, which is genuinely of arbitrary shape. `Any` is the honest annotation for a node that may be a mapping, a sequence, or a scalar. | A recursive type alias would be more machinery than the two helpers are worth, and it would still collapse to `Any` at the leaves. |

The third finding, `C901` on `check_pipelines.main`, is not suppressed. It is fixed at the source by
extracting the per-file scan into a helper, which is the change the Control Flow convention asks for.
