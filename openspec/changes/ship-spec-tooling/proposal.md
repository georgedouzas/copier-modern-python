# Proposal

## Why

Generated projects currently get their AI agent conventions through an opt-in AGENTS.md and an
opt-in Spec Kit constitution, while the engineering body those are seeded from lives as a stray
`constitution.md` at this repository's root, belonging to no shipped file. Spec-driven tooling
has moved on, this repository itself now runs on OpenSpec, and the template should ship one
coherent vehicle for a generated project's principles instead of three loosely related options.

## What Changes

- The `include_speckit` boolean question becomes a `spec_tool` choice: OpenSpec, Spec Kit, or
  None, with OpenSpec as the default. **BREAKING**: projects generated before this change
  recorded `include_speckit` in their answers file, a question that no longer exists, so
  `copier update` asks the new question and defaults to OpenSpec.
- The engineering constitution at the repository root, the repo-agnostic body of MUST rules
  ending in a Project Profile, moves into the template as the single seed both tools ship.
  OpenSpec ships it as `openspec/constitution.md` beside an `openspec/config.yaml` whose context
  points at it. Spec Kit keeps shipping it as `.specify/memory/constitution.md`. The root copy
  is removed.
- AGENTS.md is removed from shipping entirely: the `include_agents_md` question, the
  `AGENTS.md.jinja` template, and its fixture variant all go. **BREAKING**: a generated project
  that wants an AGENTS.md writes its own, and the shipped constitution is the template's one
  vehicle for agent conventions.
- Fixture variants change accordingly: `-speckit-enabled` and `-agents-md-disabled` are
  replaced by `-spec-tool-speckit` and `-spec-tool-none`, and every base fixture gains the
  default OpenSpec scaffold.

This change is orthogonal to the layout, git provider, and package manager matrix: the new
question and shipped files are identical across every branch of all three dimensions, and the
full cross product of base fixtures picks up the OpenSpec default uniformly, so no branch is
treated specially.

Out of scope: running `openspec init` or `specify init` on behalf of the generated project (the
shipped files are static scaffolding, each tool's own init completes its setup), any change to
the repository's own constitution in `openspec/constitution.md`, which governs this repository
rather than generated projects, and any change to the quality floor, tasks, or release topology
of generated projects.

## Capabilities

### New Capabilities

- `spec-tooling`: which spec-driven tool a generated project ships with, what each choice lays
  down, and the constitution seed both choices share.

### Modified Capabilities

<!-- none: project-layouts, repo-python-gate, and fixture-docs-gate requirements are unchanged.
     The fixture variant renames fall out of spec-tooling's own coverage requirement; the
     fixture-docs-gate derives its coverage from tests/expected/ and needs no edit. -->

## Impact

- `copier.yml`: the `include_speckit` and `include_agents_md` questions are replaced by
  `spec_tool`.
- `project/`: the AGENTS.md template is deleted, the `.specify` conditional directory is keyed
  to the new answer, a new conditional `openspec` directory is added, and both tools'
  constitution files render from one shared seed moved in from the repository root.
- `constitution.md` at the repository root: removed, its content now lives in the template.
- `scripts/regen_fixtures.py` and `tests/expected/`: variant fixtures renamed, every fixture
  regenerated.
- `README.md` and the generated README: the AI assistants section describes the spec tool
  choice instead of AGENTS.md plus Spec Kit.
- Existing projects on `copier update`: see the breaking notes above.
