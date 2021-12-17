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
# onetbb-2021.4.0

onetbb-version = 2021.4.0
onetbb = onetbb-$(onetbb-version)
$(onetbb)-description = oneAPI Threading Building Blocks shared-memory parallel C++ framework
$(onetbb)-url = https://oneapi-src.github.io/oneTBB/
$(onetbb)-srcurl =
$(onetbb)-builddeps = $(cmake) $(python)
$(onetbb)-prereqs =
$(onetbb)-src = $($(onetbb-src)-src)
$(onetbb)-srcdir = $(pkgsrcdir)/$(onetbb)
$(onetbb)-builddir = $($(onetbb)-srcdir)
$(onetbb)-modulefile = $(modulefilesdir)/$(onetbb)
$(onetbb)-prefix = $(pkgdir)/$(onetbb)
$(onetbb)-site-packages = $($(onetbb)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(onetbb)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(onetbb)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(onetbb)-prefix)/.pkgunpack: $$($(onetbb)-src) $($(onetbb)-srcdir)/.markerfile $($(onetbb)-prefix)/.markerfile $$(foreach dep,$$($(onetbb)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(onetbb)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(onetbb)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(onetbb)-builddeps),$(modulefilesdir)/$$(dep)) $($(onetbb)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(onetbb)-builddir),$($(onetbb)-srcdir))
$($(onetbb)-builddir)/.markerfile: $($(onetbb)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(onetbb)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(onetbb)-builddeps),$(modulefilesdir)/$$(dep)) $($(onetbb)-builddir)/.markerfile $($(onetbb)-prefix)/.pkgpatch
	cd $($(onetbb)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(onetbb)-builddeps) && \
		$(CMAKE) . \
			-DCMAKE_INSTALL_PREFIX=$($(onetbb)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DTBB4PY_BUILD:BOOL=ON && \
		$(MAKE) && \
		$(MAKE) python_build
	@touch $@

$($(onetbb)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(onetbb)-builddeps),$(modulefilesdir)/$$(dep)) $($(onetbb)-builddir)/.markerfile $($(onetbb)-prefix)/.pkgbuild
	@touch $@

$($(onetbb)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(onetbb)-builddeps),$(modulefilesdir)/$$(dep)) $($(onetbb)-builddir)/.markerfile $($(onetbb)-prefix)/.pkgcheck
	cd $($(onetbb)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(onetbb)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(onetbb)-modulefile): $(modulefilesdir)/.markerfile $($(onetbb)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(onetbb)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(onetbb)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(onetbb)-description)\"" >>$@
	echo "module-whatis \"$($(onetbb)-url)\"" >>$@
	printf "$(foreach prereq,$($(onetbb)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv ONETBB_ROOT $($(onetbb)-prefix)" >>$@
	echo "setenv ONETBB_INCDIR $($(onetbb)-prefix)/include" >>$@
	echo "setenv ONETBB_INCLUDEDIR $($(onetbb)-prefix)/include" >>$@
	echo "setenv ONETBB_LIBDIR $($(onetbb)-prefix)/lib" >>$@
	echo "setenv ONETBB_LIBRARYDIR $($(onetbb)-prefix)/lib" >>$@
	echo "setenv TBBROOT $($(onetbb)-prefix)" >>$@
	echo "prepend-path PATH $($(onetbb)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(onetbb)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(onetbb)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(onetbb)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(onetbb)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(onetbb)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(onetbb)-prefix)/lib/cmake/TBB" >>$@
	echo "prepend-path PYTHONPATH $($(python-onetbb)-site-packages)" >>$@
	echo "prepend-path MANPATH $($(onetbb)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(onetbb)-prefix)/share/info" >>$@
	echo "set MSG \"$(onetbb)\"" >>$@

$(onetbb)-src: $$($(onetbb)-src)
$(onetbb)-unpack: $($(onetbb)-prefix)/.pkgunpack
$(onetbb)-patch: $($(onetbb)-prefix)/.pkgpatch
$(onetbb)-build: $($(onetbb)-prefix)/.pkgbuild
$(onetbb)-check: $($(onetbb)-prefix)/.pkgcheck
$(onetbb)-install: $($(onetbb)-prefix)/.pkginstall
$(onetbb)-modulefile: $($(onetbb)-modulefile)
$(onetbb)-clean:
	rm -rf $($(onetbb)-modulefile)
	rm -rf $($(onetbb)-prefix)
	rm -rf $($(onetbb)-builddir)
	rm -rf $($(onetbb)-srcdir)
	rm -rf $($(onetbb)-src)
$(onetbb): $(onetbb)-src $(onetbb)-unpack $(onetbb)-patch $(onetbb)-build $(onetbb)-check $(onetbb)-install $(onetbb)-modulefile
