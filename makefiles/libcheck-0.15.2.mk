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
# libcheck-0.15.2

libcheck-version = 0.15.2
libcheck = libcheck-$(libcheck-version)
$(libcheck)-description =
$(libcheck)-url = https://libcheck.github.io/check/
$(libcheck)-srcurl = https://github.com/libcheck/check/releases/download/$(libcheck-version)/check-$(libcheck-version).tar.gz
$(libcheck)-builddeps =
$(libcheck)-prereqs =
$(libcheck)-src = $(pkgsrcdir)/$(notdir $($(libcheck)-srcurl))
$(libcheck)-srcdir = $(pkgsrcdir)/$(libcheck)
$(libcheck)-builddir = $($(libcheck)-srcdir)
$(libcheck)-modulefile = $(modulefilesdir)/$(libcheck)
$(libcheck)-prefix = $(pkgdir)/$(libcheck)

$($(libcheck)-src): $(dir $($(libcheck)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libcheck)-srcurl)

$($(libcheck)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libcheck)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libcheck)-prefix)/.pkgunpack: $$($(libcheck)-src) $($(libcheck)-srcdir)/.markerfile $($(libcheck)-prefix)/.markerfile $$(foreach dep,$$($(libcheck)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libcheck)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libcheck)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libcheck)-builddeps),$(modulefilesdir)/$$(dep)) $($(libcheck)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libcheck)-builddir),$($(libcheck)-srcdir))
$($(libcheck)-builddir)/.markerfile: $($(libcheck)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libcheck)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libcheck)-builddeps),$(modulefilesdir)/$$(dep)) $($(libcheck)-builddir)/.markerfile $($(libcheck)-prefix)/.pkgpatch
	cd $($(libcheck)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libcheck)-builddeps) && \
		./configure --prefix=$($(libcheck)-prefix) && \
		$(MAKE)
	@touch $@

$($(libcheck)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libcheck)-builddeps),$(modulefilesdir)/$$(dep)) $($(libcheck)-builddir)/.markerfile $($(libcheck)-prefix)/.pkgbuild
	# cd $($(libcheck)-builddir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(libcheck)-builddeps) && \
	# 	$(MAKE) check
	@touch $@

$($(libcheck)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libcheck)-builddeps),$(modulefilesdir)/$$(dep)) $($(libcheck)-builddir)/.markerfile $($(libcheck)-prefix)/.pkgcheck
	cd $($(libcheck)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libcheck)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libcheck)-modulefile): $(modulefilesdir)/.markerfile $($(libcheck)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libcheck)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libcheck)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libcheck)-description)\"" >>$@
	echo "module-whatis \"$($(libcheck)-url)\"" >>$@
	printf "$(foreach prereq,$($(libcheck)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBCHECK_ROOT $($(libcheck)-prefix)" >>$@
	echo "setenv LIBCHECK_INCDIR $($(libcheck)-prefix)/include" >>$@
	echo "setenv LIBCHECK_INCLUDEDIR $($(libcheck)-prefix)/include" >>$@
	echo "setenv LIBCHECK_LIBDIR $($(libcheck)-prefix)/lib" >>$@
	echo "setenv LIBCHECK_LIBRARYDIR $($(libcheck)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libcheck)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libcheck)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libcheck)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libcheck)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libcheck)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libcheck)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libcheck)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libcheck)-prefix)/share/info" >>$@
	echo "set MSG \"$(libcheck)\"" >>$@

$(libcheck)-src: $$($(libcheck)-src)
$(libcheck)-unpack: $($(libcheck)-prefix)/.pkgunpack
$(libcheck)-patch: $($(libcheck)-prefix)/.pkgpatch
$(libcheck)-build: $($(libcheck)-prefix)/.pkgbuild
$(libcheck)-check: $($(libcheck)-prefix)/.pkgcheck
$(libcheck)-install: $($(libcheck)-prefix)/.pkginstall
$(libcheck)-modulefile: $($(libcheck)-modulefile)
$(libcheck)-clean:
	rm -rf $($(libcheck)-modulefile)
	rm -rf $($(libcheck)-prefix)
	rm -rf $($(libcheck)-builddir)
	rm -rf $($(libcheck)-srcdir)
	rm -rf $($(libcheck)-src)
$(libcheck): $(libcheck)-src $(libcheck)-unpack $(libcheck)-patch $(libcheck)-build $(libcheck)-check $(libcheck)-install $(libcheck)-modulefile
