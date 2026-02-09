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
# casacore-3.7.1

casacore-version = 3.7.1
casacore = casacore-$(casacore-version)
$(casacore)-description =  Suite of C++ libraries for radio astronomy data processing 
$(casacore)-url = https://github.com/casacore/casacore
$(casacore)-srcurl = https://github.com/casacore/casacore/archive/refs/tags/v3.7.1.tar.gz
$(casacore)-builddeps = $(cmake) $(bison) $(flex) $(blas) $(cfitsio) $(wcslib) $(gsl) $(fftw) $(hdf5) $(boost-python) $(python) $(python-numpy) $(ncurses)
$(casacore)-prereqs = $(blas) $(cfitsio) $(wcslib) $(fftw) $(gsl) $(hdf5) $(python) $(boost-python) $(python-numpy) $(ncurses)
$(casacore)-src = $(pkgsrcdir)/casacore-$(notdir $($(casacore)-srcurl))
$(casacore)-srcdir = $(pkgsrcdir)/$(casacore)
$(casacore)-builddir = $($(casacore)-srcdir)/build
$(casacore)-modulefile = $(modulefilesdir)/$(casacore)
$(casacore)-prefix = $(pkgdir)/$(casacore)

$($(casacore)-src): $(dir $($(casacore)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(casacore)-srcurl)

$($(casacore)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(casacore)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(casacore)-prefix)/.pkgunpack: $$($(casacore)-src) $($(casacore)-srcdir)/.markerfile $($(casacore)-prefix)/.markerfile $$(foreach dep,$$($(casacore)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(casacore)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(casacore)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(casacore)-builddeps),$(modulefilesdir)/$$(dep)) $($(casacore)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(casacore)-builddir),$($(casacore)-srcdir))
$($(casacore)-builddir)/.markerfile: $($(casacore)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(casacore)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(casacore)-builddeps),$(modulefilesdir)/$$(dep)) $($(casacore)-builddir)/.markerfile $($(casacore)-prefix)/.pkgpatch
	cd $($(casacore)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(casacore)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(casacore)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
                        -DBUILD_PYTHON3=YES -DPython3_EXECUTABLE="$${PYTHON_ROOT}/bin/python3" && \
		$(MAKE)
	@touch $@

$($(casacore)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(casacore)-builddeps),$(modulefilesdir)/$$(dep)) $($(casacore)-builddir)/.markerfile $($(casacore)-prefix)/.pkgbuild
	# cd $($(casacore)-builddir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(casacore)-builddeps) && \
	# 	$(MAKE) check
	@touch $@

$($(casacore)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(casacore)-builddeps),$(modulefilesdir)/$$(dep)) $($(casacore)-builddir)/.markerfile $($(casacore)-prefix)/.pkgcheck
	cd $($(casacore)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(casacore)-builddeps) && \
		$(MAKE) install
	mkdir -p $($(casacore)-prefix)/share/casacore/data
	wget 'ftp://ftp.astron.nl/outgoing/Measures/WSRT_Measures.ztar' --output-document=$($(casacore)-prefix)/share/casacore/data/WSRT_Measures.ztar
	tar -C $($(casacore)-prefix)/share/casacore/data -xz -f $($(casacore)-prefix)/share/casacore/data/WSRT_Measures.ztar
	@touch $@

$($(casacore)-modulefile): $(modulefilesdir)/.markerfile $($(casacore)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(casacore)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(casacore)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(casacore)-description)\"" >>$@
	echo "module-whatis \"$($(casacore)-url)\"" >>$@
	printf "$(foreach prereq,$($(casacore)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CASACORE_ROOT $($(casacore)-prefix)" >>$@
	echo "setenv CASACORE_INCDIR $($(casacore)-prefix)/include" >>$@
	echo "setenv CASACORE_INCLUDEDIR $($(casacore)-prefix)/include" >>$@
	echo "setenv CASACORE_LIBDIR $($(casacore)-prefix)/lib" >>$@
	echo "setenv CASACORE_LIBRARYDIR $($(casacore)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(casacore)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(casacore)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(casacore)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(casacore)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(casacore)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(casacore)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(casacore)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(casacore)-prefix)/share/info" >>$@
	echo "set MSG \"$(casacore)\"" >>$@

$(casacore)-src: $$($(casacore)-src)
$(casacore)-unpack: $($(casacore)-prefix)/.pkgunpack
$(casacore)-patch: $($(casacore)-prefix)/.pkgpatch
$(casacore)-build: $($(casacore)-prefix)/.pkgbuild
$(casacore)-check: $($(casacore)-prefix)/.pkgcheck
$(casacore)-install: $($(casacore)-prefix)/.pkginstall
$(casacore)-modulefile: $($(casacore)-modulefile)
$(casacore)-clean:
	rm -rf $($(casacore)-modulefile)
	rm -rf $($(casacore)-prefix)
	rm -rf $($(casacore)-builddir)
	rm -rf $($(casacore)-srcdir)
	rm -rf $($(casacore)-src)
$(casacore): $(casacore)-src $(casacore)-unpack $(casacore)-patch $(casacore)-build $(casacore)-check $(casacore)-install $(casacore)-modulefile
