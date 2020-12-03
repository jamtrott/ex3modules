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
# fftw-3.3.8

fftw-version = 3.3.8
fftw = fftw-$(fftw-version)
$(fftw)-description = C library for computing the discrete Fourier transform (DFT)
$(fftw)-url = http://fftw.org/
$(fftw)-srcurl = http://fftw.org/fftw-$(fftw-version).tar.gz
$(fftw)-builddeps =
$(fftw)-prereqs =
$(fftw)-src = $(pkgsrcdir)/$(notdir $($(fftw)-srcurl))
$(fftw)-srcdir = $(pkgsrcdir)/$(fftw)
$(fftw)-builddir = $($(fftw)-srcdir)
$(fftw)-modulefile = $(modulefilesdir)/$(fftw)
$(fftw)-prefix = $(pkgdir)/$(fftw)

$($(fftw)-src): $(dir $($(fftw)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fftw)-srcurl)

$($(fftw)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fftw)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(fftw)-prefix)/.pkgunpack: $$($(fftw)-src) $($(fftw)-srcdir)/.markerfile $($(fftw)-prefix)/.markerfile
	tar -C $($(fftw)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(fftw)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fftw)-builddeps),$(modulefilesdir)/$$(dep)) $($(fftw)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(fftw)-builddir),$($(fftw)-srcdir))
$($(fftw)-builddir)/.markerfile: $($(fftw)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(fftw)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fftw)-builddeps),$(modulefilesdir)/$$(dep)) $($(fftw)-builddir)/.markerfile $($(fftw)-prefix)/.pkgpatch
	cd $($(fftw)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fftw)-builddeps) && \
		./configure --prefix=$($(fftw)-prefix) && \
		$(MAKE)
	@touch $@

$($(fftw)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fftw)-builddeps),$(modulefilesdir)/$$(dep)) $($(fftw)-builddir)/.markerfile $($(fftw)-prefix)/.pkgbuild
	cd $($(fftw)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fftw)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(fftw)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(fftw)-builddeps),$(modulefilesdir)/$$(dep)) $($(fftw)-builddir)/.markerfile $($(fftw)-prefix)/.pkgcheck
	cd $($(fftw)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(fftw)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(fftw)-modulefile): $(modulefilesdir)/.markerfile $($(fftw)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(fftw)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(fftw)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(fftw)-description)\"" >>$@
	echo "module-whatis \"$($(fftw)-url)\"" >>$@
	printf "$(foreach prereq,$($(fftw)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv FFTW_ROOT $($(fftw)-prefix)" >>$@
	echo "setenv FFTW_INCDIR $($(fftw)-prefix)/include" >>$@
	echo "setenv FFTW_INCLUDEDIR $($(fftw)-prefix)/include" >>$@
	echo "setenv FFTW_LIBDIR $($(fftw)-prefix)/lib" >>$@
	echo "setenv FFTW_LIBRARYDIR $($(fftw)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(fftw)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(fftw)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(fftw)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(fftw)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(fftw)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(fftw)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(fftw)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(fftw)-prefix)/share/info" >>$@
	echo "set MSG \"$(fftw)\"" >>$@

$(fftw)-src: $$($(fftw)-src)
$(fftw)-unpack: $($(fftw)-prefix)/.pkgunpack
$(fftw)-patch: $($(fftw)-prefix)/.pkgpatch
$(fftw)-build: $($(fftw)-prefix)/.pkgbuild
$(fftw)-check: $($(fftw)-prefix)/.pkgcheck
$(fftw)-install: $($(fftw)-prefix)/.pkginstall
$(fftw)-modulefile: $($(fftw)-modulefile)
$(fftw)-clean:
	rm -rf $($(fftw)-modulefile)
	rm -rf $($(fftw)-prefix)
	rm -rf $($(fftw)-srcdir)
	rm -rf $($(fftw)-src)
$(fftw): $(fftw)-src $(fftw)-unpack $(fftw)-patch $(fftw)-build $(fftw)-check $(fftw)-install $(fftw)-modulefile
