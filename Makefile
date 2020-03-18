.PHONY: install

installdir=/opt/dptrp1-printer

install: $(installdir)/printto-dptrp1.sh
	mkdir -p $(installdir)
	cp printto-dptrp1.sh $(installdir)/printto-dptrp1.sh
	chmod +x $(installdir)/printto-dptrp1.sh

configure:
	tea4cups.conf > test.conf

uninstall:
	rm $(installdir)/printto-dptrp1.sh
	rm -r $(install)
