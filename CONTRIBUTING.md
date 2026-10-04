# Contributing

Contributions are welcome, and they are greatly appreciated.

## Working on the template

Two trees matter and are easy to confuse:

- `project/` is the template source. Its `.jinja` files are rendered into a new project, and
  directory names containing `{% ... %}` are literal names on disk, not placeholders.
- `tests/expected/` holds the rendered output for each supported combination of answers.

Fixtures are the specification. Regenerate them with `make regen-fixtures`; never edit one by
hand to match an expectation. `scripts/regen_fixtures.py` is the single source of truth for
which combinations exist — the full cross product of layout, git provider and package manager,
plus the publish and license edges — and `tests/test_copier.bats` reads the same set back by
iterating the directories, reconstructing each render's answers from its name. Neither the
golden test nor the fixture list needs a per-fixture case, so they cannot drift apart.

Run `make tests` before every commit, and `make tests-integration` whenever you touch
`project/noxfile.py.jinja`, `project/pyproject.toml.jinja` or a pipeline template — that target
generates real projects and runs their toolchains, which is the only way to know a change works.

The repository holds its own Python to the same bar it ships. `make checks`, which `make tests`
runs first, gates the scripts under `scripts/` with black, ruff, and mypy, using the same
configuration in `pyproject.toml` that the template puts in a generated project. The same three
run on commit through pre-commit, scoped to `scripts/` so they never touch the `.jinja` templates
or the rendered fixtures.

`make tests` also runs `scripts/check_pipelines.py`, which parses every generated YAML rather
than reading it. Jinja whitespace control can move a key into the block scalar above it,
producing a file that still parses and means something else entirely; a textual diff cannot see
that, so the fixture would record the broken output just as faithfully as correct output. That
checker deliberately excludes GitHub Actions `${{ ... }}` expression syntax from its
unrendered-construct scan, because the templates emit it on purpose; the negative lookbehind in
the pattern is what keeps a real expression from being flagged as leftover Jinja.

`make tests` finishes with `scripts/check_docs.py`, which builds every fixture's documentation
with `properdocs build --strict` in one shared environment that uv provisions from the docs
dependency groups the fixtures themselves declare. A render can pass the golden diff while the
docs it describes no longer build, and strict mode turns the quiet failures, such as a
navigation entry pointing at a page that does not exist, into hard ones. The first run needs the
network to install the docs toolchain; later runs reuse uv's cache. Fixtures whose docs inputs
are byte-identical are built once and reported as covered by the fixture that built.

## Adding a project layout

A layout is a kind of project the generator can produce. Adding one is deliberately confined to
a few places, so shipped layouts are not disturbed:

1. Add the value to `project_layout` in `copier.yml`, with help text describing the kind of
   project rather than the file tree it emits.
2. Condition the content that varies. Use in-file Jinja for files that mostly stay the same
   (`project/pyproject.toml.jinja`, `project/noxfile.py.jinja`), and conditional directory names
   for whole trees that only one layout wants, following
   `project/{% if project_layout == 'ml' %}notebooks{% endif %}/`.
3. Add the layout segment to `LAYOUTS` in `scripts/regen_fixtures.py`. The fixtures are the
   cross product of the dimensions, so this creates one fixture per provider and package
   manager automatically; the golden test picks them up without a per-fixture case.
4. Add a case to `tests/test_integration.bats` that generates the layout and runs its `install`,
   `checks` and `tests`. The golden suite proves the layout renders; the integration suite proves
   the generated project works.
5. Run `make regen-fixtures`, then confirm `git diff --exit-code tests/expected/` shows changes
   *only* under the new layout's fixtures. Any movement elsewhere means the new layout disturbed
   an existing one, which is a defect rather than something to regenerate away.

Two rules constrain what a layout may carry. It must not add a dependency unless one of the
generated project's own tasks exercises it, and any framework it does add must run locally with
no account or server to provision. Both exist because every generated project pays for each
dependency, including the projects that wanted a different choice.

A layout that is deployed rather than installed should default `include_dockerfile` on. A
layout whose framework collects telemetry must decline it in generated output rather than
inherit consent the project's owner never gave — see the `.telemetry` file the `dataeng`
layout ships.

Layouts differ in what they generate, never in whether the quality floor applies: the same task
names, the same checks at the same strictness, the same release topology.

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
