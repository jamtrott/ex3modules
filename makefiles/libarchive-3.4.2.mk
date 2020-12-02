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
# libarchive-3.4.2

libarchive-version = 3.4.2
libarchive = libarchive-$(libarchive-version)
$(libarchive)-description = Multi-format archive and compression library
$(libarchive)-url = https://www.libarchive.org/
$(libarchive)-srcurl = https://www.libarchive.org/downloads/$(libarchive).tar.gz
$(libarchive)-builddeps =
$(libarchive)-prereqs =
$(libarchive)-src = $(pkgsrcdir)/$(notdir $($(libarchive)-srcurl))
$(libarchive)-srcdir = $(pkgsrcdir)/$(libarchive)
$(libarchive)-builddir = $($(libarchive)-srcdir)
$(libarchive)-modulefile = $(modulefilesdir)/$(libarchive)
$(libarchive)-prefix = $(pkgdir)/$(libarchive)

$($(libarchive)-src): $(dir $($(libarchive)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libarchive)-srcurl)

$($(libarchive)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libarchive)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libarchive)-prefix)/.pkgunpack: $($(libarchive)-src) $($(libarchive)-srcdir)/.markerfile $($(libarchive)-prefix)/.markerfile
	tar -C $($(libarchive)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libarchive)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libarchive)-builddeps),$(modulefilesdir)/$$(dep)) $($(libarchive)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libarchive)-builddir),$($(libarchive)-srcdir))
$($(libarchive)-builddir)/.markerfile: $($(libarchive)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(libarchive)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libarchive)-builddeps),$(modulefilesdir)/$$(dep)) $($(libarchive)-builddir)/.markerfile $($(libarchive)-prefix)/.pkgpatch
	cd $($(libarchive)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libarchive)-builddeps) && \
		./configure --prefix=$($(libarchive)-prefix) && \
		$(MAKE)
	@touch $@

$($(libarchive)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libarchive)-builddeps),$(modulefilesdir)/$$(dep)) $($(libarchive)-builddir)/.markerfile $($(libarchive)-prefix)/.pkgbuild
# 	cd $($(libarchive)-builddir) && \
# 		$(MODULESINIT) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(libarchive)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(libarchive)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libarchive)-builddeps),$(modulefilesdir)/$$(dep)) $($(libarchive)-builddir)/.markerfile $($(libarchive)-prefix)/.pkgcheck
	cd $($(libarchive)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libarchive)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libarchive)-modulefile): $(modulefilesdir)/.markerfile $($(libarchive)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libarchive)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libarchive)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libarchive)-description)\"" >>$@
	echo "module-whatis \"$($(libarchive)-url)\"" >>$@
	printf "$(foreach prereq,$($(libarchive)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBARCHIVE_ROOT $($(libarchive)-prefix)" >>$@
	echo "setenv LIBARCHIVE_INCDIR $($(libarchive)-prefix)/include" >>$@
	echo "setenv LIBARCHIVE_INCLUDEDIR $($(libarchive)-prefix)/include" >>$@
	echo "setenv LIBARCHIVE_LIBDIR $($(libarchive)-prefix)/lib" >>$@
	echo "setenv LIBARCHIVE_LIBRARYDIR $($(libarchive)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libarchive)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libarchive)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libarchive)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libarchive)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libarchive)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libarchive)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libarchive)-prefix)/share/man" >>$@
	echo "set MSG \"$(libarchive)\"" >>$@

$(libarchive)-src: $($(libarchive)-src)
$(libarchive)-unpack: $($(libarchive)-prefix)/.pkgunpack
$(libarchive)-patch: $($(libarchive)-prefix)/.pkgpatch
$(libarchive)-build: $($(libarchive)-prefix)/.pkgbuild
$(libarchive)-check: $($(libarchive)-prefix)/.pkgcheck
$(libarchive)-install: $($(libarchive)-prefix)/.pkginstall
$(libarchive)-modulefile: $($(libarchive)-modulefile)
$(libarchive)-clean:
	rm -rf $($(libarchive)-modulefile)
	rm -rf $($(libarchive)-prefix)
	rm -rf $($(libarchive)-srcdir)
	rm -rf $($(libarchive)-src)
$(libarchive): $(libarchive)-src $(libarchive)-unpack $(libarchive)-patch $(libarchive)-build $(libarchive)-check $(libarchive)-install $(libarchive)-modulefile
