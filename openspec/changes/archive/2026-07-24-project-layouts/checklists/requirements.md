# Specification Quality Checklist: Project Layouts

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-07-24
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- Items marked incomplete require spec updates before `/speckit-clarify` or `/speckit-plan`.

### Outstanding

None. All 16 items pass, re-validated after the clarification session of 2026-07-24 (16/16 →
16/16, no state changes). The four clarifications added FR-017 through FR-021 and SC-008
through SC-010; each is testable, and the spec remains free of framework names — the Metaflow
decision lives in `research.md` R4a, not here.

**Resolved**: FR-015 carried the sole `[NEEDS CLARIFICATION]`, on which layouts ship first.
Answered by the user: library, script/CLI and machine learning, with data engineering
deferred. FR-016 was added to capture the consequence — machine learning is the kind that
demonstrates publishing being omitted rather than generated broken.

### Validation notes

- Implementation detail was deliberately kept out of the spec: it names no Jinja construct,
  no directory under `project/`, and no answer key in `copier.yml`, describing instead what
  the user chooses and what they receive. First-pass drafting leaked "copier.yml" and "nox
  session" from the feature description into the requirements; both were rewritten to
  "generator" and "task" in the second iteration.
- FR-002 and SC-002 are the regression guard the user asked for: the library layout is
  pinned to its current output by comparison, not by review.
- FR-010, SC-005 and the fifth edge case encode the constitution's coverage rule
  (Principle III) rather than restating it, so the matrix growth is bounded by an explicit
  requirement instead of being discovered during planning.
