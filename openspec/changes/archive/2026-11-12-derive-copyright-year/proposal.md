# Proposal

## Why

The `copyright_date` question defaults to the literal string `"2026"`. From 1 January 2027 every
project generated with defaults gets a license whose copyright year is wrong, and the default has to be
edited by hand each year to stay correct. Copier renders with the Jinja Ansible filters, so the current
year is available at generation time as `{{ '%Y' | strftime }}`, which renders `2026` today.

## What Changes

- The `copyright_date` default becomes the current year at generation time.
- The golden fixture renderer and the golden test pin `copyright_date` to a fixed year, so the fixtures
  stay byte-identical after the calendar year changes.

## Out of Scope

- Copyright year ranges such as `2024-2026`, and updating the year in existing projects on
  `copier update`.
- Any other license content.

## Matrix

The year appears in the `LICENSE` file, which every layout, git provider, and package manager renders
unless `copyright_license` is `None`. All branches move together. The rendered fixtures do not change,
because the pinned year equals today's default.

## Capabilities

### New Capabilities

- `project-license`: how the generator fills in the license of a generated project.

### Modified Capabilities

None.

## Impact

- `copier.yml`: the `copyright_date` default.
- `scripts/regen_fixtures.py`: `COMMON` gains `copyright_date`.
- `tests/test_copier.bats` and `tests/test_integration.bats`: pass the same `copyright_date`.
- `tests/expected/`: no change expected.
