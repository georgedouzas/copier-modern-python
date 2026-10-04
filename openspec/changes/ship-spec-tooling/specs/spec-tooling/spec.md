# Spec Delta

## Purpose

Which spec-driven tool a generated project ships with, what each choice lays down, and the
engineering constitution seed both choices share.

## ADDED Requirements

### Requirement: The generator asks which spec tool to ship

The generator MUST ask which spec-driven tool the generated project carries, as a choice of
OpenSpec, Spec Kit, or none, at the same point it asks its other questions. OpenSpec MUST be the
default. The question MUST be identical across every layout, git provider, and package manager.

#### Scenario: Default generation

- **WHEN** a project is generated with all defaults
- **THEN** it carries the OpenSpec scaffolding and no Spec Kit files

#### Scenario: Opting out

- **WHEN** a project is generated with the spec tool answered none
- **THEN** it carries no OpenSpec and no Spec Kit files

### Requirement: OpenSpec shipping

When OpenSpec is chosen, the generated project MUST carry an `openspec/` directory holding a
`config.yaml` with the default schema and a context that points at the constitution, and the
constitution itself as `openspec/constitution.md`. The scaffolding MUST be static files only,
with the tool's own init left to the user to complete the setup.

#### Scenario: Generated OpenSpec project

- **WHEN** a project is generated with OpenSpec
- **THEN** `openspec/config.yaml` and `openspec/constitution.md` exist, and the config's context
  names the constitution as binding

### Requirement: Spec Kit shipping

When Spec Kit is chosen, the generated project MUST carry the constitution as
`.specify/memory/constitution.md`, with `specify init` left to the user to complete the setup,
matching the shipping shape that existed before this change.

#### Scenario: Generated Spec Kit project

- **WHEN** a project is generated with Spec Kit
- **THEN** `.specify/memory/constitution.md` exists and no `openspec/` directory does

### Requirement: One constitution seed

Both tools MUST ship the same engineering constitution, rendered from a single seed inside the
template, the repo-agnostic body of MUST rules ending in a Project Profile the generated
project fills in. The seed MUST exist in exactly one place in the template, and the
repository root MUST NOT carry a loose constitution file.

#### Scenario: Comparing the two tools' output

- **WHEN** two projects are generated from the same answers except the spec tool
- **THEN** the constitution content they carry is the same body, placed per tool

### Requirement: AGENTS.md is not shipped

The generator MUST NOT ask about or ship an AGENTS.md. The shipped constitution is the
template's one vehicle for a generated project's conventions, and a project that wants an
AGENTS.md writes its own.

#### Scenario: Generated project tree

- **WHEN** a project is generated with any combination of answers
- **THEN** no AGENTS.md is present and no question about one was asked

### Requirement: Fixture coverage of the choice

The golden fixtures MUST cover each value of the spec tool choice: the default through the base
cross product, and the Spec Kit and none values through one variant fixture each.

#### Scenario: Fixture suite

- **WHEN** the fixture suite runs
- **THEN** fixtures exist for the OpenSpec default, a Spec Kit variant, and a none variant, and
  all render identically to their committed output
