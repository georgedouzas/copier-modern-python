# repo-dependency-updates Specification

## Purpose
Keep the repository's own CI and commit-hook dependencies, and the action versions the template writes
into generated projects, current, so neither the repository nor a new project starts behind.

## Requirements

### Requirement: The repository's own dependencies are tracked

The repository MUST have an update bot configuration that proposes updates to the GitHub Actions in its
own workflows and to its pre-commit hooks, on a regular schedule, grouped so one pull request carries
each ecosystem's updates.

#### Scenario: A new action release

- **WHEN** a new major version of an action used in the repository's workflows is released
- **THEN** a pull request updating it is opened within one scheduled run

### Requirement: Generated workflows start current

The GitHub workflows the template generates MUST pin the current major version of each action at the
time of the template release.

#### Scenario: Fresh GitHub project

- **WHEN** a GitHub project is generated from a template release
- **THEN** every action in its workflows is on the latest major version released before that template
  release, and the workflows pass on their first run
