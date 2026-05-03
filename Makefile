# ===============================================

.PHONY: bump-project
bump-project:
	./devel-tools/script/bump-project.linux-x64.bash

.PHONY: install-devel-tools
install-devel-tools:
	./devel-tools/script/install-devel-tools.linux-x64.bash

.PHONY: check-devel-tools-versions
check-devel-tools-versions:
	./devel-tools/script/check-devel-tools-versions.linux-x64.bash

# ===============================================

.PHONY: lint
lint:
	./devel-tools/script/run-lint.linux-x64.bash

.PHONY: validate
validate:
	./devel-tools/script/check-project-version-consistency.linux-x64.bash

.PHONY: run-integ-test-to-head
run-integ-test-to-head:
	./proper7y

.PHONY: run-integ-test-to-latest
# Note: This target only checks that proper7y exits with status 0.
# It does NOT assert the output content (field names, values, format, etc.).
# See ADR-005 for the integration test design and assertion levels.
run-integ-test-to-latest:
	./devel-tools/script/run-integ-test.bash

# ===============================================

.PHONY: format
format:
	./devel-tools/script/run-format.linux-x64.bash

# ===============================================
# Commands called from CI and automated runs
# (call these directly from the CI YAML file)
# ===============================================

.PHONY: static-tests
static-tests: lint validate

.PHONY: unit-tests
unit-tests:
	./devel-tools/bin/bats test/unit/

.PHONY: integ-tests
# Run head first (fast, local), then latest (slow, network).
# No strict dependency between the two; this order is just a convention.
integ-tests: run-integ-test-to-head run-integ-test-to-latest

# ===============================================
# Commands called from when working locally
# (call these directly from your terminal)
# ===============================================

.PHONY: pre-commit
pre-commit: static-tests format unit-tests

.PHONY: pre-push
pre-push: static-tests format unit-tests integ-tests
