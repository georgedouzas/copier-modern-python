# Proposal

## Why

The GitLab, Bitbucket, and Azure DevOps pipelines hard-code Python 3.11 as the interpreter they run on,
whatever range the user chose. A project generated for GitLab with `>=3.12, <3.14` declares
`requires-python = ">=3.12, <3.14"` and gets `image: python:3.11`, so the pipeline runs on an
interpreter the project does not support. The Dockerfile has the same defect in the other direction.
It hard-codes `python:3.13-slim`, which falls outside a range such as `>=3.11, <3.13`. The GitHub
workflow reads the range, so the three other providers and the container image diverge from it
silently, which the constitution's matrix parity principle prohibits.

## What Changes

- The GitLab, Bitbucket, and Azure DevOps pipelines run on the lowest supported Python version, read
  from the derived versions, instead of a fixed 3.11.
- Each of those pipelines makes every supported version available to the test job, so the nox test
  sessions run on the full range, as they do on GitHub.
- The Dockerfile builds and runs on the newest supported Python version instead of a fixed 3.13.

## Out of Scope

- Moving the GitHub workflow, which already reads the range.
- Changing which jobs each provider runs or how they are staged.
- The derivation of the versions itself, which `fix-python-versions-parsing` owns. This change depends
  on it and lands after it.

## Matrix

- Git providers: GitLab, Bitbucket, and Azure DevOps change. GitHub is unchanged because it already
  reads the range. None has no pipeline.
- Package managers: PDM and uv branches inside each pipeline change together.
- Layouts: every layout renders the pipelines, so all five move. The Dockerfile change reaches every
  layout that includes a Dockerfile, which is dataeng and service by default and any layout that opts in.

## Capabilities

### New Capabilities

- `python-version-support`: CI interpreters and the container image follow the supported range. The
  capability is introduced by `fix-python-versions-parsing`, which archives first, so this change adds
  requirements to it.

### Modified Capabilities

None.

## Impact

- `project/{% if git_provider == 'GitLab' %}.gitlab-ci.yml{% endif %}.jinja`
- `project/{% if git_provider == 'Bitbucket' %}bitbucket-pipelines.yml{% endif %}.jinja`
- `project/{% if git_provider == 'Azure DevOps' %}azure-pipelines.yml{% endif %}.jinja`
- `project/{% if include_dockerfile %}Dockerfile{% endif %}.jinja`
- `tests/expected/`: the GitLab, Bitbucket, Azure DevOps, and Dockerfile fixtures change.
