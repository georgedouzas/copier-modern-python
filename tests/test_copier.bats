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
    local failures=0 total=0
    for dir in "$EXPECTED_DIR"/*/; do
        local name out
        name="$(basename "$dir")"
        out="$TEST_DIR/$name"
        total=$((total + 1))

        local data=()
        while IFS= read -r line; do data+=("$line"); done < <(fixture_data "$name")

        copier copy "$TEMPLATE_DIR" "$out" --defaults --vcs-ref=HEAD \
            --data project_description="A test project." \
            --data author_fullname="Georgios Douzas" \
            --data author_email="gdouzas@icloud.com" \
            --data author_username="gdouzas" \
            --data repository_name="test-repo" \
        --data copyright_date="2026" \
            "${data[@]}" || true

        if [ ! -d "$out" ]; then
            echo "      fail  ${name}: nothing rendered" >&3
            failures=$((failures + 1))
            continue
        fi
        if ! diff -r --exclude=.copier-answers.yml "$dir" "$out"; then
            echo "      fail  ${name}: rendered output differs from the fixture" >&3
            failures=$((failures + 1))
        else
            echo "      ok    ${name}" >&3
        fi
    done
    echo >&3
    echo " golden fixtures: $((total - failures)) ok, ${failures} failed of ${total}" >&3
    [ "$failures" -eq 0 ]
}

# Render with the common answers plus overrides, expecting the given question to reject the answer.
expect_rejected() {
    local question="$1" message="$2"
    shift 2
    local out="$TEST_DIR/rejected"
    rm -rf "$out"
    run copier copy "$TEMPLATE_DIR" "$out" --defaults --vcs-ref=HEAD \
        --data project_description="A test project." \
        --data author_fullname="Georgios Douzas" \
        --data author_email="gdouzas@icloud.com" \
        --data author_username="gdouzas" \
        --data repository_name="test-repo" \
        "$@"
    if [ "$status" -eq 0 ] || [ -d "$out" ] \
        || [[ "$output" != *"Validation error for question '$question': $message"* ]]; then
        echo "      fail  $question accepted or rejected without its message: $*" >&3
        return 1
    fi
    echo "      ok    $question rejects $*" >&3
}

@test "Invalid answers are rejected before rendering" {
    local identifier="Use a valid Python identifier in lowercase"
    local distribution="Use letters, digits, \`.\`, \`_\` and \`-\`"
    local email="Use an email address"
    local one_line="Use a single line without a backslash or three double quotes in a row"
    local failures=0
    expect_rejected python_package_import_name "$identifier" --data python_package_import_name=my-pkg \
        || failures=$((failures + 1))
    expect_rejected python_package_import_name "$identifier" --data python_package_import_name=class \
        || failures=$((failures + 1))
    expect_rejected python_package_import_name "$identifier" --data repository_name=2fa-tool \
        || failures=$((failures + 1))
    expect_rejected python_package_distribution_name "$distribution" \
        --data python_package_distribution_name=-pkg- || failures=$((failures + 1))
    expect_rejected author_email "$email" --data author_email=me@localhost || failures=$((failures + 1))
    expect_rejected author_email "$email" --data "author_email=not an email" || failures=$((failures + 1))
    expect_rejected copyright_holder_email "$email" --data copyright_holder_email=x || failures=$((failures + 1))
    expect_rejected project_description "$one_line" --data 'project_description=Parses C:\paths.' \
        || failures=$((failures + 1))
    expect_rejected project_description "$one_line" --data 'project_description=Say """hi""".' \
        || failures=$((failures + 1))
    expect_rejected project_description "$one_line" --data $'project_description=Two\nlines.' \
        || failures=$((failures + 1))
    expect_rejected project_description "This answer cannot be empty" --data 'project_description= ' \
        || failures=$((failures + 1))
    expect_rejected author_fullname "$one_line" --data 'author_fullname=A\B' || failures=$((failures + 1))
    expect_rejected copyright_holder "$one_line" --data 'copyright_holder=A\B' || failures=$((failures + 1))
    [ "$failures" -eq 0 ]
}
