## MODIFIED Requirements

### Requirement: Open upper bound

When the answer has no upper bound, the derived versions MUST run from the lower bound through the
newest Python minor version the template supports for the chosen layout, and `requires-python` MUST keep
the answer as the user wrote it.

#### Scenario: Lower bound only

- **WHEN** a project is generated with `python_versions` set to `>=3.12`
- **THEN** generation succeeds, `requires-python` is `>=3.12`, and the derived versions run from 3.12
  through the newest minor version the template supports for that layout

#### Scenario: Lower bound only for a layout with an older ceiling

- **WHEN** an `ml` or `dataeng` project is generated with `python_versions` set to `>=3.12`
- **THEN** the derived versions run from 3.12 through 3.14

### Requirement: Invalid ranges are rejected before rendering

An answer outside the accepted forms, a lower bound below 3.11, a range that leaves no supported
version, or a range whose upper bound includes a version newer than the layout supports MUST be rejected
at the question with a message that names the accepted forms or the newest supported version. Generation
MUST NOT reach rendering and fail there with a traceback.

#### Scenario: Unsupported specifier

- **WHEN** `python_versions` is set to `~=3.12`, `==3.12`, or `>=3.12, !=3.13`
- **THEN** the question is rejected with a message that names the accepted forms

#### Scenario: Lower bound too old

- **WHEN** `python_versions` is set to `>=3.10, <3.14`
- **THEN** the question is rejected with a message that the minimum is Python 3.11

#### Scenario: Empty range

- **WHEN** `python_versions` is set to `>=3.13, <3.13`
- **THEN** the question is rejected with a message that the range contains no Python version

#### Scenario: Range past the layout's newest supported version

- **WHEN** an `ml` or `dataeng` project is generated with `python_versions` set to `>=3.11, <3.16`
- **THEN** the question is rejected with a message that the layout supports Python up to 3.14

### Requirement: The default range covers the released versions that work

For each layout, the default `python_versions` MUST include every released CPython minor version, from
the oldest one still supported upstream, on which that layout passes the integration suite. A released
version left out of a layout's default MUST have its blocking dependency recorded in the change that
leaves it out.

#### Scenario: Default generation

- **WHEN** a project of any layout is generated with all defaults
- **THEN** its declared range and derived versions include the newest released CPython minor version on
  which that layout passes the integration suite

#### Scenario: Python 3.15 by layout

- **WHEN** a project is generated with all defaults
- **THEN** the default range is `>=3.11, <3.16` for `library`, `script` and `service`, and
  `>=3.11, <3.15` for `ml` and `dataeng`, which are blocked by Metaflow 2.19.41 and Kedro 1.8.0
