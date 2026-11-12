# Spec Delta

## Purpose

Define how the generator fills in the license of a generated project, so the license names the right
holder and year without manual editing.

## ADDED Requirements

### Requirement: The copyright year defaults to the current year

When the user accepts the default for the copyright date, the generated license MUST state the calendar
year in which the project is generated. An explicit answer MUST be used as given.

#### Scenario: Default answer

- **WHEN** a project is generated with defaults in a given calendar year
- **THEN** its `LICENSE` states that year as the copyright year

#### Scenario: Explicit answer

- **WHEN** a project is generated with `copyright_date` set to `2019-2026`
- **THEN** its `LICENSE` states `2019-2026`

#### Scenario: No license

- **WHEN** a project is generated with `copyright_license` set to `None`
- **THEN** no `LICENSE` file is generated and the copyright date has no effect
