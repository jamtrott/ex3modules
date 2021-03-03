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
# autoconf-2.70

autoconf-version = 2.70
autoconf = autoconf-$(autoconf-version)
$(autoconf)-description = Automatic generation of shell scripts to configure software source code packages
$(autoconf)-url = https://www.gnu.org/software/autoconf/
$(autoconf)-srcurl = https://ftp.gnu.org/gnu/autoconf/autoconf-2.70.tar.xz
$(autoconf)-builddeps =
$(autoconf)-prereqs =
$(autoconf)-src = $(pkgsrcdir)/$(notdir $($(autoconf)-srcurl))
$(autoconf)-srcdir = $(pkgsrcdir)/$(autoconf)
$(autoconf)-builddir = $($(autoconf)-srcdir)
$(autoconf)-modulefile = $(modulefilesdir)/$(autoconf)
$(autoconf)-prefix = $(pkgdir)/$(autoconf)

$($(autoconf)-src): $(dir $($(autoconf)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(autoconf)-srcurl)

$($(autoconf)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(autoconf)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(autoconf)-prefix)/.pkgunpack: $$($(autoconf)-src) $($(autoconf)-srcdir)/.markerfile $($(autoconf)-prefix)/.markerfile
	tar -C $($(autoconf)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(autoconf)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(autoconf)-builddeps),$(modulefilesdir)/$$(dep)) $($(autoconf)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(autoconf)-builddir),$($(autoconf)-srcdir))
$($(autoconf)-builddir)/.markerfile: $($(autoconf)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(autoconf)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(autoconf)-builddeps),$(modulefilesdir)/$$(dep)) $($(autoconf)-builddir)/.markerfile $($(autoconf)-prefix)/.pkgpatch
	cd $($(autoconf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(autoconf)-builddeps) && \
		./configure --prefix=$($(autoconf)-prefix) && \
		$(MAKE)
	@touch $@

$($(autoconf)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(autoconf)-builddeps),$(modulefilesdir)/$$(dep)) $($(autoconf)-builddir)/.markerfile $($(autoconf)-prefix)/.pkgbuild
	cd $($(autoconf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(autoconf)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(autoconf)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(autoconf)-builddeps),$(modulefilesdir)/$$(dep)) $($(autoconf)-builddir)/.markerfile $($(autoconf)-prefix)/.pkgcheck
	cd $($(autoconf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(autoconf)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(autoconf)-modulefile): $(modulefilesdir)/.markerfile $($(autoconf)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(autoconf)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(autoconf)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(autoconf)-description)\"" >>$@
	echo "module-whatis \"$($(autoconf)-url)\"" >>$@
	printf "$(foreach prereq,$($(autoconf)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv AUTOCONF_ROOT $($(autoconf)-prefix)" >>$@
	echo "setenv AUTOCONF_INCDIR $($(autoconf)-prefix)/include" >>$@
	echo "setenv AUTOCONF_INCLUDEDIR $($(autoconf)-prefix)/include" >>$@
	echo "setenv AUTOCONF_LIBDIR $($(autoconf)-prefix)/lib" >>$@
	echo "setenv AUTOCONF_LIBRARYDIR $($(autoconf)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(autoconf)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(autoconf)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(autoconf)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(autoconf)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(autoconf)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(autoconf)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(autoconf)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(autoconf)-prefix)/share/info" >>$@
	echo "set MSG \"$(autoconf)\"" >>$@

$(autoconf)-src: $$($(autoconf)-src)
$(autoconf)-unpack: $($(autoconf)-prefix)/.pkgunpack
$(autoconf)-patch: $($(autoconf)-prefix)/.pkgpatch
$(autoconf)-build: $($(autoconf)-prefix)/.pkgbuild
$(autoconf)-check: $($(autoconf)-prefix)/.pkgcheck
$(autoconf)-install: $($(autoconf)-prefix)/.pkginstall
$(autoconf)-modulefile: $($(autoconf)-modulefile)
$(autoconf)-clean:
	rm -rf $($(autoconf)-modulefile)
	rm -rf $($(autoconf)-prefix)
	rm -rf $($(autoconf)-builddir)
	rm -rf $($(autoconf)-srcdir)
	rm -rf $($(autoconf)-src)
$(autoconf): $(autoconf)-src $(autoconf)-unpack $(autoconf)-patch $(autoconf)-build $(autoconf)-check $(autoconf)-install $(autoconf)-modulefile
