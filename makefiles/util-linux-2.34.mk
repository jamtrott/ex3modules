# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2020 James D. Trotter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Authors: James D. Trotter <james@simula.no>
#
# util-linux-2.34

util-linux-version = 2.34
util-linux = util-linux-$(util-linux-version)
$(util-linux)-description = Miscellaneous utility programs, including tools for handling file systems, consoles, partitions, and messages
$(util-linux)-url = https://www.kernel.org/
$(util-linux)-srcurl = https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v$(util-linux-version)/util-linux-$(util-linux-version).tar.gz
$(util-linux)-src = $(pkgsrcdir)/$(util-linux).tar.gz
$(util-linux)-srcdir = $(pkgsrcdir)/$(util-linux)
$(util-linux)-builddeps = $(ncurses)
$(util-linux)-prereqs =
$(util-linux)-modulefile = $(modulefilesdir)/$(util-linux)
$(util-linux)-prefix = $(pkgdir)/$(util-linux)

$($(util-linux)-src): $(dir $($(util-linux)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(util-linux)-srcurl)

$($(util-linux)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(util-linux)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(util-linux)-prefix)/.pkgunpack: $($(util-linux)-src) $($(util-linux)-srcdir)/.markerfile $($(util-linux)-prefix)/.markerfile $$(foreach dep,$$($(util-linux)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(util-linux)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(util-linux)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(util-linux)-builddeps),$(modulefilesdir)/$$(dep)) $($(util-linux)-prefix)/.pkgunpack
	@touch $@

$($(util-linux)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(util-linux)-builddeps),$(modulefilesdir)/$$(dep)) $($(util-linux)-prefix)/.pkgpatch
	cd $($(util-linux)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(util-linux)-builddeps) && \
		./configure \
		--prefix=$($(util-linux)-prefix) \
		--disable-chfn-chsh \
		--disable-login \
		--disable-nologin \
		--disable-su \
		--disable-setpriv \
		--disable-runuser \
		--disable-pylibmount \
		--disable-mount \
		--disable-static \
		--disable-use-tty-group \
		--disable-bash-completion \
		--without-python \
		--without-systemd \
		--without-systemdsystemunitdir && \
		$(MAKE) MAKEFLAGS=
	@touch $@

$($(util-linux)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(util-linux)-builddeps),$(modulefilesdir)/$$(dep)) $($(util-linux)-prefix)/.pkgbuild
# Disable tests - not recommended to run on production systems
# 	cd $($(util-linux)-srcdir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(util-linux)-builddeps) && \
# 		$(MAKE) MAKEFLAGS= check
	@touch $@

$($(util-linux)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(util-linux)-builddeps),$(modulefilesdir)/$$(dep)) $($(util-linux)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= -C $($(util-linux)-srcdir) install
	@touch $@

$($(util-linux)-modulefile): $(modulefilesdir)/.markerfile $($(util-linux)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(util-linux)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(util-linux)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(util-linux)-description)\"" >>$@
	echo "module-whatis \"$($(util-linux)-url)\"" >>$@
	printf "$(foreach prereq,$($(util-linux)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv UTIL_LINUX_ROOT $($(util-linux)-prefix)" >>$@
	echo "setenv UTIL_LINUX_INCDIR $($(util-linux)-prefix)/include" >>$@
	echo "setenv UTIL_LINUX_INCLUDEDIR $($(util-linux)-prefix)/include" >>$@
	echo "setenv UTIL_LINUX_LIBDIR $($(util-linux)-prefix)/lib" >>$@
	echo "setenv UTIL_LINUX_LIBRARYDIR $($(util-linux)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(util-linux)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(util-linux)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(util-linux)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(util-linux)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(util-linux)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(util-linux)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(util-linux)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(util-linux)-prefix)/share/info" >>$@
	echo "set MSG \"$(util-linux)\"" >>$@

$(util-linux)-src: $($(util-linux)-src)
$(util-linux)-unpack: $($(util-linux)-prefix)/.pkgunpack
$(util-linux)-patch: $($(util-linux)-prefix)/.pkgpatch
$(util-linux)-build: $($(util-linux)-prefix)/.pkgbuild
$(util-linux)-check: $($(util-linux)-prefix)/.pkgcheck
$(util-linux)-install: $($(util-linux)-prefix)/.pkginstall
$(util-linux)-modulefile: $($(util-linux)-modulefile)
$(util-linux)-clean:
	rm -rf $($(util-linux)-modulefile)
	rm -rf $($(util-linux)-prefix)
	rm -rf $($(util-linux)-srcdir)
	rm -rf $($(util-linux)-src)
$(util-linux): $(util-linux)-src $(util-linux)-unpack $(util-linux)-patch $(util-linux)-build $(util-linux)-check $(util-linux)-install $(util-linux)-modulefile
