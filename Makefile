server_versions := SERVER2003K SERVER2041X

all: dist

dist: dist/install.sh
	@echo "Installer build ready"

dist/install.sh: ${server_versions}

${server_versions}:
	@mkdir -p dist
	(cd src && ./build_installer.sh $@)

.PHONY: clean
clean:
	rm -rf dist
