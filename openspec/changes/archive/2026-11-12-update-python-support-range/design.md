# Design

## Context

CPython 3.14 and 3.15 are released. The generated layouts pull dependencies with compiled parts, among
them Metaflow for ml, Kedro and its datasets for dataeng, and FastAPI with pydantic-core for service,
and a new Python minor version is only usable once these publish wheels or install cleanly. The
integration suite in `tests/test_integration.bats` generates and runs every layout, and it is the only
way to know.

## Goals / Non-Goals

**Goals:**

- Choose the default upper bound by running the integration suite, not by assumption.

**Non-Goals:**

- Adding a pre-release Python, such as 3.16 alpha, to CI.

## Decisions

**Extend in two steps, 3.14 then 3.15.** Run the integration suite with the range ending at 3.14
first, then at 3.15. If 3.15 fails on a dependency the template cannot fix, the default stops at
`<3.15` and the proposal records the blocker, so 3.14 support is not held back by 3.15. The
alternative, one jump, would leave the result unclear when it fails.

**Fix template code, not the range, when the failure is ours.** A failure caused by generated code,
like the earlier `Path.relative_to` change, is fixed in the template in a separate `fix:` commit, as
the constitution requires for out-of-scope fixes. Only a third-party blocker justifies a narrower range.

## Risks / Trade-offs

- [The integration suite runs for a long time per version] → Run it locally for the new versions first,
  then let the scheduled CI job confirm.
- [A dependency drops 3.11 before 3.11 reaches end of life] → Out of scope here. The integration suite
  would show it on the next scheduled run.
