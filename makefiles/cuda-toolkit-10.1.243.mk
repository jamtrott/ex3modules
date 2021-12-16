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
# cuda-toolkit-10.1.243

cuda-toolkit-version = 10.1.243
cuda-toolkit = cuda-toolkit-$(cuda-toolkit-version)
$(cuda-toolkit)-description = Development environment for high performance GPU-accelerated applications
$(cuda-toolkit)-url = https://developer.nvidia.com/cuda-toolkit/
$(cuda-toolkit)-srcurl = http://developer.download.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.243_418.87.00_linux.run
$(cuda-toolkit)-builddeps = $(gcc)
$(cuda-toolkit)-prereqs = $(gcc)
$(cuda-toolkit)-src = $(pkgsrcdir)/$(notdir $($(cuda-toolkit)-srcurl))
$(cuda-toolkit)-srcdir = $(pkgsrcdir)/$(cuda-toolkit)
$(cuda-toolkit)-builddir = $($(cuda-toolkit)-srcdir)
$(cuda-toolkit)-modulefile = $(modulefilesdir)/$(cuda-toolkit)
$(cuda-toolkit)-prefix = $(pkgdir)/$(cuda-toolkit)

ifneq ($(ARCH),x86_64)
$(info Skipping $(cuda-toolkit) - requires x86_64)
$(cuda-toolkit)-src:
$(cuda-toolkit)-unpack:
$(cuda-toolkit)-patch:
$(cuda-toolkit)-build:
$(cuda-toolkit)-check:
$(cuda-toolkit)-install:
$(cuda-toolkit)-modulefile:
$(cuda-toolkit)-clean:
$(cuda-toolkit): $(cuda-toolkit)-src $(cuda-toolkit)-unpack $(cuda-toolkit)-patch $(cuda-toolkit)-build $(cuda-toolkit)-check $(cuda-toolkit)-install $(cuda-toolkit)-modulefile

else
$($(cuda-toolkit)-src): $(dir $($(cuda-toolkit)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cuda-toolkit)-srcurl)

$($(cuda-toolkit)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cuda-toolkit)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cuda-toolkit)-prefix)/.pkgunpack: $($(cuda-toolkit)-src) $($(cuda-toolkit)-srcdir)/.markerfile $($(cuda-toolkit)-prefix)/.markerfile $$(foreach dep,$$($(cuda-toolkit)-builddeps),$(modulefilesdir)/$$(dep))
	@touch $@

$($(cuda-toolkit)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(cuda-toolkit)-builddir),$($(cuda-toolkit)-srcdir))
$($(cuda-toolkit)-builddir)/.markerfile: $($(cuda-toolkit)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(cuda-toolkit)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit)-builddir)/.markerfile $($(cuda-toolkit)-prefix)/.pkgpatch
	@touch $@

$($(cuda-toolkit)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit)-builddir)/.markerfile $($(cuda-toolkit)-prefix)/.pkgbuild
	@touch $@

$($(cuda-toolkit)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit)-builddir)/.markerfile $($(cuda-toolkit)-prefix)/.pkgcheck
	chmod u+x $($(cuda-toolkit)-src)
	cd $($(cuda-toolkit)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cuda-toolkit)-builddeps) && \
		$($(cuda-toolkit)-src) --silent --toolkit \
			--toolkitpath=$($(cuda-toolkit)-prefix) \
			--defaultroot=$($(cuda-toolkit)-prefix)
	@touch $@

$($(cuda-toolkit)-modulefile): $(modulefilesdir)/.markerfile $($(cuda-toolkit)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cuda-toolkit)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cuda-toolkit)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cuda-toolkit)-description)\"" >>$@
	echo "module-whatis \"$($(cuda-toolkit)-url)\"" >>$@
	printf "$(foreach prereq,$($(cuda-toolkit)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CUDA_TOOLKIT_ROOT $($(cuda-toolkit)-prefix)" >>$@
	echo "setenv CUDA_TOOLKIT_INCDIR $($(cuda-toolkit)-prefix)/include" >>$@
	echo "setenv CUDA_TOOLKIT_INCLUDEDIR $($(cuda-toolkit)-prefix)/include" >>$@
	echo "setenv CUDA_TOOLKIT_LIBDIR $($(cuda-toolkit)-prefix)/lib64" >>$@
	echo "setenv CUDA_TOOLKIT_LIBRARYDIR $($(cuda-toolkit)-prefix)/lib64" >>$@
	echo "prepend-path PATH $($(cuda-toolkit)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(cuda-toolkit)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(cuda-toolkit)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(cuda-toolkit)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(cuda-toolkit)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cuda-toolkit)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cuda-toolkit)-prefix)/lib64" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(cuda-toolkit)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(cuda-toolkit)-prefix)/lib64/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(cuda-toolkit)-prefix)/share/man" >>$@
	echo "set MSG \"$(cuda-toolkit)\"" >>$@

$(cuda-toolkit)-src: $($(cuda-toolkit)-src)
$(cuda-toolkit)-unpack: $($(cuda-toolkit)-prefix)/.pkgunpack
$(cuda-toolkit)-patch: $($(cuda-toolkit)-prefix)/.pkgpatch
$(cuda-toolkit)-build: $($(cuda-toolkit)-prefix)/.pkgbuild
$(cuda-toolkit)-check: $($(cuda-toolkit)-prefix)/.pkgcheck
$(cuda-toolkit)-install: $($(cuda-toolkit)-prefix)/.pkginstall
$(cuda-toolkit)-modulefile: $($(cuda-toolkit)-modulefile)
$(cuda-toolkit)-clean:
	rm -rf $($(cuda-toolkit)-modulefile)
	rm -rf $($(cuda-toolkit)-prefix)
	rm -rf $($(cuda-toolkit)-srcdir)
	rm -rf $($(cuda-toolkit)-src)
$(cuda-toolkit): $(cuda-toolkit)-src $(cuda-toolkit)-unpack $(cuda-toolkit)-patch $(cuda-toolkit)-build $(cuda-toolkit)-check $(cuda-toolkit)-install $(cuda-toolkit)-modulefile
endif
