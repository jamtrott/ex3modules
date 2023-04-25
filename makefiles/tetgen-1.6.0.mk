# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# tetgen-1.6.0

tetgen-version = 1.6.0
tetgen = tetgen-$(tetgen-version)
$(tetgen)-description = generate tetrahedral meshes of 3D polyhedral domains
$(tetgen)-url = https://wias-berlin.de/software/index.jsp?id=TetGen&lang=1
$(tetgen)-srcurl = http://wias-berlin.de/software/tetgen/1.5/src/tetgen1.6.0.tar.gz
$(tetgen)-builddeps = $(cmake)
$(tetgen)-prereqs =
$(tetgen)-src = $(pkgsrcdir)/$(notdir $($(tetgen)-srcurl))
$(tetgen)-srcdir = $(pkgsrcdir)/$(tetgen)
$(tetgen)-builddir = $($(tetgen)-srcdir)/build
$(tetgen)-modulefile = $(modulefilesdir)/$(tetgen)
$(tetgen)-prefix = $(pkgdir)/$(tetgen)

$($(tetgen)-src): $(dir $($(tetgen)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(tetgen)-srcurl)

$($(tetgen)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(tetgen)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(tetgen)-prefix)/.pkgunpack: $$($(tetgen)-src) $($(tetgen)-srcdir)/.markerfile $($(tetgen)-prefix)/.markerfile $$(foreach dep,$$($(tetgen)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(tetgen)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(tetgen)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(tetgen)-builddeps),$(modulefilesdir)/$$(dep)) $($(tetgen)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(tetgen)-builddir),$($(tetgen)-srcdir))
$($(tetgen)-builddir)/.markerfile: $($(tetgen)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(tetgen)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(tetgen)-builddeps),$(modulefilesdir)/$$(dep)) $($(tetgen)-builddir)/.markerfile $($(tetgen)-prefix)/.pkgpatch
	cd $($(tetgen)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(tetgen)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(tetgen)-prefix) \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_POSITION_INDEPENDENT_CODE=ON && \
		$(MAKE)
	@touch $@

$($(tetgen)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(tetgen)-builddeps),$(modulefilesdir)/$$(dep)) $($(tetgen)-builddir)/.markerfile $($(tetgen)-prefix)/.pkgbuild
	@touch $@

$($(tetgen)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(tetgen)-builddeps),$(modulefilesdir)/$$(dep)) $($(tetgen)-builddir)/.markerfile $($(tetgen)-prefix)/.pkgcheck
	cd $($(tetgen)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(tetgen)-builddeps) && \
		$(INSTALL) -m 755 -D -t "$($(tetgen)-prefix)/bin" tetgen && \
		$(INSTALL) -m 644 -D -t "$($(tetgen)-prefix)/lib" libtet.a && \
		$(INSTALL) -m 644 -D -t "$($(tetgen)-prefix)/include" ../tetgen.h
	@touch $@

$($(tetgen)-modulefile): $(modulefilesdir)/.markerfile $($(tetgen)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(tetgen)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(tetgen)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(tetgen)-description)\"" >>$@
	echo "module-whatis \"$($(tetgen)-url)\"" >>$@
	printf "$(foreach prereq,$($(tetgen)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv TETGEN_ROOT $($(tetgen)-prefix)" >>$@
	echo "setenv TETGEN_INCDIR $($(tetgen)-prefix)/include" >>$@
	echo "setenv TETGEN_INCLUDEDIR $($(tetgen)-prefix)/include" >>$@
	echo "setenv TETGEN_LIBDIR $($(tetgen)-prefix)/lib" >>$@
	echo "setenv TETGEN_LIBRARYDIR $($(tetgen)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(tetgen)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(tetgen)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(tetgen)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(tetgen)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(tetgen)-prefix)/lib" >>$@
	echo "set MSG \"$(tetgen)\"" >>$@

$(tetgen)-src: $$($(tetgen)-src)
$(tetgen)-unpack: $($(tetgen)-prefix)/.pkgunpack
$(tetgen)-patch: $($(tetgen)-prefix)/.pkgpatch
$(tetgen)-build: $($(tetgen)-prefix)/.pkgbuild
$(tetgen)-check: $($(tetgen)-prefix)/.pkgcheck
$(tetgen)-install: $($(tetgen)-prefix)/.pkginstall
$(tetgen)-modulefile: $($(tetgen)-modulefile)
$(tetgen)-clean:
	rm -rf $($(tetgen)-modulefile)
	rm -rf $($(tetgen)-prefix)
	rm -rf $($(tetgen)-builddir)
	rm -rf $($(tetgen)-srcdir)
	rm -rf $($(tetgen)-src)
$(tetgen): $(tetgen)-src $(tetgen)-unpack $(tetgen)-patch $(tetgen)-build $(tetgen)-check $(tetgen)-install $(tetgen)-modulefile
