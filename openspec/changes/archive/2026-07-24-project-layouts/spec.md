# Feature Specification: Project Layouts

**Feature Branch**: `001-project-layouts`

**Created**: 2026-07-24

**Status**: Draft

**Input**: User description: "Support multiple generated project layouts. Today copier-modern-python only generates a library layout: a src/ package with a distribution name, published to PyPI, documented with an API reference. Users starting a script or CLI tool, a machine learning project, or a data engineering pipeline have to delete and rewrite parts of what they get. Add a layout choice to copier.yml so the generated source tree, dependency set, documentation shape, and applicable nox sessions match the kind of project being started, while every layout keeps the same quality floor: the same checks, tests and release topology, across all four git providers and both package managers. Library layout must remain the default and must keep generating exactly what it generates today."

## Clarifications

### Session 2026-07-24

- Q: How should the spec bound the cost a layout may add to the quality floor? → A: A relevance rule, not a time budget — a layout MUST NOT add a dependency unless a task exercises it.
- Q: Should changing `project_layout` on an existing project via update be supported? → A: Out of scope, and documented as such — the answer may be changed, but the result is whatever the update merge produces.
- Q: Should generated data or artifact directories be version-control ignored by default? → A: Yes — contents excluded by default, the directory itself still tracked so the structure survives a clone.
- Q: Should the machine learning kind ship a workflow framework, or only shape and configuration? → A: A workflow framework, provided it runs locally with no infrastructure and a task exercises it; plus the means to run any notebooks it generates. Modelling libraries and tracker servers remain excluded. The specific choice is recorded in the design, not here.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Choosing a layout at generation time (Priority: P1)

Someone starting a new project is asked what kind of project it is, alongside the questions
they are already asked about provider, package manager and licence. They pick the kind that
matches their intent, and the project they receive is shaped for that kind of work: the
source tree, the dependencies, the documentation and the available tasks all fit. Nothing has
to be deleted before work starts.

**Why this priority**: This is the feature. Without a choice at generation time there is
nothing to deliver, and every other story refines what that choice produces. It is also the
smallest slice worth shipping: one additional kind beside the library one proves the
mechanism and already serves a real group of users.

**Independent Test**: Generate a project for each offered kind and confirm each one installs,
passes its own quality checks and passes its own test suite without manual repair, and that
no file in it is vestigial for that kind of project.

**Acceptance Scenarios**:

1. **Given** someone runs the generator and is offered a layout choice, **When** they accept
   every default, **Then** they receive the library layout, identical to what the generator
   produced before this feature existed.
2. **Given** someone selects a non-library layout, **When** generation finishes, **Then** the
   project installs, its quality checks pass and its tests pass with no edits.
3. **Given** someone selects a non-library layout, **When** they inspect the result, **Then**
   it contains no artifact that exists only to serve a different kind of project.
4. **Given** any layout is selected, **When** it is generated against each supported provider
   and package manager, **Then** every combination produces a working project.

---

### User Story 2 - Keeping the quality floor identical across layouts (Priority: P2)

Someone who has used the generator before starts a project of a different kind. The commands
they already know still work and still mean the same thing. Formatting, quality checks, type
checking, security scanning, docstring coverage, dependency auditing, tests, changelog and
release behave the same way regardless of the kind of project, except where a task genuinely
does not apply.

**Why this priority**: The generator's value is the floor it guarantees, not the file tree it
emits. A layout that quietly drops type checking or ships a different release process turns
one dependable tool into several unreliable ones. This ranks below Story 1 only because the
choice must exist before its consistency can be judged.

**Independent Test**: For every layout, list the available tasks and run each one. Confirm the
set of task names matches, that each behaves equivalently, and that any task absent from a
layout is absent for a stated reason rather than by omission.

**Acceptance Scenarios**:

1. **Given** two projects of different layouts, **When** their task lists are compared,
   **Then** the names and meanings match, except for tasks documented as inapplicable.
2. **Given** a project of any layout, **When** its quality checks run, **Then** the same
   checks are enforced at the same strictness as the library layout.
3. **Given** a publishable project of any layout, **When** a release is cut, **Then** it
   follows the same topology: the local task prepares and tags, the pipeline publishes, and
   exactly one publisher exists for the version.
4. **Given** a layout for which publishing is not meaningful, **When** it is generated,
   **Then** publishing is absent by design and the omission is stated, not silent.

---

### User Story 3 - Adding a further layout later (Priority: P3)

A maintainer adds support for another kind of project. They add it in one place, following the
shape the existing layouts establish, without reworking the generator's spine and without
touching the layouts already shipped.

**Why this priority**: This decides whether the feature is a foundation or a one-off. It is
valuable but not required for the first release, and it is best judged once more than one
layout exists to generalise from.

**Independent Test**: Add a further layout following only the documented procedure, and confirm
the previously shipped layouts produce identical output to before.

**Acceptance Scenarios**:

1. **Given** a maintainer adds a new layout, **When** the existing layouts are regenerated,
   **Then** their output is unchanged.
2. **Given** a new layout is added, **When** the test suite runs, **Then** it fails until
   coverage for that layout is present.

---

### Edge Cases

- What happens when a layout is chosen alongside a contradictory answer, such as requesting
  publication to a package index for a layout that produces nothing publishable? The generator
  must resolve this predictably and say what it did, rather than emitting a project configured
  to publish something that does not exist.
- What happens to someone on an existing generated project when they update to a version that
  has layouts? Their project predates the choice; it must continue to update as a library
  project without being asked to re-answer and without silently changing kind.
- What happens to someone who changes the kind of an existing project on update, for instance a
  library that grows into a machine learning project? Out of scope per FR-018: not prevented,
  not supported, and documented as such rather than left to be discovered.
- How does the system handle a layout whose natural dependencies are heavy enough that the
  quality floor becomes slow, and people start skipping it? Addressed by FR-017: the constraint
  is relevance rather than runtime. A layout carries only what a task exercises, so weight has
  to be earned. Slowness that survives that rule is accepted.
- What happens when a task has no meaning for a layout, such as an API documentation task for
  a project that exposes no importable package? It must be absent or adapted deliberately,
  never present-but-broken.
- What happens when someone selects a combination of layout and package manager that has no
  fixture coverage? The matrix grows multiplicatively, and an untested combination must not be
  presented as supported.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The generator MUST ask which kind of project is being created, as one of a fixed
  set of choices, at the same point it asks its other questions.
- **FR-002**: The library kind MUST be the default, and selecting it MUST produce output
  identical to what the generator produced before this feature.
- **FR-003**: Each kind MUST determine the generated source tree, the dependency set, the
  documentation shape, and which tasks are available.
- **FR-004**: Every kind MUST produce a project that installs, passes its own quality checks
  and passes its own test suite immediately after generation, with no manual repair.
- **FR-005**: Every kind MUST be generatable in combination with every supported git provider
  and every supported package manager.
- **FR-006**: The set of task names MUST be the same across kinds, except where a task does not
  apply to a kind, in which case its absence MUST be documented.
- **FR-007**: Quality enforcement — formatting, linting, type checking, security scanning,
  docstring coverage and dependency auditing — MUST be applied at the same strictness to every
  kind.
- **FR-008**: For kinds that produce a publishable artifact, the release topology MUST match
  the library kind: a local task prepares and tags, the pipeline publishes, and exactly one
  publisher exists per version.
- **FR-009**: For kinds that produce nothing publishable, publishing MUST be omitted rather
  than generated and left broken.
- **FR-010**: Every kind MUST be represented in the fixture suite by at least one generated
  combination, and MUST be generated and executed by the integration suite.
- **FR-011**: Projects generated before this feature MUST continue to update cleanly, treated
  as the library kind, without the user re-answering.
- **FR-012**: Adding a further kind MUST NOT require changes to already-shipped kinds and MUST
  NOT alter their generated output.
- **FR-013**: Where an answer contradicts the selected kind, the generator MUST resolve it
  predictably and report what it did.
- **FR-014**: The documentation MUST state which kinds exist, what each produces, and which
  tasks differ for each.
- **FR-015**: The first release MUST offer exactly three kinds: library, script or CLI tool,
  and machine learning. Data engineering is wanted but deferred, and MUST be addable later
  under FR-012 without changing the three that shipped.
- **FR-016**: The machine learning kind MUST be the case that proves FR-009: it produces no
  artifact published to a package index, so its generated project MUST omit publishing while
  still carrying the full quality floor of FR-006 and FR-007.
- **FR-017**: A kind MUST NOT add a dependency to the generated project unless one of that
  project's tasks exercises it. Illustrative or aspirational dependencies are forbidden: every
  generated project pays for each one, including the projects that wanted a different choice.
  Dependency weight is therefore bounded by relevance, not by a runtime budget.
- **FR-018**: Changing the kind of an existing project on update is OUT OF SCOPE. It is not
  prevented, but it is not supported or tested, and the outcome is whatever the update merge
  produces. The documentation required by FR-014 MUST state this, so the limit is a published
  boundary rather than a surprise.
- **FR-019**: Where a kind generates a directory intended to hold data or model artifacts, that
  directory's contents MUST be excluded from version control by default, while the directory
  itself remains tracked so the structure survives a clone. The safe default matters because the
  failure it prevents — data reaching a shared repository — cannot be undone by a later commit.
- **FR-020**: Where a kind generates an artifact of a particular format, the project MUST also
  carry the means to run or open that artifact. A directory of notebooks with nothing able to
  execute a notebook is the vestigial output FR-004 and the third acceptance scenario of User
  Story 1 forbid. This bounds FR-017 from the other side: relevance excludes what nothing uses,
  and this requires what the generated output needs.
- **FR-021**: Any framework a kind adds MUST be runnable locally, with no account, server or
  other infrastructure the user must provision. A framework whose value requires infrastructure
  the generator cannot supply MUST NOT be a default.

### Key Entities

- **Layout**: A kind of project the generator can produce. Defines a source tree shape, a
  dependency set, a documentation shape, and the applicable task set. The library layout is
  the default and the reference against which others are judged.
- **Quality floor**: The guarantees every generated project carries regardless of layout — the
  task interface, the enforced checks, and the release topology.
- **Generation matrix**: The combinations of layout, git provider and package manager that are
  offered, and therefore must be demonstrated to work.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Someone starting a project of any offered kind can go from generation to a first
  passing run of that project's own checks and tests without editing or deleting any generated
  file.
- **SC-002**: Accepting every default produces output identical to the pre-feature generator,
  established by comparison rather than by inspection.
- **SC-003**: Every offered combination of kind, provider and package manager produces a
  project that installs and passes its own checks and tests.
- **SC-004**: The task interface is identical across kinds, with every difference accounted for
  in documentation; zero undocumented differences.
- **SC-005**: Every offered kind appears in the fixture suite and is exercised by the
  integration suite; zero kinds are offered without coverage.
- **SC-006**: A project generated before this feature updates to the version introducing
  layouts without conflict attributable to the layout change, and without changing kind.
- **SC-007**: A maintainer can add a further kind by following the documented procedure alone,
  leaving the output of existing kinds unchanged.
- **SC-008**: Every dependency in a generated project can be traced to a task that exercises it;
  zero dependencies exist for illustration alone.
- **SC-009**: Adding a file to a generated data or artifact directory leaves the project's
  version control status clean; the directory survives a clone with zero data files carried.
- **SC-010**: Every artifact format a kind generates can be run or opened using only what the
  generated project already installs, with no account or server to provision first.

## Assumptions

- "Layout" and "kind of project" name the same concept; the specification uses plain language
  and the implementation may name it differently.
- The library layout's current output is the baseline. Any change to it caused by this feature
  is a regression, not an improvement, and is out of scope.
- Layout is an additional dimension of the existing generation matrix, not a replacement for
  any existing question. Provider and package manager remain independently selectable.
- Because the matrix grows multiplicatively, fixture coverage is representative rather than
  exhaustive: every value of every dimension appears at least once, but not every combination
  is enumerated. This follows the constitution's coverage rule.
- Layouts differ in what they generate, never in whether the quality floor applies, per the
  constitution's matrix parity principle.
- Some layouts will pull heavier dependencies than the library layout. Slower generated
  toolchains are acceptable; a weaker quality floor is not. What is not acceptable is weight
  that nothing uses, which FR-017 forbids. No runtime budget is imposed, because a threshold
  meaningful across developer machines and CI runners would be either flaky or too loose to
  ever fire.
- This feature implies no change to the generator's own release process, test harness structure
  or supported provider set.
- Three kinds ship first (library, script/CLI, machine learning) and data engineering is
  deferred. Machine learning is included ahead of it deliberately: it is the case least like
  the library layout, so it stresses the abstraction before further kinds are built on it.
  Data engineering is expected to reuse whatever that stress reveals.
- A distinction is drawn between two categories of framework, and only one is acceptable as a
  default. A *modelling* library encodes a choice the practitioner owns and that no task the
  generator ships could exercise. A *workflow* library is scaffolding, which is what a kind
  exists to provide. FR-017 and FR-021 are what separate them in practice: exercised by a task,
  and runnable without infrastructure.
