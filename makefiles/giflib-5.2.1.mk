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
# giflib-5.2.1

giflib-major-version = 5
giflib-version = 5.2.1
giflib = giflib-$(giflib-version)
$(giflib)-description = Library for reading and writing gif images
$(giflib)-url = http://giflib.sourceforge.net/
$(giflib)-srcurl = https://download.sourceforge.net/giflib/giflib-$(giflib-version).tar.gz
$(giflib)-src = $(pkgsrcdir)/$(notdir $($(giflib)-srcurl))
$(giflib)-srcdir = $(pkgsrcdir)/$(giflib)
$(giflib)-builddeps =
$(giflib)-prereqs =
$(giflib)-modulefile = $(modulefilesdir)/$(giflib)
$(giflib)-prefix = $(pkgdir)/$(giflib)

$($(giflib)-src): $(dir $($(giflib)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(giflib)-srcurl)

$($(giflib)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(giflib)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(giflib)-prefix)/.pkgunpack: $($(giflib)-src) $($(giflib)-srcdir)/.markerfile $($(giflib)-prefix)/.markerfile
	tar -C $($(giflib)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(giflib)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(giflib)-builddeps),$(modulefilesdir)/$$(dep)) $($(giflib)-prefix)/.pkgunpack
	@touch $@

$($(giflib)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(giflib)-builddeps),$(modulefilesdir)/$$(dep)) $($(giflib)-prefix)/.pkgpatch
	cd $($(giflib)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(giflib)-builddeps) && \
		$(MAKE)
	@touch $@

$($(giflib)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(giflib)-builddeps),$(modulefilesdir)/$$(dep)) $($(giflib)-prefix)/.pkgbuild
	@touch $@

$($(giflib)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(giflib)-builddeps),$(modulefilesdir)/$$(dep)) $($(giflib)-prefix)/.pkgcheck
	$(INSTALL) -d "$($(giflib)-prefix)/bin"
	cd $($(giflib)-srcdir) && $(INSTALL) gif2rgb gifbuild giffix giftext giftool gifclrmp "$($(giflib)-prefix)/bin"
	$(INSTALL) -d "$($(giflib)-prefix)/include"
	cd $($(giflib)-srcdir) && $(INSTALL) -m 644 gif_lib.h "$($(giflib)-prefix)/include"
	$(INSTALL) -d "$($(giflib)-prefix)/lib"
	cd $($(giflib)-srcdir) && $(INSTALL) -m 644 libgif.a "$($(giflib)-prefix)/lib/libgif.a"
	cd $($(giflib)-srcdir) && $(INSTALL) -m 755 libgif.so "$($(giflib)-prefix)/lib/libgif.so.$(giflib-version)"
	cd $($(giflib)-prefix)/lib/ && ln -sf libgif.so.$(giflib-version) "$($(giflib)-prefix)/lib/libgif.so.$(giflib-major-version)"
	cd $($(giflib)-prefix)/lib/ && ln -sf libgif.so.$(giflib-major-version) "$($(giflib)-prefix)/lib/libgif.so"
	$(INSTALL) -d "$($(giflib)-prefix)/share/man/man1"
	cd $($(giflib)-srcdir) && $(INSTALL) -m 644 doc/*.1 "$($(giflib)-prefix)/share/man/man1"
	@touch $@

$($(giflib)-modulefile): $(modulefilesdir)/.markerfile $($(giflib)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(giflib)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(giflib)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(giflib)-description)\"" >>$@
	echo "module-whatis \"$($(giflib)-url)\"" >>$@
	printf "$(foreach prereq,$($(giflib)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GIFLIB_ROOT $($(giflib)-prefix)" >>$@
	echo "setenv GIFLIB_INCDIR $($(giflib)-prefix)/include" >>$@
	echo "setenv GIFLIB_INCLUDEDIR $($(giflib)-prefix)/include" >>$@
	echo "setenv GIFLIB_LIBDIR $($(giflib)-prefix)/lib" >>$@
	echo "setenv GIFLIB_LIBRARYDIR $($(giflib)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(giflib)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(giflib)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(giflib)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(giflib)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(giflib)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(giflib)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(giflib)-prefix)/share/man" >>$@
	echo "set MSG \"$(giflib)\"" >>$@

$(giflib)-src: $($(giflib)-src)
$(giflib)-unpack: $($(giflib)-prefix)/.pkgunpack
$(giflib)-patch: $($(giflib)-prefix)/.pkgpatch
$(giflib)-build: $($(giflib)-prefix)/.pkgbuild
$(giflib)-check: $($(giflib)-prefix)/.pkgcheck
$(giflib)-install: $($(giflib)-prefix)/.pkginstall
$(giflib)-modulefile: $($(giflib)-modulefile)
$(giflib)-clean:
	rm -rf $($(giflib)-modulefile)
	rm -rf $($(giflib)-prefix)
	rm -rf $($(giflib)-srcdir)
	rm -rf $($(giflib)-src)
$(giflib): $(giflib)-src $(giflib)-unpack $(giflib)-patch $(giflib)-build $(giflib)-check $(giflib)-install $(giflib)-modulefile
