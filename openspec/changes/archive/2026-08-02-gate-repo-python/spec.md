# Feature Specification: Gate the Repository's Own Python

**Feature Branch**: `002-gate-repo-python`

**Created**: 2026-08-02

**Status**: Draft

**Input**: User description: "Gate the repository's own Python with ruff and mypy, and make its scripts conform to the Code Conventions in the constitution. The repository enforces a quality gate on every project it generates but runs none of it on its own Python. ruff and mypy are the sensible floor for two standalone scripts with no declared runtime dependencies."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The repository holds itself to the bar it sets (Priority: P1)

A maintainer changes one of the repository's own scripts. The same kind of linting and type checking
the template puts on every generated project now runs on that script, locally on commit and in the
suite. A change that introduces a lint violation or a type error is caught before it lands, the same
way it would be caught in a project the template generated.

**Why this priority**: This is the feature. The constitution states a quality gate as a non-negotiable
principle and the repository does not run it on its own code. Closing that gap is the whole point, and
one script gated proves the mechanism.

**Independent Test**: Introduce a deliberate lint violation and a deliberate type error in a script,
run the commit and the suite, and confirm each is blocked. Remove them and confirm both pass.

**Acceptance Scenarios**:

1. **Given** a maintainer edits a script and stages it, **When** they commit, **Then** the gate runs and
   a lint violation or a type error blocks the commit.
2. **Given** the repository's scripts as they stand, **When** the gate runs, **Then** it passes with no
   findings, so the gate is green on the code that ships today.
3. **Given** the test suite, **When** it runs, **Then** it runs the same gate, so a violation that slips
   past a local commit is caught by the suite in CI.

---

### User Story 2 - Findings are fixed, not silenced (Priority: P2)

Where the gate reports something on the existing scripts, the maintainer fixes it at the source rather
than suppressing the rule. A suppression is a last resort for a genuine one-off and carries its rule
code and reason, as the Code Conventions require.

**Why this priority**: A gate that is satisfied by blanket suppressions enforces nothing. This keeps the
gate honest, but it ranks below standing the gate up, because there is nothing to fix until the gate
runs.

**Independent Test**: Read the scripts and the configuration after the change and confirm there is no
blanket rule disablement, and that any remaining suppression names its rule and its reason.

**Acceptance Scenarios**:

1. **Given** the gate reports a finding on an existing script, **When** the maintainer resolves it,
   **Then** the resolution is a change to the code, not a disabled rule, unless a suppression is
   justified in place with its rule code and reason.

---

### Edge Cases

- What is in scope for the gate? Only the repository's own Python, the scripts under `scripts/`. The
  `.jinja` templates under `project/` are not Python and are governed by the constitution the template
  seeds into a generated project. The rendered Python under `tests/expected/` is generated output that is
  never hand-edited, so gating it would report on code the repository does not author.
- What happens when the gate and the existing scripts disagree on a rule that is a matter of taste rather
  than a defect? The rule is configured once, in one place, with intent, rather than suppressed line by
  line.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Formatting, linting, and type checking MUST run on the repository's own Python, the scripts
  under `scripts/`.
- **FR-002**: The gate MUST run locally on commit, so a violation blocks the commit.
- **FR-003**: The gate MUST run in the repository's test suite, so a violation blocks the suite and CI.
- **FR-004**: The repository's scripts MUST pass the gate with no findings at the point this feature is
  complete.
- **FR-005**: A finding on an existing script MUST be fixed at the source. A suppression is permitted only
  as a justified one-off that names its rule code and its reason, and a rule that is a matter of taste is
  configured once rather than suppressed repeatedly.
- **FR-006**: The gate MUST NOT run on the `.jinja` templates under `project/` or on the rendered output
  under `tests/expected/`, because the first is not Python the repository authors as Python and the second
  is generated output.
- **FR-007**: The gate's configuration MUST live in one place, so its rules are recorded rather than
  scattered.
- **FR-008**: The scope of the gate is formatting, linting, and type checking, and its tools use the same
  configuration the template ships for a generated project. The dependency and security tools of the
  generated-project floor are out of scope, because the repository declares no runtime dependencies to
  audit and its Python is two standalone scripts rather than a distributed package.

### Key Entities

- **The repository's own Python**: the scripts under `scripts/`, currently `regen_fixtures.py` and
  `check_pipelines.py`. This is the code the repository authors and ships, as distinct from the templates
  it renders and the fixtures it generates.
- **The gate**: the linting and type checking that the change stands up, run on commit and in the suite.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A deliberate lint violation or type error in a script is blocked on commit and by the suite;
  removing it lets both pass.
- **SC-002**: The repository's scripts pass the gate with zero findings on the code that ships today.
- **SC-003**: The quality principle the constitution states now runs on the repository's own Python, so
  the repository meets the bar it sets for the projects it generates, within the linting and type-checking
  scope of this feature.
- **SC-004**: No blanket rule disablement exists; every remaining suppression names its rule and its
  reason.

## Assumptions

- The gate is formatting, linting, and type checking, resolved with the maintainer as the sensible floor
  for two standalone scripts, with the tools configured exactly as the template configures them for a
  generated project. The dependency and security tools of the full seven-tool floor are deliberately out
  of scope for the reasons in FR-008.
- Where the gate's configuration lives, in a new project file or a standalone configuration file, is an
  implementation choice for the plan, not a requirement of this specification.
- The scripts already carry type annotations and docstrings, so the change is expected to add the gate and
  make small conformance fixes, not to rewrite the scripts.
