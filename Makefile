.PHONY: install-devel-tools
install-devel-tools:
	./devel-tools/script/install-devel-tools.linux-x64.sh

.PHONY: print-devel-tools-versions
print-devel-tools-versions:
	./devel-tools/bin/shellcheck --version | grep "version: " | sed 's/version: /v/'
	./devel-tools/bin/shfmt --version

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
