# Tasks

## 1. Keep the repository current

- [x] 1.1 Add `.github/dependabot.yml` with weekly, grouped `github-actions` and `pre-commit` entries, and
  verify it against the SchemaStore Dependabot schema. Dependabot supports both ecosystems, `github_actions` and
  `pre_commit` in dependabot-core.
- [x] 1.2 Move `.github/workflows/tests.yml` and `doc.yml` to the current major versions, reading each
  action's release notes for breaking input changes, and verify every input the workflows pass exists, undeprecated,
  in the new `action.yml`.
## 2. Generated workflows start current

- [x] 2.1 Move every action pin in the template's GitHub `ci.yml.jinja`, `doc.yml.jinja`, and
  `release.yml.jinja` to the current major version, adjusting inputs per the release notes, and run
  `scripts/check_pipelines.py` to verify the rendered workflows parse.
- [x] 2.2 Run `make regen-fixtures` and confirm the diff moves only in the GitHub fixtures' workflow files.

- [x] 2.4 Run `make tests` and confirm it is green.

## Workflow follow-up

These checks need GitHub and were not run before archive, because the branch stays local.

- After pushing, confirm the repository's Insights, Dependency graph, Dependabot page lists both ecosystems without a
  configuration error. Drop the `pre-commit` entry if GitHub rejects it.
- Confirm the Tests workflow passes on the pull request, and the Documentation workflow passes on a `workflow_dispatch`
  run of the branch.
- Push a generated GitHub uv project and a generated GitHub PDM project to a scratch repository, and confirm their CI
  and documentation workflows pass and a test tag runs the release workflow through the artifact upload and download
  steps.
