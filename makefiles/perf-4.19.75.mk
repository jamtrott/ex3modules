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
# perf-4.19.75

perf-version = 4.19.75
perf = perf-$(perf-version)
$(perf)-description = Performance analysis tools for Linux
$(perf)-url = https://perf.wiki.kernel.org/index.php/Main_Page
$(perf)-srcurl = $($(linux-src)-srcurl)
$(perf)-builddeps = $(numactl) $(elfutils) $(openssl) $(libunwind) $(sparse)
$(perf)-prereqs = $(numactl) $(elfutils) $(openssl) $(libunwind)
$(perf)-src = $($(linux-src)-src)
$(perf)-srcdir = $(pkgsrcdir)/$(perf)
$(perf)-builddir = $($(perf)-srcdir)/tools/perf
$(perf)-modulefile = $(modulefilesdir)/$(perf)
$(perf)-prefix = $(pkgdir)/$(perf)

$($(perf)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(perf)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(perf)-prefix)/.pkgunpack: $$($(perf)-src) $($(perf)-srcdir)/.markerfile $($(perf)-prefix)/.markerfile
	tar -C $($(perf)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(perf)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(perf)-builddeps),$(modulefilesdir)/$$(dep)) $($(perf)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(perf)-builddir),$($(perf)-srcdir))
$($(perf)-builddir)/.markerfile: $($(perf)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(perf)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(perf)-builddeps),$(modulefilesdir)/$$(dep)) $($(perf)-builddir)/.markerfile $($(perf)-prefix)/.pkgpatch
	cd $($(perf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(perf)-builddeps) && \
		$(MAKE)
	@touch $@

$($(perf)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(perf)-builddeps),$(modulefilesdir)/$$(dep)) $($(perf)-builddir)/.markerfile $($(perf)-prefix)/.pkgbuild
	# Tests don't work at the moment
	# cd $($(perf)-builddir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(perf)-builddeps) && \
	# 	$(MAKE) check
	@touch $@

$($(perf)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(perf)-builddeps),$(modulefilesdir)/$$(dep)) $($(perf)-builddir)/.markerfile $($(perf)-prefix)/.pkgcheck
	cd $($(perf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(perf)-builddeps) && \
		$(MAKE) MAKEFLAGS="prefix=$($(perf)-prefix)" install
	@touch $@

$($(perf)-modulefile): $(modulefilesdir)/.markerfile $($(perf)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(perf)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(perf)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(perf)-description)\"" >>$@
	echo "module-whatis \"$($(perf)-url)\"" >>$@
	printf "$(foreach prereq,$($(perf)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PERF_ROOT $($(perf)-prefix)" >>$@
	echo "setenv PERF_INCDIR $($(perf)-prefix)/include" >>$@
	echo "setenv PERF_INCLUDEDIR $($(perf)-prefix)/include" >>$@
	echo "setenv PERF_LIBDIR $($(perf)-prefix)/lib" >>$@
	echo "setenv PERF_LIBRARYDIR $($(perf)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(perf)-prefix)/bin" >>$@
	echo "prepend-path LIBRARY_PATH $($(perf)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(perf)-prefix)/lib" >>$@
	echo "set MSG \"$(perf)\"" >>$@

$(perf)-src: $($(perf)-src)
$(perf)-unpack: $($(perf)-prefix)/.pkgunpack
$(perf)-patch: $($(perf)-prefix)/.pkgpatch
$(perf)-build: $($(perf)-prefix)/.pkgbuild
$(perf)-check: $($(perf)-prefix)/.pkgcheck
$(perf)-install: $($(perf)-prefix)/.pkginstall
$(perf)-modulefile: $($(perf)-modulefile)
$(perf)-clean:
	rm -rf $($(perf)-modulefile)
	rm -rf $($(perf)-prefix)
	rm -rf $($(perf)-srcdir)
	rm -rf $($(perf)-src)
$(perf): $(perf)-src $(perf)-unpack $(perf)-patch $(perf)-build $(perf)-check $(perf)-install $(perf)-modulefile
