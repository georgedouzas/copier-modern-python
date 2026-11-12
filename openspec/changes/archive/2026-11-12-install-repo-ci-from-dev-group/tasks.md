# Tasks

## 1. One source for the tools

- [x] 1.1 Add `pdm` to the `dev` group in `pyproject.toml`, and verify in a fresh virtual environment that
  `pip install --group dev` provides `copier`, `pdm`, `properdocs`, and PyYAML.
- [x] 1.2 Replace the ad hoc `pip install` lines in both jobs of `.github/workflows/tests.yml` with an
  upgrade of pip to a version that supports `--group`, followed by `pip install --group dev`, keeping the
  `bats` install, and parse the workflow with PyYAML to verify its structure.
- [x] 1.3 State in `CONTRIBUTING.md` that `make install` installs every tool `make tests` and
  `make tests-integration` need besides `bats` and `docker`, and verify by following those steps in a
  fresh virtual environment that `make tests` passes.

## Workflow follow-up

- Not run before archive, because the branch stays local. Once it is pushed, confirm the Tests workflow's fixtures job
  passes on the pull request.
- Run the Tests workflow with `workflow_dispatch` on the branch and confirm the integration job passes with the PDM
  installed from the `dev` group.
