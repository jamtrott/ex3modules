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
# blis-generic-0.7.0

blis-generic-version = 0.7.0
blis-generic = blis-generic-$(blis-generic-version)
$(blis-generic)-description = High-performance BLAS for generic CPUs
$(blis-generic)-url = https://github.com/flame/blis
$(blis-generic)-srcurl =
$(blis-generic)-builddeps = $(gfortran)
$(blis-generic)-prereqs =
$(blis-generic)-src =  $($(blis-src)-src)
$(blis-generic)-srcdir = $(pkgsrcdir)/$(blis-generic)
$(blis-generic)-builddir = $($(blis-generic)-srcdir)
$(blis-generic)-modulefile = $(modulefilesdir)/$(blis-generic)
$(blis-generic)-prefix = $(pkgdir)/$(blis-generic)

$($(blis-generic)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-generic)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(blis-generic)-prefix)/.pkgunpack: $$($(blis-generic)-src) $($(blis-generic)-srcdir)/.markerfile $($(blis-generic)-prefix)/.markerfile $$(foreach dep,$$($(blis-generic)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(blis-generic)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(blis-generic)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-generic)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-generic)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(blis-generic)-builddir),$($(blis-generic)-srcdir))
$($(blis-generic)-builddir)/.markerfile: $($(blis-generic)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(blis-generic)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-generic)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-generic)-builddir)/.markerfile $($(blis-generic)-prefix)/.pkgpatch
	cd $($(blis-generic)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-generic)-builddeps) && \
		./configure --prefix=$($(blis-generic)-prefix) generic && \
		$(MAKE)
	@touch $@

$($(blis-generic)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-generic)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-generic)-builddir)/.markerfile $($(blis-generic)-prefix)/.pkgbuild
	cd $($(blis-generic)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-generic)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(blis-generic)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(blis-generic)-builddeps),$(modulefilesdir)/$$(dep)) $($(blis-generic)-builddir)/.markerfile $($(blis-generic)-prefix)/.pkgcheck
	cd $($(blis-generic)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(blis-generic)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(blis-generic)-modulefile): $(modulefilesdir)/.markerfile $($(blis-generic)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(blis-generic)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(blis-generic)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(blis-generic)-description)\"" >>$@
	echo "module-whatis \"$($(blis-generic)-url)\"" >>$@
	printf "$(foreach prereq,$($(blis-generic)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv BLIS_ROOT $($(blis-generic)-prefix)" >>$@
	echo "setenv BLIS_INCDIR $($(blis-generic)-prefix)/include" >>$@
	echo "setenv BLIS_INCLUDEDIR $($(blis-generic)-prefix)/include" >>$@
	echo "setenv BLIS_LIBDIR $($(blis-generic)-prefix)/lib" >>$@
	echo "setenv BLIS_LIBRARYDIR $($(blis-generic)-prefix)/lib" >>$@
	echo "setenv BLASDIR $($(blis-generic)-prefix)/lib" >>$@
	echo "setenv BLASLIB blis" >>$@
	echo "prepend-path PATH $($(blis-generic)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(blis-generic)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(blis-generic)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(blis-generic)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(blis-generic)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(blis-generic)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(blis-generic)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(blis-generic)-prefix)/share/info" >>$@
	echo "set MSG \"$(blis-generic)\"" >>$@

$(blis-generic)-src: $$($(blis-generic)-src)
$(blis-generic)-unpack: $($(blis-generic)-prefix)/.pkgunpack
$(blis-generic)-patch: $($(blis-generic)-prefix)/.pkgpatch
$(blis-generic)-build: $($(blis-generic)-prefix)/.pkgbuild
$(blis-generic)-check: $($(blis-generic)-prefix)/.pkgcheck
$(blis-generic)-install: $($(blis-generic)-prefix)/.pkginstall
$(blis-generic)-modulefile: $($(blis-generic)-modulefile)
$(blis-generic)-clean:
	rm -rf $($(blis-generic)-modulefile)
	rm -rf $($(blis-generic)-prefix)
	rm -rf $($(blis-generic)-srcdir)
$(blis-generic): $(blis-generic)-src $(blis-generic)-unpack $(blis-generic)-patch $(blis-generic)-build $(blis-generic)-check $(blis-generic)-install $(blis-generic)-modulefile
