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

.PHONY: integ-test
integ-test:
	./devel-tools/script/run-integ-test.linux-x64.sh

.PHONY: bump-project
bump-project:
	./devel-tools/script/bump-project.linux-x64.sh

.PHONY: pre-commit
pre-commit: lint format

.PHONY: pre-push
pre-push: lint format integ-test
