# Design

## Context

`copier.yml` sets `copyright_date` to the string `"2026"`. The golden fixtures are rendered by
`scripts/regen_fixtures.py` from a `COMMON` answer set, and `tests/test_copier.bats` renders them again
with its own copy of those answers. Neither passes `copyright_date`, so both rely on the default.

## Goals / Non-Goals

**Goals:**

- A correct year for users with no yearly edit.
- Fixtures that do not change on 1 January.

**Non-Goals:**

- Making the golden test read its answers from the regen script. The two answer lists are a known
  duplication, and removing it is a separate change.

## Decisions

**Use the `strftime` filter.** `{{ '%Y' | strftime }}` works in Copier 9 with no extension or
`--trust`, which a test template confirmed. The alternative, a `jinja2_time` extension, needs an extra
dependency and `_jinja_extensions`.

**Pin the year in every test that renders, to the current fixture value.** Passing `copyright_date=2026`
from `COMMON` and from both bats files keeps the fixtures unchanged today and stable later. Pinning
to a different year would rewrite every `LICENSE` fixture for no benefit.

## Risks / Trade-offs

- [A future test renders without the pin and its output depends on the date] → The golden test fails on
  the first run in a new year, which points straight at the missing pin.
