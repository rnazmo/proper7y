.PHONY: lint
lint:
	./devel-tools/script/run-lint.linux-x64.sh

.PHONY: install-devel-tools
install-devel-tools:
	./devel-tools/script/install-dependencies-for-devel.linux-x64.sh
