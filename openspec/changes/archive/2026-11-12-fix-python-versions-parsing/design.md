# Design

## Context

The parsing lives in four copies, two in `pyproject.toml.jinja`, one in `noxfile.py.jinja`, and one in
the GitHub `ci.yml.jinja`. Each splits the answer on commas, strips `>`, `<`, and `=`, takes the second
dot-separated field as the minor version, and indexes `minor_versions[1]` for the upper bound. That
index is what crashes when there is no upper bound. The validator in `copier.yml` reads the last
dot-separated field of the lower bound, which is the patch number when one is present. Copier renders
with the Jinja Ansible filters, so `regex_search`, `regex_findall`, and `strftime` are available.

## Goals / Non-Goals

**Goals:**

- Validate the answer against an exact pattern before anything renders.
- Derive the versions once and let every consumer read the result.

**Non-Goals:**

- Support the full PEP 440 specifier grammar. The template generates CI matrices, and a matrix needs a
  contiguous run of minor versions, which the accepted forms always describe.

## Decisions

**Validate with one regular expression in the question's validator.** The validator matches
`^\s*>=?\s*3\.(\d+)(\.\d+)?\s*(,\s*<=?\s*3\.(\d+)\s*)?$` and then checks the minimum and that the
range is non-empty. The alternative, a Python validator through a Copier extension, adds a dependency
on a local extension module and `--trust` for every user, which is too high a cost for a string check.

**Hold the newest supported minor version in one hidden question.** A question with `when: false`, for
example `python_newest_supported: 13`, is never asked and never written to the answers file, and both
the open-upper-bound case and `update-python-support-range` read it. The alternative, hard-coding the
number inside the derivation, would hide a value that has to move every October.

**Compute the derived versions as a hidden `yaml` question.** A `when: false` question of type `yaml`
whose default renders the list, for example `["3.11", "3.12", "3.13"]`, gives every template the same
value as `python_test_versions`. The lowest entry replaces the separate lower-bound parsing for the
black and ruff targets. The alternative, a Jinja macro in an included file, still repeats the call in
each template and cannot be read by the validator.

## Risks / Trade-offs

- [A hidden question's default renders before validation in some Copier versions] → Write the default
  so it returns an empty list for an unparsable answer instead of failing, and let the validator report
  the error. Verify with Copier 9 by generating with each rejected answer.
- [Whitespace in the rendered list shifts fixtures] → Regenerate and confirm the diff is empty for the
  default answer before committing.
