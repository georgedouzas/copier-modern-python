# Proposal

## Why

Generated projects invoke properdocs as their documentation tool but still enumerate the
underlying mkdocs plugin stack, eight `mkdocs-*` packages and friends, in their docs dependency
groups, and their README badge says mkdocs. properdocs should own that stack, so a generated
project declares one documentation tool and the engine becomes an internal detail.

This was User Story 4 of the Spec Kit feature `003-fixture-docs-build` (archived under
`openspec/changes/archive/2026-10-04-fixture-docs-build/`). It is blocked on an external
dependency: properdocs 1.6.7, the latest release on PyPI, does not carry the plugin stack as its
own dependencies, so collapsing the declarations today would break every generated project's
docs build. The fixture docs gate (`openspec/specs/fixture-docs-gate/`) is already in place as
the regression net for the swap.

## What Changes

- The `docs` dependency groups in `project/pyproject.toml.jinja` collapse to the single
  properdocs requirement, in both the PDM and the uv branches.
- The generated README's documentation badge names properdocs instead of mkdocs.
- The repository's own `[dependency-groups]` in `pyproject.toml` follows the same single-tool
  rule.
- Fixtures are regenerated, and the docs gate must stay green with no edit to the gate itself.

Out of scope: the plugin identifiers inside `properdocs.yml` and the `mkdocs_gen_files` imports
in the docs generator scripts, which are properdocs' compatible plugin surface and keep their
names until the tool renames them.

## Capabilities

### New Capabilities

- `docs-toolchain`: what a generated project declares and advertises about its documentation
  toolchain, a single named tool rather than an enumeration of the engine's plugins.

### Modified Capabilities

<!-- none: the fixture-docs-gate requirements are unchanged; the gate's derivation rule is what
     lets this change land without touching it -->

## Impact

- `project/pyproject.toml.jinja`, `project/README.md.jinja`, the repository's `pyproject.toml`,
  and every fixture's `pyproject.toml` and `README.md` under `tests/expected/`.
- Blocked until a properdocs release carries the documentation stack (theme, mkdocstrings,
  gen-files, literate-nav, section-index, gallery, coverage, callouts, markdown-exec, jupyter)
  as dependencies or an extra. Do not merge before that release exists.
