all: dist

dist: clean dist/installer

dist/installer:
	@mkdir -p dist
	(cd src && ./build_installer.sh)

.PHONY: clean
clean:
	rm -rf dist
