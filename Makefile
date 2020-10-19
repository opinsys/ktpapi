dist: dist/install.sh
	@echo "Installer build ready"

dist/install.sh: SERVER2041X SERVER2003K

SERVER2041X:
	@mkdir -p dist
	src/build_installer.sh SERVER2041X

SERVER2003K:
	@mkdir -p dist
	src/build_installer.sh SERVER2003K

clean:
	rm -rf dist