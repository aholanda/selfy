PROJ=selfy
CFGDIR=/etc/selfy/
BINDIR=/usr/local/bin/

default: setup

$(CFGDIR):
	mkdir $(CFGDIR)

install: $(CFGDIR)
	-install selfy $(BINDIR)
	-cp *.yml $(CFGDIR)
	-find . -maxdepth 1 -type d \
		-not -path "." \
		-not -path "./.git"  \
		-not -path "./win_*" \
		-not -path "./Windows" \
		-exec cp -r {} $(CFGDIR) \;
	@echo "Installation of $(PROJ) completed."

uninstall:
	$(RM) -r $(CFGDIR)
	$(RM) $(BINDIR)/selfy
	@echo "$(PROJ) was removed."

reinstall: uninstall install

setup:
	./selfy --setup

.PHONY: default install uninstall reinstall setup
