#!/usr/bin/env bats
#
# Integration smoke tests: generate a project and actually run its toolchain.
# These need network access plus pdm and uv installed, so they are kept out of
# the default `make tests` target and run via `make tests-integration`.

generate() {
    local out="$1"
    shift
    copier copy "$TEMPLATE_DIR" "$out" --defaults --vcs-ref=HEAD \
        --data project_description="A test project." \
        --data author_fullname="Georgios Douzas" \
        --data author_email="gdouzas@icloud.com" \
        --data author_username="gdouzas" \
        --data repository_name="test-repo" \
        "$@" || true
    [ -d "$out" ]
}

init_git() {
    git init -q
    git add -A
    git -c user.email=test@test.com -c user.name=test commit -qm "init"
    git tag 0.1.0
}

# Log the command on the bats progress descriptor, then run it.
step() {
    echo "  run    $*" >&3
    run "$@"
}

setup() {
    echo "== ${BATS_TEST_DESCRIPTION}" >&3
    export TEST_DIR="$(mktemp -d)"
    export TEMPLATE_DIR="$(pwd)"
    cd "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "Generated PDM project installs, checks and tests pass" {
    command -v pdm >/dev/null || skip "pdm not installed"
    command -v uv >/dev/null || skip "uv not installed (needed for nox venvs)"

    generate proj
    cd proj
    init_git

    step pdm install
    [ "$status" -eq 0 ]

    step pdm checks
    [ "$status" -eq 0 ]

    step pdm tests
    [ "$status" -eq 0 ]
    [ -f coverage.xml ]
}

@test "Generated uv project installs, checks and tests pass" {
    command -v uv >/dev/null || skip "uv not installed"

    generate proj --data package_manager=uv
    cd proj
    init_git

    step uv sync
    [ "$status" -eq 0 ]

    step uv run nox -s checks
    [ "$status" -eq 0 ]

    step uv run nox -s tests
    [ "$status" -eq 0 ]
    [ -f coverage.xml ]
}

@test "Generated script layout installs, checks, tests and runs its command" {
    command -v pdm >/dev/null || skip "pdm not installed"
    command -v uv >/dev/null || skip "uv not installed (needed for nox venvs)"

    generate proj --data project_layout=script
    cd proj
    init_git

    step pdm install
    [ "$status" -eq 0 ]

    step pdm checks
    [ "$status" -eq 0 ]

    step pdm tests
    [ "$status" -eq 0 ]

    step pdm run test-repo --name layouts
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello, layouts!"* ]]
}

@test "Generated ML layout installs, checks and tests with no cloud credentials" {
    command -v pdm >/dev/null || skip "pdm not installed"
    command -v uv >/dev/null || skip "uv not installed (needed for nox venvs)"

    generate proj --data project_layout=ml
    cd proj
    init_git

    step pdm install
    [ "$status" -eq 0 ]

    # pdm install writes the lock, which is committed. Capture it here, as a user would after a
    # first install, so the cleanliness check below tests only what running the flow leaves
    # behind -- .metaflow and notebook outputs -- rather than the lock created at install.
    git add -A
    git -c user.email=test@test.com -c user.name=test commit -qm "lock"

    step pdm checks
    [ "$status" -eq 0 ]

    # Stripped of AWS configuration: Metaflow local mode must need no account or server.
    step env -u AWS_ACCESS_KEY_ID -u AWS_SECRET_ACCESS_KEY -u AWS_PROFILE pdm tests
    [ "$status" -eq 0 ]

    # Running the flow must not leave the project dirty.
    step git status --porcelain
    [ -z "$output" ]
}

@test "Generated ML layout keeps data out of version control" {
    generate proj --data project_layout=ml
    cd proj
    init_git

    echo "secret,data" > data/probe.csv

    step git status --porcelain
    [ -z "$output" ]

    step git ls-files data/
    [ -n "$output" ]
}

@test "Generated data engineering layout installs, checks and tests, with telemetry declined" {
    command -v pdm >/dev/null || skip "pdm not installed"
    command -v uv >/dev/null || skip "uv not installed (needed for nox venvs)"

    generate proj --data project_layout=dataeng
    cd proj
    init_git

    step pdm install
    [ "$status" -eq 0 ]

    step pdm checks
    [ "$status" -eq 0 ]

    step pdm tests
    [ "$status" -eq 0 ]

    # Kedro ships telemetry as a core dependency; a generated project must decline it rather
    # than inherit consent its owner never gave.
    step grep -q "consent: false" .telemetry
    [ "$status" -eq 0 ]

    # Deployed rather than distributed, so a container is the artifact.
    [ -f Dockerfile ]
}

@test "Generated service layout installs, checks, tests and serves" {
    command -v pdm >/dev/null || skip "pdm not installed"
    command -v uv >/dev/null || skip "uv not installed (needed for nox venvs)"

    generate proj --data project_layout=service
    cd proj
    init_git

    step pdm install
    [ "$status" -eq 0 ]

    step pdm checks
    [ "$status" -eq 0 ]

    step pdm tests
    [ "$status" -eq 0 ]

    [ -f Dockerfile ]
}

@test "Library and script layouts carry no Dockerfile by default" {
    generate proj
    [ ! -f proj/Dockerfile ]

    rm -rf proj
    generate proj --data project_layout=script
    [ ! -f proj/Dockerfile ]
}

@test "A Dockerfile can be opted into for any layout" {
    generate proj --data include_dockerfile=True
    [ -f proj/Dockerfile ]
}

@test "Generated Dockerfile builds and the image runs" {
    command -v docker >/dev/null || skip "docker not installed"
    docker info >/dev/null 2>&1 || skip "docker daemon not running"

    generate proj --data project_layout=service
    cd proj
    init_git

    # A generated Dockerfile is a claim that the project containerises. Build it rather than
    # check it exists: the version comes from the SCM tags, which needs git in the build
    # stage and the .git directory in the context, and only a real build proves both.
    step docker build -t cmp-integration-test .
    [ "$status" -eq 0 ]

    step docker run --rm cmp-integration-test python -c "import test_repo.app"
    [ "$status" -eq 0 ]

    docker rmi -f cmp-integration-test || true
}
