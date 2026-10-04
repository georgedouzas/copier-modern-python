#!/usr/bin/env bats
#
# Golden-file tests: render every fixture under tests/expected and diff it against the
# committed output. The fixtures are the single source of truth for which combinations exist;
# each fixture's directory name encodes the answers it was built from, so this suite needs no
# per-fixture case and cannot drift out of step with what scripts/regen_fixtures.py writes.

# Map a git-provider name segment to the answer copier expects.
provider_value() {
    case "$1" in
        github) echo "GitHub" ;;
        gitlab) echo "GitLab" ;;
        azure-devops) echo "Azure DevOps" ;;
        bitbucket) echo "Bitbucket" ;;
        none) echo "None" ;;
    esac
}

# Map a package-manager name segment to the answer copier expects.
manager_value() {
    case "$1" in
        pdm) echo "PDM" ;;
        uv) echo "uv" ;;
    esac
}

# Turn a fixture directory name into the --data flags that reproduce it.
fixture_data() {
    local name="$1"
    local layout provider manager rest

    layout="${name#layout-}"
    layout="${layout%%-git-provider-*}"

    rest="${name#*-git-provider-}"
    provider="${rest%%-package-manager-*}"

    rest="${name#*-package-manager-}"
    manager="${rest%%-*}"

    printf -- '--data\nproject_layout=%s\n' "$layout"
    printf -- '--data\ngit_provider=%s\n' "$(provider_value "$provider")"
    printf -- '--data\npackage_manager=%s\n' "$(manager_value "$manager")"
    [[ "$name" == *-publish-pypi-disabled ]] && printf -- '--data\npublish_pypi=False\n'
    [[ "$name" == *-license-none ]] && printf -- '--data\ncopyright_license=None\n'
    [[ "$name" == *-spec-tool-speckit ]] && printf -- '--data\nspec_tool=speckit\n'
    [[ "$name" == *-spec-tool-none ]] && printf -- '--data\nspec_tool=none\n'
}

setup() {
    export TEST_DIR="$(mktemp -d)"
    export TEMPLATE_DIR="$(pwd)"
    export EXPECTED_DIR="$TEMPLATE_DIR/tests/expected"
    cd "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "Every fixture renders identically to its committed output" {
    local failures=0
    for dir in "$EXPECTED_DIR"/*/; do
        local name out
        name="$(basename "$dir")"
        out="$TEST_DIR/$name"

        local data=()
        while IFS= read -r line; do data+=("$line"); done < <(fixture_data "$name")

        copier copy "$TEMPLATE_DIR" "$out" --defaults --vcs-ref=HEAD \
            --data project_description="A test project." \
            --data author_fullname="Georgios Douzas" \
            --data author_email="gdouzas@icloud.com" \
            --data author_username="gdouzas" \
            --data repository_name="test-repo" \
            "${data[@]}" || true

        if [ ! -d "$out" ]; then
            echo "FAIL ${name}: nothing rendered"
            failures=$((failures + 1))
            continue
        fi
        if ! diff -r --exclude=.copier-answers.yml "$dir" "$out"; then
            echo "FAIL ${name}: rendered output differs from the fixture"
            failures=$((failures + 1))
        fi
    done
    [ "$failures" -eq 0 ]
}
