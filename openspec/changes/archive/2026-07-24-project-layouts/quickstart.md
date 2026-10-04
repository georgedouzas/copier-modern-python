# Quickstart: Validating Project Layouts

**Feature**: [spec.md](./spec.md) | **Contract**: [contracts/layout-contract.md](./contracts/layout-contract.md)

How to prove the feature works, end to end. These are validation scenarios, not
implementation steps — the work itself belongs in `tasks.md`.

## Prerequisites

- `copier`, `bats`, `pdm`, `uv` on `PATH`
- A clean working tree (several checks below are `git diff` based)

## S1: The library layout did not move (contract C7)

The most important scenario, and the one to run first and most often. It must pass **before**
any new layout is added, proving the `project_layout` question alone changed nothing.

```bash
make tests                          # all existing fixtures still diff clean
git diff --exit-code tests/expected/  # and regeneration produced no changes
```

**Expected**: `make tests` reports 8/8 passing (rising as layout fixtures are added), and the
`git diff` exits 0. Any change under `tests/expected/layout-library-git-provider-github-package-manager-pdm/` is a C7 breach — investigate
before continuing, do not regenerate the fixture to make it pass.

## S2: Each layout generates a working project (contract C1)

For each of `library`, `script`, `ml`, and for each package manager:

```bash
copier copy . /tmp/probe --defaults --vcs-ref=HEAD \
  --data project_layout=<layout> --data package_manager=<pm> \
  --data project_description="A probe." --data repository_name="probe"
cd /tmp/probe && git init -q && git add -A && git commit -qm init && git tag 0.1.0
<pm> install && <pm> checks && <pm> tests && <pm> docs build
```

**Expected**: every command exits 0, and `coverage.xml` exists afterwards. This is what
`tests/test_integration.bats` automates; run it by hand first when bringing up a new layout,
because the failure output is easier to read.

## S3: The task interface is identical (contract C2)

```bash
for d in tests/expected/layout-library-git-provider-github-package-manager-pdm tests/expected/layout-script-git-provider-github-package-manager-pdm tests/expected/layout-ml-git-provider-github; do
  echo "== $d"; sed -n '/\[tool.pdm.scripts\]/,/^\[/p' "$d/pyproject.toml"
done
```

**Expected**: the same seven task names in each. Any difference must appear in the session
applicability matrix in [data-model.md](./data-model.md); an undocumented one is a C2 breach.

## S4: Publishing is absent, not broken, for ML (contract C4, FR-009, FR-016)

```bash
grep -rn "twine\|pypi-release\|Release to PyPI" tests/expected/layout-ml-git-provider-github-package-manager-pdm/ || echo "none — correct"
grep -rn "release" tests/expected/layout-ml-git-provider-github-package-manager-pdm/pyproject.toml
```

**Expected**: no publish step anywhere in the ML fixture, **and** the `release` task still
present in `pyproject.toml`. Both halves matter: absent publishing, retained releasing. If
the `release` task vanished too, the layout dropped versioning as well, which C4 forbids.

## S5: Every generated pipeline is structurally valid (contract C6)

Do not read the YAML; parse it. This is the check that would have caught the Azure
`displayName` defect.

```bash
python - <<'PY'
import glob, yaml
for f in glob.glob('tests/expected/*/**/*.yml', recursive=True):
    d = yaml.safe_load(open(f))
    assert d, f"{f} parsed empty"
    print("OK", f)
PY
```

**Expected**: every file parses, none empty. Extend this to assert step names are real keys
rather than script content — that is the specific shape of the bug this guards against.

## S6: An existing project still updates (FR-011, ST-001)

```bash
# from a project generated before this feature
copier update --defaults
```

**Expected**: no prompt for `project_layout`, no conflict attributable to layout, and the
project's kind unchanged. `.copier-answers.yml` gains `project_layout: library`.

## S7: Generated data stays out of version control (contract C5, FR-019)

```bash
cd /tmp/probe                      # an ML-layout project from S2
echo "secret,data" > data/probe.csv
git status --porcelain             # must be empty
git ls-files data/                 # must list the ignore file, proving the dir is tracked
```

**Expected**: `git status --porcelain` prints nothing, and `git ls-files data/` is non-empty.
Both halves matter: contents ignored, directory tracked, so the structure survives a clone
without carrying data.

## S8: The ML layout runs with no infrastructure (FR-021)

```bash
cd /tmp/probe
env -u AWS_ACCESS_KEY_ID -u AWS_SECRET_ACCESS_KEY -u AWS_PROFILE \
  <pm> run pytest -k flow
```

**Expected**: passes. Metaflow's local mode requires no account and no server; if this needs
credentials, FR-021 is breached and the dependency does not belong as a default.

## Definition of done

All eight scenarios pass, plus `make tests` and `make tests-integration` green. S1 and S5 are
the ones to automate first — they are cheap, and they cover the two failure modes this
repository has actually shipped. S7 and S8 guard requirements added during clarification.
