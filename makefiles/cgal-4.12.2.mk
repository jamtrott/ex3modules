# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# cgal-4.12.2

cgal-4.12-version = 4.12.2
cgal-4.12 = cgal-$(cgal-4.12-version)
$(cgal-4.12)-description = C++ library of geometric algorithms
$(cgal-4.12)-url = https://www.cgal.org/
$(cgal-4.12)-srcurl = https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-$(cgal-4.12-version)/CGAL-$(cgal-4.12-version).tar.xz
$(cgal-4.12)-builddeps = $(cmake) $(boost) $(gmp) $(mpfr)
$(cgal-4.12)-prereqs = $(cmake) $(boost) $(gmp) $(mpfr)
$(cgal-4.12)-src = $(pkgsrcdir)/$(notdir $($(cgal-4.12)-srcurl))
$(cgal-4.12)-srcdir = $(pkgsrcdir)/$(cgal-4.12)
$(cgal-4.12)-builddir = $($(cgal-4.12)-srcdir)/build
$(cgal-4.12)-modulefile = $(modulefilesdir)/$(cgal-4.12)
$(cgal-4.12)-prefix = $(pkgdir)/$(cgal-4.12)

$($(cgal-4.12)-src): $(dir $($(cgal-4.12)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cgal-4.12)-srcurl)

$($(cgal-4.12)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cgal-4.12)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cgal-4.12)-prefix)/.pkgunpack: $$($(cgal-4.12)-src) $($(cgal-4.12)-srcdir)/.markerfile $($(cgal-4.12)-prefix)/.markerfile
	tar -C $($(cgal-4.12)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(cgal-4.12)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cgal-4.12)-builddeps),$(modulefilesdir)/$$(dep)) $($(cgal-4.12)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(cgal-4.12)-builddir),$($(cgal-4.12)-srcdir))
$($(cgal-4.12)-builddir)/.markerfile: $($(cgal-4.12)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(cgal-4.12)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cgal-4.12)-builddeps),$(modulefilesdir)/$$(dep)) $($(cgal-4.12)-builddir)/.markerfile $($(cgal-4.12)-prefix)/.pkgpatch
	cd $($(cgal-4.12)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cgal-4.12)-builddeps) && \
		cmake -DCMAKE_INSTALL_PREFIX=$($(cgal-4.12)-prefix) \
		-DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
		-DMPFR_LIBRARIES="$$(pkg-config --libs mpfr)" \
		-DMPFR_INCLUDE_DIR="$${MPFR_INCDIR}" \
		.. && \
		$(MAKE)
	@touch $@

$($(cgal-4.12)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cgal-4.12)-builddeps),$(modulefilesdir)/$$(dep)) $($(cgal-4.12)-builddir)/.markerfile $($(cgal-4.12)-prefix)/.pkgbuild
	@touch $@

$($(cgal-4.12)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cgal-4.12)-builddeps),$(modulefilesdir)/$$(dep)) $($(cgal-4.12)-builddir)/.markerfile $($(cgal-4.12)-prefix)/.pkgcheck
	cd $($(cgal-4.12)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cgal-4.12)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(cgal-4.12)-modulefile): $(modulefilesdir)/.markerfile $($(cgal-4.12)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cgal-4.12)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cgal-4.12)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cgal-4.12)-description)\"" >>$@
	echo "module-whatis \"$($(cgal-4.12)-url)\"" >>$@
	printf "$(foreach prereq,$($(cgal-4.12)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CGAL_ROOT $($(cgal-4.12)-prefix)" >>$@
	echo "setenv CGAL_LIBDIR $($(cgal-4.12)-prefix)/lib" >>$@
	echo "setenv CGAL_LIBRARYDIR $($(cgal-4.12)-prefix)/lib" >>$@
	echo "setenv CGAL_INCDIR $($(cgal-4.12)-prefix)/include" >>$@
	echo "setenv CGAL_INCLUDEDIR $($(cgal-4.12)-prefix)/include" >>$@
	echo "prepend-path PATH $($(cgal-4.12)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(cgal-4.12)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(cgal-4.12)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(cgal-4.12)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cgal-4.12)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(cgal-4.12)-prefix)/share/man" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(cgal-4.12)-prefix)/lib/cmake/CGAL" >>$@
	echo "set MSG \"$(cgal-4.12)\"" >>$@

$(cgal-4.12)-src: $$($(cgal-4.12)-src)
$(cgal-4.12)-unpack: $($(cgal-4.12)-prefix)/.pkgunpack
$(cgal-4.12)-patch: $($(cgal-4.12)-prefix)/.pkgpatch
$(cgal-4.12)-build: $($(cgal-4.12)-prefix)/.pkgbuild
$(cgal-4.12)-check: $($(cgal-4.12)-prefix)/.pkgcheck
$(cgal-4.12)-install: $($(cgal-4.12)-prefix)/.pkginstall
$(cgal-4.12)-modulefile: $($(cgal-4.12)-modulefile)
$(cgal-4.12)-clean:
	rm -rf $($(cgal-4.12)-modulefile)
	rm -rf $($(cgal-4.12)-prefix)
	rm -rf $($(cgal-4.12)-builddir)
	rm -rf $($(cgal-4.12)-srcdir)
	rm -rf $($(cgal-4.12)-src)
$(cgal-4.12): $(cgal-4.12)-src $(cgal-4.12)-unpack $(cgal-4.12)-patch $(cgal-4.12)-build $(cgal-4.12)-check $(cgal-4.12)-install $(cgal-4.12)-modulefile
