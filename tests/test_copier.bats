#!/usr/bin/env bats

compare_repos() {
    local expected_dir="$1"
    local generated_dir="$2"

    [ -d "test-repo" ]

    # Check all expected files and directories exist in generated repo
    for expected_item in "$expected_dir"/* "$expected_dir"/.*; do
        [ "$expected_item" = "$expected_dir/*" ] && continue
        [ "$expected_item" = "$expected_dir/.*" ] && continue
        [ "$(basename "$expected_item")" = "." ] && continue
        [ "$(basename "$expected_item")" = ".." ] && continue
        [ "$(basename "$expected_item")" = ".copier-answers.yml" ] && continue
        if [ -f "$expected_item" ]; then
            filename=$(basename "$expected_item")
            [ -f "$generated_dir/$filename" ] || { echo "Missing file: $filename"; return 1; }
            if ! diff "$expected_item" "$generated_dir/$filename"; then
                echo "Difference found in file: $filename"
                return 1
            fi
        elif [ -d "$expected_item" ]; then
            dirname=$(basename "$expected_item")
            [ -d "$generated_dir/$dirname" ] || { echo "Missing directory: $dirname"; return 1; }
        fi
    done

    # Check no extra files or directories exist in generated repo
    for generated_item in "$generated_dir"/* "$generated_dir"/.*; do
        [ "$generated_item" = "$generated_dir/*" ] && continue
        [ "$generated_item" = "$generated_dir/.*" ] && continue
        [ "$(basename "$generated_item")" = "." ] && continue
        [ "$(basename "$generated_item")" = ".." ] && continue
        [ "$(basename "$generated_item")" = ".copier-answers.yml" ] && continue
        if [ -f "$generated_item" ] || [ -d "$generated_item" ]; then
            itemname=$(basename "$generated_item")
            [ -e "$expected_dir/$itemname" ] || { echo "Extra item: $itemname"; return 1; }
        fi
    done
}

setup() {
    export TEST_DIR="$(mktemp -d)"
    export TEMPLATE_DIR="$(pwd)"
    cd "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "Test default choices" {
    run copier copy "$TEMPLATE_DIR" test-repo --defaults --vcs-ref=HEAD \
    --data project_description="A test project." \
    --data author_fullname="Georgios Douzas" \
    --data author_email="gdouzas@icloud.com" \
    --data author_username="gdouzas" \
    --data repository_name="test-repo"

    [ -d test-repo ]
    compare_repos "$(dirname "$BATS_TEST_FILENAME")/expected/default" "test-repo"
}

@test "Test no git provider choice" {
    run copier copy "$TEMPLATE_DIR" test-repo --defaults --vcs-ref=HEAD \
    --data project_description="A test project." \
    --data author_fullname="Georgios Douzas" \
    --data author_email="gdouzas@icloud.com" \
    --data author_username="gdouzas" \
    --data repository_name="test-repo" \
    --data git_provider="None"

    [ -d test-repo ]
    compare_repos "$(dirname "$BATS_TEST_FILENAME")/expected/no-git-provider" "test-repo"
}

@test "Test uv package manager choice" {
    run copier copy "$TEMPLATE_DIR" test-repo --defaults --vcs-ref=HEAD \
    --data project_description="A test project." \
    --data author_fullname="Georgios Douzas" \
    --data author_email="gdouzas@icloud.com" \
    --data author_username="gdouzas" \
    --data repository_name="test-repo" \
    --data package_manager="uv"

    [ -d test-repo ]
    compare_repos "$(dirname "$BATS_TEST_FILENAME")/expected/uv-package-manager" "test-repo"
}

@test "Test no publish PyPI choice" {
    run copier copy "$TEMPLATE_DIR" test-repo --defaults --vcs-ref=HEAD \
    --data project_description="A test project." \
    --data author_fullname="Georgios Douzas" \
    --data author_email="gdouzas@icloud.com" \
    --data author_username="gdouzas" \
    --data repository_name="test-repo" \
    --data publish_pypi="False"

    [ -d test-repo ]
    compare_repos "$(dirname "$BATS_TEST_FILENAME")/expected/no-publish-pypi" "test-repo"
}
