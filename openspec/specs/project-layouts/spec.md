# project-layouts Specification

## Purpose

Define the kinds of project the template generates. A layout fits the generated tree to the kind
of work being started, library, command line tool, machine learning, data engineering, or
service, without ever weakening the guarantees every generated project carries.

## Requirements

### Requirement: Layout choice at generation

The generator MUST ask which kind of project is being created, as one of a fixed set of choices,
at the same point it asks its other questions. The choices are library, script, ml, dataeng, and
service. The library kind MUST be the default.

#### Scenario: Default generation

- **WHEN** a project is generated with all defaults
- **THEN** the library layout is produced, an importable `src/` package distributed to others

### Requirement: Layout determines the generated shape

Each layout MUST determine the generated source tree, the dependency set, the documentation
shape, and which tasks are available. A layout MUST NOT add a dependency unless one of the
generated project's tasks exercises it, any framework it adds MUST run locally with no account or
server to provision, and where a layout generates an artifact of a particular format the project
MUST also carry the means to run or open it.

#### Scenario: Machine learning layout

- **WHEN** the ml layout is generated
- **THEN** it carries a Metaflow flow, a `notebooks/` directory executed by the test suite and
  rendered into the docs, and a `data/` directory whose contents stay out of version control
  while the directory itself remains tracked

#### Scenario: Deployed layouts

- **WHEN** the dataeng or service layout is generated
- **THEN** dataeng carries a Kedro pipeline with a `conf/` catalog and a telemetry opt-out, and
  service carries a FastAPI application with a health endpoint, each with a Dockerfile by default

### Requirement: Every layout yields a working project

Every layout MUST produce a project that installs, passes its own quality checks, and passes its
own test suite immediately after generation, with no manual repair step.

#### Scenario: Fresh generation

- **WHEN** a project of any layout is generated and its `install`, `checks`, and `tests` tasks run
- **THEN** all of them pass

### Requirement: Uniform quality floor

The set of task names MUST be the same across layouts, except where a task does not apply, in
which case its absence MUST be documented. Formatting, linting, type checking, security scanning,
docstring coverage, and dependency auditing MUST be applied at the same strictness to every
layout.

#### Scenario: Checks across layouts

- **WHEN** the `checks` task runs in any generated project
- **THEN** the same tools run at the same strictness regardless of layout

### Requirement: Matrix coverage

Every layout MUST be generatable in combination with every supported git provider and every
supported package manager. The golden fixtures MUST cover the full cross product of layout, git
provider, and package manager, and every layout MUST be generated and executed by the integration
suite.

#### Scenario: Fixture suite

- **WHEN** the golden suite runs
- **THEN** every layout, provider, and package manager combination renders identically to its
  committed fixture

### Requirement: Release topology per layout

For layouts that produce a publishable artifact, the release topology MUST match the library
kind: a local task prepares and tags, the pipeline is the sole publisher, and exactly one
publisher exists per version. For layouts that produce nothing publishable, ml, dataeng, and
service, publishing MUST be omitted rather than generated and left broken.

#### Scenario: Non-publishable layout

- **WHEN** an ml, dataeng, or service project is generated
- **THEN** no publishing question is asked and no publish job is generated, while the full
  quality floor remains

### Requirement: Layout change on update is out of scope

Changing the layout of an existing project on `copier update` is not supported or tested, and the
outcome is whatever the update merge produces. The documentation MUST state this boundary.

#### Scenario: Documented boundary

- **WHEN** a user reads the template documentation
- **THEN** it states which layouts exist, what each produces, and that changing layout after
  generation is unsupported
