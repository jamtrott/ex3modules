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
# mpc-1.1.0

mpc-version = 1.1.0
mpc = mpc-$(mpc-version)
$(mpc)-description = Library for arbitrary precision complex arithmetic with correct rounding
$(mpc)-url = http://www.multiprecision.org/mpc/
$(mpc)-srcurl = https://ftp.gnu.org/gnu/mpc/mpc-$(mpc-version).tar.gz
$(mpc)-src = $(pkgsrcdir)/$(notdir $($(mpc)-srcurl))
$(mpc)-srcdir = $(pkgsrcdir)/$(mpc)
$(mpc)-builddeps = $(gmp) $(mpfr)
$(mpc)-prereqs = $(gmp) $(mpfr)
$(mpc)-modulefile = $(modulefilesdir)/$(mpc)
$(mpc)-prefix = $(pkgdir)/$(mpc)

$($(mpc)-src): $(dir $($(mpc)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mpc)-srcurl)

$($(mpc)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mpc)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mpc)-prefix)/.pkgunpack: $($(mpc)-src) $($(mpc)-srcdir)/.markerfile $($(mpc)-prefix)/.markerfile
	tar -C $($(mpc)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mpc)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpc)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpc)-prefix)/.pkgunpack
	@touch $@

$($(mpc)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpc)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpc)-prefix)/.pkgpatch
	cd $($(mpc)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mpc)-builddeps) && \
		./configure --prefix=$($(mpc)-prefix) && \
		$(MAKE)
	@touch $@

$($(mpc)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpc)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpc)-prefix)/.pkgbuild
	cd $($(mpc)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mpc)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(mpc)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mpc)-builddeps),$(modulefilesdir)/$$(dep)) $($(mpc)-prefix)/.pkgcheck
	$(MAKE) -C $($(mpc)-srcdir) install
	@touch $@

$($(mpc)-modulefile): $(modulefilesdir)/.markerfile $($(mpc)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mpc)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mpc)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mpc)-description)\"" >>$@
	echo "module-whatis \"$($(mpc)-url)\"" >>$@
	printf "$(foreach prereq,$($(mpc)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MPC_ROOT $($(mpc)-prefix)" >>$@
	echo "setenv MPC_INCDIR $($(mpc)-prefix)/include" >>$@
	echo "setenv MPC_INCLUDEDIR $($(mpc)-prefix)/include" >>$@
	echo "setenv MPC_LIBDIR $($(mpc)-prefix)/lib" >>$@
	echo "setenv MPC_LIBRARYDIR $($(mpc)-prefix)/lib" >>$@
	echo "setenv MPCDIR $($(mpc)-prefix)" >>$@
	echo "setenv MPCLIB $($(mpc)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(mpc)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(mpc)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(mpc)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(mpc)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(mpc)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(mpc)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(mpc)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(mpc)-prefix)/share/info" >>$@
	echo "set MSG \"$(mpc)\"" >>$@

$(mpc)-src: $($(mpc)-src)
$(mpc)-unpack: $($(mpc)-prefix)/.pkgunpack
$(mpc)-patch: $($(mpc)-prefix)/.pkgpatch
$(mpc)-build: $($(mpc)-prefix)/.pkgbuild
$(mpc)-check: $($(mpc)-prefix)/.pkgcheck
$(mpc)-install: $($(mpc)-prefix)/.pkginstall
$(mpc)-modulefile: $($(mpc)-modulefile)
$(mpc)-clean:
	rm -rf $($(mpc)-modulefile)
	rm -rf $($(mpc)-prefix)
	rm -rf $($(mpc)-srcdir)
	rm -rf $($(mpc)-src)
$(mpc): $(mpc)-src $(mpc)-unpack $(mpc)-patch $(mpc)-build $(mpc)-check $(mpc)-install $(mpc)-modulefile
