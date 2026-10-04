"""Build the documentation of every fixture under `tests/expected` in a shared environment."""

import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    sys.exit('Python 3.11 or newer is required, for its tomllib module.')

REPO = Path(__file__).resolve().parent.parent
EXPECTED = REPO / 'tests' / 'expected'
DOCS_INPUTS = ('properdocs.yml', 'docs', 'src', 'README.md', 'CONTRIBUTING.md', 'CHANGELOG.md', 'notebooks')

INSTALL_UV = 'uv is required to provision the docs environment. Install it from https://docs.astral.sh/uv/.'


def digest_docs_inputs(fixture: Path) -> str:
    """Hash the files a fixture's docs build reads.

    Args:
        fixture: The fixture directory.

    Returns:
        A hex digest identifying the fixture's documentation configuration.
    """
    digest = hashlib.sha256()
    for name in DOCS_INPUTS:
        root = fixture / name
        if root.is_dir():
            paths = sorted(path for path in root.rglob('*') if path.is_file())
        elif root.is_file():
            paths = [root]
        else:
            continue
        for path in paths:
            digest.update(str(path.relative_to(fixture)).encode())
            digest.update(path.read_bytes())
    return digest.hexdigest()


def load_docs_requirements(fixture: Path) -> list[str]:
    """Read the docs dependency group a fixture declares, in either package manager's form.

    Args:
        fixture: The fixture directory.

    Returns:
        The requirement strings of the fixture's docs group, empty when it declares none.
    """
    data = tomllib.loads((fixture / 'pyproject.toml').read_text(encoding='utf-8'))
    pdm_group = data.get('tool', {}).get('pdm', {}).get('dev-dependencies', {}).get('docs', [])
    pep735_group = data.get('dependency-groups', {}).get('docs', [])
    return [item for item in [*pdm_group, *pep735_group] if isinstance(item, str)]


def collect_requirements(fixtures: list[Path]) -> list[str]:
    """Union the docs requirements declared across all fixtures.

    Args:
        fixtures: The fixture directories.

    Returns:
        The de-duplicated requirement strings, in first-seen order.
    """
    requirements: dict[str, None] = {}
    for fixture in fixtures:
        for requirement in load_docs_requirements(fixture):
            requirements[requirement] = None
    if not requirements:
        sys.exit('No fixture declares a docs dependency group, so there is nothing to install.')
    return list(requirements)


def provision_environment(workdir: Path, requirements: list[str]) -> Path:
    """Create one shared virtual environment holding the docs toolchain.

    Args:
        workdir: The temporary directory to create the environment in.
        requirements: The requirement strings to install.

    Returns:
        The environment's executables directory.
    """
    uv = shutil.which('uv')
    if uv is None:
        sys.exit(INSTALL_UV)
    venv = workdir / 'venv'
    for command in (
        [uv, 'venv', str(venv)],
        [uv, 'pip', 'install', '--python', str(venv / 'bin' / 'python'), *requirements],
    ):
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        if result.returncode != 0:
            sys.exit(
                f'Provisioning the docs environment failed, so no fixture was checked. Check that '
                f'the package index is reachable.\n{result.stdout}\n{result.stderr}',
            )
    return venv / 'bin'


def build_docs(fixture: Path, venv_bin: Path, workdir: Path) -> str | None:
    """Build one fixture's documentation in a temporary copy of it.

    Args:
        fixture: The fixture directory.
        venv_bin: The shared environment's executables directory.
        workdir: The temporary directory to copy the fixture into.

    Returns:
        The captured build output when the build fails, or None when it passes.
    """
    workcopy = workdir / fixture.name
    shutil.copytree(fixture, workcopy)
    environment = {**os.environ, 'PYTHONPATH': 'src', 'PATH': f'{venv_bin}{os.pathsep}{os.environ["PATH"]}'}
    result = subprocess.run(
        [str(venv_bin / 'properdocs'), 'build', '--strict'],
        cwd=workcopy,
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )
    shutil.rmtree(workcopy, ignore_errors=True)
    if result.returncode != 0:
        return f'{result.stdout}\n{result.stderr}'
    return None


def main() -> None:
    """Build the documentation of every fixture and fail naming the ones that broke."""
    if not EXPECTED.is_dir():
        sys.exit(f'No fixtures found at {EXPECTED}')
    fixtures = sorted(path for path in EXPECTED.iterdir() if path.is_dir())

    failures: dict[str, str] = {}
    built: dict[str, str] = {}
    with tempfile.TemporaryDirectory() as tmp:
        workdir = Path(tmp)
        requirements = collect_requirements(fixtures)
        venv_bin = provision_environment(workdir, requirements)
        for fixture in fixtures:
            key = digest_docs_inputs(fixture)
            if key in built:
                print(f'  covered {fixture.name} (by {built[key]})')
                continue
            output = build_docs(fixture, venv_bin, workdir)
            print(f'  {"FAIL " if output else "built"}  {fixture.name}')
            if output:
                failures[fixture.name] = output
            built[key] = fixture.name

    if failures:
        print(f'\n{len(failures)} fixture(s) whose documentation does not build:\n')
        for name, output in failures.items():
            print(f'--- {name} ---\n{output}')
        sys.exit(1)
    print(f'docs OK: {len(built)} built, {len(fixtures) - len(built)} covered by docs-identical fixtures')


if __name__ == '__main__':
    main()
