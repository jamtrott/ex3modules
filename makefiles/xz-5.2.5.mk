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
# xz-5.2.5

xz-version = 5.2.5
xz = xz-$(xz-version)
$(xz)-description = General-purpose data compression software with a high compression ratio
$(xz)-url = https://tukaani.org/xz/
$(xz)-srcurl = https://download.sourceforge.net/lzmautils/xz-$(xz-version).tar.gz
$(xz)-src = $(pkgsrcdir)/$(xz).tar.gz
$(xz)-srcdir = $(pkgsrcdir)/$(xz)
$(xz)-builddeps =
$(xz)-prereqs =
$(xz)-modulefile = $(modulefilesdir)/$(xz)
$(xz)-prefix = $(pkgdir)/$(xz)

$($(xz)-src): $(dir $($(xz)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(xz)-srcurl)

$($(xz)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xz)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(xz)-prefix)/.pkgunpack: $($(xz)-src) $($(xz)-srcdir)/.markerfile $($(xz)-prefix)/.markerfile
	tar -C $($(xz)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(xz)-srcdir)/0001-compat-libs.patch: $($(xz)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'We provided two 5.1.2alpha symbols (lzma_stream_encoder_mt and' >>$@.tmp
	@echo 'lzma_stream_encoder_mt_memusage) before we updated to xz-5.2.2-1 in RHEL7.3.' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'Those symbols did not change ABI in 5.2.2 so it should be safe to provide' >>$@.tmp
	@echo '(except for 5.0 and 5.2 symbols) also the two 5.1.2alpha symbols and' >>$@.tmp
	@echo 'use 5.1.2alpha symbol version as parent for 5.2.' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'For better reasoning look at container.h in 5.1.2alpha -- those two symbols' >>$@.tmp
	@echo 'were for testing purposes only, and thus not considered to be API/ABI.' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/src/liblzma/liblzma.map b/src/liblzma/liblzma.map' >>$@.tmp
	@echo 'index f53a4ea..9c3002a 100644' >>$@.tmp
	@echo '--- a/src/liblzma/liblzma.map' >>$@.tmp
	@echo '+++ b/src/liblzma/liblzma.map' >>$@.tmp
	@echo '@@ -95,7 +95,13 @@ global:' >>$@.tmp
	@echo '   lzma_vli_size;' >>$@.tmp
	@echo ' };' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-XZ_5.2 {' >>$@.tmp
	@echo '+XZ_5.1.2alpha {' >>$@.tmp
	@echo '+global:' >>$@.tmp
	@echo '+	lzma_stream_encoder_mt;' >>$@.tmp
	@echo '+	lzma_stream_encoder_mt_memusage;' >>$@.tmp
	@echo '+} XZ_5.0;' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+XZ_5.2.2 {' >>$@.tmp
	@echo ' global:' >>$@.tmp
	@echo '	lzma_block_uncomp_encode;' >>$@.tmp
	@echo ' 	lzma_cputhreads;' >>$@.tmp
	@echo '@@ -105,4 +111,4 @@ global:' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo ' local:' >>$@.tmp
	@echo '	*;' >>$@.tmp
	@echo '-} XZ_5.0;' >>$@.tmp
	@echo '+} XZ_5.1.2alpha;' >>$@.tmp
	@mv $@.tmp $@

$($(xz)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xz)-builddeps),$(modulefilesdir)/$$(dep)) $($(xz)-prefix)/.pkgunpack
$($(xz)-prefix)/.pkgpatch: $($(xz)-srcdir)/0001-compat-libs.patch
	cd $($(xz)-srcdir) && patch -t -p1 <0001-compat-libs.patch
	@touch $@

$($(xz)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xz)-builddeps),$(modulefilesdir)/$$(dep)) $($(xz)-prefix)/.pkgpatch
	cd $($(xz)-srcdir) && \
		./configure --prefix=$($(xz)-prefix) && \
		$(MAKE)
	@touch $@

$($(xz)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xz)-builddeps),$(modulefilesdir)/$$(dep)) $($(xz)-prefix)/.pkgbuild
	$(MAKE) -C $($(xz)-srcdir) check
	@touch $@

$($(xz)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(xz)-builddeps),$(modulefilesdir)/$$(dep)) $($(xz)-prefix)/.pkgcheck
	$(MAKE) -C $($(xz)-srcdir) install
	@touch $@

$($(xz)-modulefile): $(modulefilesdir)/.markerfile $($(xz)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(xz)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(xz)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(xz)-description)\"" >>$@
	echo "module-whatis \"$($(xz)-url)\"" >>$@
	echo "" >>$@
	echo "$(foreach prereq,$($(xz)-prereqs),$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "setenv XZ_ROOT $($(xz)-prefix)" >>$@
	echo "setenv XZ_INCDIR $($(xz)-prefix)/include" >>$@
	echo "setenv XZ_INCLUDEDIR $($(xz)-prefix)/include" >>$@
	echo "setenv XZ_LIBDIR $($(xz)-prefix)/lib" >>$@
	echo "setenv XZ_LIBRARYDIR $($(xz)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(xz)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(xz)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(xz)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(xz)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(xz)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(xz)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(xz)-prefix)/share/man" >>$@
	echo "set MSG \"$(xz)\"" >>$@

$(xz)-src: $($(xz)-src)
$(xz)-unpack: $($(xz)-prefix)/.pkgunpack
$(xz)-patch: $($(xz)-prefix)/.pkgpatch
$(xz)-build: $($(xz)-prefix)/.pkgbuild
$(xz)-check: $($(xz)-prefix)/.pkgcheck
$(xz)-install: $($(xz)-prefix)/.pkginstall
$(xz)-modulefile: $($(xz)-modulefile)
$(xz)-clean:
	rm -rf $($(xz)-modulefile)
	rm -rf $($(xz)-prefix)
	rm -rf $($(xz)-srcdir)
	rm -rf $($(xz)-src)
$(xz): $(xz)-src $(xz)-unpack $(xz)-patch $(xz)-build $(xz)-check $(xz)-install $(xz)-modulefile
