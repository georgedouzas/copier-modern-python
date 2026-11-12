# Spec Delta

## Purpose

Give people who use the template a working way to report a bug in it or request a feature, through
issue forms that GitHub recognises and that describe this repository.

## ADDED Requirements

### Requirement: GitHub recognises every issue form

Every file under the repository's `.github/ISSUE_TEMPLATE/` MUST have a `.yml` or `.yaml` extension and
MUST parse as YAML, so GitHub offers each form in the new-issue chooser.

#### Scenario: Opening a new issue

- **WHEN** a person opens the new-issue page of the repository
- **THEN** the chooser offers a bug report form and a feature request form

### Requirement: Forms describe this repository

The issue forms MUST contain no template placeholders and MUST link only to pages that exist on this
repository.

#### Scenario: Bug report form content

- **WHEN** a person opens the bug report form
- **THEN** its link to past issues points at this repository's issues page and its text shows no `{{`
  or `}}`

### Requirement: Forms apply existing labels

Each form MUST apply only labels that exist on the repository.

#### Scenario: Submitting a form

- **WHEN** a person submits the bug report or the feature request form
- **THEN** the issue receives the `bug` or the `enhancement` label respectively
