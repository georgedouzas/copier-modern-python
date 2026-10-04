# Feature Specification: Fixture Tests Build the Docs

**Feature Branch**: `003-fixture-docs-build`

**Created**: 2026-10-04

**Status**: Draft

**Input**: User description: "The tests of fixtures should include building the docs", followed by
"in the same spec include replacement of mkdocs with paperdocs", clarified by the user to mean
properdocs: generated projects should declare properdocs as their documentation tool instead of
enumerating the underlying mkdocs stack.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A docs-breaking change fails the fixture tests (Priority: P1)

A maintainer edits the template, for example the documentation configuration, a docs page, or the
source tree a docs generator reads. The change renders fine, so the golden diff stays green, but the
documentation of a generated project no longer builds. When the maintainer runs the fixture tests,
the suite builds the documentation of the affected fixture projects and fails, naming the
combination whose docs build broke, before the change is committed or merged.

**Why this priority**: this is the whole feature. Today a change can ship that leaves every
generated project unable to build its own documentation, and nothing in the per-push tests says so.
The constitution holds that the generated project is the product and that claims are verified by
execution, and the docs build is currently the largest part of the product verified only by
inspection.

**Independent Test**: introduce a deliberate defect that breaks the docs build of a generated
project while still rendering valid output, for example a navigation entry pointing at a page that
does not exist. Run the fixture tests and confirm they fail and identify the broken combination.
Revert the defect and confirm they pass.

**Acceptance Scenarios**:

1. **Given** a template change that makes a generated project's documentation build fail, **When**
   the fixture tests run, **Then** the suite fails and the failure names the answer combination
   whose documentation did not build.
2. **Given** a template where every covered combination's documentation builds, **When** the fixture
   tests run, **Then** the suite passes, including the docs build step.
3. **Given** a docs build failure in one combination, **When** the suite reports it, **Then** the
   build output of the failing combination is available to the maintainer for diagnosis.

---

### User Story 2 - Every distinct documentation configuration is covered (Priority: P2)

A maintainer changes a branch of the documentation configuration that only some combinations use,
for example the notebook rendering of the machine learning layout or the navigation entry that
exists only when a license is chosen. The docs build coverage includes at least one fixture for
every distinct documentation configuration the template can produce, so the change is exercised and
cannot break a branch silently.

**Why this priority**: coverage that builds only one combination would miss exactly the defects
this template historically ships, the ones hiding in a conditional branch. Without this story the
feature gives false confidence, but the suite still catches global breakage, so it ranks below the
basic capability.

**Independent Test**: break a docs configuration branch used by only one layout, for example the
machine learning notebook page, and confirm the suite fails. Repeat for a branch used only when no
license is chosen.

**Acceptance Scenarios**:

1. **Given** the set of committed fixtures, **When** the docs build coverage is derived, **Then**
   every distinct rendered documentation configuration among the fixtures is built at least once.
2. **Given** two fixtures whose rendered documentation configuration and docs inputs are identical,
   **When** the docs build coverage is derived, **Then** the duplicate is not rebuilt, so the suite
   does not pay twice for the same proof.
3. **Given** a new layout or option added later with its fixtures, **When** the fixture tests run,
   **Then** its documentation configuration is picked up by the docs build coverage without a
   per-fixture case being written.

---

### User Story 3 - The suite stays practical to run on every change (Priority: P3)

A contributor runs the fixture tests locally before committing, and the CI runs them on every push
and pull request. With docs builds included, the suite still completes in a time that keeps it the
default pre-commit gate rather than something contributors learn to skip.

**Why this priority**: the value of the first two stories depends on the suite actually running on
every change. If docs builds make the suite slow enough that it moves to a scheduled job, the
feature degrades into the coverage the integration suite already provides.

**Independent Test**: run the full fixture suite, including docs builds, on a development machine
and in CI, and measure the wall-clock time against the success criteria.

**Acceptance Scenarios**:

1. **Given** the fixture suite including docs builds, **When** it runs in CI on a push, **Then** it
   completes within the time bound in the success criteria.
2. **Given** a contributor without the docs toolchain prepared, **When** the suite runs, **Then**
   the docs build step either provisions what it needs or fails with a message saying what to
   install, never with an unexplained error.

---

### User Story 4 - The docs stack is declared as one tool (Priority: P4)

A user generates a project and reads its dependency declarations. The documentation toolchain is
declared as a single tool, properdocs, rather than an enumeration of the underlying engine's
plugin packages. The engine and its plugins still arrive, but as the tool's own dependencies, so a
generated project no longer names mkdocs anywhere a user makes decisions: not in its dependency
declarations and not in its README badge. The docs build gate from the earlier stories proves the
swap changes nothing about whether the documentation builds.

**Why this priority**: this is a presentation and ownership change, not a behavioural one. It
depends on a properdocs release that carries the documentation stack as its own dependencies,
which is outside this repository, so it must be able to land after and independently of the gate.
The gate is also its safety net, which is why the two share a spec.

**Independent Test**: generate a project and inspect its dependency declarations and README. The
docs toolchain is one named tool and the badge names that tool. Run the fixture tests and confirm
every covered docs build still passes.

**Acceptance Scenarios**:

1. **Given** a generated project after the replacement, **When** its docs dependency declarations
   are read, **Then** they name properdocs and no mkdocs plugin package, for both package
   managers.
2. **Given** a generated project after the replacement, **When** its README badges are read,
   **Then** the documentation badge names properdocs rather than mkdocs.
3. **Given** the replacement applied to the template, **When** the fixture tests run, **Then**
   every covered documentation build passes, proving the collapsed declaration still builds the
   same site.
4. **Given** the repository's own tooling dependencies, **When** they are read, **Then** the same
   single-tool rule holds for its own docs stack.

---

### Edge Cases

- A fixture's documentation imports the generated package to document its API. The build must run
  against the fixture's own source tree, so a defect in the generated package's importability
  surfaces here as a docs build failure with a legible cause.
- The machine learning layout's documentation includes notebooks. Its docs build must cover the
  notebook path without executing long-running training code.
- A combination with no license omits the license page from the navigation. Both the with-license
  and without-license configurations must build.
- The docs build of a generated project fetches its tooling from a package index. When the index is
  unreachable the failure must be distinguishable from a documentation defect, so a network outage
  does not read as a broken template.
- A docs defect the build tool reports as a warning rather than an error, a navigation entry
  pointing at a missing page among them: the gate builds in the tool's strict mode, where such
  defects abort the build, because they are exactly the silent breakage the gate exists to catch
  and every covered combination builds cleanly under strict mode today. The generated project's
  own docs command keeps its default mode, and tightening the product's own sessions is not part
  of this feature.
- After the replacement the engine may still arrive in the environment as a transitive dependency
  of the tool's own stack. The requirement is about what a generated project declares, not about
  which distributions a resolver ultimately installs.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The fixture test suite MUST build the documentation of generated projects and fail
  when any covered documentation build fails.
- **FR-002**: The docs build coverage MUST include every distinct documentation configuration the
  committed fixtures contain, across project layout, git provider, and the option variants that
  alter documentation output.
- **FR-003**: The docs build coverage MUST NOT rebuild combinations whose documentation
  configuration and docs inputs are identical to one already covered, so dimensions that do not
  affect documentation, such as the package manager, are not crossed.
- **FR-004**: The covered set MUST be derived from the committed fixtures rather than restated, so
  a fixture added or removed by the fixture regeneration script is picked up without editing the
  docs build coverage.
- **FR-005**: A docs build failure MUST identify the answer combination that failed and preserve
  the build output for diagnosis.
- **FR-006**: The docs build step MUST run as part of the same fixture test entry point that the
  development workflow and the per-push CI already invoke, not as a separate target a contributor
  must remember.
- **FR-007**: The docs build MUST run non-interactively, blocking on no prompt, in both local and
  CI runs.
- **FR-008**: The suite MUST remain usable when only the rendering checks are wanted, in the sense
  that a docs toolchain problem fails with a message naming the missing prerequisite rather than an
  unexplained error.
- **FR-009**: A generated project MUST declare its documentation toolchain as the single tool
  properdocs. Its dependency declarations MUST NOT enumerate the underlying engine or its plugin
  packages, for either package manager.
- **FR-010**: The generated README's documentation badge MUST name properdocs, not mkdocs.
- **FR-011**: The repository's own tooling dependencies MUST follow the same single-tool rule for
  the docs stack.
- **FR-012**: The replacement MUST NOT change whether or what the documentation build produces,
  and this MUST be established by the docs build gate passing across all covered configurations
  before and after the swap.
- **FR-013**: The docs build gate MUST derive the toolchain it installs from the fixtures'
  dependency declarations rather than restating them, so the gate follows the replacement without
  being edited.

### Key Entities

- **Fixture**: a committed answer combination with its fully rendered project under the expected
  output tree. Already exists and is the source the docs build coverage is derived from.
- **Documentation configuration**: the rendered documentation setup of a fixture, the file that
  configures the docs build together with the docs pages and generators it references. Two fixtures
  share a configuration when these are identical.
- **Docs build run**: one execution of a fixture project's documentation build, with a pass or fail
  outcome and captured output.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: a template change that breaks the documentation build of any covered combination is
  detected by the fixture tests before merge, verified by seeding such a defect and observing the
  failure.
- **SC-002**: 100% of the distinct documentation configurations present in the committed fixtures
  are built by the suite.
- **SC-003**: a maintainer reading a failure can name the broken answer combination from the test
  output alone, without rerunning anything.
- **SC-004**: the fixture suite including docs builds completes in CI in under 15 minutes on every
  push, and a warm local rerun completes in under 10 minutes.
- **SC-005**: adding a new layout with its fixtures requires zero edits to the docs build coverage
  for its documentation configuration to be covered.
- **SC-006**: after the replacement, a generated project's docs dependency declarations name
  exactly one documentation tool, and 100% of the covered docs builds still pass.
- **SC-007**: after the replacement, no generated dependency declaration and no generated README
  badge names mkdocs or an mkdocs plugin package.

## Assumptions

- "Building the docs" means producing the static documentation site of a generated project and
  treating a failed build as a test failure. Treating warnings as failures is out of scope.
- "The tests of fixtures" means the per-push fixture suite that the development workflow's test
  target runs, not the scheduled integration suite. The integration suite keeps its role of running
  generated toolchains end to end.
- Docs inputs differ textually across every fixture dimension, including the package manager,
  whose choice changes the wording of the development page. FR-003's identity rule therefore
  collapses nothing today, and the coverage is every fixture. The rule stays, so coverage shrinks
  automatically if fixtures ever become docs-identical, and never silently under-covers.
- Where the fixture suite runs, the network and a package index are reachable, as the existing
  install target already assumes. The docs build step may provision the docs toolchain on first
  run and reuse it afterwards to meet the time bound.
- The single-tool replacement depends on a properdocs release that carries the documentation
  stack, the theme, the API renderer, and the other plugins, as its own dependencies or an extra.
  properdocs is maintained by this template's maintainer, and until that release exists the
  replacement cannot merge. The docs build gate does not depend on it and lands first.
- The replacement covers what a generated project declares and advertises, its dependency
  declarations and its README badge. The plugin identifiers inside the docs configuration file and
  the generator scripts' imports are the tool's own compatible plugin surface and keep their
  current names until the tool renames them.
