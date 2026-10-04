# Copier Modern Python

[Copier](https://github.com/copier-org/copier) template for modern Python projects.

This template provides a comprehensive, production-ready Python project structure with modern tooling and best practices. It
supports both [PDM](https://github.com/pdm-project/pdm) and [uv](https://github.com/astral-sh/uv) package managers, includes
automated testing and quality checks, comprehensive documentation setup, and CI/CD workflows for multiple Git providers.

## Features

During the Copier generation process, you'll be prompted to select your preferences for package management, Git provider,
licensing, and other options. The template then generates a customized project structure with only the tools and configurations
you need.

### Package Management

Choose between two modern Python package managers. [PDM](https://github.com/pdm-project/pdm) offers cutting-edge dependency
management with PEP 582 support, allowing you to avoid virtual environments entirely. [uv](https://github.com/astral-sh/uv)
provides blazing-fast package installation and resolution, significantly reducing setup times. Both managers handle dependency
locking, virtual environment management, and script execution seamlessly.

### Task Runner

[Nox](https://github.com/wntrblm/nox) replaces traditional Makefiles with Python-based automation. The template includes
pre-configured sessions for testing across multiple Python versions, code formatting, quality checks, and documentation building.
This ensures consistent development workflows across different environments and team members.

### Project layouts

Choose the kind of project you are starting and the generated tree fits it, so nothing has to be deleted before work begins:

| Layout | What you get | Published | Container |
| ------ | ------------ | --------- | --------- |
| `library` (default) | An importable `src/` package you distribute to others | Yes | Opt-in |
| `script` | The same, plus a [click](https://click.palletsprojects.com) command and a console entry point | Yes | Opt-in |
| `ml` | A [Metaflow](https://metaflow.org) flow, a `notebooks/` directory executed as part of the test suite and rendered into the docs, and a `data/` directory kept out of version control | No | Opt-in |
| `dataeng` | A [Kedro](https://kedro.org) pipeline with a `conf/` catalog, plus `data/` kept out of version control | No | Yes |
| `service` | A [FastAPI](https://fastapi.tiangolo.com) application with a health endpoint, served by uvicorn | No | Yes |

A Dockerfile is generated for the layouts that are deployed rather than installed, and can be opted into for any of the others.
Kedro ships telemetry as a core dependency, so the `dataeng` layout writes a `.telemetry` file declining it — a project generated
from a template never had the chance to consent, so consent is not assumed.

Every layout carries the same quality floor: the same task names, the same checks at the same strictness, and the same release
topology. Layouts differ in what they generate, never in whether that floor applies. The machine learning layout publishes
nothing to a package index, so publishing is simply absent rather than generated and left broken.

Layouts add only what a task actually exercises, and any framework they add runs locally with no account or server to
provision. Changing a project's layout after generation is out of scope: the answer can be changed, but the result is whatever
the update merge produces, and it is neither supported nor tested.

### Spec-driven development

Generated projects ship with a spec-driven workflow tool seeding their engineering constitution, asked as one
question with three answers. The default is [OpenSpec](https://github.com/Fission-AI/OpenSpec), which lays down
`openspec/constitution.md` and an `openspec/config.yaml` naming it as binding; run `openspec init` to add the rest of
the workflow. The alternative is [Spec Kit](https://github.com/github/spec-kit), which lays down the same constitution
as `.specify/memory/constitution.md`; run `specify init` alongside it. Answering None ships neither. Both tools seed
the identical constitution, the repo-agnostic body of engineering rules ending in a Project Profile instantiated for
the generated project, so the choice is about workflow tooling, never about which rules apply.

### Documentation

Automatic documentation generation using [properdocs](https://github.com/properdocs/properdocs) with the beautiful
[Material](https://squidfunk.github.io/mkdocs-material) theme. The [mkdocstrings](https://mkdocstrings.github.io/) plugin extracts
API documentation directly from your docstrings, keeping documentation in sync with code. Includes example pages, custom CSS, and
responsive design out of the box.

### Code Quality & Formatting

Enforce consistent code style with [black](https://github.com/psf/black) for uncompromising formatting and
[docformatter](https://github.com/PyCQA/docformatter) for PEP 257 compliant docstrings. [Ruff](https://github.com/astral-sh/ruff)
provides extremely fast linting with hundreds of rules, replacing multiple toolsin a single, performant package.
[interrogate](https://interrogate.readthedocs.io/en/latest/) ensures your code is properly documented by checking docstring
coverage.

### Security & Safety

Proactive security scanning with [pip-audit](https://github.com/pypa/pip-audit) to detect known vulnerabilities in dependencies
and [bandit](https://github.com/PyCQA/bandit) to identify common security issues in your code. Both run as part of the `checks`
task and in CI, and both read their configuration from `pyproject.toml`, so a project records its own suppressions where the rest
of its tooling lives.

### Type Checking

[mypy](https://github.com/python/mypy) provides static type analysis to catch type-related bugs before runtime. The template
includes sensible defaults and excludes common directories like tests and generated documentation.

### Testing

Comprehensive testing setup with [pytest](https://github.com/pytest-dev/pytest) and essential plugins.
[coverage](https://github.com/coveragepy/coveragepy) tracks code coverage with HTML reports. Tests run in parallel for faster
feedback during development.

### Development Workflow

[pre-commit](https://github.com/pre-commit/pre-commit) hooks automatically run quality checks before each commit, preventing
broken code from entering the repository. [git-changelog](https://github.com/pawamoy/git-changelog) generates beautiful changelogs
from conventional commit messages, automating release documentation.

Releasing has one shape on every provider. The `release` task is the local half: it writes the changelog, opens and merges the
release pull request, and pushes the tag. The pipeline is the only publisher, and it will not publish a tag whose tests and
quality checks have not passed. Exactly one publisher exists for a given version, so a local release cannot race the pipeline for
it.

### Platform Support

Supports all major Git providers with pre-configured CI/CD workflows. Choose from GitHub Actions, GitLab CI, Azure Pipelines, or
Bitbucket Pipelines. Includes automated testing, quality checks, documentation deployment, and PyPI publishing. License selection
covers all popular open-source licenses with proper SPDX identifiers.

## Prerequisites

Before using this template, ensure you have the following tools installed:

### Required Tools

- [Python](https://www.python.org/) (>= 3.11)
- [Git](https://git-scm.com/) (>= 2.30.0)
- [Copier](https://github.com/copier-org/copier)

### Package Manager

Choose one of the following:

- [PDM](https://github.com/pdm-project/pdm) (>= 2.9.0)
- [uv](https://github.com/astral-sh/uv) (>= 0.1.0)

### Git Provider CLI Tools

Depending on your chosen Git provider, install the corresponding CLI tool for automated releases:

- [GitHub](https://cli.github.com/)
- [GitLab](https://gitlab.com/gitlab-org/cli)
- [Azure](https://docs.microsoft.com/en-us/cli/azure/)
- [Atlassian](https://developer.atlassian.com/cloud/acli)

## Usage

### Creating a New Project

To create a new Python project using this template:

```bash
copier copy "gh:georgedouzas/copier-modern-python.git" /path/to/your/new/project
```

The template will prompt you for various configuration options including:

- Project name and description
- Author information
- Package manager preference (PDM or uv)
- Project layout (library, command line tool, machine learning, data engineering, or service)
- Whether to include a Dockerfile, and the spec-driven workflow tool (OpenSpec, Spec Kit, or None)
- Git provider (GitHub, GitLab, Azure DevOps, Bitbucket, or None)
- License selection
- Python version requirements
- Publishing preferences, unless the layout publishes nothing

### Updating an Existing Project

To update your project with the latest template version:

```bash
cd /path/to/your/project
copier update
```

This will apply any template updates while preserving your project-specific configurations.
