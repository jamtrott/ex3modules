# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2025 James D. Trotter
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
# libunwind-1.6.2

libunwind-version = 1.6.2
libunwind = libunwind-$(libunwind-version)
$(libunwind)-description = Library for working with program call-chains
$(libunwind)-url = https://www.nongnu.org/libunwind/
$(libunwind)-srcurl = http://download.savannah.nongnu.org/releases/libunwind/libunwind-$(libunwind-version).tar.gz
$(libunwind)-builddeps = 
$(libunwind)-prereqs = 
$(libunwind)-src = $(pkgsrcdir)/$(notdir $($(libunwind)-srcurl))
$(libunwind)-srcdir = $(pkgsrcdir)/$(libunwind)
$(libunwind)-builddir = $($(libunwind)-srcdir)
$(libunwind)-modulefile = $(modulefilesdir)/$(libunwind)
$(libunwind)-prefix = $(pkgdir)/$(libunwind)

$($(libunwind)-src): $(dir $($(libunwind)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libunwind)-srcurl)

$($(libunwind)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libunwind)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libunwind)-prefix)/.pkgunpack: $($(libunwind)-src) $($(libunwind)-srcdir)/.markerfile $($(libunwind)-prefix)/.markerfile $$(foreach dep,$$($(libunwind)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libunwind)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libunwind)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libunwind)-builddeps),$(modulefilesdir)/$$(dep)) $($(libunwind)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libunwind)-builddir),$($(libunwind)-srcdir))
$($(libunwind)-builddir)/.markerfile: $($(libunwind)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libunwind)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libunwind)-builddeps),$(modulefilesdir)/$$(dep)) $($(libunwind)-builddir)/.markerfile $($(libunwind)-prefix)/.pkgpatch
	cd $($(libunwind)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libunwind)-builddeps) && \
		./configure --prefix=$($(libunwind)-prefix) && \
		$(MAKE)
	@touch $@

$($(libunwind)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libunwind)-builddeps),$(modulefilesdir)/$$(dep)) $($(libunwind)-builddir)/.markerfile $($(libunwind)-prefix)/.pkgbuild
	# cd $($(libunwind)-builddir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(libunwind)-builddeps) && \
	# 	$(MAKE) check
	@touch $@

$($(libunwind)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libunwind)-builddeps),$(modulefilesdir)/$$(dep)) $($(libunwind)-builddir)/.markerfile $($(libunwind)-prefix)/.pkgcheck
	cd $($(libunwind)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libunwind)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libunwind)-modulefile): $(modulefilesdir)/.markerfile $($(libunwind)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libunwind)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libunwind)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libunwind)-description)\"" >>$@
	echo "module-whatis \"$($(libunwind)-url)\"" >>$@
	printf "$(foreach prereq,$($(libunwind)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBUNWIND_ROOT $($(libunwind)-prefix)" >>$@
	echo "setenv LIBUNWIND_INCDIR $($(libunwind)-prefix)/include" >>$@
	echo "setenv LIBUNWIND_INCLUDEDIR $($(libunwind)-prefix)/include" >>$@
	echo "setenv LIBUNWIND_LIBDIR $($(libunwind)-prefix)/lib" >>$@
	echo "setenv LIBUNWIND_LIBRARYDIR $($(libunwind)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libunwind)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libunwind)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libunwind)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libunwind)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libunwind)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(libunwind)-prefix)/share/man" >>$@
	echo "set MSG \"$(libunwind)\"" >>$@

$(libunwind)-src: $($(libunwind)-src)
$(libunwind)-unpack: $($(libunwind)-prefix)/.pkgunpack
$(libunwind)-patch: $($(libunwind)-prefix)/.pkgpatch
$(libunwind)-build: $($(libunwind)-prefix)/.pkgbuild
$(libunwind)-check: $($(libunwind)-prefix)/.pkgcheck
$(libunwind)-install: $($(libunwind)-prefix)/.pkginstall
$(libunwind)-modulefile: $($(libunwind)-modulefile)
$(libunwind)-clean:
	rm -rf $($(libunwind)-modulefile)
	rm -rf $($(libunwind)-prefix)
	rm -rf $($(libunwind)-srcdir)
	rm -rf $($(libunwind)-src)
$(libunwind): $(libunwind)-src $(libunwind)-unpack $(libunwind)-patch $(libunwind)-build $(libunwind)-check $(libunwind)-install $(libunwind)-modulefile
