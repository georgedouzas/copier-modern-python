# Quickstart: Validate the Docs Build Gate

## Prerequisites

- Python 3.11+, uv, bats, and copier, the same set `make tests` already needs plus uv.
- Network access on the first run, for the docs toolchain install.

## Validate the gate passes on a clean tree

```bash
make tests
```

Expected: the golden suite passes, `check_pipelines.py` passes, then the docs gate reports one
line per fixture, all built or covered-by, and `make tests` exits 0. Note the wall-clock time:
the whole target must stay under 10 minutes warm (SC-004).

## Validate a docs defect is caught (SC-001)

Seed a defect that renders fine but cannot build, regenerate, and watch the gate fail:

```bash
sed -i '' 's|overview/user_guide.md|overview/missing.md|' project/properdocs.yml.jinja
make regen-fixtures
make tests
```

Expected: the golden suite passes (the render is valid), and the docs gate fails naming each
affected fixture with the build error about the missing page (SC-003). Revert:

```bash
git checkout -- project/properdocs.yml.jinja tests/expected
make tests
```

Expected: everything passes again.

## Validate a branch-specific defect is caught (User Story 2)

Repeat the seeding against a conditional branch, for example the ml notebook page in
`project/properdocs.yml.jinja` or the license page inside the `copyright_license != "None"`
condition. Expected: only the fixtures on that branch fail, and they are named.

## Validate prerequisite failures read as such (FR-008)

```bash
PATH=/usr/bin:/bin python3 scripts/check_docs.py
```

Expected: a message naming the missing prerequisite (uv), not a documentation failure.

## Validate the single-tool replacement (User Story 4, once properdocs ships the stack)

After the template's docs groups collapse to the single properdocs requirement and fixtures are
regenerated:

```bash
grep -rn 'mkdocs' tests/expected/*/pyproject.toml tests/expected/*/README.md
make tests
```

Expected: no dependency declaration or badge names mkdocs (SC-007), and the docs gate still
passes for every fixture (SC-006), with the gate itself unedited (FR-013).

## CI

Push a branch and confirm the fixtures job runs the gate on the push and finishes within the
15-minute bound (SC-004). The job already installs uv.
