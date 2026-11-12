# Spec Delta

## Purpose

Define how the generator takes the Python range a project supports, rejects ranges it cannot honour,
and derives the Python versions the generated project declares and tests against.

## ADDED Requirements

### Requirement: The default range covers the released versions that work

The default `python_versions` MUST include every released CPython minor version, from the oldest one
still supported upstream, on which every layout passes the integration suite. A released version left
out MUST have its blocking dependency recorded in the change that leaves it out.

#### Scenario: Default generation

- **WHEN** a project of any layout is generated with all defaults
- **THEN** its declared range and derived versions include the newest released CPython minor version on
  which every layout passes the integration suite

### Requirement: Integration CI covers the default range

The repository's integration CI MUST install every Python version in the default range, so every
layout is exercised on each of them.

#### Scenario: Scheduled integration run

- **WHEN** the scheduled integration job runs
- **THEN** every version in the default range is installed and available to the generated projects'
  test sessions
