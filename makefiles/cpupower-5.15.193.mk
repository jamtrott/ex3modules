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
# cpupower-5.15.193

cpupower-version = 5.15.193
cpupower = cpupower-$(cpupower-version)
$(cpupower)-description = Tools for accessing cpufreq core and drivers in the Linux kernel
$(cpupower)-url = https://www.kernel.org/
$(cpupower)-srcurl = $($(linux-src)-srcurl)
$(cpupower)-builddeps = $(pciutils)
$(cpupower)-prereqs = $(pciutils)
$(cpupower)-src = $($(linux-src)-src)
$(cpupower)-srcdir = $(pkgsrcdir)/$(cpupower)
$(cpupower)-builddir = $($(cpupower)-srcdir)/tools/power/cpupower
$(cpupower)-modulefile = $(modulefilesdir)/$(cpupower)
$(cpupower)-prefix = $(pkgdir)/$(cpupower)

$($(cpupower)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cpupower)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cpupower)-prefix)/.pkgunpack: $$($(cpupower)-src) $($(cpupower)-srcdir)/.markerfile $($(cpupower)-prefix)/.markerfile $$(foreach dep,$$($(cpupower)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(cpupower)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(cpupower)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cpupower)-builddeps),$(modulefilesdir)/$$(dep)) $($(cpupower)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(cpupower)-builddir),$($(cpupower)-srcdir))
$($(cpupower)-builddir)/.markerfile: $($(cpupower)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(cpupower)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cpupower)-builddeps),$(modulefilesdir)/$$(dep)) $($(cpupower)-builddir)/.markerfile $($(cpupower)-prefix)/.pkgpatch
	cd $($(cpupower)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cpupower)-builddeps) && \
		$(MAKE) confdir=$($(cpupower)-prefix)/etc/
	@touch $@

$($(cpupower)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cpupower)-builddeps),$(modulefilesdir)/$$(dep)) $($(cpupower)-builddir)/.markerfile $($(cpupower)-prefix)/.pkgbuild
	@touch $@

$($(cpupower)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cpupower)-builddeps),$(modulefilesdir)/$$(dep)) $($(cpupower)-builddir)/.markerfile $($(cpupower)-prefix)/.pkgcheck
	cd $($(cpupower)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cpupower)-builddeps) && \
		$(MAKE) install \
			bindir=$($(cpupower)-prefix)/bin \
			sbindir=$($(cpupower)-prefix)/sbin \
			libdir=$($(cpupower)-prefix)/lib \
			includedir=$($(cpupower)-prefix)/include \
			mandir=$($(cpupower)-prefix)/share/man \
			localedir=$($(cpupower)-prefix)/share/locale \
			docdir=$($(cpupower)-prefix)/share/doc/packages/cpupower \
			confdir=$($(cpupower)-prefix)/etc/ \
			bash_completion_dir=$($(cpupower)-prefix)/share/bash-completion/completions
	@touch $@

$($(cpupower)-modulefile): $(modulefilesdir)/.markerfile $($(cpupower)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cpupower)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cpupower)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cpupower)-description)\"" >>$@
	echo "module-whatis \"$($(cpupower)-url)\"" >>$@
	printf "$(foreach prereq,$($(cpupower)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CPUPOWER_ROOT $($(cpupower)-prefix)" >>$@
	echo "setenv CPUPOWER_INCDIR $($(cpupower)-prefix)/include" >>$@
	echo "setenv CPUPOWER_INCLUDEDIR $($(cpupower)-prefix)/include" >>$@
	echo "setenv CPUPOWER_LIBDIR $($(cpupower)-prefix)/lib" >>$@
	echo "setenv CPUPOWER_LIBRARYDIR $($(cpupower)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(cpupower)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(cpupower)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(cpupower)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(cpupower)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cpupower)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(cpupower)-prefix)/share/man" >>$@
	echo "set MSG \"$(cpupower)\"" >>$@

$(cpupower)-src: $($(cpupower)-src)
$(cpupower)-unpack: $($(cpupower)-prefix)/.pkgunpack
$(cpupower)-patch: $($(cpupower)-prefix)/.pkgpatch
$(cpupower)-build: $($(cpupower)-prefix)/.pkgbuild
$(cpupower)-check: $($(cpupower)-prefix)/.pkgcheck
$(cpupower)-install: $($(cpupower)-prefix)/.pkginstall
$(cpupower)-modulefile: $($(cpupower)-modulefile)
$(cpupower)-clean:
	rm -rf $($(cpupower)-modulefile)
	rm -rf $($(cpupower)-prefix)
	rm -rf $($(cpupower)-srcdir)
	rm -rf $($(cpupower)-src)
$(cpupower): $(cpupower)-src $(cpupower)-unpack $(cpupower)-patch $(cpupower)-build $(cpupower)-check $(cpupower)-install $(cpupower)-modulefile
