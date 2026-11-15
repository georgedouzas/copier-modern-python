# project-answers Specification

## Purpose
Define which answers the generator accepts, how it rejects the rest before rendering, and how accepted
answers are written into generated files so the project parses and passes its own checks.

## Requirements

### Requirement: Package names are validated

The generator MUST reject a `python_package_import_name` that is not a lowercase Python identifier
(letters, digits and underscores, not starting with a digit) or that is a Python keyword. It MUST reject a
`python_package_distribution_name` that is not a valid distribution name. Each rejection MUST happen at
the question, with a message that says what the answer must look like.

#### Scenario: Hyphenated import name

- **WHEN** a project is generated with `python_package_import_name` set to `my-pkg`
- **THEN** the question is rejected with a message that the import name must be a valid Python identifier
  and no project is rendered

#### Scenario: Keyword as import name

- **WHEN** a project is generated with `python_package_import_name` set to `class`
- **THEN** the question is rejected and no project is rendered

#### Scenario: Invalid distribution name

- **WHEN** a project is generated with `python_package_distribution_name` set to `-pkg-`
- **THEN** the question is rejected with a message that names the allowed characters

#### Scenario: Derived default

- **WHEN** a project is generated with `repository_name` set to `My Repo-Name` and the package names left
  at their defaults
- **THEN** generation succeeds with the import name `my_repo_name`

### Requirement: Email answers are validated

The generator MUST reject an `author_email` or `copyright_holder_email` that does not have the shape
`local@domain.tld` with no whitespace, at the question.

#### Scenario: Missing domain

- **WHEN** a project is generated with `author_email` set to `me@localhost` or `not an email`
- **THEN** the question is rejected with a message that an email address is expected

### Requirement: Free text answers are single line

The generator MUST reject a `project_description`, `author_fullname` or `copyright_holder` that is empty,
spans more than one line, or contains a backslash or three double quotes in a row, at the question.

#### Scenario: Backslash in the description

- **WHEN** a project is generated with `project_description` set to `Parses C:\paths.`
- **THEN** the question is rejected with a message that the answer must be one line without a backslash

#### Scenario: Triple quotes in the description

- **WHEN** a project is generated with `project_description` set to `Say """hi""".`
- **THEN** the question is rejected

### Requirement: Accepted answers keep the project valid

For every accepted answer, the generated project's TOML, YAML and Python files MUST parse, and the
project MUST pass its own quality checks. Quotes, apostrophes and non ASCII text in a free text answer
MUST appear in the generated files as the user wrote them.

#### Scenario: Quotes in the description

- **WHEN** a project is generated with `project_description` set to `A "quoted" tool`
- **THEN** `pyproject.toml` parses and its `description` is `A "quoted" tool`, and `properdocs.yml` and
  every Python file parse

#### Scenario: Apostrophe in the description of a service

- **WHEN** a `service` project is generated with `project_description` set to `Kedro's helper.`
- **THEN** `app.py` parses and the FastAPI description is `Kedro's helper.`

#### Scenario: Apostrophe and non ASCII text in the author name

- **WHEN** a project is generated with `author_fullname` set to `Seán O'Brien`
- **THEN** `pyproject.toml` parses and lists the author as `Seán O'Brien`

### Requirement: The package docstring ends with punctuation

The package docstring generated from `project_description` MUST end with `.`, `?` or `!`. When the
description does not, the docstring MUST add a full stop. Every other file MUST keep the description
exactly as written.

#### Scenario: Description without a full stop

- **WHEN** a project is generated with `project_description` set to `A tool`
- **THEN** the package docstring is `A tool.`, `pyproject.toml` has `description = "A tool"`, and the
  project passes its quality checks

#### Scenario: Description ending with a question mark

- **WHEN** a project is generated with `project_description` set to `Why not?`
- **THEN** the package docstring is `Why not?` with no full stop added
