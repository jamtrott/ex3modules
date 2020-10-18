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
# boost-python-1.73.0

boost-python-version = 1.73.0
boost-python = boost-python-$(boost-python-version)
$(boost-python)-description = C++ library for interoperability between C++ and Python
$(boost-python)-url = https://www.boost.org/
$(boost-python)-srcurl =
$(boost-python)-builddeps = $(python)
$(boost-python)-prereqs = $(python)
$(boost-python)-src = $($(boost-src)-src)
$(boost-python)-srcdir = $(pkgsrcdir)/$(boost-python)
$(boost-python)-modulefile = $(modulefilesdir)/$(boost-python)
$(boost-python)-prefix = $(pkgdir)/$(boost-python)

$($(boost-python)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(boost-python)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(boost-python)-prefix)/.pkgunpack: $$($(boost-python)-src) $($(boost-python)-srcdir)/.markerfile $($(boost-python)-prefix)/.markerfile
	tar -C $($(boost-python)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(boost-python)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-python)-prefix)/.pkgunpack
	@touch $@

$($(boost-python)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-python)-prefix)/.pkgpatch
	cd $($(boost-python)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost-python)-builddeps) && \
		./bootstrap.sh --prefix=$($(boost-python)-prefix) \
			--with-python=$${PYTHON_ROOT}/bin/python3 \
			--with-python-version=$${PYTHON_VERSION_SHORT} \
			--with-python-root=$${PYTHON_ROOT} && \
		cat project-config.jam && \
		./b2 --with-python
	@touch $@

$($(boost-python)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-python)-prefix)/.pkgbuild
	@touch $@

$($(boost-python)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-python)-prefix)/.pkgcheck
	cd $($(boost-python)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost-python)-builddeps) && \
		./b2 --with-python install
	@touch $@

$($(boost-python)-modulefile): $(modulefilesdir)/.markerfile $($(boost-python)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(boost-python)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(boost-python)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(boost-python)-description)\"" >>$@
	echo "module-whatis \"$($(boost-python)-url)\"" >>$@
	printf "$(foreach prereq,$($(boost-python)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BOOST_PYTHON_ROOT $($(boost-python)-prefix)" >>$@
	echo "setenv BOOST_PYTHON_INCDIR $($(boost-python)-prefix)/include" >>$@
	echo "setenv BOOST_PYTHON_INCLUDEDIR $($(boost-python)-prefix)/include" >>$@
	echo "setenv BOOST_PYTHON_LIBDIR $($(boost-python)-prefix)/lib" >>$@
	echo "setenv BOOST_PYTHON_LIBRARYDIR $($(boost-python)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(boost-python)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(boost-python)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(boost-python)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(boost-python)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(boost-python)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(boost-python)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(boost-python)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(boost-python)-prefix)/share/info" >>$@
	echo "set MSG \"$(boost-python)\"" >>$@

$(boost-python)-src: $$($(boost-python)-src)
$(boost-python)-unpack: $($(boost-python)-prefix)/.pkgunpack
$(boost-python)-patch: $($(boost-python)-prefix)/.pkgpatch
$(boost-python)-build: $($(boost-python)-prefix)/.pkgbuild
$(boost-python)-check: $($(boost-python)-prefix)/.pkgcheck
$(boost-python)-install: $($(boost-python)-prefix)/.pkginstall
$(boost-python)-modulefile: $($(boost-python)-modulefile)
$(boost-python)-clean:
	rm -rf $($(boost-python)-modulefile)
	rm -rf $($(boost-python)-prefix)
	rm -rf $($(boost-python)-srcdir)
$(boost-python): $(boost-python)-src $(boost-python)-unpack $(boost-python)-patch $(boost-python)-build $(boost-python)-check $(boost-python)-install $(boost-python)-modulefile
