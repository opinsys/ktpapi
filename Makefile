dist: dist/install.sh
	@echo "Installer build ready"

dist/install.sh:
	@mkdir -p dist
	src/make.sh

clean:
	rm -rf dist