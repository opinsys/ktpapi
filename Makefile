sysconfdir = /etc

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

latest_commit_id = $(shell git rev-parse HEAD 2>/dev/null || echo NOGIT)
archive_filename = "opinsys-ktpapi-$(latest_commit_id).tar.gz"

remote_server = private-archive.opinsys.fi
remote_server_path = /srv/private-archive/.distfiles/abitti-ktpapi/

all:

installdirs:
	mkdir -p $(DESTDIR)/lib/systemd/system
	mkdir -p $(DESTDIR)/opt/ktpapu
	mkdir -p $(DESTDIR)$(sysconfdir)/systemd/system/multi-user.target.wants

install: installdirs
	$(INSTALL_PROGRAM) -t $(DESTDIR)/opt/ktpapu/ \
		src/apiwatcher.sh \
		src/timertrigger.sh
	cp -R src/platforms $(DESTDIR)/opt/ktpapu/
	$(INSTALL_DATA) -t $(DESTDIR)/lib/systemd/system/ \
		src/systemd/opinsys-ktpapi-timer.service \
		src/systemd/opinsys-ktpapi-timer.timer \
		src/systemd/opinsys-ktpapi-watcher.service
	ln -fs -t $(DESTDIR)$(sysconfdir)/systemd/system/multi-user.target.wants/ \
		/lib/systemd/system/opinsys-ktpapi-timer.service
	ln -fs -t $(DESTDIR)$(sysconfdir)/systemd/system/multi-user.target.wants/ \
		/lib/systemd/system/opinsys-ktpapi-timer.timer
	ln -fs -t $(DESTDIR)$(sysconfdir)/systemd/system/multi-user.target.wants/ \
		/lib/systemd/system/opinsys-ktpapi-watcher.service

.PHONY: archive
archive: ${archive_filename}

${archive_filename}:
	git archive --format=tar.gz --prefix=opinsys-ktpapi/ \
		-o $(archive_filename) ${latest_commit_id}

.PHONY: update-remote-archive
update-remote-archive: ${archive_filename}
	scp -p $< ${remote_server}:${remote_server_path}

.PHONY: clean
clean:
	rm -rf opinsys-ktpapi-*.tar.gz
