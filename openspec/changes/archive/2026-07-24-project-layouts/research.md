# Phase 0 Research: Project Layouts

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-07-24

Phase 0 resolves the unknowns the plan's Technical Context could not settle, and closes the
Principle VI gate the Constitution Check left open.

## R1: How layout varies the template

**Decision**: One shared template spine, branching on a `project_layout` answer through the
two mechanisms already used for `git_provider` and `package_manager` — in-file Jinja
conditionals, and conditional path-name directories such as
`{% if project_layout == 'ml' %}notebooks{% endif %}`.

**Rationale**: `noxfile.py.jinja` is where the quality floor lives. If it is shared, then
FR-006 and FR-007 hold by construction: there is only one definition of what `checks` means,
so a layout cannot quietly weaken it. The repository already proves this mechanism scales to
a four-value answer (`git_provider`) inside the same files.

**Alternatives considered**:

- *Per-layout template subdirectory* (`project-library/`, `project-script/`, `project-ml/`,
  selected via `_subdirectory`). Rejected: forks `noxfile.py.jinja` and
  `pyproject.toml.jinja` three ways. Principle II exists because copies drift, and this
  would guarantee three copies of the exact thing that must not drift. It also breaks FR-012,
  since a fourth layout would mean a fourth full copy.
- *Copier `_exclude` patterns driven by layout*. Rejected as the primary mechanism: it can
  remove files but cannot vary their contents, so `pyproject.toml` and `noxfile.py` would
  still need in-file conditionals. Two mechanisms where one suffices.
- *Post-generation task that deletes inapplicable files*. Rejected: the intermediate state
  exists on disk, `copier update` reasons about the pre-deletion tree, and the deletion
  logic is invisible to the fixtures.

## R2: Guaranteeing the library layout does not change

**Decision**: Add `project_layout` with `default: library`, and make every new conditional
render its current content on the `library` branch. Verify by regenerating all existing
fixtures and asserting a zero-byte diff, before any new layout is added.

**Rationale**: SC-002 demands comparison, not inspection (Principle IV). The existing eight
fixtures in `tests/expected/` already encode today's output exactly; if adding the question
leaves them untouched, FR-002 is proven rather than asserted. This makes the first
implementation task a pure no-op change whose entire success criterion is "nothing moved".

**Alternatives considered**:

- *Review the diff by eye*. Rejected outright — this is exactly the failure mode Principle IV
  was written about after the Azure `displayName` bug.

## R3: What the script/CLI layout contains

**Decision**: Keep `src/` and the packaging spine, add a `cli.py` module and a
`[project.scripts]` console-script entry point. Dependency addition: **one** CLI framework.

**Rationale**: A CLI tool is a library with an entry point; it is publishable, so the entire
release topology (FR-008) applies unchanged. This is the layout that proves the mechanism
cheaply. `click` is the conservative choice — it is already the dependency `properdocs`
itself pulls in, so the generated project's dependency tree gains nothing new at the
transitive level, and `mkdocs-click` exists should CLI documentation be wanted later.

**Principle VI check**: the framework is configured in `pyproject.toml` (`[project.scripts]`),
exercised by the generated test suite, and its command is runnable immediately after
generation. It is integrated, not merely installed.

**Alternatives considered**:

- *`typer`*. A reasonable choice, but it is `click` plus type-driven sugar, and it adds a
  dependency the tree does not already carry. Deferred rather than rejected; the decision is
  cheap to revisit before implementation.
- *`argparse`, no dependency at all*. Rejected: generates a project whose CLI is a worked
  example of boilerplate the user will replace, which fails the spirit of FR-004's "nothing
  vestigial".

## R4: What the ML layout contains, and what it must not

**Superseded.** The original decision was to ship no framework at all. It was wrong in one
respect and over-corrected in another; see R4a below for the decision now in force. The
reasoning is kept because the constraint it derived — a framework must be locally runnable
and actually exercised — is what the replacement is measured against.

**Original decision**: A `notebooks/` directory, a version-control-ignored `data/` directory,
a `src/` package, and no ML framework dependency. The layout ships shape, not a stack.

**Original rationale**: An ML layout is the natural place to bundle a fashionable stack, and
every dependency is paid for by every ML project the template ever generates — including the
ones that wanted a different framework and must now remove this one. A modelling library also
cannot satisfy Principle VI's "exercised by CI" condition, because the template has no model
to train.

**Where it was wrong**: it shipped a `notebooks/` directory with nothing capable of opening a
notebook. That is precisely the vestigial artifact contract C5 forbids, arrived at by applying
the anti-stack rule to tooling the layout genuinely needs.

**Where it over-corrected**: it treated all frameworks as one category. A *modelling* library
(scikit-learn, torch) is a choice the practitioner owns and the template cannot exercise. A
*workflow* library is scaffolding — the very thing the layout's value was defined as — and can
be exercised locally with no infrastructure.

**Still rejected, and why**:

- *scikit-learn, pandas, numpy as defaults*. The practitioner owns this choice, and no task
  the template ships would exercise them. Fails FR-017.
- *MLflow or a similar tracker*. Implies a server the template cannot provision; an
  unconfigured tracker is worse than none.
- *A nested "ML framework" question*. Multiplies the matrix for a choice the user can make in
  one line of `pyproject.toml`.

## R4a: The ML layout ships Metaflow and notebook tooling

**Decision**: The ML layout ships **Metaflow**, a runnable flow module exercised by the
generated test suite, and notebook tooling (`jupyter`/`ipykernel`) so `notebooks/` is usable.
No modelling library, no tracker server.

**Rationale**: Metaflow is scaffolding rather than a modelling opinion, and it clears every bar
the alternatives failed:

| Criterion | kedro 1.5.0 | metaflow 2.19.35 |
| --------- | ----------- | ---------------- |
| Core dependencies | 17 | 2 (`requests`, `boto3`) |
| Telemetry in core deps | `kedro-telemetry` | none |
| Competing project scaffolder | `cookiecutter` | none |
| Structural imposition | `conf/base`, `catalog.yml`, `pipelines/`, `nodes` | a `FlowSpec` class in a module |
| Runs locally with no infrastructure | yes | yes, and it is the default |

The decisive point is User Story 1's "nothing has to be deleted before work starts". Metaflow
is a library, so a user who does not want it deletes one module. Kedro is a tree, so the same
user deletes a directory taxonomy — which inverts the story the feature exists to serve.

**FR-017 check (the relevance rule)**: passes. `python flow.py run` executes locally with no
config files and no cloud account, so the generated test suite exercises the dependency rather
than merely declaring it. This is the bar scikit-learn cannot clear.

**Principle VI check**: passes on all three conditions. It earns its place against a
hand-rolled directory convention by giving the layout something that runs; it is integrated
(declared in `pyproject.toml`, invoked by a task, exercised by the test suite); and it is
verified by execution on a generated project.

**Costs accepted, recorded rather than glossed**:

- `boto3` is an unconditional dependency. A purely local user installs the AWS SDK and never
  touches it, and botocore is not small. This is the one axis on which shipping nothing was
  better, and it is accepted because the alternative leaves the layout with nothing runnable.
- Metaflow declares no `requires-python`. Low risk against the template's `>=3.11, <3.14`
  range, but it is undeclared rather than guaranteed, so the integration suite is what
  establishes compatibility.
- The flow abstraction is still an opinion. It is a far smaller one than a directory taxonomy,
  and it is confined to a single module.

**Alternatives considered**: kedro, per the table above — rejected primarily for telemetry
arriving by a default the generated project's owner never chose, and for structural
imposition. See R8 for where kedro is better placed.

## R8: Kedro belongs to the deferred data-engineering layout

**Decision**: Record kedro as the leading candidate for the data-engineering layout when it
lands, not as a rejected option.

**Rationale**: Kedro describes itself as building "production-ready data and analytics
pipelines". Catalogs, environment-scoped configuration and DAGs are the vocabulary of data
engineering, not of ML experimentation. The objections in R4a are objections to kedro *as the
ML layout* — structural imposition is a cost when the user wants notebooks, and a feature when
the user wants a pipeline project with a defined shape.

The telemetry dependency remains a genuine concern for any layout, and MUST be decided
explicitly rather than inherited silently when data engineering is specified.

**Resolved (post-first-release)**: the `dataeng` layout shipped on Kedro. The telemetry concern
was settled the way this note demanded — the generated project writes a `.telemetry` file with
`consent: false`, so a project made from a template declines the data collection its owner never
had the chance to opt into. Set it to `true` to send usage data. This was added under FR-012
alongside the `service` (FastAPI) layout, without disturbing the three that shipped first, which
is the extension path US3 anticipated.

## R5: Publishing for a layout that publishes nothing

**Decision**: Make `publish_pypi` conditional — `when: "{{ project_layout != 'ml' }}"` with
a computed default of `false` for `ml`. The release *session* remains present for every
layout, because changelog and tagging are still meaningful; only the publish step is absent.

**Rationale**: FR-009 requires omission rather than a broken artifact, and FR-016 makes ML
the case that proves it. This also resolves the spec's first edge case — the contradiction
cannot arise, because the question is not asked when it does not apply. The distinction that
matters is between *releasing* (versioning, changelog, tagging — universal) and *publishing*
(uploading a distribution — layout-dependent).

**Alternatives considered**:

- *Ask `publish_pypi` anyway and ignore a `true` answer*. Rejected: silently discarding a
  user's answer is precisely the "resolve predictably and report" failure FR-013 forbids.
- *Hard-error on the contradictory combination*. Rejected as hostile for a case the question
  flow can simply avoid.

## R6: Documentation shape per layout

**Revised during implementation.** The original decision was to drop the API reference for
the ML layout. Building the generated project showed the premise was wrong.

**Original decision**: the API-reference generator (`docs/generate_api.py.jinja`, driven by
`mkdocstrings`) is library-and-script only, on the grounds that an API reference over a thin
`src/` package is the "present-but-broken" artifact the spec's fourth edge case names.

**Why it was wrong**: the premise was that an ML layout might not expose an importable
package. It does — `data-model.md` says so explicitly, and the flow lives in it. Generating an
ML project and running `docs build` produces a working API reference over real code. The edge
case the original reasoning invoked is about a task that is *broken*, and this one is not.

**Decision in force**: every layout keeps the API reference. The only documentation difference
is that `properdocs.yml.jinja`'s `watch` list gains `notebooks` for the ML layout, so editing a
notebook rebuilds the docs during `docs serve`.

**Consequence for the data model**: the `has_api_docs` derived value turned out to be true for
every layout, so it does not exist. A derived value that never varies is a conditional waiting
to be mis-set, not an abstraction.

**Verified by**: `pdm docs build` on a generated ML project — builds clean, and the API page is
populated rather than empty.

## R7: Fixture coverage strategy

**Decision**: Add exactly two fixtures — `script-layout` and `ml-layout`, both at otherwise
default answers. Extend `tests/test_integration.bats` to generate and run all three layouts.
Do not expand the provider or package-manager fixtures per layout.

**Rationale**: The constitution's Principle III coverage rule requires every dimension value
to appear at least once, not every combination to be enumerated. Three layouts × four
providers × two package managers is 24 fixtures; that suite would stop being run before
every commit, which would cost more than it catches. Layout affects the source tree, the
dependency set and the docs shape — dimensions largely orthogonal to which CI provider is
configured — so the cross terms are low-risk.

**Residual risk, accepted and recorded**: a defect that appears only in, say, ml + Bitbucket
would not be caught. The integration suite's per-layout runs mitigate the most likely
version of this, which is a layout breaking the shared nox spine.

**Alternatives considered**:

- *Full cross product*. Rejected: 24 fixtures, unrunnable before every commit.
- *One fixture per layout per package manager* (6). Deferred: a reasonable middle ground if
  the ML layout turns out to interact with dependency-group syntax, which differs between
  PDM and uv. Revisit if implementation surfaces it.

## Open questions carried into implementation

None blocking. Three decisions are cheap to revisit and flagged in place: the CLI framework
choice (R3), whether ML needs a per-package-manager fixture (R7), and whether `boto3` arriving
transitively with Metaflow proves annoying enough in practice to reconsider R4a.
