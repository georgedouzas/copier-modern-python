# Design

## Context

The GitHub workflow installs every supported version with `actions/setup-python` and lets the nox
sessions, parametrized on `PYTHON_VERSIONS`, run across them. The other three providers start from one
interpreter: GitLab and Bitbucket through `image: python:3.11`, and Azure DevOps through
`UsePythonVersion@0` with `pythonVersion: '3.11'`. The noxfile uses the uv virtualenv backend, and
whether nox then downloads the missing interpreters or skips the sessions depends on the nox and uv
versions and on the `CI` environment variable. Nobody has established it by running a pipeline.

## Goals / Non-Goals

**Goals:**

- No job runs on an unsupported interpreter.
- The test sessions run on the whole range on every provider.

**Non-Goals:**

- Running the checks or docs jobs across a matrix on the non-GitHub providers. GitHub runs checks on
  three operating systems, and that difference stays declared rather than closed here.

## Decisions

**The base interpreter is the lowest derived version.** The image or `versionSpec` becomes
`python:{{ python_test_versions[0] }}`. The lowest version is where a too-new syntax or API breaks
first, and it matches the black and ruff targets.

**The other versions come from uv, not from the image.** In each test job, the before-script runs
`uv python install` with the derived versions, and nox is set to error rather than skip on a missing
interpreter. This gives the three providers one mechanism and keeps a single job per pipeline. The
alternative, a provider matrix over images (`parallel: matrix` on GitLab, a `strategy: matrix` on
Azure, a generated step per version on Bitbucket), would give three different shapes and multiply the
pipeline minutes. PDM projects also have uv available, since the nox backend already requires it.

**The Dockerfile uses the newest derived version.** A container ships one interpreter, and the newest
supported one gets the longest support window.

## Risks / Trade-offs

- [nox already downloads interpreters through uv, so the test-range fix is a no-op] → Task 1 runs a
  rendered pipeline's commands in the provider's base image first. If nothing is skipped, the second
  spec requirement is already met and only the base interpreter changes.
- [A Bitbucket or Azure image lacks a tool uv needs to install Python] → Verify each pipeline's test
  commands inside its base image with `docker run` before committing.
