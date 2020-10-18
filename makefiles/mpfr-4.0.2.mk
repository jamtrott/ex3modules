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
# mpfr-4.0.2

mpfr-version = 4.0.2
mpfr = mpfr-$(mpfr-version)
$(mpfr)-description = C library for multiple-precision floating-point computations
$(mpfr)-url = https://www.mpfr.org/
$(mpfr)-srcurl = https://ftp.gnu.org/gnu/mpfr/mpfr-$(mpfr-version).tar.gz
$(mpfr)-src = $(pkgsrcdir)/$(notdir $($(mpfr)-srcurl))
$(mpfr)-srcdir = $(pkgsrcdir)/$(mpfr)
$(mpfr)-builddeps = $(gmp)
$(mpfr)-prereqs = $(gmp)
$(mpfr)-modulefile = $(modulefilesdir)/$(mpfr)
$(mpfr)-prefix = $(pkgdir)/$(mpfr)

$($(mpfr)-src): $(dir $($(mpfr)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mpfr)-srcurl)

$($(mpfr)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(mpfr)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(mpfr)-prefix)/.pkgunpack: $($(mpfr)-src) $($(mpfr)-srcdir)/.markerfile $($(mpfr)-prefix)/.markerfile
	tar -C $($(mpfr)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mpfr)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpfr)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpfr)-prefix)/.pkgunpack
	@touch $@

$($(mpfr)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpfr)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpfr)-prefix)/.pkgpatch
	cd $($(mpfr)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mpfr)-builddeps) && \
		./configure --prefix=$($(mpfr)-prefix) && \
		$(MAKE)
	@touch $@

$($(mpfr)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpfr)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpfr)-prefix)/.pkgbuild
	cd $($(mpfr)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mpfr)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(mpfr)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpfr)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpfr)-prefix)/.pkgcheck
	$(MAKE) -C $($(mpfr)-srcdir) install
	@touch $@

$($(mpfr)-modulefile): $(modulefilesdir)/.markerfile $($(mpfr)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mpfr)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mpfr)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mpfr)-description)\"" >>$@
	echo "module-whatis \"$($(mpfr)-url)\"" >>$@
	printf "$(foreach prereq,$($(mpfr)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MPFR_ROOT $($(mpfr)-prefix)" >>$@
	echo "setenv MPFR_INCDIR $($(mpfr)-prefix)/include" >>$@
	echo "setenv MPFR_INCLUDEDIR $($(mpfr)-prefix)/include" >>$@
	echo "setenv MPFR_LIBDIR $($(mpfr)-prefix)/lib" >>$@
	echo "setenv MPFR_LIBRARYDIR $($(mpfr)-prefix)/lib" >>$@
	echo "setenv MPFRDIR $($(mpfr)-prefix)" >>$@
	echo "setenv MPFRLIB $($(mpfr)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(mpfr)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mpfr)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mpfr)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mpfr)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mpfr)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(mpfr)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path INFOPATH $($(mpfr)-prefix)/share/info" >>$@
	echo "set MSG \"$(mpfr)\"" >>$@

$(mpfr)-src: $($(mpfr)-src)
$(mpfr)-unpack: $($(mpfr)-prefix)/.pkgunpack
$(mpfr)-patch: $($(mpfr)-prefix)/.pkgpatch
$(mpfr)-build: $($(mpfr)-prefix)/.pkgbuild
$(mpfr)-check: $($(mpfr)-prefix)/.pkgcheck
$(mpfr)-install: $($(mpfr)-prefix)/.pkginstall
$(mpfr)-modulefile: $($(mpfr)-modulefile)
$(mpfr)-clean:
	rm -rf $($(mpfr)-modulefile)
	rm -rf $($(mpfr)-prefix)
	rm -rf $($(mpfr)-srcdir)
	rm -rf $($(mpfr)-src)
$(mpfr): $(mpfr)-src $(mpfr)-unpack $(mpfr)-patch $(mpfr)-build $(mpfr)-check $(mpfr)-install $(mpfr)-modulefile
