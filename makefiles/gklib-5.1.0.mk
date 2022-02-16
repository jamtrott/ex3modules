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
# gklib-5.1.0

gklib-version = 5.1.0
gklib = gklib-$(gklib-version)
$(gklib)-description = Serial Graph Partitioning and Fill-reducing Matrix Ordering
$(gklib)-url = http://glaros.dtc.umn.edu/gkhome/metis/metis/overview
$(gklib)-srcurl = $($(metis-src)-srcurl)
$(gklib)-builddeps = $(cmake)
$(gklib)-prereqs =
$(gklib)-src = $($(metis-src)-src)
$(gklib)-srcdir = $(pkgsrcdir)/$(gklib)
$(gklib)-builddir = $($(gklib)-srcdir)/GKlib/build
$(gklib)-modulefile = $(modulefilesdir)/$(gklib)
$(gklib)-prefix = $(pkgdir)/$(gklib)

$($(gklib)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gklib)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gklib)-prefix)/.pkgunpack: $$($(gklib)-src) $($(gklib)-srcdir)/.markerfile $($(gklib)-prefix)/.markerfile $$(foreach dep,$$($(gklib)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(gklib)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gklib)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gklib)-builddeps),$(modulefilesdir)/$$(dep)) $($(gklib)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gklib)-builddir),$($(gklib)-srcdir))
$($(gklib)-builddir)/.markerfile: $($(gklib)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gklib)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gklib)-builddeps),$(modulefilesdir)/$$(dep)) $($(gklib)-builddir)/.markerfile $($(gklib)-prefix)/.pkgpatch
	cd $($(gklib)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gklib)-builddeps) && \
		$(CMAKE) .. -DCMAKE_INSTALL_PREFIX=$($(gklib)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib && \
		$(MAKE)
	@touch $@

$($(gklib)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gklib)-builddeps),$(modulefilesdir)/$$(dep)) $($(gklib)-builddir)/.markerfile $($(gklib)-prefix)/.pkgbuild
	@touch $@

$($(gklib)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gklib)-builddeps),$(modulefilesdir)/$$(dep)) $($(gklib)-builddir)/.markerfile $($(gklib)-prefix)/.pkgcheck
	cd $($(gklib)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gklib)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gklib)-modulefile): $(modulefilesdir)/.markerfile $($(gklib)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gklib)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gklib)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gklib)-description)\"" >>$@
	echo "module-whatis \"$($(gklib)-url)\"" >>$@
	printf "$(foreach prereq,$($(gklib)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GKLIB_ROOT $($(gklib)-prefix)" >>$@
	echo "setenv GKLIB_INCDIR $($(gklib)-prefix)/include" >>$@
	echo "setenv GKLIB_INCLUDEDIR $($(gklib)-prefix)/include" >>$@
	echo "setenv GKLIB_LIBDIR $($(gklib)-prefix)/lib" >>$@
	echo "setenv GKLIB_LIBRARYDIR $($(gklib)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(gklib)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gklib)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gklib)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gklib)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gklib)-prefix)/lib" >>$@
	echo "set MSG \"$(gklib)\"" >>$@

$(gklib)-src: $($(gklib)-src)
$(gklib)-unpack: $($(gklib)-prefix)/.pkgunpack
$(gklib)-patch: $($(gklib)-prefix)/.pkgpatch
$(gklib)-build: $($(gklib)-prefix)/.pkgbuild
$(gklib)-check: $($(gklib)-prefix)/.pkgcheck
$(gklib)-install: $($(gklib)-prefix)/.pkginstall
$(gklib)-modulefile: $($(gklib)-modulefile)
$(gklib)-clean:
	rm -rf $($(gklib)-modulefile)
	rm -rf $($(gklib)-prefix)
	rm -rf $($(gklib)-srcdir)
	rm -rf $($(gklib)-src)
$(gklib): $(gklib)-src $(gklib)-unpack $(gklib)-patch $(gklib)-build $(gklib)-check $(gklib)-install $(gklib)-modulefile
