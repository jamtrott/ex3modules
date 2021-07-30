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
# paraview-5.9.1

paraview-version = 5.9.1
paraview = paraview-$(paraview-version)
$(paraview)-description = Open-source, multi-platform data analysis and visualization application
$(paraview)-url = https://www.paraview.org/
$(paraview)-srcurl = https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.9&type=source&os=Sources&downloadFile=ParaView-v5.9.1.tar.xz
$(paraview)-builddeps = $(cmake) $(mpi) $(python) $(libxt) $(qt5)
$(paraview)-prereqs = $(mpi) $(python) $(qt5)
$(paraview)-src = $(pkgsrcdir)/paraview-$(paraview-version).tar.xz
$(paraview)-srcdir = $(pkgsrcdir)/$(paraview)
$(paraview)-builddir = $($(paraview)-srcdir)/build
$(paraview)-modulefile = $(modulefilesdir)/$(paraview)
$(paraview)-prefix = $(pkgdir)/$(paraview)

$($(paraview)-src): $(dir $($(paraview)-src)).markerfile
	$(CURL) $(curl_options) --output $@ "$($(paraview)-srcurl)"

$($(paraview)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(paraview)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(paraview)-prefix)/.pkgunpack: $$($(paraview)-src) $($(paraview)-srcdir)/.markerfile $($(paraview)-prefix)/.markerfile
	tar -C $($(paraview)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(paraview)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(paraview)-builddeps),$(modulefilesdir)/$$(dep)) $($(paraview)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(paraview)-builddir),$($(paraview)-srcdir))
$($(paraview)-builddir)/.markerfile: $($(paraview)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(paraview)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(paraview)-builddeps),$(modulefilesdir)/$$(dep)) $($(paraview)-builddir)/.markerfile $($(paraview)-prefix)/.pkgpatch
	cd $($(paraview)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(paraview)-builddeps) && \
		cmake -DCMAKE_INSTALL_PREFIX=$($(paraview)-prefix) \
		.. && \
		$(MAKE)
	@touch $@

$($(paraview)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(paraview)-builddeps),$(modulefilesdir)/$$(dep)) $($(paraview)-builddir)/.markerfile $($(paraview)-prefix)/.pkgbuild
	@touch $@

$($(paraview)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(paraview)-builddeps),$(modulefilesdir)/$$(dep)) $($(paraview)-builddir)/.markerfile $($(paraview)-prefix)/.pkgcheck
	cd $($(paraview)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(paraview)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(paraview)-modulefile): $(modulefilesdir)/.markerfile $($(paraview)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(paraview)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(paraview)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(paraview)-description)\"" >>$@
	echo "module-whatis \"$($(paraview)-url)\"" >>$@
	printf "$(foreach prereq,$($(paraview)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PARAVIEW_ROOT $($(paraview)-prefix)" >>$@
	echo "setenv PARAVIEW_INCDIR $($(paraview)-prefix)/include" >>$@
	echo "setenv PARAVIEW_INCLUDEDIR $($(paraview)-prefix)/include" >>$@
	echo "setenv PARAVIEW_LIBDIR $($(paraview)-prefix)/lib" >>$@
	echo "setenv PARAVIEW_LIBRARYDIR $($(paraview)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(paraview)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(paraview)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(paraview)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(paraview)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(paraview)-prefix)/lib" >>$@
	echo "prepend-path CMAKE_PREFIX_PATH $($(paraview)-prefix)" >>$@
	echo "set MSG \"$(paraview)\"" >>$@

$(paraview)-src: $$($(paraview)-src)
$(paraview)-unpack: $($(paraview)-prefix)/.pkgunpack
$(paraview)-patch: $($(paraview)-prefix)/.pkgpatch
$(paraview)-build: $($(paraview)-prefix)/.pkgbuild
$(paraview)-check: $($(paraview)-prefix)/.pkgcheck
$(paraview)-install: $($(paraview)-prefix)/.pkginstall
$(paraview)-modulefile: $($(paraview)-modulefile)
$(paraview)-clean:
	rm -rf $($(paraview)-modulefile)
	rm -rf $($(paraview)-prefix)
	rm -rf $($(paraview)-builddir)
	rm -rf $($(paraview)-srcdir)
	rm -rf $($(paraview)-src)
$(paraview): $(paraview)-src $(paraview)-unpack $(paraview)-patch $(paraview)-build $(paraview)-check $(paraview)-install $(paraview)-modulefile
