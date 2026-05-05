# ==============================================================================
# devel-tools management
# ==============================================================================

# Install shellcheck, shfmt, and bats under devel-tools/bin/.
# Run once after cloning the repository, or after changing devel-tools versions.
.PHONY: install-devel-tools
install-devel-tools:
	./devel-tools/script/install-devel-tools.linux-x64.bash

# Check devel-tools versions and interactively upgrade if a newer version is available.
# Compares current, installed, and latest GitHub release versions of shellcheck and shfmt.
.PHONY: check-devel-tools-versions
check-devel-tools-versions:
	./devel-tools/script/check-devel-tools-versions.linux-x64.bash

# ==============================================================================
# Individual test and check commands
# ==============================================================================

# Run shellcheck and shfmt in check mode (no file modification) on all target scripts.
.PHONY: lint
lint:
	./devel-tools/script/run-lint.linux-x64.bash

# Verify PROPER7Y_VERSION is consistent across proper7y, install.bash, and common.bash.
.PHONY: validate
validate:
	./devel-tools/script/check-project-version-consistency.linux-x64.bash

# Run bats unit tests under test/unit/.
.PHONY: unit-tests
unit-tests:
	./devel-tools/bin/bats test/unit/

# Run proper7y from the local working copy (integration test against local HEAD).
.PHONY: run-integ-test-to-head
run-integ-test-to-head:
	./proper7y

# Download and install the latest stable proper7y via install.bash, then assert its output.
# Requires network access. This target only checks that proper7y exits with status 0
# and validates basic output structure. See ADR-005 for the full assertion design.
.PHONY: run-integ-test-to-latest
run-integ-test-to-latest:
	./devel-tools/script/run-integ-test.bash

# ==============================================================================
# Formatting (modifies files in place)
# ==============================================================================

# Format all target scripts using shfmt. Overwrites files in place.
# WARNING: This modifies files. Commit your changes before running.
.PHONY: format
format:
	./devel-tools/script/run-format.linux-x64.bash

# ==============================================================================
# Compound commands -- for CI (called directly from .github/workflows/)
# ==============================================================================

# Run lint + validate. No side effects; safe for automated environments.
.PHONY: static-tests
static-tests: lint validate

# Run all integration tests: local HEAD first (fast), then remote stable (slow, needs network).
# No strict dependency between the two; this order is just a convention.
.PHONY: integ-tests
integ-tests: run-integ-test-to-head run-integ-test-to-latest

# ==============================================================================
# Compound commands -- for local development
# ==============================================================================

# Run before committing: static-tests + format + unit-tests.
.PHONY: pre-commit
pre-commit: static-tests format unit-tests

# Run before pushing: static-tests + format + unit-tests + integ-tests.
.PHONY: pre-push
pre-push: static-tests format unit-tests integ-tests

# ==============================================================================
# Project release
# ==============================================================================

# Bump the proper7y project version. All changes must be committed and pushed first.
.PHONY: bump-project
bump-project:
	./devel-tools/script/bump-project.linux-x64.bash
