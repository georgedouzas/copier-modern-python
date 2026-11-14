"""Check that every GitHub Action pinned in the workflows exists at the pinned reference.

Collects each `uses: owner/repo@ref` from the repository's own workflows and from the workflows of every
fixture under `tests/expected`, and resolves the reference as a tag or branch of the action's repository
with `git ls-remote`. A floating tag that an action stopped publishing, such as `astral-sh/setup-uv@v10`,
fails here instead of in the first CI run of a generated project. Needs network access to GitHub.
"""

import re
import shutil
import subprocess
import sys
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
WORKFLOW_GLOBS = ['.github/workflows/*.y*ml', 'tests/expected/*/.github/workflows/*.y*ml']
USES = re.compile(r'^\s*(?:-\s*)?uses:\s*["\']?([^\s"\'#]+)', re.MULTILINE)
COMMIT_SHA = re.compile(r'^[0-9a-f]{40}$')
GIT = shutil.which('git') or sys.exit('git is required to resolve action references')


def collect_references() -> dict[str, list[Path]]:
    """Collect every remote action reference and the workflow files that pin it.

    Returns:
        A mapping of `owner/repo@ref` to the files that use it. Local actions and Docker images are left
        out, since they have no repository reference to resolve.
    """
    references: dict[str, list[Path]] = defaultdict(list)
    for pattern in WORKFLOW_GLOBS:
        for path in sorted(REPO.glob(pattern)):
            for reference in USES.findall(path.read_text(encoding='utf-8')):
                if reference.startswith(('./', 'docker://')) or '@' not in reference:
                    continue
                references[reference].append(path)
    return references


def resolves(reference: str) -> bool:
    """Tell whether an action reference exists as a tag or branch of its repository.

    Args:
        reference: An `owner/repo[/path]@ref` reference.

    Returns:
        True if the reference resolves. A full commit SHA is accepted as is, since `git ls-remote` only
        lists named references.
    """
    action, ref = reference.rsplit('@', 1)
    if COMMIT_SHA.match(ref):
        return True
    owner, repo = action.split('/')[:2]
    url = f'https://github.com/{owner}/{repo}'
    result = subprocess.run(
        [GIT, 'ls-remote', '--exit-code', url, f'refs/tags/{ref}', f'refs/heads/{ref}'],
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode == 0


def main() -> None:
    """Resolve every pinned action reference and report the ones that do not exist."""
    references = collect_references()
    if not references:
        sys.exit('No action references found in the workflows')

    with ThreadPoolExecutor(max_workers=8) as pool:
        results = dict(zip(references, pool.map(resolves, references), strict=True))

    missing = sorted(reference for reference, found in results.items() if not found)
    if missing:
        print(f'{len(missing)} pinned action reference(s) do not exist:\n')
        for reference in missing:
            paths = references[reference]
            print(f'  - {reference}, pinned in {paths[0].relative_to(REPO)}', end='')
            print(f' and {len(paths) - 1} more file(s)' if len(paths) > 1 else '')
        sys.exit(1)
    files = len({path for paths in references.values() for path in paths})
    print(f'actions OK: {len(references)} references in {files} workflow files resolve')


if __name__ == '__main__':
    main()
