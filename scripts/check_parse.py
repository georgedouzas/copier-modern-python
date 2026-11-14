"""Check that every TOML and Python file in the generated fixtures under `tests/expected` parses.

YAML files are parsed by `check_pipelines.py`, so this check covers the other formats an answer is written
into.
"""

import ast
import sys
import tomllib
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
EXPECTED = REPO / 'tests' / 'expected'


def parse_failure(path: Path) -> str | None:
    """Parse one file according to its suffix.

    Args:
        path: The TOML or Python file to parse.

    Returns:
        A failure message, or None if the file parses.
    """
    text = path.read_text(encoding='utf-8')
    try:
        if path.suffix == '.toml':
            tomllib.loads(text)
        else:
            ast.parse(text, filename=str(path))
    except (tomllib.TOMLDecodeError, SyntaxError) as error:
        return f'{path.relative_to(REPO)}: does not parse: {error}'
    return None


def main() -> None:
    """Parse every TOML and Python file in every fixture."""
    if not EXPECTED.is_dir():
        sys.exit(f'No fixtures found at {EXPECTED}')

    paths = sorted(p for p in EXPECTED.rglob('*') if p.is_file() and p.suffix in {'.toml', '.py'})
    failures = [failure for path in paths if (failure := parse_failure(path))]
    if failures:
        print(f'{len(failures)} file(s) in the generated fixtures do not parse:\n')
        for failure in failures:
            print(f'  - {failure}')
        sys.exit(1)
    print(f'parse OK: {len(paths)} TOML and Python files parsed')


if __name__ == '__main__':
    main()
