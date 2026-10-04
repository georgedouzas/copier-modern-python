[black badge]: <https://img.shields.io/badge/%20style-black-000000.svg>
[black]: <https://github.com/psf/black>
[docformatter badge]: <https://img.shields.io/badge/%20formatter-docformatter-fedcba.svg>
[docformatter]: <https://github.com/PyCQA/docformatter>
[ruff badge]: <https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/charliermarsh/ruff/main/assets/badge/v1.json>
[ruff]: <https://github.com/charliermarsh/ruff>
[mypy badge]: <http://www.mypy-lang.org/static/mypy_badge.svg>
[mypy]: <http://mypy-lang.org>
[mkdocs badge]: <https://img.shields.io/badge/docs-mkdocs%20material-blue.svg?style=flat>
[mkdocs]: <https://squidfunk.github.io/mkdocs-material>
[pip-audit badge]: <https://img.shields.io/badge/security-pip--audit-green>
[pip-audit]: <https://github.com/pypa/pip-audit>
[bandit badge]: <https://img.shields.io/badge/security-bandit-yellow>
[bandit]: <https://github.com/PyCQA/bandit>
[pytest badge]: <https://img.shields.io/badge/tests-pytest-blue>
[pytest]: <https://github.com/pytest-dev/pytest>
[coverage badge]: <https://img.shields.io/badge/coverage-pytest--cov-blue>
[coverage]: <https://github.com/nedbat/coveragepy>
[interrogate badge]: <https://img.shields.io/badge/docstring-interrogate-blue>
[interrogate]: <https://github.com/econchick/interrogate>
[pre-commit badge]: <https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit>
[pre-commit]: <https://github.com/pre-commit/pre-commit>
[nox badge]: <https://img.shields.io/badge/%F0%9F%A6%8A-Nox-D85E00.svg>
[nox]: <https://github.com/wntrblm/nox>
[pythonversion badge]: <https://img.shields.io/pypi/pyversions/test-repo.svg>
[discussions]: <https://github.com/gdouzas/test-repo/discussions>
[discussions badge]: <https://img.shields.io/github/discussions/gdouzas/test-repo>
[ci]: <https://github.com/gdouzas/test-repo/actions?query=workflow>
[ci badge]: <https://github.com/gdouzas/test-repo/actions/workflows/ci.yml/badge.svg?branch=main>
[doc]: <https://github.com/gdouzas/test-repo/actions?query=workflow>
[doc badge]: <https://github.com/gdouzas/test-repo/actions/workflows/doc.yml/badge.svg?branch=main>

# test-repo

[![ci][ci badge]][ci] [![doc][doc badge]][doc]

| Category          | Tools    |
| ------------------| -------- |
| **Development**   | [![black][black badge]][black] [![ruff][ruff badge]][ruff] [![mypy][mypy badge]][mypy] [![docformatter][docformatter badge]][docformatter] |
| **Testing**       | [![pytest][pytest badge]][pytest] [![coverage][coverage badge]][coverage] [![interrogate][interrogate badge]][interrogate] |
| **Security**      | [![pip-audit][pip-audit badge]][pip-audit] [![bandit][bandit badge]][bandit] |
| **Automation**    | [![nox][nox badge]][nox] [![pre-commit][pre-commit badge]][pre-commit] |
| **Package**       |  ![pythonversion][pythonversion badge] |
| **Documentation** | [![mkdocs][mkdocs badge]][mkdocs]|
| **Communication** | [![discussions][discussions badge]][discussions] |

## Introduction

A test project.

## Installation

Development installation requires to clone the repository and then use [uv](https://github.com/astral-sh/uv) to install the
project as well as the main and development dependencies:

```bash
git clone https://github.com/gdouzas/test-repo.git
cd test_repo
uv sync
```

## Usage

Run the flow locally. No account or server is needed; Metaflow's local mode is the default:

```bash
python -m test_repo.flow run
```

Notebooks live in `notebooks/` and are executed by the test suite, so a notebook that stops
working fails the build. Anything placed in `data/` stays out of version control.

## Spec-driven development

The project's engineering constitution lives in `openspec/constitution.md` and binds all work. The
project uses [OpenSpec](https://github.com/Fission-AI/OpenSpec) for spec-driven development: run
`openspec init` once to add the workflow, and `openspec/config.yaml` already names the constitution
as binding.
