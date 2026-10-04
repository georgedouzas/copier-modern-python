# Contract: What every layout guarantees

**Feature**: [spec.md](../spec.md) | **Date**: 2026-07-24

The generator's external interface is the project it hands a user. This contract states what
holds for **every** layout. A layout that cannot meet it is not ready to ship.

It is written to be checkable: each clause names how it is verified, so `/speckit-tasks` can
turn it into work and a reviewer can tell whether it held.

## C1: The project works on arrival

Immediately after generation, with no edits and no deletions:

- `<pm> install` (or `uv sync`) succeeds
- the project's `checks` task passes
- the project's `tests` task passes and produces `coverage.xml`
- the project's `docs build` task succeeds

**Verified by**: `tests/test_integration.bats`, one case per layout, per package manager.

## C2: The task interface is identical

Every layout exposes the same seven task names with the same meanings: `clean`, `formatting`,
`checks`, `tests`, `docs`, `changelog`, `release`.

No layout may remove, rename or repurpose a task. Where behaviour differs — the `docs` nav,
the `release` publish step — it differs inside the task, and the difference is documented in
[data-model.md](../data-model.md).

**Verified by**: comparing the script table across generated fixtures; any diff is a
contract breach unless [data-model.md](../data-model.md) records it.

## C3: The quality floor does not vary

`checks` enforces the same tools at the same strictness for every layout: `ruff`, `mypy`,
`bandit` (reading `pyproject.toml`), `interrogate`, `pip-audit`.

A layout MAY add configuration — notebook-aware excludes for `ml` — but MUST NOT relax a
rule, drop a tool, or narrow the checked file set to dodge a failure.

**Verified by**: the `[tool.*]` sections in each fixture's `pyproject.toml` are identical
except for documented layout additions.

## C4: Release topology is uniform

For every layout, `release` prepares locally — changelog, release branch, PR, merge, tag —
and pushes a tag the pipeline reacts to.

For publishable layouts the pipeline is the sole publisher, gated on green checks and tests.
For non-publishable layouts the publish step is absent, not broken.

Exactly one publisher exists per version, always.

**Verified by**: parsing each fixture's pipeline files; asserting a publish step exists iff
the layout is publishable, and that it depends on the test and quality stages.

## C5: Nothing vestigial

A generated project MUST NOT contain a file whose only purpose serves a different layout: no
API-reference generator where there is no package to document, no `[project.scripts]` without
a CLI module, no `notebooks/` for a library.

**Verified by**: fixture review at implementation time, and by C1 — a vestigial artifact
usually announces itself by failing a task.

## C6: Rendering is total

Every layout renders against every `git_provider` and every `package_manager`. No combination
may fail to render, and none may render a file containing an unrendered Jinja construct.

**Verified by**: rendering the full matrix in the fixture harness and parsing every generated
YAML file, per constitution Principle IV.

## C7: The library layout is frozen

The `library` layout's output is byte-identical to what the generator produced before this
feature. This is the strongest clause here: it is not "equivalent", it is "identical".

**Verified by**: the existing `tests/expected/` fixtures remaining untouched by the
implementation, checked with `git diff --exit-code tests/expected/` after regeneration.

## Breaking this contract

A change that breaks a clause is a breaking change to the generator, not a layout detail. It
requires the constitution's amendment path, or a documented and justified exception in the
commit body.
