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
# libfabric-fabtests-1.12.1

libfabric-fabtests-version = 1.12.1
libfabric-fabtests = libfabric-fabtests-$(libfabric-fabtests-version)
$(libfabric-fabtests)-description = Test suite for libfabric
$(libfabric-fabtests)-url = http://libfabric.org/
$(libfabric-fabtests)-srcurl = https://github.com/ofiwg/libfabric/releases/download/v$(libfabric-fabtests-version)/fabtests-$(libfabric-fabtests-version).tar.bz2
$(libfabric-fabtests)-builddeps = $(libfabric)
$(libfabric-fabtests)-prereqs = $(libfabric)
$(libfabric-fabtests)-src = $(pkgsrcdir)/$(notdir $($(libfabric-fabtests)-srcurl))
$(libfabric-fabtests)-srcdir = $(pkgsrcdir)/$(libfabric-fabtests)
$(libfabric-fabtests)-builddir = $($(libfabric-fabtests)-srcdir)
$(libfabric-fabtests)-modulefile = $(modulefilesdir)/$(libfabric-fabtests)
$(libfabric-fabtests)-prefix = $(pkgdir)/$(libfabric-fabtests)

$($(libfabric-fabtests)-src): $(dir $($(libfabric-fabtests)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libfabric-fabtests)-srcurl)

$($(libfabric-fabtests)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libfabric-fabtests)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libfabric-fabtests)-prefix)/.pkgunpack: $$($(libfabric-fabtests)-src) $($(libfabric-fabtests)-srcdir)/.markerfile $($(libfabric-fabtests)-prefix)/.markerfile
	tar -C $($(libfabric-fabtests)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(libfabric-fabtests)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfabric-fabtests)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfabric-fabtests)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libfabric-fabtests)-builddir),$($(libfabric-fabtests)-srcdir))
$($(libfabric-fabtests)-builddir)/.markerfile: $($(libfabric-fabtests)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libfabric-fabtests)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfabric-fabtests)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfabric-fabtests)-builddir)/.markerfile $($(libfabric-fabtests)-prefix)/.pkgpatch
	cd $($(libfabric-fabtests)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfabric-fabtests)-builddeps) && \
		./configure --prefix=$($(libfabric-fabtests)-prefix) \
			--with-libfabric=$${LIBFABRIC_ROOT} && \
		$(MAKE)
	@touch $@

$($(libfabric-fabtests)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfabric-fabtests)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfabric-fabtests)-builddir)/.markerfile $($(libfabric-fabtests)-prefix)/.pkgbuild
	cd $($(libfabric-fabtests)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfabric-fabtests)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libfabric-fabtests)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libfabric-fabtests)-builddeps),$(modulefilesdir)/$$(dep)) $($(libfabric-fabtests)-builddir)/.markerfile $($(libfabric-fabtests)-prefix)/.pkgcheck
	cd $($(libfabric-fabtests)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libfabric-fabtests)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libfabric-fabtests)-modulefile): $(modulefilesdir)/.markerfile $($(libfabric-fabtests)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libfabric-fabtests)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libfabric-fabtests)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libfabric-fabtests)-description)\"" >>$@
	echo "module-whatis \"$($(libfabric-fabtests)-url)\"" >>$@
	printf "$(foreach prereq,$($(libfabric-fabtests)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBFABRIC_FABTESTS_ROOT $($(libfabric-fabtests)-prefix)" >>$@
	echo "setenv LIBFABRIC_FABTESTS_INCDIR $($(libfabric-fabtests)-prefix)/include" >>$@
	echo "setenv LIBFABRIC_FABTESTS_INCLUDEDIR $($(libfabric-fabtests)-prefix)/include" >>$@
	echo "setenv LIBFABRIC_FABTESTS_LIBDIR $($(libfabric-fabtests)-prefix)/lib" >>$@
	echo "setenv LIBFABRIC_FABTESTS_LIBRARYDIR $($(libfabric-fabtests)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libfabric-fabtests)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libfabric-fabtests)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libfabric-fabtests)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libfabric-fabtests)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libfabric-fabtests)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libfabric-fabtests)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libfabric-fabtests)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libfabric-fabtests)-prefix)/share/info" >>$@
	echo "set MSG \"$(libfabric-fabtests)\"" >>$@

$(libfabric-fabtests)-src: $$($(libfabric-fabtests)-src)
$(libfabric-fabtests)-unpack: $($(libfabric-fabtests)-prefix)/.pkgunpack
$(libfabric-fabtests)-patch: $($(libfabric-fabtests)-prefix)/.pkgpatch
$(libfabric-fabtests)-build: $($(libfabric-fabtests)-prefix)/.pkgbuild
$(libfabric-fabtests)-check: $($(libfabric-fabtests)-prefix)/.pkgcheck
$(libfabric-fabtests)-install: $($(libfabric-fabtests)-prefix)/.pkginstall
$(libfabric-fabtests)-modulefile: $($(libfabric-fabtests)-modulefile)
$(libfabric-fabtests)-clean:
	rm -rf $($(libfabric-fabtests)-modulefile)
	rm -rf $($(libfabric-fabtests)-prefix)
	rm -rf $($(libfabric-fabtests)-srcdir)
$(libfabric-fabtests): $(libfabric-fabtests)-src $(libfabric-fabtests)-unpack $(libfabric-fabtests)-patch $(libfabric-fabtests)-build $(libfabric-fabtests)-check $(libfabric-fabtests)-install $(libfabric-fabtests)-modulefile
