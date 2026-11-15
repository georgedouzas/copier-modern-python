# project-clean Specification

## Purpose
Define what the generated project's `clean` task removes and how it behaves when it cannot remove the
virtual environment it runs from, so a cleaned project can always be reinstalled.

## Requirements

### Requirement: Clean removes build artifacts and caches

The `clean` task (`pdm clean` or `uv run nox -s clean`) MUST remove the build, cache, coverage and
documentation artifacts the project's tools create, both folders and files, and MUST leave every other
file in place. `coverage.xml`, `.coverage` data files and `*.rej` files MUST be removed wherever they are in
the project tree.

#### Scenario: Coverage report and data files

- **WHEN** `clean` runs in a project that has `coverage.xml`, `.coverage`, `.coverage.<suffix>` and a
  `*.rej` file in a subfolder
- **THEN** all of them are removed

#### Scenario: Unrelated files survive

- **WHEN** `clean` runs in a project that has a file not created by its tools
- **THEN** that file is still there afterwards

### Requirement: Clean removes the virtual environment

The `clean` task MUST remove the project's `.venv` on Linux and macOS, so that `pdm install` or
`uv sync` afterwards rebuilds it from scratch and the project's tests pass.

#### Scenario: Reinstall after clean

- **WHEN** `clean` runs in an installed project on Linux or macOS, followed by `pdm install` or `uv sync`
- **THEN** `.venv` was removed by `clean`, is recreated by the install, and the project's tests pass

### Requirement: Clean never leaves a half deleted environment

When the `clean` task runs on Windows from the project's own `.venv`, it MUST NOT attempt to delete
`.venv`. It MUST print a message that `.venv` was kept and how to delete it after the task exits. Every
other artifact MUST still be removed.

#### Scenario: Windows run from the project environment

- **WHEN** `clean` runs on Windows through `pdm clean` or `uv run nox -s clean`
- **THEN** `.venv` is left intact and usable, a message says how to remove it, and the other artifacts are
  removed
