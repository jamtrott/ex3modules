# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# libceed-0.11.0

libceed-version = 0.11.0
libceed = libceed-$(libceed-version)
$(libceed)-description = CEED Library: Code for Efficient Extensible Discretizations
$(libceed)-url = https://github.com/CEED/libCEED
$(libceed)-srcurl = https://github.com/CEED/libCEED/archive/refs/tags/v$(libceed-version).tar.gz
$(libceed)-builddeps =
$(libceed)-prereqs =
$(libceed)-src = $(pkgsrcdir)/$(notdir $($(libceed)-srcurl))
$(libceed)-srcdir = $(pkgsrcdir)/$(libceed)
$(libceed)-builddir = $($(libceed)-srcdir)
$(libceed)-modulefile = $(modulefilesdir)/$(libceed)
$(libceed)-prefix = $(pkgdir)/$(libceed)

$($(libceed)-src): $(dir $($(libceed)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libceed)-srcurl)

$($(libceed)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libceed)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libceed)-prefix)/.pkgunpack: $$($(libceed)-src) $($(libceed)-srcdir)/.markerfile $($(libceed)-prefix)/.markerfile $$(foreach dep,$$($(libceed)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libceed)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libceed)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libceed)-builddeps),$(modulefilesdir)/$$(dep)) $($(libceed)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libceed)-builddir),$($(libceed)-srcdir))
$($(libceed)-builddir)/.markerfile: $($(libceed)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libceed)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libceed)-builddeps),$(modulefilesdir)/$$(dep)) $($(libceed)-builddir)/.markerfile $($(libceed)-prefix)/.pkgpatch
	cd $($(libceed)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libceed)-builddeps) && \
		$(MAKE) for_install=1 prefix=$($(libceed)-prefix) \
		OPT='-O3 -march=native' \
		$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo CUDA_DIR="$${CUDA_TOOLKIT_ROOT}")
	@touch $@

$($(libceed)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libceed)-builddeps),$(modulefilesdir)/$$(dep)) $($(libceed)-builddir)/.markerfile $($(libceed)-prefix)/.pkgbuild
	@touch $@

$($(libceed)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libceed)-builddeps),$(modulefilesdir)/$$(dep)) $($(libceed)-builddir)/.markerfile $($(libceed)-prefix)/.pkgcheck
	cd $($(libceed)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libceed)-builddeps) && \
		$(MAKE) install prefix=$($(libceed)-prefix)
	@touch $@

$($(libceed)-modulefile): $(modulefilesdir)/.markerfile $($(libceed)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libceed)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libceed)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libceed)-description)\"" >>$@
	echo "module-whatis \"$($(libceed)-url)\"" >>$@
	printf "$(foreach prereq,$($(libceed)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBCEED_ROOT $($(libceed)-prefix)" >>$@
	echo "setenv LIBCEED_INCDIR $($(libceed)-prefix)/include" >>$@
	echo "setenv LIBCEED_INCLUDEDIR $($(libceed)-prefix)/include" >>$@
	echo "setenv LIBCEED_LIBDIR $($(libceed)-prefix)/lib" >>$@
	echo "setenv LIBCEED_LIBRARYDIR $($(libceed)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libceed)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libceed)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libceed)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libceed)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libceed)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libceed)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libceed)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libceed)-prefix)/share/info" >>$@
	echo "set MSG \"$(libceed)\"" >>$@

$(libceed)-src: $$($(libceed)-src)
$(libceed)-unpack: $($(libceed)-prefix)/.pkgunpack
$(libceed)-patch: $($(libceed)-prefix)/.pkgpatch
$(libceed)-build: $($(libceed)-prefix)/.pkgbuild
$(libceed)-check: $($(libceed)-prefix)/.pkgcheck
$(libceed)-install: $($(libceed)-prefix)/.pkginstall
$(libceed)-modulefile: $($(libceed)-modulefile)
$(libceed)-clean:
	rm -rf $($(libceed)-modulefile)
	rm -rf $($(libceed)-prefix)
	rm -rf $($(libceed)-builddir)
	rm -rf $($(libceed)-srcdir)
	rm -rf $($(libceed)-src)
$(libceed): $(libceed)-src $(libceed)-unpack $(libceed)-patch $(libceed)-build $(libceed)-check $(libceed)-install $(libceed)-modulefile
