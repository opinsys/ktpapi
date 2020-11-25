latest_commit_id = $(shell git rev-parse HEAD 2>/dev/null || echo NOGIT)
archive_filename = "opinsys-ktpapi-$(latest_commit_id).tar.gz"

remote_server = private-archive.opinsys.fi
remote_server_path = /srv/private-archive/.distfiles/abitti-ktpapi/

all: dist

.PHONY: archive
archive: ${archive_filename}

dist: dist/ktpapu-asennin

.PHONY: dist/ktpapu-asennin
dist/ktpapu-asennin:
	@mkdir -p dist
	(cd src && ./build_installer.sh)

${archive_filename}:
	git archive --format=tar.gz --prefix=opinsys-ktpapi/ \
		-o $(archive_filename) ${latest_commit_id}

.PHONY: update-remote-archive
update-remote-archive: ${archive_filename}
	scp -p $< ${remote_server}:${remote_server_path}

.PHONY: clean
clean:
	rm -rf dist opinsys-ktpapi-*.tar.gz
