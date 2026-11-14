# Contributing

Contributions are welcome, and they are greatly appreciated.

## Tasks

This project uses [nox](https://nox.thea.codes/en/stable/) to run development tasks. Please check the `noxfile.py` at the root of
the project for more details. You can run any of the following commands and subcommands that corresponds to a particular task:

### Documentation

- `uv run nox -s docs`: Serve the documentation.
- `uv run nox -s docs -- build`: Build locally the documentation.

### Formatting

- `uv run nox -s formatting`: Format both the code and docstrings.
  - `uv run nox -s formatting -- code`: Format only the code.
  - `uv run nox -s formatting -- docstrings`: Format only the docstrings.

### Checks

- `uv run nox -s checks`: Run all checks.
  - `uv run nox -s checks -- quality`: Check only code quality.
  - `uv run nox -s checks -- types`: Check only type annotations.
  - `uv run nox -s checks -- dependencies`: Check only for vulnerabilities in dependencies.
  - `uv run nox -s checks -- security`: Run only security checks with bandit.
  - `uv run nox -s checks -- docs`: Check only docstring coverage with interrogate.

### Tests

- `uv run nox -s tests`: Run the tests.

### Changelog

- `uv run nox -s changelog`: Build the changelog.

### Release

- `uv run nox -s release`: Release a new Python package with an updated version.

## Development

The next steps should be followed during development:

- `git checkout -b new-branch-name` to create a new branch and then modify the code.
- `uv run nox -s formatting` to auto-format the code and docstrings.
- `uv run nox -s checks` to apply all checks.
- `uv run nox -s tests` to run the tests.
- `uv run nox -s docs` if you updated the documentation or the project dependencies to check that everything looks as expected.

## Commit message convention

Commit messages follow conventions based on the [Angular
style](https://gist.github.com/stephenparish/9941e89d80e2bc58a153#format-of-the-commit-message).

### Structure

```bash
<type>(<scope>): <subject>

<body>

<footer>
```

### Example

```
feat(directive): A new feature of code

A description of the new feature.
It contains **important** information.

Issue #10: https://github.com/namespace/project/issues/10
Related to PR namespace/other-project#15: https://github.com/namespace/other-project/pull/15
```

#### Guidelines

- Scope and body are optional.
- Subject and body must be valid Markdown.
- Body must add trailers at the end, for example issues and PR references or co-authors.
- Subject must have proper casing, i.e. uppercase for first letter if it makes sense.
- Subject must have no dot at the end and no punctuation.
- Type can be:
  - `feat`: New feature implementation.
  - `fix`: Bug fix.
  - `docs`: Documentation changes.
  - `style`: Code style or format changes.
  - `refactor`: Changes that are not features or bug fixes.
  - `tests`: Test additions or corrections.
  - `chore`: Maintenance code changes.

## Pull Request guidelines

Link to any related issue in the Pull Request message. We also recommend using fixups:

```bash
git commit --fixup=SHA
```

Once all the changes are approved, you can squash your commits:

```bash
git rebase -i --autosquash master
```

And force-push:

```bash
git push -f
```
