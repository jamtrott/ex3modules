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
# opencascade-7.5.0

opencascade-version = 7.5.0
opencascade = opencascade-$(opencascade-version)
$(opencascade)-description = 
$(opencascade)-url = https://dev.opencascade.org/
$(opencascade)-srcurl = https://github.com/tpaviot/oce/releases/download/official-upstream-packages/opencascade-7.5.0.tgz
$(opencascade)-builddeps = $(cmake) $(freetype) $(flex) $(bison) $(eigen)
$(opencascade)-prereqs = $(cmake) $(freetype) $(flex) $(bison) $(eigen)
$(opencascade)-src = $(pkgsrcdir)/$(notdir $($(opencascade)-srcurl))
$(opencascade)-srcdir = $(pkgsrcdir)/$(opencascade)
$(opencascade)-builddir = $($(opencascade)-srcdir)/build
$(opencascade)-modulefile = $(modulefilesdir)/$(opencascade)
$(opencascade)-prefix = $(pkgdir)/$(opencascade)

$($(opencascade)-src): $(dir $($(opencascade)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(opencascade)-srcurl)

$($(opencascade)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(opencascade)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(opencascade)-prefix)/.pkgunpack: $$($(opencascade)-src) $($(opencascade)-srcdir)/.markerfile $($(opencascade)-prefix)/.markerfile $$(foreach dep,$$($(opencascade)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(opencascade)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(opencascade)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(opencascade)-builddeps),$(modulefilesdir)/$$(dep)) $($(opencascade)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(opencascade)-builddir),$($(opencascade)-srcdir))
$($(opencascade)-builddir)/.markerfile: $($(opencascade)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(opencascade)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(opencascade)-builddeps),$(modulefilesdir)/$$(dep)) $($(opencascade)-builddir)/.markerfile $($(opencascade)-prefix)/.pkgpatch
	cd $($(opencascade)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(opencascade)-builddeps) && \
		$(CMAKE) .. -DCMAKE_INSTALL_PREFIX=$($(opencascade)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_MODULE_Draw:BOOL=FALSE && \
		$(MAKE)
	@touch $@

$($(opencascade)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(opencascade)-builddeps),$(modulefilesdir)/$$(dep)) $($(opencascade)-builddir)/.markerfile $($(opencascade)-prefix)/.pkgbuild
	@touch $@

$($(opencascade)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(opencascade)-builddeps),$(modulefilesdir)/$$(dep)) $($(opencascade)-builddir)/.markerfile $($(opencascade)-prefix)/.pkgcheck
	cd $($(opencascade)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(opencascade)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(opencascade)-modulefile): $(modulefilesdir)/.markerfile $($(opencascade)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(opencascade)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(opencascade)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(opencascade)-description)\"" >>$@
	echo "module-whatis \"$($(opencascade)-url)\"" >>$@
	printf "$(foreach prereq,$($(opencascade)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENCASCADE_ROOT $($(opencascade)-prefix)" >>$@
	echo "setenv OPENCASCADE_INCDIR $($(opencascade)-prefix)/include" >>$@
	echo "setenv OPENCASCADE_INCLUDEDIR $($(opencascade)-prefix)/include" >>$@
	echo "setenv OPENCASCADE_LIBDIR $($(opencascade)-prefix)/lib" >>$@
	echo "setenv OPENCASCADE_LIBRARYDIR $($(opencascade)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(opencascade)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(opencascade)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(opencascade)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(opencascade)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(opencascade)-prefix)/lib" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(opencascade)-prefix)/lib/cmake/opencascade" >>$@
	echo "set MSG \"$(opencascade)\"" >>$@

$(opencascade)-src: $$($(opencascade)-src)
$(opencascade)-unpack: $($(opencascade)-prefix)/.pkgunpack
$(opencascade)-patch: $($(opencascade)-prefix)/.pkgpatch
$(opencascade)-build: $($(opencascade)-prefix)/.pkgbuild
$(opencascade)-check: $($(opencascade)-prefix)/.pkgcheck
$(opencascade)-install: $($(opencascade)-prefix)/.pkginstall
$(opencascade)-modulefile: $($(opencascade)-modulefile)
$(opencascade)-clean:
	rm -rf $($(opencascade)-modulefile)
	rm -rf $($(opencascade)-prefix)
	rm -rf $($(opencascade)-builddir)
	rm -rf $($(opencascade)-srcdir)
	rm -rf $($(opencascade)-src)
$(opencascade): $(opencascade)-src $(opencascade)-unpack $(opencascade)-patch $(opencascade)-build $(opencascade)-check $(opencascade)-install $(opencascade)-modulefile
