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
# nvtop-2.0.1

nvtop-version = 2.0.1
nvtop = nvtop-$(nvtop-version)
$(nvtop)-description = htop-like monitoring tool for AMD and NVIDIA GPUs
$(nvtop)-url = https://github.com/Syllo/nvtop
$(nvtop)-srcurl = https://github.com/Syllo/nvtop/archive/refs/tags/$(nvtop-version).tar.gz
$(nvtop)-builddeps = $(cuda-toolkit)
$(nvtop)-prereqs = $(cuda-toolkit)
$(nvtop)-src = $(pkgsrcdir)/$(notdir $($(nvtop)-srcurl))
$(nvtop)-srcdir = $(pkgsrcdir)/$(nvtop)
$(nvtop)-builddir = $($(nvtop)-srcdir)/build
$(nvtop)-modulefile = $(modulefilesdir)/$(nvtop)
$(nvtop)-prefix = $(pkgdir)/$(nvtop)

$($(nvtop)-src): $(dir $($(nvtop)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(nvtop)-srcurl)

$($(nvtop)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(nvtop)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(nvtop)-prefix)/.pkgunpack: $$($(nvtop)-src) $($(nvtop)-srcdir)/.markerfile $($(nvtop)-prefix)/.markerfile $$(foreach dep,$$($(nvtop)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(nvtop)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(nvtop)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nvtop)-builddeps),$(modulefilesdir)/$$(dep)) $($(nvtop)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(nvtop)-builddir),$($(nvtop)-srcdir))
$($(nvtop)-builddir)/.markerfile: $($(nvtop)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(nvtop)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nvtop)-builddeps),$(modulefilesdir)/$$(dep)) $($(nvtop)-builddir)/.markerfile $($(nvtop)-prefix)/.pkgpatch
	cd $($(nvtop)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(nvtop)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(nvtop)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON && \
		$(MAKE)
	@touch $@

$($(nvtop)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nvtop)-builddeps),$(modulefilesdir)/$$(dep)) $($(nvtop)-builddir)/.markerfile $($(nvtop)-prefix)/.pkgbuild
	@touch $@

$($(nvtop)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nvtop)-builddeps),$(modulefilesdir)/$$(dep)) $($(nvtop)-builddir)/.markerfile $($(nvtop)-prefix)/.pkgcheck
	cd $($(nvtop)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(nvtop)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(nvtop)-modulefile): $(modulefilesdir)/.markerfile $($(nvtop)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(nvtop)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(nvtop)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(nvtop)-description)\"" >>$@
	echo "module-whatis \"$($(nvtop)-url)\"" >>$@
	printf "$(foreach prereq,$($(nvtop)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv NVTOP_ROOT $($(nvtop)-prefix)" >>$@
	echo "prepend-path PATH $($(nvtop)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(nvtop)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(nvtop)-prefix)/share/info" >>$@
	echo "set MSG \"$(nvtop)\"" >>$@

$(nvtop)-src: $$($(nvtop)-src)
$(nvtop)-unpack: $($(nvtop)-prefix)/.pkgunpack
$(nvtop)-patch: $($(nvtop)-prefix)/.pkgpatch
$(nvtop)-build: $($(nvtop)-prefix)/.pkgbuild
$(nvtop)-check: $($(nvtop)-prefix)/.pkgcheck
$(nvtop)-install: $($(nvtop)-prefix)/.pkginstall
$(nvtop)-modulefile: $($(nvtop)-modulefile)
$(nvtop)-clean:
	rm -rf $($(nvtop)-modulefile)
	rm -rf $($(nvtop)-prefix)
	rm -rf $($(nvtop)-builddir)
	rm -rf $($(nvtop)-srcdir)
	rm -rf $($(nvtop)-src)
$(nvtop): $(nvtop)-src $(nvtop)-unpack $(nvtop)-patch $(nvtop)-build $(nvtop)-check $(nvtop)-install $(nvtop)-modulefile
