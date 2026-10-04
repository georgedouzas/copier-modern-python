# Spec Delta

## Purpose

What a generated project declares and advertises about its documentation toolchain: one named
tool, properdocs, rather than an enumeration of the underlying engine's plugin packages.

## ADDED Requirements

### Requirement: One declared documentation tool

A generated project MUST declare its documentation toolchain as the single tool properdocs. Its
docs dependency declarations MUST NOT enumerate the underlying engine or its plugin packages,
for either package manager. The engine may still arrive in the environment as a transitive
dependency of the tool's own stack; the requirement is about what the project declares.

#### Scenario: Reading a generated project's dependencies

- **WHEN** a generated project's docs dependency declarations are read, for either package
  manager
- **THEN** they name properdocs and no mkdocs plugin package

### Requirement: The badge names the tool

The generated README's documentation badge MUST name properdocs, not mkdocs.

#### Scenario: Reading a generated README

- **WHEN** a generated README's badges are read
- **THEN** the documentation badge names properdocs

### Requirement: The repository follows its own rule

The repository's own tooling dependencies MUST follow the same single-tool rule for the docs
stack.

#### Scenario: Reading the repository's dependency groups

- **WHEN** the repository's own dependency groups are read
- **THEN** the docs stack is the single properdocs requirement

### Requirement: The swap changes nothing observable

The replacement MUST NOT change whether or what the documentation build produces, established by
the fixture docs gate passing across all covered configurations before and after the swap, with
the gate itself unedited.

#### Scenario: Gate before and after

- **WHEN** the collapsed declarations land and fixtures are regenerated
- **THEN** every covered docs build still passes and `scripts/check_docs.py` is unchanged
