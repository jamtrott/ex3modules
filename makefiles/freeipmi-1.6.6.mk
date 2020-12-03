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
# freeipmi-1.6.6

freeipmi-version = 1.6.6
freeipmi = freeipmi-$(freeipmi-version)
$(freeipmi)-description = Collection of Intelligent Platform Management IPMI system software
$(freeipmi)-url = https://www.gnu.org/software/freeipmi/
$(freeipmi)-srcurl = https://ftp.gnu.org/gnu/freeipmi/freeipmi-$(freeipmi-version).tar.gz
$(freeipmi)-builddeps = $(libgcrypt)
$(freeipmi)-prereqs = $(libgcrypt)
$(freeipmi)-src = $(pkgsrcdir)/$(notdir $($(freeipmi)-srcurl))
$(freeipmi)-srcdir = $(pkgsrcdir)/$(freeipmi)
$(freeipmi)-builddir = $($(freeipmi)-srcdir)
$(freeipmi)-modulefile = $(modulefilesdir)/$(freeipmi)
$(freeipmi)-prefix = $(pkgdir)/$(freeipmi)

$($(freeipmi)-src): $(dir $($(freeipmi)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(freeipmi)-srcurl)

$($(freeipmi)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(freeipmi)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(freeipmi)-prefix)/.pkgunpack: $($(freeipmi)-src) $($(freeipmi)-srcdir)/.markerfile $($(freeipmi)-prefix)/.markerfile
	tar -C $($(freeipmi)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(freeipmi)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(freeipmi)-builddeps),$(modulefilesdir)/$$(dep)) $($(freeipmi)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(freeipmi)-builddir),$($(freeipmi)-srcdir))
$($(freeipmi)-builddir)/.markerfile: $($(freeipmi)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(freeipmi)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(freeipmi)-builddeps),$(modulefilesdir)/$$(dep)) $($(freeipmi)-builddir)/.markerfile $($(freeipmi)-prefix)/.pkgpatch
	cd $($(freeipmi)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(freeipmi)-builddeps) && \
		./configure --prefix=$($(freeipmi)-prefix) && \
		$(MAKE)
	@touch $@

$($(freeipmi)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(freeipmi)-builddeps),$(modulefilesdir)/$$(dep)) $($(freeipmi)-builddir)/.markerfile $($(freeipmi)-prefix)/.pkgbuild
	cd $($(freeipmi)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(freeipmi)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(freeipmi)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(freeipmi)-builddeps),$(modulefilesdir)/$$(dep)) $($(freeipmi)-builddir)/.markerfile $($(freeipmi)-prefix)/.pkgcheck
	cd $($(freeipmi)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(freeipmi)-builddeps) && \
		$(MAKE) -i install
	@touch $@

$($(freeipmi)-modulefile): $(modulefilesdir)/.markerfile $($(freeipmi)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(freeipmi)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(freeipmi)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(freeipmi)-description)\"" >>$@
	echo "module-whatis \"$($(freeipmi)-url)\"" >>$@
	printf "$(foreach prereq,$($(freeipmi)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FREEIPMI_ROOT $($(freeipmi)-prefix)" >>$@
	echo "setenv FREEIPMI_INCDIR $($(freeipmi)-prefix)/include" >>$@
	echo "setenv FREEIPMI_INCLUDEDIR $($(freeipmi)-prefix)/include" >>$@
	echo "setenv FREEIPMI_LIBDIR $($(freeipmi)-prefix)/lib" >>$@
	echo "setenv FREEIPMI_LIBRARYDIR $($(freeipmi)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(freeipmi)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(freeipmi)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(freeipmi)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(freeipmi)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(freeipmi)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(freeipmi)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(freeipmi)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(freeipmi)-prefix)/share/info" >>$@
	echo "set MSG \"$(freeipmi)\"" >>$@

$(freeipmi)-src: $($(freeipmi)-src)
$(freeipmi)-unpack: $($(freeipmi)-prefix)/.pkgunpack
$(freeipmi)-patch: $($(freeipmi)-prefix)/.pkgpatch
$(freeipmi)-build: $($(freeipmi)-prefix)/.pkgbuild
$(freeipmi)-check: $($(freeipmi)-prefix)/.pkgcheck
$(freeipmi)-install: $($(freeipmi)-prefix)/.pkginstall
$(freeipmi)-modulefile: $($(freeipmi)-modulefile)
$(freeipmi)-clean:
	rm -rf $($(freeipmi)-modulefile)
	rm -rf $($(freeipmi)-prefix)
	rm -rf $($(freeipmi)-srcdir)
	rm -rf $($(freeipmi)-src)
$(freeipmi): $(freeipmi)-src $(freeipmi)-unpack $(freeipmi)-patch $(freeipmi)-build $(freeipmi)-check $(freeipmi)-install $(freeipmi)-modulefile
