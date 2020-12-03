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
# numactl-2.0.13

numactl-version = 2.0.13
numactl = numactl-$(numactl-version)
$(numactl)-description = NUMA support for Linux
$(numactl)-url = https://github.com/numactl/numactl/
$(numactl)-srcurl = https://github.com/numactl/numactl/releases/download/v$(numactl-version)/numactl-$(numactl-version).tar.gz
$(numactl)-src = $(pkgsrcdir)/$(notdir $($(numactl)-srcurl))
$(numactl)-srcdir = $(pkgsrcdir)/$(numactl)
$(numactl)-builddeps = 
$(numactl)-prereqs =
$(numactl)-modulefile = $(modulefilesdir)/$(numactl)
$(numactl)-prefix = $(pkgdir)/$(numactl)

$($(numactl)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(numactl)-src): $(dir $($(numactl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(numactl)-srcurl)

$($(numactl)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(numactl)-prefix)/.pkgunpack: $($(numactl)-src) $($(numactl)-srcdir)/.markerfile $($(numactl)-prefix)/.markerfile
	tar -C $($(numactl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(numactl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(numactl)-builddeps),$(modulefilesdir)/$$(dep)) $($(numactl)-prefix)/.pkgunpack
	@touch $@

$($(numactl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(numactl)-builddeps),$(modulefilesdir)/$$(dep)) $($(numactl)-prefix)/.pkgpatch
	cd $($(numactl)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(numactl)-builddeps) && \
		./configure --prefix=$($(numactl)-prefix) && \
		$(MAKE)
	@touch $@

$($(numactl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(numactl)-builddeps),$(modulefilesdir)/$$(dep)) $($(numactl)-prefix)/.pkgbuild
# 	cd $($(numactl)-srcdir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(numactl)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(numactl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(numactl)-builddeps),$(modulefilesdir)/$$(dep)) $($(numactl)-prefix)/.pkgcheck
	$(MAKE) -C $($(numactl)-srcdir) install
	@touch $@

$($(numactl)-modulefile): $(modulefilesdir)/.markerfile $($(numactl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(numactl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(numactl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(numactl)-description)\"" >>$@
	echo "module-whatis \"$($(numactl)-url)\"" >>$@
	printf "$(foreach prereq,$($(numactl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv NUMACTL_ROOT $($(numactl)-prefix)" >>$@
	echo "setenv NUMACTL_INCDIR $($(numactl)-prefix)/include" >>$@
	echo "setenv NUMACTL_INCLUDEDIR $($(numactl)-prefix)/include" >>$@
	echo "setenv NUMACTL_LIBDIR $($(numactl)-prefix)/lib" >>$@
	echo "setenv NUMACTL_LIBRARYDIR $($(numactl)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(numactl)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(numactl)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(numactl)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(numactl)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(numactl)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(numactl)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(numactl)-prefix)/share/man" >>$@
	echo "set MSG \"$(numactl)\"" >>$@

$(numactl)-src: $($(numactl)-src)
$(numactl)-unpack: $($(numactl)-prefix)/.pkgunpack
$(numactl)-patch: $($(numactl)-prefix)/.pkgpatch
$(numactl)-build: $($(numactl)-prefix)/.pkgbuild
$(numactl)-check: $($(numactl)-prefix)/.pkgcheck
$(numactl)-install: $($(numactl)-prefix)/.pkginstall
$(numactl)-modulefile: $($(numactl)-modulefile)
$(numactl)-clean:
	rm -rf $($(numactl)-modulefile)
	rm -rf $($(numactl)-prefix)
	rm -rf $($(numactl)-srcdir)
	rm -rf $($(numactl)-src)
$(numactl): $(numactl)-src $(numactl)-unpack $(numactl)-patch $(numactl)-build $(numactl)-check $(numactl)-install $(numactl)-modulefile
