include config.conf

.PHONY: install

installdir=/opt/sony-dpt-printer
tea4cupsconf=/etc/cups/tea4cups.conf
printername?=PrintToDPT

install:
	@echo "DPT virtual printer installation"
	@echo "  Copying files..."
	mkdir -p $(installdir)
	install print-to-dpt.sh $(installdir)/print-to-dptrp1.sh
	@chmod +x $(installdir)/print-to-dptrp1.sh
	@echo "  Installing virtual printer..."
	lpadmin -p $(printername) -v tea4cups:// -E -m raw
	@echo "  Configuring tea4cups..."
	@printf '\n[$(printername)]\nprehook_dpt : $(installdir)/print-to-dptrp1.sh\n' >> $(tea4cupsconf)
	@echo "Installation complete!"

configure:
	sed -i 's/^DPTADDR=.*$$/DPTADDR=$(address)/' print-to-dpt.sh
	sed -i 's;^installdir=.*$$;installdir=$(installdir);' print-to-dpt.sh
	@echo "DPT printer configured."

update-config:
	sed -i 's/^DPTADDR=.*$$/DPTADDR=$(address)/' $(installdir)/print-to-dpt.sh
	@echo "DPT configuration updated."

uninstall:
	@echo "Uninstalling DPT virtual printer..."
	@echo "  Removing files..."
	rm $(installdir)/print-to-dptrp1.sh
	rm -r $(installdir)
	@echo "  Configuring tea4cups..."
	sed -i '/$(printername)/,/^/d' $(tea4cupsconf)
	@echo "  Removing virtual printer..."
	lpadmin -x $(printername)
	@echo "Uninstallation complete!"
