# Proposal

## Why

The repository pins GitHub Actions several major versions behind their current releases, and nothing
keeps them current. Generated projects ship a Renovate configuration, but the repository has none of
its own, and Renovate has never opened a pull request here. The template's own workflow files carry the
same stale pins, so every new GitHub project starts behind and receives a batch of update pull requests
on its first Renovate run. The constitution's sixth principle asks the template to keep its tooling
current rather than carry it.

| Action | Pinned | Latest release |
|---|---|---|
| `actions/checkout` | v4 | v7 |
| `actions/setup-python` | v5 | v7 |
| `astral-sh/setup-uv` | v5 | v10 |
| `actions/upload-artifact` | v4 | v7 |
| `actions/download-artifact` | v4 | v8 |
| `actions/configure-pages` | v5 | v6 |
| `actions/deploy-pages` | v4 | v5 |
| `actions/upload-pages-artifact` | v3 | v5 |
| `softprops/action-gh-release` | v2 | v3 |
| `pdm-project/setup-pdm` | v4 | v4 |

## What Changes

- The repository gets a Dependabot configuration that opens grouped weekly pull requests for its own
  GitHub Actions and pre-commit hooks.
- The repository's workflows move to the current major versions.
- The template's GitHub workflow pins move to the same current major versions, so a new project starts
  current.

## Out of Scope

- Automating updates of the pins inside the `.jinja` workflow templates. No update bot reads `.jinja`
  files, so they move by hand in a change like this one.
- The Docker images and Python versions in the non-GitHub pipelines, owned by
  `fix-provider-ci-python-version`.
- The repository's Python dependencies in `uv.lock`.

## Matrix

The template pins change only on the GitHub provider, for every layout and both package managers.
GitLab, Azure DevOps, and Bitbucket pin no GitHub Actions and are unaffected. None has no pipeline.

## Capabilities

### New Capabilities

- `repo-dependency-updates`: how the repository keeps its own CI and hook dependencies, and the
  versions the template pins for generated projects, current.

### Modified Capabilities

None.

## Impact

- New `.github/dependabot.yml`.
- `.github/workflows/tests.yml` and `.github/workflows/doc.yml`.
- `project/{% if git_provider == 'GitHub' %}.github{% endif %}/workflows/*.yml.jinja`.
- `tests/expected/`: the GitHub fixtures' workflows change.
