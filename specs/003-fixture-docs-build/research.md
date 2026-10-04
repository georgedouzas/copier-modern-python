# Research: Fixture Tests Build the Docs

All findings below were established by execution on 2026-10-04, per Principle IV. The experiments
ran in a scratch directory against copies of committed fixtures, with uv's warm cache.

## R1. How a generated project builds its docs today

The generated `docs` nox session installs the project with its `docs` dependency group and runs
`properdocs build` or `properdocs serve`. The `docs` group names properdocs plus the mkdocs plugin
stack: mkdocs-coverage, mkdocs-gen-files, mkdocs-literate-nav, mkdocs-material, mkdocs-gallery,
mkdocs-section-index, mkdocstrings[python], markdown-callouts, markdown-exec, pandas, and for the
ml layout mkdocs-jupyter. Neither test suite builds docs today. The golden suite diffs rendered
output, and the integration suite runs `checks` and `tests` sessions only.

**Decision**: the gate builds docs the way the product does, by running `properdocs build` against
a fixture's rendered tree, so a pass means the product's own docs command works.

## R2. properdocs is an mkdocs fork, and the plugins run under it

properdocs 1.6.7 on PyPI declares mkdocs' own dependency list (click, jinja2, markdown, watchdog,
ghp-import, pyyaml-env-tag, an i18n extra) and no plugin. Installing the generated `docs` group
yields both properdocs 1.6.7 and mkdocs 1.6.1 in one environment, the latter pulled transitively
by the plugins. `properdocs build` drives the build and the mkdocs-API plugins load and run under
it, confirmed by successful builds in R4. properdocs does not yet carry the plugin stack as its
own dependencies, so collapsing the generated `docs` group to properdocs alone would not install
the theme or the renderers today.

**Decision**: the single-tool replacement (FR-009 to FR-012) is gated on a properdocs release that
carries the documentation stack, as its dependencies or an extra. The gate lands first and is the
regression net for the swap. The plan phases the work accordingly.

## R3. mkdocstrings needs the package importable, and `PYTHONPATH=src` suffices

A build from a bare fixture copy fails with `Could not collect 'test_repo'`, because mkdocstrings
resolves the package from `sys.path` and the fixture is not installed. Setting `PYTHONPATH=src`
makes the build pass with no project install. No layout needed its runtime framework installed:
the ml, dataeng, service, and script fixtures all built without metaflow, kedro, fastapi, or
click in the environment, because the API renderer reads the sources statically.

**Decision**: the gate sets `PYTHONPATH=src` and never installs the fixture project or its runtime
dependencies.

**Alternative rejected**: installing each fixture with its package manager, as the nox session
does. It needs pdm for half the fixtures, resolves 55 environments, and proves nothing more for
this gate. The integration suite already exercises the real install path.

## R4. One shared environment builds every layout, in well under the budget

One venv holding the union of the `docs` groups (the base list plus mkdocs-jupyter) built the
library, script, ml, dataeng, and service fixtures successfully. Measured times: venv creation
plus install about 1.5 s with a warm uv cache, each `properdocs build` 0.3 to 0.5 s. Fifty-five
fixtures extrapolate to under a minute warm. A cold CI cache adds one download and install of the
stack, on the order of a minute. Both sit far inside SC-004's bounds of 15 minutes in CI and 10
minutes locally.

**Decision**: one shared environment for all fixtures, provisioned with uv, holding the union of
the fixtures' `docs` groups. Coverage is every fixture, with FR-003's identity rule implemented as
a hash over each fixture's docs inputs so duplicates would be skipped if they ever appear.

**Alternative rejected**: selecting one fixture per distinct docs configuration by hand. The spec
assumed the package manager did not touch docs inputs, and inspection falsified that: the
development page's wording branches on the package manager, the README (included into the docs
index via snippets) branches on provider and manager, and `properdocs.yml` branches on provider
and layout. No two fixtures are docs-identical, a hand-picked subset would need its own list to
maintain, and building everything is cheap enough not to bother.

## R5. Where the gate lives

**Decision**: a new `scripts/check_docs.py`, invoked by `make tests` after the golden suite and
`scripts/check_pipelines.py`. It discovers fixtures by listing `tests/expected/`, reads each
fixture's `pyproject.toml` to derive the toolchain to install (FR-013). The pdm fixtures scope a
`docs` group under `[tool.pdm.dev-dependencies]`, while the uv fixtures fold the docs
requirements into their single `dev` group under `[dependency-groups]`, so the gate reads a
`docs` group from either form where one exists, and the pdm twins cover every combination today.
Parsing uses stdlib `tomllib`. The gate provisions the shared venv, copies each fixture to a temp
directory, builds, and on failure prints the fixture name and the captured build output. Missing
uv or an unreachable index is reported as a prerequisite failure naming what to install (FR-008),
distinct from a documentation defect.

**Alternatives rejected**: extending `tests/test_copier.bats`, because environment provisioning,
TOML parsing, and failure reporting in bash duplicate what Python does plainly, and the repo
already has the `check_pipelines.py` precedent for a Python stage inside `make tests`; a separate
make target, because FR-006 requires the existing entry point.

## R6. Scope of the mkdocs surface to replace

Explicit mkdocs references in generated projects: the `docs` dependency group (R1), the README's
"docs: mkdocs material" badge, `import mkdocs_gen_files` in `docs/generate_api.py` and the ml
layout's `docs/generate_notebooks.py`, plugin identifiers and a `mkdocstrings.css` filename inside
`properdocs.yml`. The repository's own `pyproject.toml` dev group likewise names mkdocs-material,
markdown-exec, mkdocs-section-index, and mdx-truly-sane-lists next to properdocs.

**Decision**: the replacement covers the dependency declarations (template, both package manager
branches, and the repository's own dev group) and the README badge. The plugin identifiers, the
gen-files imports, and the css filename are properdocs' compatible plugin surface and stay, per
the spec's scope assumption.
