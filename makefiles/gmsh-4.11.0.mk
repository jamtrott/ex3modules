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
# gmsh-4.11.0

gmsh-version = 4.11.0
gmsh = gmsh-$(gmsh-version)
$(gmsh)-description = A three-dimensional finite element mesh generator with built-in pre- and post-processing facilities
$(gmsh)-url = http://gmsh.info/
$(gmsh)-srcurl = http://gmsh.info/src/gmsh-$(gmsh-version)-source.tgz
$(gmsh)-builddeps = $(cmake) $(eigen) $(python) $(opencascade)
$(gmsh)-prereqs = $(eigen) $(python) $(opencascade)
$(gmsh)-src = $(pkgsrcdir)/$(notdir $($(gmsh)-srcurl))
$(gmsh)-srcdir = $(pkgsrcdir)/$(gmsh)
$(gmsh)-builddir = $($(gmsh)-srcdir)/build
$(gmsh)-modulefile = $(modulefilesdir)/$(gmsh)
$(gmsh)-prefix = $(pkgdir)/$(gmsh)

$($(gmsh)-src): $(dir $($(gmsh)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gmsh)-srcurl)

$($(gmsh)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gmsh)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gmsh)-prefix)/.pkgunpack: $($(gmsh)-src) $($(gmsh)-srcdir)/.markerfile $($(gmsh)-prefix)/.markerfile $$(foreach dep,$$($(gmsh)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(gmsh)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gmsh)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gmsh)-builddeps),$(modulefilesdir)/$$(dep)) $($(gmsh)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gmsh)-builddir),$($(gmsh)-srcdir))
$($(gmsh)-builddir)/.markerfile: $($(gmsh)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gmsh)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gmsh)-builddeps),$(modulefilesdir)/$$(dep)) $($(gmsh)-builddir)/.markerfile $($(gmsh)-prefix)/.pkgpatch
	cd $($(gmsh)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gmsh)-builddeps) && \
		$(CMAKE) .. -DCMAKE_INSTALL_PREFIX=$($(gmsh)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DENABLE_BUILD_SHARED=ON \
			-DENABLE_GRAPHICS=ON \
			-DENABLE_OCC=ON \
			-DCMAKE_PREFIX_PATH=$${OPENCASCADE_ROOT} && \
		$(MAKE)
	@touch $@

$($(gmsh)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gmsh)-builddeps),$(modulefilesdir)/$$(dep)) $($(gmsh)-builddir)/.markerfile $($(gmsh)-prefix)/.pkgbuild
	@touch $@

$($(gmsh)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gmsh)-builddeps),$(modulefilesdir)/$$(dep)) $($(gmsh)-builddir)/.markerfile $($(gmsh)-prefix)/.pkgcheck
	cd $($(gmsh)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gmsh)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gmsh)-modulefile): $(modulefilesdir)/.markerfile $($(gmsh)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gmsh)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gmsh)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gmsh)-description)\"" >>$@
	echo "module-whatis \"$($(gmsh)-url)\"" >>$@
	printf "$(foreach prereq,$($(gmsh)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GMSH_ROOT $($(gmsh)-prefix)" >>$@
	echo "setenv GMSH_INCDIR $($(gmsh)-prefix)/include" >>$@
	echo "setenv GMSH_INCLUDEDIR $($(gmsh)-prefix)/include" >>$@
	echo "setenv GMSH_LIBDIR $($(gmsh)-prefix)/lib" >>$@
	echo "setenv GMSH_LIBRARYDIR $($(gmsh)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(gmsh)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gmsh)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gmsh)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gmsh)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gmsh)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(gmsh)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(gmsh)-prefix)/share/man" >>$@
	echo "prepend-path PYTHONPATH $($(gmsh)-prefix)/lib" >>$@
	echo "set MSG \"$(gmsh)\"" >>$@

$(gmsh)-src: $($(gmsh)-src)
$(gmsh)-unpack: $($(gmsh)-prefix)/.pkgunpack
$(gmsh)-patch: $($(gmsh)-prefix)/.pkgpatch
$(gmsh)-build: $($(gmsh)-prefix)/.pkgbuild
$(gmsh)-check: $($(gmsh)-prefix)/.pkgcheck
$(gmsh)-install: $($(gmsh)-prefix)/.pkginstall
$(gmsh)-modulefile: $($(gmsh)-modulefile)
$(gmsh)-clean:
	rm -rf $($(gmsh)-modulefile)
	rm -rf $($(gmsh)-prefix)
	rm -rf $($(gmsh)-srcdir)
	rm -rf $($(gmsh)-src)
$(gmsh): $(gmsh)-src $(gmsh)-unpack $(gmsh)-patch $(gmsh)-build $(gmsh)-check $(gmsh)-install $(gmsh)-modulefile
