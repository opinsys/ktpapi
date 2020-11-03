all: dist

dist: dist/installer
	@echo "Installer build ready"

dist/installer:
	@mkdir -p dist
	(cd src && ./build_installer.sh)

.PHONY: clean
clean:
	rm -rf dist
