# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# libatomic_ops-7.6.10

libatomic_ops-version = 7.6.10
libatomic_ops = libatomic_ops-$(libatomic_ops-version)
$(libatomic_ops)-description = Hardware-provided atomic memory update operations on a number of architectures
$(libatomic_ops)-url = https://github.com/ivmai/libatomic_ops/
$(libatomic_ops)-srcurl = https://github.com/ivmai/libatomic_ops/releases/download/v7.6.10/libatomic_ops-7.6.10.tar.gz
$(libatomic_ops)-builddeps =
$(libatomic_ops)-prereqs =
$(libatomic_ops)-src = $(pkgsrcdir)/$(notdir $($(libatomic_ops)-srcurl))
$(libatomic_ops)-srcdir = $(pkgsrcdir)/$(libatomic_ops)
$(libatomic_ops)-builddir = $($(libatomic_ops)-srcdir)
$(libatomic_ops)-modulefile = $(modulefilesdir)/$(libatomic_ops)
$(libatomic_ops)-prefix = $(pkgdir)/$(libatomic_ops)

$($(libatomic_ops)-src): $(dir $($(libatomic_ops)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libatomic_ops)-srcurl)

$($(libatomic_ops)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libatomic_ops)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libatomic_ops)-prefix)/.pkgunpack: $$($(libatomic_ops)-src) $($(libatomic_ops)-srcdir)/.markerfile $($(libatomic_ops)-prefix)/.markerfile $$(foreach dep,$$($(libatomic_ops)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libatomic_ops)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libatomic_ops)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libatomic_ops)-builddeps),$(modulefilesdir)/$$(dep)) $($(libatomic_ops)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libatomic_ops)-builddir),$($(libatomic_ops)-srcdir))
$($(libatomic_ops)-builddir)/.markerfile: $($(libatomic_ops)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libatomic_ops)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libatomic_ops)-builddeps),$(modulefilesdir)/$$(dep)) $($(libatomic_ops)-builddir)/.markerfile $($(libatomic_ops)-prefix)/.pkgpatch
	cd $($(libatomic_ops)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libatomic_ops)-builddeps) && \
		./configure --prefix=$($(libatomic_ops)-prefix) \
			--enable-shared \
			--disable-static \
			--docdir=$($(libatomic_ops)-prefix)/share/doc && \
		$(MAKE)
	@touch $@

$($(libatomic_ops)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libatomic_ops)-builddeps),$(modulefilesdir)/$$(dep)) $($(libatomic_ops)-builddir)/.markerfile $($(libatomic_ops)-prefix)/.pkgbuild
	@touch $@

$($(libatomic_ops)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libatomic_ops)-builddeps),$(modulefilesdir)/$$(dep)) $($(libatomic_ops)-builddir)/.markerfile $($(libatomic_ops)-prefix)/.pkgcheck
	cd $($(libatomic_ops)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libatomic_ops)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libatomic_ops)-modulefile): $(modulefilesdir)/.markerfile $($(libatomic_ops)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libatomic_ops)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libatomic_ops)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libatomic_ops)-description)\"" >>$@
	echo "module-whatis \"$($(libatomic_ops)-url)\"" >>$@
	printf "$(foreach prereq,$($(libatomic_ops)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBATOMIC_OPS_ROOT $($(libatomic_ops)-prefix)" >>$@
	echo "setenv LIBATOMIC_OPS_INCDIR $($(libatomic_ops)-prefix)/include" >>$@
	echo "setenv LIBATOMIC_OPS_INCLUDEDIR $($(libatomic_ops)-prefix)/include" >>$@
	echo "setenv LIBATOMIC_OPS_LIBDIR $($(libatomic_ops)-prefix)/lib" >>$@
	echo "setenv LIBATOMIC_OPS_LIBRARYDIR $($(libatomic_ops)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libatomic_ops)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libatomic_ops)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libatomic_ops)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libatomic_ops)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libatomic_ops)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(libatomic_ops)\"" >>$@

$(libatomic_ops)-src: $$($(libatomic_ops)-src)
$(libatomic_ops)-unpack: $($(libatomic_ops)-prefix)/.pkgunpack
$(libatomic_ops)-patch: $($(libatomic_ops)-prefix)/.pkgpatch
$(libatomic_ops)-build: $($(libatomic_ops)-prefix)/.pkgbuild
$(libatomic_ops)-check: $($(libatomic_ops)-prefix)/.pkgcheck
$(libatomic_ops)-install: $($(libatomic_ops)-prefix)/.pkginstall
$(libatomic_ops)-modulefile: $($(libatomic_ops)-modulefile)
$(libatomic_ops)-clean:
	rm -rf $($(libatomic_ops)-modulefile)
	rm -rf $($(libatomic_ops)-prefix)
	rm -rf $($(libatomic_ops)-builddir)
	rm -rf $($(libatomic_ops)-srcdir)
	rm -rf $($(libatomic_ops)-src)
$(libatomic_ops): $(libatomic_ops)-src $(libatomic_ops)-unpack $(libatomic_ops)-patch $(libatomic_ops)-build $(libatomic_ops)-check $(libatomic_ops)-install $(libatomic_ops)-modulefile
