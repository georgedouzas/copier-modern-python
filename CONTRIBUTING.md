# Contributing

Contributions are welcome, and they are greatly appreciated.

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

```bash
feat(directive): A new feature of code

A description of the new feature.
It contains **important** information.

BREAKING CHANGES:
Explanation, code, etc.

Issue #10: https://github.com/namespace/project/issues/10
Related to PR namespace/other-project#15: https://github.com/namespace/other-project/pull/15
```

### Guidelines

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
