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
# cgal-5.2.2

cgal-version = 5.2.2
cgal = cgal-$(cgal-version)
$(cgal)-description = C++ library of geometric algorithms
$(cgal)-url = https://www.cgal.org/
$(cgal)-srcurl = https://github.com/CGAL/cgal/releases/download/v$(cgal-version)/CGAL-$(cgal-version).tar.xz
$(cgal)-builddeps = $(cgal) $(boost) $(gmp) $(mpfr)
$(cgal)-prereqs = $(cgal) $(boost) $(gmp) $(mpfr)
$(cgal)-src = $(pkgsrcdir)/$(notdir $($(cgal)-srcurl))
$(cgal)-srcdir = $(pkgsrcdir)/$(cgal)
$(cgal)-builddir = $($(cgal)-srcdir)/build
$(cgal)-modulefile = $(modulefilesdir)/$(cgal)
$(cgal)-prefix = $(pkgdir)/$(cgal)

$($(cgal)-src): $(dir $($(cgal)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cgal)-srcurl)

$($(cgal)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cgal)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cgal)-prefix)/.pkgunpack: $$($(cgal)-src) $($(cgal)-srcdir)/.markerfile $($(cgal)-prefix)/.markerfile
	tar -C $($(cgal)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(cgal)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cgal)-builddeps),$(modulefilesdir)/$$(dep)) $($(cgal)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(cgal)-builddir),$($(cgal)-srcdir))
$($(cgal)-builddir)/.markerfile: $($(cgal)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(cgal)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cgal)-builddeps),$(modulefilesdir)/$$(dep)) $($(cgal)-builddir)/.markerfile $($(cgal)-prefix)/.pkgpatch
	cd $($(cgal)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cgal)-builddeps) && \
		cmake -DCMAKE_INSTALL_PREFIX=$($(cgal)-prefix) \
		-DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
		-DMPFR_LIBRARIES="$$(pkg-config --libs mpfr)" \
		-DMPFR_INCLUDE_DIR="$${MPFR_INCDIR}" \
		.. && \
		$(MAKE)
	@touch $@

$($(cgal)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cgal)-builddeps),$(modulefilesdir)/$$(dep)) $($(cgal)-builddir)/.markerfile $($(cgal)-prefix)/.pkgbuild
	@touch $@

$($(cgal)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cgal)-builddeps),$(modulefilesdir)/$$(dep)) $($(cgal)-builddir)/.markerfile $($(cgal)-prefix)/.pkgcheck
	cd $($(cgal)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cgal)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(cgal)-modulefile): $(modulefilesdir)/.markerfile $($(cgal)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cgal)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cgal)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cgal)-description)\"" >>$@
	echo "module-whatis \"$($(cgal)-url)\"" >>$@
	printf "$(foreach prereq,$($(cgal)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CGAL_ROOT $($(cgal)-prefix)" >>$@
	echo "setenv CGAL_INCDIR $($(cgal)-prefix)/include" >>$@
	echo "setenv CGAL_INCLUDEDIR $($(cgal)-prefix)/include" >>$@
	echo "prepend-path PATH $($(cgal)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(cgal)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(cgal)-prefix)/include" >>$@
	echo "prepend-path MANPATH $($(cgal)-prefix)/share/man" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(cgal)-prefix)/lib/cmake/CGAL" >>$@
	echo "set MSG \"$(cgal)\"" >>$@

$(cgal)-src: $$($(cgal)-src)
$(cgal)-unpack: $($(cgal)-prefix)/.pkgunpack
$(cgal)-patch: $($(cgal)-prefix)/.pkgpatch
$(cgal)-build: $($(cgal)-prefix)/.pkgbuild
$(cgal)-check: $($(cgal)-prefix)/.pkgcheck
$(cgal)-install: $($(cgal)-prefix)/.pkginstall
$(cgal)-modulefile: $($(cgal)-modulefile)
$(cgal)-clean:
	rm -rf $($(cgal)-modulefile)
	rm -rf $($(cgal)-prefix)
	rm -rf $($(cgal)-builddir)
	rm -rf $($(cgal)-srcdir)
	rm -rf $($(cgal)-src)
$(cgal): $(cgal)-src $(cgal)-unpack $(cgal)-patch $(cgal)-build $(cgal)-check $(cgal)-install $(cgal)-modulefile
