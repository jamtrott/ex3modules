# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# boost-python-1.90.0

boost-python-1.90.0-version = 1.90.0
boost-python-1.90.0 = boost-python-$(boost-python-1.90.0-version)
$(boost-python-1.90.0)-description = C++ library for interoperability between C++ and Python
$(boost-python-1.90.0)-url = https://www.boost.org/
$(boost-python-1.90.0)-srcurl =
$(boost-python-1.90.0)-builddeps = $(python)
$(boost-python-1.90.0)-prereqs = $(python)
$(boost-python-1.90.0)-src = $($(boost-src)-src)
$(boost-python-1.90.0)-srcdir = $(pkgsrcdir)/$(boost-python-1.90.0)
$(boost-python-1.90.0)-modulefile = $(modulefilesdir)/$(boost-python-1.90.0)
$(boost-python-1.90.0)-prefix = $(pkgdir)/$(boost-python-1.90.0)

$($(boost-python-1.90.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(boost-python-1.90.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(boost-python-1.90.0)-prefix)/.pkgunpack: $$($(boost-python-1.90.0)-src) $($(boost-python-1.90.0)-srcdir)/.markerfile $($(boost-python-1.90.0)-prefix)/.markerfile $$(foreach dep,$$($(boost-python-1.90.0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(boost-python-1.90.0)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(boost-python-1.90.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-python-1.90.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-python-1.90.0)-prefix)/.pkgunpack
	@touch $@

$($(boost-python-1.90.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-python-1.90.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-python-1.90.0)-prefix)/.pkgpatch
	cd $($(boost-python-1.90.0)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost-python-1.90.0)-builddeps) && \
		./bootstrap.sh --prefix=$($(boost-python-1.90.0)-prefix) \
			--with-toolset=gcc \
			--with-python=$(PYTHON) \
			--with-python-version=$(PYTHON_VERSION_SHORT) \
			--with-python-root=$${PYTHON_ROOT} && \
		./b2 --toolset=gcc --with-python
	@touch $@

$($(boost-python-1.90.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-python-1.90.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-python-1.90.0)-prefix)/.pkgbuild
	@touch $@

$($(boost-python-1.90.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-python-1.90.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-python-1.90.0)-prefix)/.pkgcheck
	cd $($(boost-python-1.90.0)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost-python-1.90.0)-builddeps) && \
		./b2 --toolset=gcc --with-python install
	@touch $@

$($(boost-python-1.90.0)-modulefile): $(modulefilesdir)/.markerfile $($(boost-python-1.90.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(boost-python-1.90.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(boost-python-1.90.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(boost-python-1.90.0)-description)\"" >>$@
	echo "module-whatis \"$($(boost-python-1.90.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(boost-python-1.90.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BOOST_PYTHON_ROOT $($(boost-python-1.90.0)-prefix)" >>$@
	echo "setenv BOOST_PYTHON_INCDIR $($(boost-python-1.90.0)-prefix)/include" >>$@
	echo "setenv BOOST_PYTHON_INCLUDEDIR $($(boost-python-1.90.0)-prefix)/include" >>$@
	echo "setenv BOOST_PYTHON_LIBDIR $($(boost-python-1.90.0)-prefix)/lib" >>$@
	echo "setenv BOOST_PYTHON_LIBRARYDIR $($(boost-python-1.90.0)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(boost-python-1.90.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(boost-python-1.90.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(boost-python-1.90.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(boost-python-1.90.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(boost-python-1.90.0)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(boost-python-1.90.0)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(boost-python-1.90.0)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(boost-python-1.90.0)-prefix)/share/info" >>$@
	echo "set MSG \"$(boost-python-1.90.0)\"" >>$@

$(boost-python-1.90.0)-src: $$($(boost-python-1.90.0)-src)
$(boost-python-1.90.0)-unpack: $($(boost-python-1.90.0)-prefix)/.pkgunpack
$(boost-python-1.90.0)-patch: $($(boost-python-1.90.0)-prefix)/.pkgpatch
$(boost-python-1.90.0)-build: $($(boost-python-1.90.0)-prefix)/.pkgbuild
$(boost-python-1.90.0)-check: $($(boost-python-1.90.0)-prefix)/.pkgcheck
$(boost-python-1.90.0)-install: $($(boost-python-1.90.0)-prefix)/.pkginstall
$(boost-python-1.90.0)-modulefile: $($(boost-python-1.90.0)-modulefile)
$(boost-python-1.90.0)-clean:
	rm -rf $($(boost-python-1.90.0)-modulefile)
	rm -rf $($(boost-python-1.90.0)-prefix)
	rm -rf $($(boost-python-1.90.0)-srcdir)
$(boost-python-1.90.0): $(boost-python-1.90.0)-src $(boost-python-1.90.0)-unpack $(boost-python-1.90.0)-patch $(boost-python-1.90.0)-build $(boost-python-1.90.0)-check $(boost-python-1.90.0)-install $(boost-python-1.90.0)-modulefile
