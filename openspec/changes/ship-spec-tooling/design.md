# Design

## Context

The template asks two independent booleans today, `include_agents_md` (default true) and
`include_speckit` (default false). Spec Kit shipping is one conditional directory,
`project/{% if include_speckit %}.specify{% endif %}/memory/constitution.md.jinja`, a 353-line
file carrying its own copy of the engineering body. The repo-agnostic constitution lives
untracked at the repository root as `constitution.md`, about 230 lines after its simplification
on 2026-10-04 (examples and rationales dropped, Engineering consolidated to seven subsections,
Governance flattened, Project Profile a top-level section), and is shipped by nothing. Fixtures carry two variant directories, `-agents-md-disabled` and
`-speckit-enabled`, on top of the base cross product.

## Goals / Non-Goals

Goals: one `spec_tool` question with OpenSpec as default, one constitution seed shared by both
tools, AGENTS.md gone from shipping, fixtures covering all three answers.

Non-goals: running either tool's init during generation, changing this repository's own
constitution under `openspec/`, altering the generated quality floor or release topology.

## Decisions

### The question

`spec_tool` replaces both booleans in `copier.yml`, a choice in the existing style of
`project_layout`:

```yaml
spec_tool:
  type: str
  help: The spec-driven workflow tool your project ships with
  default: openspec
  choices:
    "OpenSpec, AI-native spec-driven development": openspec
    "Spec Kit, GitHub's spec-driven development kit": speckit
    "None": none
```

### One seed, two wrappers

The root `constitution.md` moves to `includes/constitution.md` at the template root, outside
`_subdirectory: project`, so copier never renders it as an output file. Each tool's shipped
constitution is a thin Jinja wrapper that includes it:

- `project/{% if spec_tool == 'openspec' %}openspec{% endif %}/constitution.md.jinja`
- `project/{% if spec_tool == 'speckit' %}.specify{% endif %}/memory/constitution.md.jinja`

Each wrapper renders a short project-specific header (project name, the note that the file is
seeded from the template, the tool's own completion step: `openspec init` or `specify init`),
then `{% include 'includes/constitution.md' %}`, then a Project Profile section instantiated
from the answers, naming the package manager, the layout's framework, and the task runner. The
existing 353-line Spec Kit body is deleted in favour of the include, so the seed exists once
(the Duplication rule of the constitution itself). Copier resolves Jinja includes against the
template root, which the first implementation task verifies by rendering before anything is
deleted.

The OpenSpec choice additionally ships
`project/{% if spec_tool == 'openspec' %}openspec{% endif %}/config.yaml.jinja` with the default
schema and a context block naming `openspec/constitution.md` as binding. No `changes/` or
`specs/` directories are shipped: `openspec init` creates what the tool needs, and empty
directories do not survive git anyway.

### AGENTS.md removal

`project/{% if include_agents_md %}AGENTS.md{% endif %}.jinja` and the `include_agents_md`
question are deleted. The generated README's AI assistants section and this repository's README
are rewritten around the spec tool choice.

### Fixtures

In `scripts/regen_fixtures.py`, the `-speckit-enabled` and `-agents-md-disabled` variants are
replaced by `-spec-tool-speckit` (`{'spec_tool': 'speckit'}`) and `-spec-tool-none`
(`{'spec_tool': 'none'}`). The base cross product picks up the OpenSpec default, so every base
fixture gains `openspec/` content in the same regeneration. The docs gate needs no edit: its
coverage lists `tests/expected/` and its docs-inputs digest does not read `openspec/` or
`.specify/`.

## Migration

A project generated before this change holds `include_speckit` and `include_agents_md` in its
answers file. On `copier update`, copier drops answers whose questions no longer exist and asks
`spec_tool` with its default. Two consequences to state in the release notes: an updating
project is offered OpenSpec regardless of its old Spec Kit answer, and a project that had
AGENTS.md keeps the file on disk but the template stops managing it. Both are acceptable: the
answer is a one-keystroke choice at update time, and an unmanaged AGENTS.md is inert.

## Risks / Trade-offs

- The include path behaviour of copier is the one mechanism this design leans on, so it is
  verified by execution first (task 1.1), before the old Spec Kit body is deleted.
- Defaulting to OpenSpec puts scaffolding into every default-answered project. The scaffold is
  two static files, and the None answer remains for projects that want neither tool.
