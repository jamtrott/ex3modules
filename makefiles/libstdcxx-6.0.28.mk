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
# libstdcxx-6.0.28

libstdcxx-version = 6.0.28
libstdcxx = libstdcxx-$(libstdcxx-version)
$(libstdcxx)-description = GNU C++ Standard Library
$(libstdcxx)-url = https://gcc.gnu.org/
$(libstdcxx)-srcurl =
$(libstdcxx)-builddeps = $(gcc)
$(libstdcxx)-prereqs =
$(libstdcxx)-src =
$(libstdcxx)-srcdir = $(pkgsrcdir)/$(libstdcxx)
$(libstdcxx)-builddir = $($(libstdcxx)-srcdir)
$(libstdcxx)-modulefile = $(modulefilesdir)/$(libstdcxx)
$(libstdcxx)-prefix = $(pkgdir)/$(libstdcxx)

$($(libstdcxx)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libstdcxx)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libstdcxx)-prefix)/.pkgunpack: $$($(libstdcxx)-src) $($(libstdcxx)-srcdir)/.markerfile $($(libstdcxx)-prefix)/.markerfile
	@touch $@

$($(libstdcxx)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libstdcxx)-builddeps),$(modulefilesdir)/$$(dep)) $($(libstdcxx)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libstdcxx)-builddir),$($(libstdcxx)-srcdir))
$($(libstdcxx)-builddir)/.markerfile: $($(libstdcxx)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libstdcxx)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libstdcxx)-builddeps),$(modulefilesdir)/$$(dep)) $($(libstdcxx)-builddir)/.markerfile $($(libstdcxx)-prefix)/.pkgpatch
	@touch $@

$($(libstdcxx)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libstdcxx)-builddeps),$(modulefilesdir)/$$(dep)) $($(libstdcxx)-builddir)/.markerfile $($(libstdcxx)-prefix)/.pkgbuild
	@touch $@

$($(libstdcxx)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libstdcxx)-builddeps),$(modulefilesdir)/$$(dep)) $($(libstdcxx)-builddir)/.markerfile $($(libstdcxx)-prefix)/.pkgcheck
	@touch $@

$($(libstdcxx)-modulefile): $(modulefilesdir)/.markerfile $($(libstdcxx)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libstdcxx)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libstdcxx)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libstdcxx)-description)\"" >>$@
	echo "module-whatis \"$($(libstdcxx)-url)\"" >>$@
	printf "$(foreach prereq,$($(libstdcxx)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBSTDCXX_ROOT $($(gcc)-prefix)" >>$@
	echo "setenv LIBSTDCXX_INCDIR $($(gcc)-prefix)/include" >>$@
	echo "setenv LIBSTDCXX_INCLUDEDIR $($(gcc)-prefix)/include" >>$@
	echo "setenv LIBSTDCXX_LIBDIR $($(gcc)-prefix)/lib" >>$@
	echo "setenv LIBSTDCXX_LIBRARYDIR $($(gcc)-prefix)/lib" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gcc)-prefix)/include/c++/$(gcc-version)" >>$@
	echo "prepend-path LIBRARY_PATH $($(gcc)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gcc)-prefix)/lib64" >>$@
	echo "set MSG \"$(libstdcxx)\"" >>$@

$(libstdcxx)-src: $$($(libstdcxx)-src)
$(libstdcxx)-unpack: $($(libstdcxx)-prefix)/.pkgunpack
$(libstdcxx)-patch: $($(libstdcxx)-prefix)/.pkgpatch
$(libstdcxx)-build: $($(libstdcxx)-prefix)/.pkgbuild
$(libstdcxx)-check: $($(libstdcxx)-prefix)/.pkgcheck
$(libstdcxx)-install: $($(libstdcxx)-prefix)/.pkginstall
$(libstdcxx)-modulefile: $($(libstdcxx)-modulefile)
$(libstdcxx)-clean:
	rm -rf $($(libstdcxx)-modulefile)
	rm -rf $($(libstdcxx)-srcdir)
$(libstdcxx): $(libstdcxx)-src $(libstdcxx)-unpack $(libstdcxx)-patch $(libstdcxx)-build $(libstdcxx)-check $(libstdcxx)-install $(libstdcxx)-modulefile
