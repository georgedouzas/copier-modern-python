# Tasks

## 1. Prove the include mechanism

- [x] 1.1 Move the root `constitution.md` to `includes/constitution.md` (plain `mv` plus `git add`,
      the file was untracked), add a
      throwaway wrapper that does `{% include 'includes/constitution.md' %}`, render one project
      with `copier copy`, and confirm the body appears in the output before deleting anything

## 2. The question

- [x] 2.1 Replace `include_speckit` and `include_agents_md` in `copier.yml` with the
      `spec_tool` choice from design.md, default `openspec`

## 3. The shipped files

- [x] 3.1 Create `project/{% if spec_tool == 'openspec' %}openspec{% endif %}/constitution.md.jinja`
      as a wrapper: project header, the include, and the Project Profile rendered from the
      answers (package manager, layout framework, task runner)
- [x] 3.2 Create `project/{% if spec_tool == 'openspec' %}openspec{% endif %}/config.yaml.jinja`
      with the default schema and a context naming `openspec/constitution.md` as binding
- [x] 3.3 Rekey the `.specify` conditional directory to `spec_tool == 'speckit'` and replace the
      353-line body of its `memory/constitution.md.jinja` with the same wrapper shape as 3.1
- [x] 3.4 Delete `project/{% if include_agents_md %}AGENTS.md{% endif %}.jinja`

## 4. Documentation

- [x] 4.1 Add a conditional Spec-driven development section to `project/README.md.jinja` (it had
      no AI assistants section to rewrite), with no AGENTS.md mention
- [x] 4.2 Rewrite the AI assistants section of the repository `README.md` the same way, and
      update its usage prompt list

## 5. Fixtures and verification

- [x] 5.1 In `scripts/regen_fixtures.py`, replace the `-speckit-enabled` and
      `-agents-md-disabled` variants with `-spec-tool-speckit` and `-spec-tool-none`, and swap
      the matching two name-to-answer lines in `tests/test_copier.bats`
- [x] 5.2 Run `make regen-fixtures` and confirm the diff shows the old variant directories
      removed, the two new ones added, `openspec/` content and no AGENTS.md in every base
      fixture, and no movement in files this change does not touch
- [x] 5.3 Run `make tests` and confirm the golden suite, the pipeline check, and the docs gate
      all pass with the docs gate unedited
- [x] 5.4 Generate one project per spec tool answer and diff the constitution bodies of the
      openspec and speckit outputs against each other, confirming the same body placed per tool
      and no root constitution file left in this repository
