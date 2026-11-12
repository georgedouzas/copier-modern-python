# Tasks

## 1. Pin the year in the tests first

- [x] 1.1 Add `copyright_date` set to `2026` to `COMMON` in `scripts/regen_fixtures.py` and to the
  answers in `tests/test_copier.bats` and `tests/test_integration.bats`, and run `make tests` to verify
  it stays green with the old default.

## 2. Derive the default

- [x] 2.1 Set the `copyright_date` default in `copier.yml` to `{{ '%Y' | strftime }}`, and verify by
  generating a project with defaults that its `LICENSE` states the current year.
- [x] 2.2 Verify the year is computed at generation time by generating with `faketime '2027-01-02'`, or
  by temporarily rendering `{{ '%Y-%m-%d' | strftime }}` into a scratch file, and confirm the output
  follows the clock.
- [x] 2.3 Generate with `copyright_date=2019-2026` and confirm the `LICENSE` states `2019-2026`.

## 3. Fixtures

- [x] 3.1 Run `make regen-fixtures` and confirm `tests/expected/` has no diff.
- [x] 3.2 Run `make tests` and confirm it is green.
