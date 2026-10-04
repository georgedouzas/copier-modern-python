## Project Profile: {{ repository_name }}

This section instantiates the body above for this repository. It is the repo-specific part, and it is a starting point
to fill in as the project takes shape.

- Ecosystem contract: TODO name the framework contract this project conforms to (for example, an estimator or plugin
  contract, a web framework's application contract, or none if the project defines its own).
- Language: Python {{ python_versions }}.
- Build and tooling: {% if package_manager == "PDM" %}PDM{% else %}uv{% endif %} with SCM-derived versioning and a `src`
  layout. The `nox` sessions are `formatting`, `checks`, `tests`, `docs`, `changelog`, and `release`. The gate covers
  `ruff`, `mypy`, `bandit`, `pip-audit`, `deptry`, `pydoclint`, and `interrogate`, with `pytest` under branch coverage
  and randomized ordering.
{% if project_layout == "ml" -%}
- Layout: machine learning. The pure logic lives in `src/{{ python_package_import_name }}`; experiments live in
  `notebooks/`, executed by the test suite; the Metaflow flow runs locally; datasets under `data/` are not committed.
{% elif project_layout == "dataeng" -%}
- Layout: data engineering. The Kedro pipeline lives in `src/{{ python_package_import_name }}`, its catalog in `conf/`,
  and datasets under `data/` are not committed. Kedro telemetry is declined in `.telemetry`.
{% elif project_layout == "service" -%}
- Layout: service. The FastAPI application lives in `src/{{ python_package_import_name }}/app.py` and exposes a health
  endpoint; it runs locally with no external service.
{% elif project_layout == "script" -%}
- Layout: command line tool. The package under `src/{{ python_package_import_name }}` exposes a `{{ repository_name }}`
  command through `cli.py`.
{% else -%}
- Layout: library. The importable package under `src/{{ python_package_import_name }}` is distributed to others.
{% endif -%}

**Version**: 1.0.0 | **Ratified**: {{ copyright_date }}-01-01 | **Last Amended**: {{ copyright_date }}-01-01
