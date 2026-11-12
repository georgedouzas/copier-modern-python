# Tasks

## 1. Establish today's behaviour

- [x] 1.1 On an unmodified checkout, generate a GitLab uv project and a GitLab PDM project with the
  default range, run the test job's commands inside `python:3.11` with `CI=true` through `docker run`,
  and record whether the 3.12 and 3.13 sessions run, are skipped, or fail.
- [x] 1.2 Generate a GitLab project with `>=3.12, <3.14` on an unmodified checkout and confirm the
  pipeline still names `python:3.11`, establishing the defect predates the change.

## 2. Base interpreter follows the range

- [x] 2.1 Make the GitLab image, the Bitbucket image, and the Azure `pythonVersion` read the lowest
  derived version, and parse each rendered file with PyYAML for `>=3.12, <3.14` to verify every
  interpreter reference is 3.12.
- [x] 2.2 Make both Dockerfile stages read the newest derived version, and verify by building the image
  of a service project generated with `>=3.11, <3.13` that `python --version` in it reports 3.12.

## 3. Tests cover the whole range

- [x] 3.1 If task 1.1 showed sessions skipped or failing, add the `uv python install` step for the
  derived versions to each non-GitHub test job, for PDM and uv, and set nox to error on a missing
  interpreter. Verify by rerunning the test commands in each provider's base image that every version's
  session runs.
  Not needed. Task 1.1 showed the uv virtualenv backend already downloads the missing interpreters,
  and every session from 3.11 to 3.13 ran inside `python:3.11` with `CI=true` for both PDM and uv.
- [x] 3.2 Run `scripts/check_pipelines.py` and confirm every rendered pipeline still parses.

## 4. Fixtures

- [x] 4.1 Run `make regen-fixtures` and confirm the diff moves only in the GitLab, Bitbucket, and Azure
  DevOps pipelines and in the Dockerfiles, and that the default range keeps the interpreter at 3.11 in
  the pipelines.
- [x] 4.2 Run `make tests` and `make tests-integration` and confirm both are green.
