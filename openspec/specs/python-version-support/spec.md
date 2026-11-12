# python-version-support Specification

## Purpose
Define how the generator takes the Python range a project supports, rejects ranges it cannot honour,
and derives the Python versions the generated project declares and tests against.

## Requirements

### Requirement: Accepted range forms

The generator MUST accept a lower bound written as `>=3.N` or `>3.N`, optionally with a patch
component, followed by an optional upper bound written as `<3.M` or `<=3.M`, separated by a comma.
The lowest supported minor version MUST be 3.11 or later.

#### Scenario: Bounded range

- **WHEN** a project is generated with `python_versions` set to `>=3.11, <3.14`
- **THEN** generation succeeds and the derived versions are 3.11, 3.12, and 3.13

#### Scenario: Patch component on the lower bound

- **WHEN** a project is generated with `python_versions` set to `>=3.11.0, <3.14`
- **THEN** generation succeeds and the derived versions are 3.11, 3.12, and 3.13

#### Scenario: Exclusive lower bound and inclusive upper bound

- **WHEN** a project is generated with `python_versions` set to `>3.11, <=3.13`
- **THEN** generation succeeds and the derived versions are 3.12 and 3.13

### Requirement: Open upper bound

When the answer has no upper bound, the derived versions MUST run from the lower bound through the
newest Python minor version the template supports, and `requires-python` MUST keep the answer as the
user wrote it.

#### Scenario: Lower bound only

- **WHEN** a project is generated with `python_versions` set to `>=3.12`
- **THEN** generation succeeds, `requires-python` is `>=3.12`, and the derived versions run from 3.12
  through the template's newest supported minor version

### Requirement: Invalid ranges are rejected before rendering

An answer outside the accepted forms, a lower bound below 3.11, or a range that leaves no supported
version MUST be rejected at the question with a message that names the accepted forms. Generation
MUST NOT reach rendering and fail there with a traceback.

#### Scenario: Unsupported specifier

- **WHEN** `python_versions` is set to `~=3.12`, `==3.12`, or `>=3.12, !=3.13`
- **THEN** the question is rejected with a message that names the accepted forms

#### Scenario: Lower bound too old

- **WHEN** `python_versions` is set to `>=3.10, <3.14`
- **THEN** the question is rejected with a message that the minimum is Python 3.11

#### Scenario: Empty range

- **WHEN** `python_versions` is set to `>=3.13, <3.13`
- **THEN** the question is rejected with a message that the range contains no Python version

### Requirement: One derivation feeds every consumer

Every generated file that lists Python versions, the nox sessions, the trove classifiers, the black
and ruff target versions, and the GitHub CI version list, MUST use the same derived versions, so they
cannot disagree for any answer.

#### Scenario: Consumers agree

- **WHEN** a project is generated with any accepted `python_versions`
- **THEN** the nox session versions, the classifiers, the CI version list, and the lowest version used
  for the black and ruff targets all describe the same set of versions

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
