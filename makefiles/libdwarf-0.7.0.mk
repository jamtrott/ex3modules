# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# libdwarf-0.7.0

libdwarf-version = 0.7.0
libdwarf = libdwarf-$(libdwarf-version)
$(libdwarf)-description = 
$(libdwarf)-url = https://www.prevanders.net/dwarf.html
$(libdwarf)-srcurl = https://www.prevanders.net/libdwarf-0.7.0.tar.xz
$(libdwarf)-builddeps =
$(libdwarf)-prereqs =
$(libdwarf)-src = $(pkgsrcdir)/$(notdir $($(libdwarf)-srcurl))
$(libdwarf)-srcdir = $(pkgsrcdir)/$(libdwarf)
$(libdwarf)-builddir = $($(libdwarf)-srcdir)/build
$(libdwarf)-modulefile = $(modulefilesdir)/$(libdwarf)
$(libdwarf)-prefix = $(pkgdir)/$(libdwarf)

$($(libdwarf)-src): $(dir $($(libdwarf)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libdwarf)-srcurl)

$($(libdwarf)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libdwarf)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libdwarf)-prefix)/.pkgunpack: $$($(libdwarf)-src) $($(libdwarf)-srcdir)/.markerfile $($(libdwarf)-prefix)/.markerfile $$(foreach dep,$$($(libdwarf)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libdwarf)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(libdwarf)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdwarf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdwarf)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libdwarf)-builddir),$($(libdwarf)-srcdir))
$($(libdwarf)-builddir)/.markerfile: $($(libdwarf)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libdwarf)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdwarf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdwarf)-builddir)/.markerfile $($(libdwarf)-prefix)/.pkgpatch
	cd $($(libdwarf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libdwarf)-builddeps) && \
		../configure --prefix=$($(libdwarf)-prefix) --enable-shared && \
		$(MAKE)
	@touch $@

$($(libdwarf)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdwarf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdwarf)-builddir)/.markerfile $($(libdwarf)-prefix)/.pkgbuild
	cd $($(libdwarf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libdwarf)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libdwarf)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libdwarf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libdwarf)-builddir)/.markerfile $($(libdwarf)-prefix)/.pkgcheck
	cd $($(libdwarf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libdwarf)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libdwarf)-modulefile): $(modulefilesdir)/.markerfile $($(libdwarf)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libdwarf)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libdwarf)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libdwarf)-description)\"" >>$@
	echo "module-whatis \"$($(libdwarf)-url)\"" >>$@
	printf "$(foreach prereq,$($(libdwarf)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBDWARF_ROOT $($(libdwarf)-prefix)" >>$@
	echo "setenv LIBDWARF_INCDIR $($(libdwarf)-prefix)/include/libdwarf-0" >>$@
	echo "setenv LIBDWARF_INCLUDEDIR $($(libdwarf)-prefix)/include/libdwarf-0" >>$@
	echo "setenv LIBDWARF_LIBDIR $($(libdwarf)-prefix)/lib" >>$@
	echo "setenv LIBDWARF_LIBRARYDIR $($(libdwarf)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libdwarf)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libdwarf)-prefix)/include/libdwarf-0" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libdwarf)-prefix)/include/libdwarf-0" >>$@
	echo "prepend-path LIBRARY_PATH $($(libdwarf)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libdwarf)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libdwarf)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libdwarf)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libdwarf)-prefix)/share/info" >>$@
	echo "set MSG \"$(libdwarf)\"" >>$@

$(libdwarf)-src: $$($(libdwarf)-src)
$(libdwarf)-unpack: $($(libdwarf)-prefix)/.pkgunpack
$(libdwarf)-patch: $($(libdwarf)-prefix)/.pkgpatch
$(libdwarf)-build: $($(libdwarf)-prefix)/.pkgbuild
$(libdwarf)-check: $($(libdwarf)-prefix)/.pkgcheck
$(libdwarf)-install: $($(libdwarf)-prefix)/.pkginstall
$(libdwarf)-modulefile: $($(libdwarf)-modulefile)
$(libdwarf)-clean:
	rm -rf $($(libdwarf)-modulefile)
	rm -rf $($(libdwarf)-prefix)
	rm -rf $($(libdwarf)-builddir)
	rm -rf $($(libdwarf)-srcdir)
	rm -rf $($(libdwarf)-src)
$(libdwarf): $(libdwarf)-src $(libdwarf)-unpack $(libdwarf)-patch $(libdwarf)-build $(libdwarf)-check $(libdwarf)-install $(libdwarf)-modulefile
