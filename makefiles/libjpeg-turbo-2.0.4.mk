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
# libjpeg-turbo-2.0.4

libjpeg-turbo-version = 2.0.4
libjpeg-turbo = libjpeg-turbo-$(libjpeg-turbo-version)
$(libjpeg-turbo)-description = JPEG image codec that uses SIMD instructions
$(libjpeg-turbo)-url = https://libjpeg-turbo.org/
$(libjpeg-turbo)-srcurl = https://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-$(libjpeg-turbo-version).tar.gz
$(libjpeg-turbo)-src = $(pkgsrcdir)/$(notdir $($(libjpeg-turbo)-srcurl))
$(libjpeg-turbo)-srcdir = $(pkgsrcdir)/$(libjpeg-turbo)
$(libjpeg-turbo)-builddeps = $(cmake) $(nasm)
$(libjpeg-turbo)-prereqs =
$(libjpeg-turbo)-modulefile = $(modulefilesdir)/$(libjpeg-turbo)
$(libjpeg-turbo)-prefix = $(pkgdir)/$(libjpeg-turbo)

$($(libjpeg-turbo)-src): $(dir $($(libjpeg-turbo)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libjpeg-turbo)-srcurl)

$($(libjpeg-turbo)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libjpeg-turbo)-srcdir)/build/.markerfile: $($(libjpeg-turbo)-srcdir)/.markerfile
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libjpeg-turbo)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(libjpeg-turbo)-prefix)/.pkgunpack: $($(libjpeg-turbo)-src) $($(libjpeg-turbo)-srcdir)/.markerfile $($(libjpeg-turbo)-prefix)/.markerfile
	tar -C $($(libjpeg-turbo)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libjpeg-turbo)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libjpeg-turbo)-builddeps),$(modulefilesdir)/$$(dep)) $($(libjpeg-turbo)-prefix)/.pkgunpack
	@touch $@

$($(libjpeg-turbo)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libjpeg-turbo)-builddeps),$(modulefilesdir)/$$(dep)) $($(libjpeg-turbo)-prefix)/.pkgpatch $($(libjpeg-turbo)-srcdir)/build/.markerfile
	cd $($(libjpeg-turbo)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libjpeg-turbo)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(libjpeg-turbo)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=$($(libjpeg-turbo)-prefix)/lib && \
		$(MAKE)
	@touch $@

$($(libjpeg-turbo)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libjpeg-turbo)-builddeps),$(modulefilesdir)/$$(dep)) $($(libjpeg-turbo)-prefix)/.pkgbuild
	@touch $@

$($(libjpeg-turbo)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libjpeg-turbo)-builddeps),$(modulefilesdir)/$$(dep)) $($(libjpeg-turbo)-prefix)/.pkgcheck
	cd $($(libjpeg-turbo)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libjpeg-turbo)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libjpeg-turbo)-modulefile): $(modulefilesdir)/.markerfile $($(libjpeg-turbo)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libjpeg-turbo)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libjpeg-turbo)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libjpeg-turbo)-description)\"" >>$@
	echo "module-whatis \"$($(libjpeg-turbo)-url)\"" >>$@
	printf "$(foreach prereq,$($(libjpeg-turbo)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBJPEG_TURBO_ROOT $($(libjpeg-turbo)-prefix)" >>$@
	echo "setenv LIBJPEG_TURBO_INCDIR $($(libjpeg-turbo)-prefix)/include" >>$@
	echo "setenv LIBJPEG_TURBO_INCLUDEDIR $($(libjpeg-turbo)-prefix)/include" >>$@
	echo "setenv LIBJPEG_TURBO_LIBDIR $($(libjpeg-turbo)-prefix)/lib" >>$@
	echo "setenv LIBJPEG_TURBO_LIBRARYDIR $($(libjpeg-turbo)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libjpeg-turbo)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libjpeg-turbo)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libjpeg-turbo)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libjpeg-turbo)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libjpeg-turbo)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libjpeg-turbo)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libjpeg-turbo)-prefix)/share/man" >>$@
	echo "set MSG \"$(libjpeg-turbo)\"" >>$@

$(libjpeg-turbo)-src: $($(libjpeg-turbo)-src)
$(libjpeg-turbo)-unpack: $($(libjpeg-turbo)-prefix)/.pkgunpack
$(libjpeg-turbo)-patch: $($(libjpeg-turbo)-prefix)/.pkgpatch
$(libjpeg-turbo)-build: $($(libjpeg-turbo)-prefix)/.pkgbuild
$(libjpeg-turbo)-check: $($(libjpeg-turbo)-prefix)/.pkgcheck
$(libjpeg-turbo)-install: $($(libjpeg-turbo)-prefix)/.pkginstall
$(libjpeg-turbo)-modulefile: $($(libjpeg-turbo)-modulefile)
$(libjpeg-turbo)-clean:
	rm -rf $($(libjpeg-turbo)-modulefile)
	rm -rf $($(libjpeg-turbo)-prefix)
	rm -rf $($(libjpeg-turbo)-srcdir)
	rm -rf $($(libjpeg-turbo)-src)
$(libjpeg-turbo): $(libjpeg-turbo)-src $(libjpeg-turbo)-unpack $(libjpeg-turbo)-patch $(libjpeg-turbo)-build $(libjpeg-turbo)-check $(libjpeg-turbo)-install $(libjpeg-turbo)-modulefile
