# Proposal

## Why

The repository declares its development tools once, in the `dev` dependency group of `pyproject.toml`,
and `make install` installs that group. The Tests workflow ignores it. The fixtures job runs
`pip install copier pyyaml` and the integration job runs `pip install copier pdm`, both unpinned and
separate from the group. CI can therefore test with a Copier version the group does not allow, and a
tool added to the group for `make tests` is missing in CI until someone also edits the workflow. The
reverse drift has already happened locally. `make tests` needs PyYAML, and a contributor who installed
the tools the way CI does, rather than with `make install`, gets a failure halfway through the suite.

## What Changes

- Both jobs of `.github/workflows/tests.yml` install the `dev` dependency group, the same way
  `make install` and the Documentation workflow do.
- PDM, which only the integration suite needs, moves into the `dev` group, so the group is the complete
  list of what the suites need besides `bats` and `docker`.
- `CONTRIBUTING.md` states that `make install` is the way to get the tools `make tests` needs.

## Out of Scope

- Pinning the dev tools with a lock file. `uv.lock` stays a local file, as `.gitignore` already says.
- The action versions in the workflow, owned by `track-repo-action-updates`.
- Generated projects. The template is unchanged.

## Matrix

No branch of the layout, provider, or package manager matrix is affected. Only the repository's own CI
and dependency group change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. This is a tooling change with no spec-level behaviour, so the change sets `skip_specs: true`.

## Impact

- `.github/workflows/tests.yml`
- `pyproject.toml`: `pdm` added to the `dev` group.
- `CONTRIBUTING.md`
