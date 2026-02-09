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
# everybeam-0.8.0

everybeam-version = 0.8.0
everybeam = everybeam-$(everybeam-version)
$(everybeam)-description = Library to compute beam responses for a variety of radio telescopes
$(everybeam)-url = https://git.astron.nl/RD/EveryBeam
$(everybeam)-srcurl = https://git.astron.nl/RD/EveryBeam/-/archive/v0.8.0/EveryBeam-v0.8.0.tar.gz
$(everybeam)-builddeps = $(cmake) $(casacore) $(gsl) $(fftw) $(hdf5) $(blas) $(libxml2) $(python) $(eigen)
$(everybeam)-prereqs = $(casacore) $(gsl) $(fftw) $(hdf5) $(blas) $(libxml2) $(python)
$(everybeam)-src = $(pkgsrcdir)/$(notdir $($(everybeam)-srcurl))
$(everybeam)-srcdir = $(pkgsrcdir)/$(everybeam)
$(everybeam)-builddir = $($(everybeam)-srcdir)/build
$(everybeam)-modulefile = $(modulefilesdir)/$(everybeam)
$(everybeam)-prefix = $(pkgdir)/$(everybeam)

$($(everybeam)-src): $(dir $($(everybeam)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(everybeam)-srcurl)

$($(everybeam)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(everybeam)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(everybeam)-prefix)/.pkgunpack: $$($(everybeam)-src) $($(everybeam)-srcdir)/.markerfile $($(everybeam)-prefix)/.markerfile $$(foreach dep,$$($(everybeam)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(everybeam)-srcdir) --strip-components 1 -xz -f $<
	rmdir $($(everybeam)-srcdir)/external/eigen
	ln -s $($(eigen)-srcdir) $($(everybeam)-srcdir)/external/eigen
	git clone https://gitlab.com/aroffringa/aocommon.git $($(everybeam)-srcdir)/external/aocommon && \
	    cd $($(everybeam)-srcdir)/external/aocommon && \
	    git checkout 7120f199
	git clone https://git.astron.nl/RD/schaapcommon.git $($(everybeam)-srcdir)/external/schaapcommon && \
	    cd $($(everybeam)-srcdir)/external/schaapcommon && \
	    git checkout 3d5fcfaf
	git clone https://github.com/pybind/pybind11 $($(everybeam)-srcdir)/external/pybind11 && \
	    cd $($(everybeam)-srcdir)/external/pybind11 && \
	    git checkout 741d86f2
	@touch $@

$($(everybeam)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(everybeam)-builddeps),$(modulefilesdir)/$$(dep)) $($(everybeam)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(everybeam)-builddir),$($(everybeam)-srcdir))
$($(everybeam)-builddir)/.markerfile: $($(everybeam)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(everybeam)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(everybeam)-builddeps),$(modulefilesdir)/$$(dep)) $($(everybeam)-builddir)/.markerfile $($(everybeam)-prefix)/.pkgpatch
	cd $($(everybeam)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(everybeam)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(everybeam)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DBUILD_WITH_PYTHON=ON \
			-DHDF5_INCLUDE_DIRS="$${HDF5_INCDIR}" \
			-DCASACORE_ROOT_DIR="$${CASACORE_ROOT}" && \
		$(MAKE)
	@touch $@

$($(everybeam)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(everybeam)-builddeps),$(modulefilesdir)/$$(dep)) $($(everybeam)-builddir)/.markerfile $($(everybeam)-prefix)/.pkgbuild
	@touch $@

$($(everybeam)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(everybeam)-builddeps),$(modulefilesdir)/$$(dep)) $($(everybeam)-builddir)/.markerfile $($(everybeam)-prefix)/.pkgcheck
	cd $($(everybeam)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(everybeam)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(everybeam)-modulefile): $(modulefilesdir)/.markerfile $($(everybeam)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(everybeam)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(everybeam)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(everybeam)-description)\"" >>$@
	echo "module-whatis \"$($(everybeam)-url)\"" >>$@
	printf "$(foreach prereq,$($(everybeam)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv EVERYBEAM_ROOT $($(everybeam)-prefix)" >>$@
	echo "setenv EVERYBEAM_INCDIR $($(everybeam)-prefix)/include" >>$@
	echo "setenv EVERYBEAM_INCLUDEDIR $($(everybeam)-prefix)/include" >>$@
	echo "setenv EVERYBEAM_LIBDIR $($(everybeam)-prefix)/lib" >>$@
	echo "setenv EVERYBEAM_LIBRARYDIR $($(everybeam)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(everybeam)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(everybeam)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(everybeam)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(everybeam)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(everybeam)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(everybeam)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(everybeam)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(everybeam)-prefix)/share/info" >>$@
	echo "set MSG \"$(everybeam)\"" >>$@

$(everybeam)-src: $$($(everybeam)-src)
$(everybeam)-unpack: $($(everybeam)-prefix)/.pkgunpack
$(everybeam)-patch: $($(everybeam)-prefix)/.pkgpatch
$(everybeam)-build: $($(everybeam)-prefix)/.pkgbuild
$(everybeam)-check: $($(everybeam)-prefix)/.pkgcheck
$(everybeam)-install: $($(everybeam)-prefix)/.pkginstall
$(everybeam)-modulefile: $($(everybeam)-modulefile)
$(everybeam)-clean:
	rm -rf $($(everybeam)-modulefile)
	rm -rf $($(everybeam)-prefix)
	rm -rf $($(everybeam)-builddir)
	rm -rf $($(everybeam)-srcdir)
	rm -rf $($(everybeam)-src)
$(everybeam): $(everybeam)-src $(everybeam)-unpack $(everybeam)-patch $(everybeam)-build $(everybeam)-check $(everybeam)-install $(everybeam)-modulefile
