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
# gdrcopy-2.2

gdrcopy-version = 2.2
gdrcopy = gdrcopy-$(gdrcopy-version)
$(gdrcopy)-description = Low-latency GPU memory copy library based on NVIDIA GPUDirect RDMA technology.
$(gdrcopy)-url = https://github.com/NVIDIA/gdrcopy
$(gdrcopy)-srcurl = https://github.com/NVIDIA/gdrcopy/archive/refs/tags/v$(gdrcopy-version).tar.gz
$(gdrcopy)-builddeps = $(gcc) $(libcheck) $(cuda-toolkit)
$(gdrcopy)-prereqs = $(cuda-toolkit)
$(gdrcopy)-src = $(pkgsrcdir)/gdrcopy-$(notdir $($(gdrcopy)-srcurl))
$(gdrcopy)-srcdir = $(pkgsrcdir)/$(gdrcopy)
$(gdrcopy)-builddir = $($(gdrcopy)-srcdir)
$(gdrcopy)-modulefile = $(modulefilesdir)/$(gdrcopy)
$(gdrcopy)-prefix = $(pkgdir)/$(gdrcopy)

$($(gdrcopy)-src): $(dir $($(gdrcopy)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gdrcopy)-srcurl)

$($(gdrcopy)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gdrcopy)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gdrcopy)-prefix)/.pkgunpack: $$($(gdrcopy)-src) $($(gdrcopy)-srcdir)/.markerfile $($(gdrcopy)-prefix)/.markerfile $$(foreach dep,$$($(gdrcopy)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(gdrcopy)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gdrcopy)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gdrcopy)-builddeps),$(modulefilesdir)/$$(dep)) $($(gdrcopy)-prefix)/.pkgunpack
	sed -i 's,gcc -I $$PWD -I $$PWD/src $$src -o $$exe,$${CC} -I $$PWD -I $$PWD/src $$src -o $$exe,' $($(gdrcopy)-srcdir)/config_arch
	@touch $@

ifneq ($($(gdrcopy)-builddir),$($(gdrcopy)-srcdir))
$($(gdrcopy)-builddir)/.markerfile: $($(gdrcopy)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gdrcopy)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gdrcopy)-builddeps),$(modulefilesdir)/$$(dep)) $($(gdrcopy)-builddir)/.markerfile $($(gdrcopy)-prefix)/.pkgpatch
	cd $($(gdrcopy)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gdrcopy)-builddeps) && \
		$(MAKE) prefix=$($(gdrcopy)-prefix) CUDA=$${CUDA_TOOLKIT_ROOT} -n all
	@touch $@

$($(gdrcopy)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gdrcopy)-builddeps),$(modulefilesdir)/$$(dep)) $($(gdrcopy)-builddir)/.markerfile $($(gdrcopy)-prefix)/.pkgbuild
	@touch $@

$($(gdrcopy)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gdrcopy)-builddeps),$(modulefilesdir)/$$(dep)) $($(gdrcopy)-builddir)/.markerfile $($(gdrcopy)-prefix)/.pkgcheck
	cd $($(gdrcopy)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gdrcopy)-builddeps) && \
		$(MAKE) prefix=$($(gdrcopy)-prefix) CUDA=$${CUDA_TOOLKIT_ROOT} install
	@touch $@

$($(gdrcopy)-modulefile): $(modulefilesdir)/.markerfile $($(gdrcopy)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gdrcopy)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gdrcopy)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gdrcopy)-description)\"" >>$@
	echo "module-whatis \"$($(gdrcopy)-url)\"" >>$@
	printf "$(foreach prereq,$($(gdrcopy)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GDRCOPY_ROOT $($(gdrcopy)-prefix)" >>$@
	echo "setenv GDRCOPY_INCDIR $($(gdrcopy)-prefix)/include" >>$@
	echo "setenv GDRCOPY_INCLUDEDIR $($(gdrcopy)-prefix)/include" >>$@
	echo "setenv GDRCOPY_LIBDIR $($(gdrcopy)-prefix)/lib" >>$@
	echo "setenv GDRCOPY_LIBRARYDIR $($(gdrcopy)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(gdrcopy)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gdrcopy)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gdrcopy)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gdrcopy)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gdrcopy)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(gdrcopy)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(gdrcopy)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gdrcopy)-prefix)/share/info" >>$@
	echo "set MSG \"$(gdrcopy)\"" >>$@

$(gdrcopy)-src: $$($(gdrcopy)-src)
$(gdrcopy)-unpack: $($(gdrcopy)-prefix)/.pkgunpack
$(gdrcopy)-patch: $($(gdrcopy)-prefix)/.pkgpatch
$(gdrcopy)-build: $($(gdrcopy)-prefix)/.pkgbuild
$(gdrcopy)-check: $($(gdrcopy)-prefix)/.pkgcheck
$(gdrcopy)-install: $($(gdrcopy)-prefix)/.pkginstall
$(gdrcopy)-modulefile: $($(gdrcopy)-modulefile)
$(gdrcopy)-clean:
	rm -rf $($(gdrcopy)-modulefile)
	rm -rf $($(gdrcopy)-prefix)
	rm -rf $($(gdrcopy)-builddir)
	rm -rf $($(gdrcopy)-srcdir)
	rm -rf $($(gdrcopy)-src)
$(gdrcopy): $(gdrcopy)-src $(gdrcopy)-unpack $(gdrcopy)-patch $(gdrcopy)-build $(gdrcopy)-check $(gdrcopy)-install $(gdrcopy)-modulefile
