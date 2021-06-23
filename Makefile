.PHONY: install-devel-tools
install-devel-tools:
	./devel-tools/script/install-dependencies-for-devel.linux-x64.sh

.PHONY: print-devel-tools-versions
print-devel-tools-versions:
	./devel-tools/bin/shellcheck --version | grep "version: " | sed 's/version: /v/'
	./devel-tools/bin/shfmt --version

.PHONY: lint
lint:
	./devel-tools/script/run-lint.linux-x64.sh
