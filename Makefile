.PHONY: bump-project
bump-project:
	./devel-tools/script/bump-project.linux-x64.bash

.PHONY: install-devel-tools
install-devel-tools:
	./devel-tools/script/install-devel-tools.linux-x64.bash

.PHONY: check-devel-tools-versions
check-devel-tools-versions:
	./devel-tools/script/check-devel-tools-versions.linux-x64.bash

.PHONY: lint
lint:
	./devel-tools/script/run-lint.linux-x64.bash

.PHONY: format
format:
	./devel-tools/script/run-format.linux-x64.bash

.PHONY: validate
validate:
	./devel-tools/script/check-project-version-consistency.linux-x64.bash

.PHONY: run-integ-test-to-head
run-integ-test-to-head:
	./proper7y

.PHONY: run-integ-test-to-latest
run-integ-test-to-latest:
	./devel-tools/script/run-integ-test.linux-x64.bash

.PHONY: static-tests
static-tests: lint validate

.PHONY: integ-tests
# Run head first (fast, local), then latest (slow, network).
# No strict dependency between the two; this order is just a convention.
integ-tests: run-integ-test-to-head run-integ-test-to-latest

.PHONY: pre-commit
pre-commit: static-tests format

.PHONY: pre-push
pre-push: static-tests integ-tests
