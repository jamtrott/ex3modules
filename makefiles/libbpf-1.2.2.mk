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
# libbpf-1.2.2

libbpf-version = 1.2.2
libbpf = libbpf-$(libbpf-version)
$(libbpf)-description =
$(libbpf)-url = https://github.com/libbpf/libbpf
$(libbpf)-srcurl = https://github.com/libbpf/libbpf/archive/refs/tags/v1.2.2.tar.gz
$(libbpf)-builddeps = $(elfutils)
$(libbpf)-prereqs = $(elfutils)
$(libbpf)-src = $(pkgsrcdir)/$(notdir $($(libbpf)-srcurl))
$(libbpf)-srcdir = $(pkgsrcdir)/$(libbpf)
$(libbpf)-builddir = $($(libbpf)-srcdir)/src
$(libbpf)-modulefile = $(modulefilesdir)/$(libbpf)
$(libbpf)-prefix = $(pkgdir)/$(libbpf)

$($(libbpf)-src): $(dir $($(libbpf)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libbpf)-srcurl)

$($(libbpf)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libbpf)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libbpf)-prefix)/.pkgunpack: $$($(libbpf)-src) $($(libbpf)-srcdir)/.markerfile $($(libbpf)-prefix)/.markerfile $$(foreach dep,$$($(libbpf)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libbpf)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libbpf)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libbpf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libbpf)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libbpf)-builddir),$($(libbpf)-srcdir))
$($(libbpf)-builddir)/.markerfile: $($(libbpf)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libbpf)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libbpf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libbpf)-builddir)/.markerfile $($(libbpf)-prefix)/.pkgpatch
	cd $($(libbpf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libbpf)-builddeps) && \
		$(MAKE)
	@touch $@

$($(libbpf)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libbpf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libbpf)-builddir)/.markerfile $($(libbpf)-prefix)/.pkgbuild
	@touch $@

$($(libbpf)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libbpf)-builddeps),$(modulefilesdir)/$$(dep)) $($(libbpf)-builddir)/.markerfile $($(libbpf)-prefix)/.pkgcheck
	cd $($(libbpf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libbpf)-builddeps) && \
		$(MAKE) install PREFIX=$($(libbpf)-prefix) LIBDIR=$($(libbpf)-prefix)/lib
	@touch $@

$($(libbpf)-modulefile): $(modulefilesdir)/.markerfile $($(libbpf)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libbpf)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libbpf)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libbpf)-description)\"" >>$@
	echo "module-whatis \"$($(libbpf)-url)\"" >>$@
	printf "$(foreach prereq,$($(libbpf)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBBPF_ROOT $($(libbpf)-prefix)" >>$@
	echo "setenv LIBBPF_INCDIR $($(libbpf)-prefix)/include" >>$@
	echo "setenv LIBBPF_INCLUDEDIR $($(libbpf)-prefix)/include" >>$@
	echo "setenv LIBBPF_LIBDIR $($(libbpf)-prefix)/lib" >>$@
	echo "setenv LIBBPF_LIBRARYDIR $($(libbpf)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libbpf)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libbpf)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libbpf)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libbpf)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libbpf)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(libbpf)\"" >>$@

$(libbpf)-src: $$($(libbpf)-src)
$(libbpf)-unpack: $($(libbpf)-prefix)/.pkgunpack
$(libbpf)-patch: $($(libbpf)-prefix)/.pkgpatch
$(libbpf)-build: $($(libbpf)-prefix)/.pkgbuild
$(libbpf)-check: $($(libbpf)-prefix)/.pkgcheck
$(libbpf)-install: $($(libbpf)-prefix)/.pkginstall
$(libbpf)-modulefile: $($(libbpf)-modulefile)
$(libbpf)-clean:
	rm -rf $($(libbpf)-modulefile)
	rm -rf $($(libbpf)-prefix)
	rm -rf $($(libbpf)-builddir)
	rm -rf $($(libbpf)-srcdir)
	rm -rf $($(libbpf)-src)
$(libbpf): $(libbpf)-src $(libbpf)-unpack $(libbpf)-patch $(libbpf)-build $(libbpf)-check $(libbpf)-install $(libbpf)-modulefile
