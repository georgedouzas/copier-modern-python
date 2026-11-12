# Spec Delta

## Purpose

Define how the generator takes the Python range a project supports, rejects ranges it cannot honour,
and derives the Python versions the generated project declares and tests against.

## ADDED Requirements

### Requirement: CI runs inside the supported range

On every git provider, each CI job MUST run on a Python version inside the project's supported range.
Jobs that run on one interpreter MUST use the lowest supported version.

#### Scenario: Raised lower bound on a non-GitHub provider

- **WHEN** a project is generated for GitLab, Bitbucket, or Azure DevOps with `python_versions` set to
  `>=3.12, <3.14`
- **THEN** no job in its pipeline runs on Python 3.11, and the single-interpreter jobs run on 3.12

### Requirement: Tests run on every supported version

On every git provider, the test job MUST make every derived Python version available, so the test
sessions run on the whole supported range rather than skip the versions the CI image lacks.

#### Scenario: Full range under test

- **WHEN** the test job of a generated GitLab, Bitbucket, or Azure DevOps pipeline runs with the
  default range
- **THEN** the test sessions run on 3.11, 3.12, and 3.13, and none is skipped for a missing interpreter

### Requirement: The container image uses a supported version

The generated Dockerfile MUST build and run on the newest version in the supported range.

#### Scenario: Range below the previous fixed image

- **WHEN** a service project is generated with `python_versions` set to `>=3.11, <3.13`
- **THEN** the Dockerfile's build and runtime stages use Python 3.12
