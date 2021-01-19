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
# boost-mpi-1.73.0

boost-mpi-version = 1.73.0
boost-mpi = boost-mpi-$(boost-mpi-version)
$(boost-mpi)-description = C++ interface library for MPI
$(boost-mpi)-url = https://www.boost.org/
$(boost-mpi)-srcurl =
$(boost-mpi)-builddeps = $(gcc-10.1.0) $(python) $(mpi)
$(boost-mpi)-prereqs = $(mpi)
$(boost-mpi)-src = $($(boost-src)-src)
$(boost-mpi)-srcdir = $(pkgsrcdir)/$(boost-mpi)
$(boost-mpi)-modulefile = $(modulefilesdir)/$(boost-mpi)
$(boost-mpi)-prefix = $(pkgdir)/$(boost-mpi)

$($(boost-mpi)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(boost-mpi)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(boost-mpi)-prefix)/.pkgunpack: $$($(boost-mpi)-src) $($(boost-mpi)-srcdir)/.markerfile $($(boost-mpi)-prefix)/.markerfile
	tar -C $($(boost-mpi)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(boost-mpi)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-mpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-mpi)-prefix)/.pkgunpack
	@touch $@

$($(boost-mpi)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-mpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-mpi)-prefix)/.pkgpatch
	cd $($(boost-mpi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost-mpi)-builddeps) && \
		./bootstrap.sh --prefix=$($(boost-mpi)-prefix) \
			 --with-toolset=gcc \
			--with-python=$${PYTHON_ROOT}/bin/python3 \
			--with-python-version=$${PYTHON_VERSION_SHORT} \
			--with-python-root=$${PYTHON_ROOT} && \
		echo "using mpi ;" >>project-config.jam && \
		./b2 --toolset=gcc-10.1 --with-mpi
	@touch $@

$($(boost-mpi)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-mpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-mpi)-prefix)/.pkgbuild
	@touch $@

$($(boost-mpi)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(boost-mpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(boost-mpi)-prefix)/.pkgcheck
	cd $($(boost-mpi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(boost-mpi)-builddeps) && \
		./b2 --toolset=gcc-10.1 --with-mpi install
	@touch $@

$($(boost-mpi)-modulefile): $(modulefilesdir)/.markerfile $($(boost-mpi)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(boost-mpi)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(boost-mpi)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(boost-mpi)-description)\"" >>$@
	echo "module-whatis \"$($(boost-mpi)-url)\"" >>$@
	printf "$(foreach prereq,$($(boost-mpi)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BOOST_MPI_ROOT $($(boost-mpi)-prefix)" >>$@
	echo "setenv BOOST_MPI_INCDIR $($(boost-mpi)-prefix)/include" >>$@
	echo "setenv BOOST_MPI_INCLUDEDIR $($(boost-mpi)-prefix)/include" >>$@
	echo "setenv BOOST_MPI_LIBDIR $($(boost-mpi)-prefix)/lib" >>$@
	echo "setenv BOOST_MPI_LIBRARYDIR $($(boost-mpi)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(boost-mpi)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(boost-mpi)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(boost-mpi)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(boost-mpi)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(boost-mpi)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(boost-mpi)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(boost-mpi)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(boost-mpi)-prefix)/share/info" >>$@
	echo "set MSG \"$(boost-mpi)\"" >>$@

$(boost-mpi)-src: $$($(boost-mpi)-src)
$(boost-mpi)-unpack: $($(boost-mpi)-prefix)/.pkgunpack
$(boost-mpi)-patch: $($(boost-mpi)-prefix)/.pkgpatch
$(boost-mpi)-build: $($(boost-mpi)-prefix)/.pkgbuild
$(boost-mpi)-check: $($(boost-mpi)-prefix)/.pkgcheck
$(boost-mpi)-install: $($(boost-mpi)-prefix)/.pkginstall
$(boost-mpi)-modulefile: $($(boost-mpi)-modulefile)
$(boost-mpi)-clean:
	rm -rf $($(boost-mpi)-modulefile)
	rm -rf $($(boost-mpi)-prefix)
	rm -rf $($(boost-mpi)-srcdir)
$(boost-mpi): $(boost-mpi)-src $(boost-mpi)-unpack $(boost-mpi)-patch $(boost-mpi)-build $(boost-mpi)-check $(boost-mpi)-install $(boost-mpi)-modulefile
