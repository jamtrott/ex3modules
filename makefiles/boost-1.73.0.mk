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
# boost-1.73.0

boost-1.73.0-version = 1.73.0
boost-1.73.0 = boost-$(boost-1.73.0-version)
$(boost-1.73.0)-description = Libraries for the C++ programming language
$(boost-1.73.0)-url = https://www.boost.org/
$(boost-1.73.0)-srcurl =
$(boost-1.73.0)-builddeps = $(xz)
$(boost-1.73.0)-prereqs = $(xz)
$(boost-1.73.0)-src = $($(boost-src-1.73.0)-src)
$(boost-1.73.0)-srcdir = $(pkgsrcdir)/$(boost-1.73.0)
$(boost-1.73.0)-modulefile = $(modulefilesdir)/$(boost-1.73.0)
$(boost-1.73.0)-prefix = $(pkgdir)/$(boost-1.73.0)

$($(boost-1.73.0)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(boost-1.73.0)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(boost-1.73.0)-prefix)/.pkgunpack: $$($(boost-1.73.0)-src) $($(boost-1.73.0)-srcdir)/.markerfile $($(boost-1.73.0)-prefix)/.markerfile $$(foreach dep,$$($(boost-1.73.0)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(boost-1.73.0)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(boost-1.73.0)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-1.73.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-1.73.0)-prefix)/.pkgunpack
	@touch $@

$($(boost-1.73.0)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-1.73.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-1.73.0)-prefix)/.pkgpatch
	cd $($(boost-1.73.0)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost-1.73.0)-builddeps) && \
		./bootstrap.sh --prefix=$($(boost-1.73.0)-prefix) \
			 --with-toolset=gcc && \
		./b2 --toolset=gcc --without-python --without-mpi
	@touch $@

$($(boost-1.73.0)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-1.73.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-1.73.0)-prefix)/.pkgbuild
	@touch $@

$($(boost-1.73.0)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-1.73.0)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-1.73.0)-prefix)/.pkgcheck
	cd $($(boost-1.73.0)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost-1.73.0)-builddeps) && \
		./b2 --toolset=gcc --without-python --without-mpi install
	@touch $@

$($(boost-1.73.0)-modulefile): $(modulefilesdir)/.markerfile $($(boost-1.73.0)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(boost-1.73.0)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(boost-1.73.0)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(boost-1.73.0)-description)\"" >>$@
	echo "module-whatis \"$($(boost-1.73.0)-url)\"" >>$@
	printf "$(foreach prereq,$($(boost-1.73.0)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BOOST_ROOT $($(boost-1.73.0)-prefix)" >>$@
	echo "setenv BOOST_INCDIR $($(boost-1.73.0)-prefix)/include" >>$@
	echo "setenv BOOST_INCLUDEDIR $($(boost-1.73.0)-prefix)/include" >>$@
	echo "setenv BOOST_LIBDIR $($(boost-1.73.0)-prefix)/lib" >>$@
	echo "setenv BOOST_LIBRARYDIR $($(boost-1.73.0)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(boost-1.73.0)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(boost-1.73.0)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(boost-1.73.0)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(boost-1.73.0)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(boost-1.73.0)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(boost-1.73.0)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(boost-1.73.0)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(boost-1.73.0)-prefix)/share/info" >>$@
	echo "set MSG \"$(boost-1.73.0)\"" >>$@

$(boost-1.73.0)-src: $$($(boost-1.73.0)-src)
$(boost-1.73.0)-unpack: $($(boost-1.73.0)-prefix)/.pkgunpack
$(boost-1.73.0)-patch: $($(boost-1.73.0)-prefix)/.pkgpatch
$(boost-1.73.0)-build: $($(boost-1.73.0)-prefix)/.pkgbuild
$(boost-1.73.0)-check: $($(boost-1.73.0)-prefix)/.pkgcheck
$(boost-1.73.0)-install: $($(boost-1.73.0)-prefix)/.pkginstall
$(boost-1.73.0)-modulefile: $($(boost-1.73.0)-modulefile)
$(boost-1.73.0)-clean:
	rm -rf $($(boost-1.73.0)-modulefile)
	rm -rf $($(boost-1.73.0)-prefix)
	rm -rf $($(boost-1.73.0)-srcdir)
$(boost-1.73.0): $(boost-1.73.0)-src $(boost-1.73.0)-unpack $(boost-1.73.0)-patch $(boost-1.73.0)-build $(boost-1.73.0)-check $(boost-1.73.0)-install $(boost-1.73.0)-modulefile
