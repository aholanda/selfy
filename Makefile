PROJ=selfy
CFGDIR=/etc/selfy/
BINDIR=/usr/local/bin/

PKG := apt-get
PKG_INSTALL := $(PKG) install -y
PKG_UNINSTALL := $(PKG) remove -y
PKGs := git gpg sudo wget ansible

ANSIBLE_DIR := /etc/ansible

default: setup

$(CFGDIR):
	mkdir $(CFGDIR)

install: $(CFGDIR) setup
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

.PHONY: default install uninstall reinstall setup TIDY

$(ANSIBLE_DIR):
	mkdir $(ANSIBLE_DIR)

setup: $(ANSIBLE_DIR)
	-$(PKG_INSTALL) $(PKGS) >/dev/null
	-cp ./hosts ${ANSIBLE_DIR}
	-sed -i 's/^%sudo\s*ALL=(ALL:ALL)\s*ALL/%sudo ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

TIDY: uninstall
	-$(PKG_UNINSTALL) $(PKGs) >/dev/null
	-$(RM) -r $(ANSIBLE_DIR)/hosts

