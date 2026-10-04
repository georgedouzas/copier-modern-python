# Tasks

## 1. Unblock

- [ ] 1.1 Confirm on PyPI that a properdocs release carries the documentation stack (theme,
      mkdocstrings, gen-files, literate-nav, section-index, gallery, coverage, callouts,
      markdown-exec, jupyter) as dependencies or an extra, record the version and whether
      jupyter is included, and stop here if no such release exists

## 2. Swap the declarations

- [ ] 2.1 Collapse the `docs` groups in `project/pyproject.toml.jinja` to the single properdocs
      requirement at the confirmed version, in both the PDM and the uv branches, keeping a
      separate ml-only jupyter requirement only if the release excludes jupyter
- [ ] 2.2 Replace the mkdocs material badge with a properdocs badge in
      `project/README.md.jinja`
- [ ] 2.3 Apply the single-tool rule to the repository's own `[dependency-groups]` in
      `pyproject.toml`, removing the enumerated mkdocs packages properdocs now carries

## 3. Verify by execution

- [ ] 3.1 Run `make regen-fixtures` and confirm `git diff tests/expected/` moves only
      `pyproject.toml` and `README.md` files
- [ ] 3.2 Run `make tests` and confirm every docs build passes with `scripts/check_docs.py`
      unedited, and `grep -rn mkdocs tests/expected/*/pyproject.toml tests/expected/*/README.md`
      finds nothing
- [ ] 3.3 Run `make tests-integration`, mandatory because `project/pyproject.toml.jinja`
      changed, and confirm every layout's generated toolchain still passes
