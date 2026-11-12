# Tasks

## 1. Make the forms recognisable

- [x] 1.1 Rename `.github/ISSUE_TEMPLATE/bug_report.yaml.jinja` to `bug_report.yaml` and
  `config.yml.jinja` to `config.yml` with `git mv`, and verify `ls .github/ISSUE_TEMPLATE` shows no
  `.jinja` file.
- [x] 1.2 Replace the placeholders in `bug_report.yaml` with this repository's values, and verify
  `grep -rn '{{' .github/ISSUE_TEMPLATE` finds nothing.

## 2. Make the content correct

- [x] 2.1 Remove the Discussions contact link from `config.yml`, keeping `blank_issues_enabled: true`,
  and verify with `gh api repos/georgedouzas/copier-modern-python --jq .has_discussions` that the removal
  matches the repository setting.
- [x] 2.2 Set the forms' labels to `bug` and `enhancement`, and verify with `gh label list` that both
  labels exist.

## 3. Verify by execution

- [x] 3.1 Parse each file with PyYAML and run `pre-commit run --files .github/ISSUE_TEMPLATE/*` to verify
  they are valid YAML.

## Workflow follow-up

- The forms were reworded for a Copier template and "feauture" was fixed, as task 2.3 asked. Its check, reading the
  forms as GitHub renders them, was not run before archive. Read each form in GitHub's file view once the branch is
  pushed, and confirm it renders with no schema error.
- After the change merges, open `https://github.com/georgedouzas/copier-modern-python/issues/new/choose` and confirm
  both forms appear in the chooser.
