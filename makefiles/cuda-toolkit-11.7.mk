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
# cuda-toolkit-11.7

cuda-toolkit-11.7-version = 11.7
cuda-toolkit-11.7 = cuda-toolkit-$(cuda-toolkit-11.7-version)
$(cuda-toolkit-11.7)-description = Development environment for high performance GPU-accelerated applications
$(cuda-toolkit-11.7)-url = https://developer.nvidia.com/cuda-toolkit/
$(cuda-toolkit-11.7)-srcurl = https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda_11.7.0_515.43.04_linux.run
$(cuda-toolkit-11.7)-builddeps =
$(cuda-toolkit-11.7)-prereqs =
$(cuda-toolkit-11.7)-src = $(pkgsrcdir)/$(notdir $($(cuda-toolkit-11.7)-srcurl))
$(cuda-toolkit-11.7)-srcdir = $(pkgsrcdir)/$(cuda-toolkit-11.7)
$(cuda-toolkit-11.7)-builddir = $($(cuda-toolkit-11.7)-srcdir)
$(cuda-toolkit-11.7)-modulefile = $(modulefilesdir)/$(cuda-toolkit-11.7)
$(cuda-toolkit-11.7)-prefix = $(pkgdir)/$(cuda-toolkit-11.7)

ifneq ($(ARCH),x86_64)
$(info Skipping $(cuda-toolkit-11.7) - requires x86_64)
$(cuda-toolkit-11.7)-src:
$(cuda-toolkit-11.7)-unpack:
$(cuda-toolkit-11.7)-patch:
$(cuda-toolkit-11.7)-build:
$(cuda-toolkit-11.7)-check:
$(cuda-toolkit-11.7)-install:
$(cuda-toolkit-11.7)-modulefile:
$(cuda-toolkit-11.7)-clean:
$(cuda-toolkit-11.7): $(cuda-toolkit-11.7)-src $(cuda-toolkit-11.7)-unpack $(cuda-toolkit-11.7)-patch $(cuda-toolkit-11.7)-build $(cuda-toolkit-11.7)-check $(cuda-toolkit-11.7)-install $(cuda-toolkit-11.7)-modulefile

else
$($(cuda-toolkit-11.7)-src): $(dir $($(cuda-toolkit-11.7)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cuda-toolkit-11.7)-srcurl)

$($(cuda-toolkit-11.7)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cuda-toolkit-11.7)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cuda-toolkit-11.7)-prefix)/.pkgunpack: $($(cuda-toolkit-11.7)-src) $($(cuda-toolkit-11.7)-srcdir)/.markerfile $($(cuda-toolkit-11.7)-prefix)/.markerfile $$(foreach dep,$$($(cuda-toolkit-11.7)-builddeps),$(modulefilesdir)/$$(dep))
	@touch $@

$($(cuda-toolkit-11.7)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit-11.7)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit-11.7)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(cuda-toolkit-11.7)-builddir),$($(cuda-toolkit-11.7)-srcdir))
$($(cuda-toolkit-11.7)-builddir)/.markerfile: $($(cuda-toolkit-11.7)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(cuda-toolkit-11.7)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit-11.7)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit-11.7)-builddir)/.markerfile $($(cuda-toolkit-11.7)-prefix)/.pkgpatch
	@touch $@

$($(cuda-toolkit-11.7)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit-11.7)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit-11.7)-builddir)/.markerfile $($(cuda-toolkit-11.7)-prefix)/.pkgbuild
	@touch $@

$($(cuda-toolkit-11.7)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit-11.7)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit-11.7)-builddir)/.markerfile $($(cuda-toolkit-11.7)-prefix)/.pkgcheck
	chmod u+x $($(cuda-toolkit-11.7)-src)
	cd $($(cuda-toolkit-11.7)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cuda-toolkit-11.7)-builddeps) && \
		$($(cuda-toolkit-11.7)-src) --silent --toolkit \
			--toolkitpath=$($(cuda-toolkit-11.7)-prefix) \
			--defaultroot=$($(cuda-toolkit-11.7)-prefix)
	@touch $@

$($(cuda-toolkit-11.7)-modulefile): $(modulefilesdir)/.markerfile $($(cuda-toolkit-11.7)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cuda-toolkit-11.7)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cuda-toolkit-11.7)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cuda-toolkit-11.7)-description)\"" >>$@
	echo "module-whatis \"$($(cuda-toolkit-11.7)-url)\"" >>$@
	printf "$(foreach prereq,$($(cuda-toolkit-11.7)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CUDA_TOOLKIT_ROOT $($(cuda-toolkit-11.7)-prefix)" >>$@
	echo "setenv CUDA_TOOLKIT_INCDIR $($(cuda-toolkit-11.7)-prefix)/include" >>$@
	echo "setenv CUDA_TOOLKIT_INCLUDEDIR $($(cuda-toolkit-11.7)-prefix)/include" >>$@
	echo "setenv CUDA_TOOLKIT_LIBDIR $($(cuda-toolkit-11.7)-prefix)/lib64" >>$@
	echo "setenv CUDA_TOOLKIT_LIBRARYDIR $($(cuda-toolkit-11.7)-prefix)/lib64" >>$@
	echo "prepend-path PATH $($(cuda-toolkit-11.7)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(cuda-toolkit-11.7)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(cuda-toolkit-11.7)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(cuda-toolkit-11.7)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(cuda-toolkit-11.7)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cuda-toolkit-11.7)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cuda-toolkit-11.7)-prefix)/lib64" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(cuda-toolkit-11.7)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(cuda-toolkit-11.7)-prefix)/lib64/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(cuda-toolkit-11.7)-prefix)/share/man" >>$@
	echo "set MSG \"$(cuda-toolkit-11.7)\"" >>$@

$(cuda-toolkit-11.7)-src: $($(cuda-toolkit-11.7)-src)
$(cuda-toolkit-11.7)-unpack: $($(cuda-toolkit-11.7)-prefix)/.pkgunpack
$(cuda-toolkit-11.7)-patch: $($(cuda-toolkit-11.7)-prefix)/.pkgpatch
$(cuda-toolkit-11.7)-build: $($(cuda-toolkit-11.7)-prefix)/.pkgbuild
$(cuda-toolkit-11.7)-check: $($(cuda-toolkit-11.7)-prefix)/.pkgcheck
$(cuda-toolkit-11.7)-install: $($(cuda-toolkit-11.7)-prefix)/.pkginstall
$(cuda-toolkit-11.7)-modulefile: $($(cuda-toolkit-11.7)-modulefile)
$(cuda-toolkit-11.7)-clean:
	rm -rf $($(cuda-toolkit-11.7)-modulefile)
	rm -rf $($(cuda-toolkit-11.7)-prefix)
	rm -rf $($(cuda-toolkit-11.7)-srcdir)
	rm -rf $($(cuda-toolkit-11.7)-src)
$(cuda-toolkit-11.7): $(cuda-toolkit-11.7)-src $(cuda-toolkit-11.7)-unpack $(cuda-toolkit-11.7)-patch $(cuda-toolkit-11.7)-build $(cuda-toolkit-11.7)-check $(cuda-toolkit-11.7)-install $(cuda-toolkit-11.7)-modulefile
endif
