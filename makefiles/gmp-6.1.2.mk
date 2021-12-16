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
# gmp-6.1.2

gmp-version = 6.1.2
gmp = gmp-$(gmp-version)
$(gmp)-description = Library for arbitrary precision arithmetic
$(gmp)-url = https://gmplib.org/
$(gmp)-srcurl = https://gmplib.org/download/gmp/gmp-$(gmp-version).tar.xz
$(gmp)-src = $(pkgsrcdir)/$(notdir $($(gmp)-srcurl))
$(gmp)-srcdir = $(pkgsrcdir)/$(gmp)
$(gmp)-builddeps =
$(gmp)-prereqs =
$(gmp)-modulefile = $(modulefilesdir)/$(gmp)
$(gmp)-prefix = $(pkgdir)/$(gmp)

$($(gmp)-src): $(dir $($(gmp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gmp)-srcurl)

$($(gmp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gmp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gmp)-prefix)/.pkgunpack: $($(gmp)-src) $($(gmp)-srcdir)/.markerfile $($(gmp)-prefix)/.markerfile $$(foreach dep,$$($(gmp)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(gmp)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(gmp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gmp)-builddeps),$(modulefilesdir)/$$(dep)) $($(gmp)-prefix)/.pkgunpack
	@touch $@

$($(gmp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gmp)-builddeps),$(modulefilesdir)/$$(dep)) $($(gmp)-prefix)/.pkgpatch
	cd $($(gmp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gmp)-builddeps) && \
		./configure --prefix=$($(gmp)-prefix) && \
		$(MAKE)
	@touch $@

$($(gmp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gmp)-builddeps),$(modulefilesdir)/$$(dep)) $($(gmp)-prefix)/.pkgbuild
	cd $($(gmp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gmp)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(gmp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gmp)-builddeps),$(modulefilesdir)/$$(dep)) $($(gmp)-prefix)/.pkgcheck
	$(MAKE) -C $($(gmp)-srcdir) install
	@touch $@

$($(gmp)-modulefile): $(modulefilesdir)/.markerfile $($(gmp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gmp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gmp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gmp)-description)\"" >>$@
	echo "module-whatis \"$($(gmp)-url)\"" >>$@
	printf "$(foreach prereq,$($(gmp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GMP_ROOT $($(gmp)-prefix)" >>$@
	echo "setenv GMP_INCDIR $($(gmp)-prefix)/include" >>$@
	echo "setenv GMP_INCLUDEDIR $($(gmp)-prefix)/include" >>$@
	echo "setenv GMP_LIBDIR $($(gmp)-prefix)/lib" >>$@
	echo "setenv GMP_LIBRARYDIR $($(gmp)-prefix)/lib" >>$@
	echo "setenv GMPDIR $($(gmp)-prefix)" >>$@
	echo "setenv GMPLIB $($(gmp)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(gmp)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gmp)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gmp)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gmp)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gmp)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(gmp)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(gmp)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gmp)-prefix)/share/info" >>$@
	echo "set MSG \"$(gmp)\"" >>$@

$(gmp)-src: $($(gmp)-src)
$(gmp)-unpack: $($(gmp)-prefix)/.pkgunpack
$(gmp)-patch: $($(gmp)-prefix)/.pkgpatch
$(gmp)-build: $($(gmp)-prefix)/.pkgbuild
$(gmp)-check: $($(gmp)-prefix)/.pkgcheck
$(gmp)-install: $($(gmp)-prefix)/.pkginstall
$(gmp)-modulefile: $($(gmp)-modulefile)
$(gmp)-clean:
	rm -rf $($(gmp)-modulefile)
	rm -rf $($(gmp)-prefix)
	rm -rf $($(gmp)-srcdir)
	rm -rf $($(gmp)-src)
$(gmp): $(gmp)-src $(gmp)-unpack $(gmp)-patch $(gmp)-build $(gmp)-check $(gmp)-install $(gmp)-modulefile
