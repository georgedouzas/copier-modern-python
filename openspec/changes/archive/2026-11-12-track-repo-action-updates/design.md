# Design

## Context

Generated projects use Renovate, which needs the Renovate GitHub App installed on each repository. The
app is not installed here. Dependabot is built into GitHub and needs only a configuration file. Several
pending updates are major versions, and the release notes of `upload-artifact`, `download-artifact`,
and `setup-uv` include breaking changes to inputs and defaults.

## Goals / Non-Goals

**Goals:**

- Updates arrive without anyone remembering to look.
- Major bumps are proven by running the workflows that use them.

**Non-Goals:**

- Switching generated projects from Renovate to Dependabot.

## Decisions

**Use Dependabot for the repository.** It needs no app installation and covers `github-actions`. The
alternative, Renovate, would match the generated projects, but requires installing an app and
onboarding, which is the user's call and can replace Dependabot later with no other change.

**Track pre-commit hooks through Dependabot's `pre-commit` ecosystem.** If GitHub rejects the ecosystem
when the configuration is pushed, drop that entry and record that the hooks stay on
`pre-commit autoupdate` by hand.

**Bump the template pins in the same change, one commit per concern.** The repository's workflows and
the template's workflows are separate commits, so the template change and its fixture diff can be
reviewed and reverted alone.

## Risks / Trade-offs

- [A major bump changes an input the generated workflow uses] → Read each action's release notes for the
  skipped majors, adjust the inputs, and run a generated project's workflows on GitHub before merging.
- [`download-artifact` v8 and `upload-artifact` v7 change artifact naming or merging] → Run the generated
  release workflow, which uses both, end to end on a test repository.
