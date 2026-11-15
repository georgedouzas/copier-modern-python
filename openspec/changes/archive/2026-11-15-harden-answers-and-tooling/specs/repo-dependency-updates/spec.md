## MODIFIED Requirements

### Requirement: Generated workflows start current

The GitHub workflows the template generates MUST pin the current major version of each action at the
time of the template release, through a reference the action actually publishes. When an action publishes
no floating major tag, the pin MUST be its latest exact release.

#### Scenario: Fresh GitHub project

- **WHEN** a GitHub project is generated from a template release
- **THEN** every action in its workflows is on the latest major version released before that template
  release, and the workflows pass on their first run

#### Scenario: Action without a major tag

- **WHEN** an action used in the generated workflows publishes only exact version tags, as `setup-uv` does
  from v8
- **THEN** the template pins its latest exact release, for example `astral-sh/setup-uv@v10.3.3`

## ADDED Requirements

### Requirement: Every pinned action reference resolves

The repository MUST have a check that resolves every `uses: owner/repo@ref` in its own workflows and in
the workflows of every golden fixture against the action's repository, and fails naming each reference
that does not exist as a tag or branch. The repository's CI MUST run it on every push and pull request.

#### Scenario: Missing tag

- **WHEN** a workflow in the repository or in a fixture pins `astral-sh/setup-uv@v10`
- **THEN** the check fails and names `astral-sh/setup-uv@v10` and the file that pins it

#### Scenario: Branch reference

- **WHEN** a workflow pins `pypa/gh-action-pypi-publish@release/v1`
- **THEN** the check accepts it, since `release/v1` is a branch of that repository

### Requirement: Generated commit hooks start current and stay current

The `.pre-commit-config.yaml` the template generates MUST pin the latest release of each hook repository
at the time of the template release, and MUST use each hook's current id. The generated update bot
configuration MUST propose updates to those hooks.

#### Scenario: Fresh project hooks

- **WHEN** a project is generated from a template release
- **THEN** every hook in its `.pre-commit-config.yaml` is on the latest release published before that
  template release, and `pre-commit run --all-files` reports no legacy hook id

#### Scenario: Hook update proposed

- **WHEN** a hook repository used by a generated project publishes a new release
- **THEN** the generated `renovate.json` lets Renovate propose updating it
