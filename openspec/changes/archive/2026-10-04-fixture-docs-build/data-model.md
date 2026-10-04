# Data Model: Fixture Tests Build the Docs

The feature adds no persistent data. The entities below are the working objects of the docs build
gate, `scripts/check_docs.py`.

## Fixture

A committed answer combination under `tests/expected/<name>/`, fully rendered.

- `name`: the directory name, encoding the answers (layout, provider, package manager, variants).
- `path`: `tests/expected/<name>`.
- `docs inputs`: the files its docs build reads: `properdocs.yml`, `docs/`, `src/`, `README.md`,
  `CONTRIBUTING.md`, `CHANGELOG.md`, and for the ml layout `notebooks/`.
- `docs dependency declaration`: the `docs` group in its `pyproject.toml`, under
  `[tool.pdm.dev-dependencies]` or `[dependency-groups]`. Today only pdm fixtures scope one, the
  uv fixtures fold docs requirements into their `dev` group, and every combination has a pdm
  twin, so the union over `docs` groups covers the full toolchain.

Derived, never stated: the gate discovers fixtures by listing `tests/expected/`, so the fixture
set stays single-sourced in `scripts/regen_fixtures.py` (FR-004, Principle III).

## Docs configuration identity

A hash over a fixture's docs inputs, used to honour FR-003.

- `digest`: content hash of the docs inputs, with file paths, taken relative to the fixture root.
- Rule: the first fixture with a given digest is built, later ones are recorded as covered by it.
- Current reality: all digests differ (research R4), so every fixture builds. The rule is kept so
  coverage shrinks only when fixtures genuinely become docs-identical.

## Docs build environment

One shared virtual environment for the whole run.

- `requirements`: the union of all fixtures' docs dependency declarations (FR-013).
- `location`: a temp or cache directory outside the repository tree.
- `provisioner`: uv, already a prerequisite of `make checks` and the CI jobs.
- Failure to provision is a prerequisite error naming the missing piece (FR-008), never reported
  as a documentation defect.

## Docs build run

One execution of `properdocs build` for one fixture.

- `fixture`: the fixture built.
- `workdir`: a temp copy of the fixture, so `site/` and `docs/generated/` never touch the repo.
- `environment overrides`: `PYTHONPATH=src` (research R3).
- `outcome`: pass when the build exits zero, fail otherwise.
- `output`: captured stdout and stderr, printed on failure under the fixture's name (FR-005).

## State transitions

```text
discover fixtures -> derive requirements -> provision environment
  -> for each fixture: digest -> build or skip-as-duplicate -> record outcome
  -> report: pass, or each failing fixture with its output, exit non-zero
```
