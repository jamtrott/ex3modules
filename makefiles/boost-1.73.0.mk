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

boost-version = 1.73.0
boost = boost-$(boost-version)
$(boost)-description = Libraries for the C++ programming language
$(boost)-url = https://www.boost.org/
$(boost)-srcurl =
$(boost)-builddeps = $(gcc-10.1.0) $(xz)
$(boost)-prereqs = $(xz)
$(boost)-src = $($(boost-src)-src)
$(boost)-srcdir = $(pkgsrcdir)/$(boost)
$(boost)-modulefile = $(modulefilesdir)/$(boost)
$(boost)-prefix = $(pkgdir)/$(boost)

$($(boost)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(boost)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(boost)-prefix)/.pkgunpack: $$($(boost)-src) $($(boost)-srcdir)/.markerfile $($(boost)-prefix)/.markerfile
	tar -C $($(boost)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(boost)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost)-prefix)/.pkgunpack
	@touch $@

$($(boost)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost)-prefix)/.pkgpatch
	cd $($(boost)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost)-builddeps) && \
		./bootstrap.sh --prefix=$($(boost)-prefix) \
			 --with-toolset=gcc && \
		./b2 --toolset=gcc-10.1 --without-python --without-mpi
	@touch $@

$($(boost)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost)-prefix)/.pkgbuild
	@touch $@

$($(boost)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost)-prefix)/.pkgcheck
	cd $($(boost)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost)-builddeps) && \
		./b2 --toolset=gcc-10.1 --without-python --without-mpi install
	@touch $@

$($(boost)-modulefile): $(modulefilesdir)/.markerfile $($(boost)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(boost)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(boost)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(boost)-description)\"" >>$@
	echo "module-whatis \"$($(boost)-url)\"" >>$@
	printf "$(foreach prereq,$($(boost)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BOOST_ROOT $($(boost)-prefix)" >>$@
	echo "setenv BOOST_INCDIR $($(boost)-prefix)/include" >>$@
	echo "setenv BOOST_INCLUDEDIR $($(boost)-prefix)/include" >>$@
	echo "setenv BOOST_LIBDIR $($(boost)-prefix)/lib" >>$@
	echo "setenv BOOST_LIBRARYDIR $($(boost)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(boost)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(boost)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(boost)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(boost)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(boost)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(boost)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(boost)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(boost)-prefix)/share/info" >>$@
	echo "set MSG \"$(boost)\"" >>$@

$(boost)-src: $$($(boost)-src)
$(boost)-unpack: $($(boost)-prefix)/.pkgunpack
$(boost)-patch: $($(boost)-prefix)/.pkgpatch
$(boost)-build: $($(boost)-prefix)/.pkgbuild
$(boost)-check: $($(boost)-prefix)/.pkgcheck
$(boost)-install: $($(boost)-prefix)/.pkginstall
$(boost)-modulefile: $($(boost)-modulefile)
$(boost)-clean:
	rm -rf $($(boost)-modulefile)
	rm -rf $($(boost)-prefix)
	rm -rf $($(boost)-srcdir)
$(boost): $(boost)-src $(boost)-unpack $(boost)-patch $(boost)-build $(boost)-check $(boost)-install $(boost)-modulefile
