.PHONY: bump-project
bump-project:
	./devel-tools/script/bump-project.linux-x64.sh

.PHONY: install-devel-tools
install-devel-tools:
	./devel-tools/script/install-devel-tools.linux-x64.sh

.PHONY: check-devel-tools-versions
check-devel-tools-versions:
	./devel-tools/script/check-devel-tools-versions.linux-x64.sh

.PHONY: lint
lint:
	./devel-tools/script/run-lint.linux-x64.sh

.PHONY: format
format:
	./devel-tools/script/run-format.linux-x64.sh

.PHONY: run-integ-test-to-head
run-integ-test-to-head:
	./proper7y

.PHONY: run-integ-test-to-latest
run-integ-test-to-latest:
	./devel-tools/script/run-integ-test.linux-x64.sh

.PHONY: static-tests
static-tests: lint format

.PHONY: integ-tests
integ-tests: run-integ-test-to-head run-integ-test-to-latest

.PHONY: pre-commit
pre-commit: static-tests

.PHONY: pre-push
pre-push: static-tests integ-tests
