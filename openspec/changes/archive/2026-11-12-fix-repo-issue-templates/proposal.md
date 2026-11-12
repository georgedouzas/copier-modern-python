# Proposal

## Why

The repository's own `.github/ISSUE_TEMPLATE/` holds `bug_report.yaml.jinja` and `config.yml.jinja`.
GitHub reads issue forms only from `.yml` and `.yaml` files, so it ignores both, and the repository
offers no bug report form and no issue chooser configuration. Only `feature_request.yaml` works. The
bug report form also still carries unrendered Jinja, `{{ repository_namespace }}` and
`{{ repository_name }}`, because the files were copied from the template and never rendered. The
chooser configuration links to GitHub Discussions, which are disabled on this repository, and both
forms apply the labels `fix` and `feat`, which do not exist here.

## What Changes

- Rename `bug_report.yaml.jinja` to `bug_report.yaml` and `config.yml.jinja` to `config.yml`, so
  GitHub reads them.
- Replace the Jinja placeholders with this repository's own values, `georgedouzas/copier-modern-python`
  and `copier-modern-python`.
- Drop the Discussions contact link, since Discussions are disabled, and keep blank issues enabled.
- Point both forms at labels that exist, `bug` and `enhancement`.
- Fix the typo "feauture" in `feature_request.yaml`, and reword both forms for a project template
  rather than an algorithm library.

## Out of Scope

- The generated projects. Their issue templates were removed by the change that closed issue #2.
- The `Discussions` URL the template writes into a generated GitHub project's `pyproject.toml`. It is a
  separate question for the template and is not touched here.
- Enabling Discussions on this repository.

## Matrix

No branch of the layout, provider, or package manager matrix is affected. The change touches only the
repository's own `.github/`, which the template does not render.

## Capabilities

### New Capabilities

- `repo-issue-forms`: the issue forms this repository offers to people reporting a bug or requesting a
  feature in the template.

### Modified Capabilities

None.

## Impact

- `.github/ISSUE_TEMPLATE/bug_report.yaml.jinja` renamed to `bug_report.yaml` and edited.
- `.github/ISSUE_TEMPLATE/config.yml.jinja` renamed to `config.yml` and edited.
- `.github/ISSUE_TEMPLATE/feature_request.yaml` edited.
- No rendered output changes, so no fixture changes.
