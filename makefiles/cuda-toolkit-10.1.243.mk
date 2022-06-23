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

cuda-toolkit-10.1-version = 10.1.243
cuda-toolkit-10.1 = cuda-toolkit-$(cuda-toolkit-10.1-version)
$(cuda-toolkit-10.1)-description = Development environment for high performance GPU-accelerated applications
$(cuda-toolkit-10.1)-url = https://developer.nvidia.com/cuda-toolkit/
$(cuda-toolkit-10.1)-srcurl = http://developer.download.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.243_418.87.00_linux.run
$(cuda-toolkit-10.1)-builddeps =
$(cuda-toolkit-10.1)-prereqs =
$(cuda-toolkit-10.1)-src = $(pkgsrcdir)/$(notdir $($(cuda-toolkit-10.1)-srcurl))
$(cuda-toolkit-10.1)-srcdir = $(pkgsrcdir)/$(cuda-toolkit-10.1)
$(cuda-toolkit-10.1)-builddir = $($(cuda-toolkit-10.1)-srcdir)
$(cuda-toolkit-10.1)-modulefile = $(modulefilesdir)/$(cuda-toolkit-10.1)
$(cuda-toolkit-10.1)-prefix = $(pkgdir)/$(cuda-toolkit-10.1)

ifneq ($(ARCH),x86_64)
$(info Skipping $(cuda-toolkit-10.1) - requires x86_64)
$(cuda-toolkit-10.1)-src:
$(cuda-toolkit-10.1)-unpack:
$(cuda-toolkit-10.1)-patch:
$(cuda-toolkit-10.1)-build:
$(cuda-toolkit-10.1)-check:
$(cuda-toolkit-10.1)-install:
$(cuda-toolkit-10.1)-modulefile:
$(cuda-toolkit-10.1)-clean:
$(cuda-toolkit-10.1): $(cuda-toolkit-10.1)-src $(cuda-toolkit-10.1)-unpack $(cuda-toolkit-10.1)-patch $(cuda-toolkit-10.1)-build $(cuda-toolkit-10.1)-check $(cuda-toolkit-10.1)-install $(cuda-toolkit-10.1)-modulefile

else
$($(cuda-toolkit-10.1)-src): $(dir $($(cuda-toolkit-10.1)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cuda-toolkit-10.1)-srcurl)

$($(cuda-toolkit-10.1)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cuda-toolkit-10.1)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cuda-toolkit-10.1)-prefix)/.pkgunpack: $($(cuda-toolkit-10.1)-src) $($(cuda-toolkit-10.1)-srcdir)/.markerfile $($(cuda-toolkit-10.1)-prefix)/.markerfile $$(foreach dep,$$($(cuda-toolkit-10.1)-builddeps),$(modulefilesdir)/$$(dep))
	@touch $@

$($(cuda-toolkit-10.1)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit-10.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit-10.1)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(cuda-toolkit-10.1)-builddir),$($(cuda-toolkit-10.1)-srcdir))
$($(cuda-toolkit-10.1)-builddir)/.markerfile: $($(cuda-toolkit-10.1)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(cuda-toolkit-10.1)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit-10.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit-10.1)-builddir)/.markerfile $($(cuda-toolkit-10.1)-prefix)/.pkgpatch
	@touch $@

$($(cuda-toolkit-10.1)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit-10.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit-10.1)-builddir)/.markerfile $($(cuda-toolkit-10.1)-prefix)/.pkgbuild
	@touch $@

$($(cuda-toolkit-10.1)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cuda-toolkit-10.1)-builddeps),$(modulefilesdir)/$$(dep)) $($(cuda-toolkit-10.1)-builddir)/.markerfile $($(cuda-toolkit-10.1)-prefix)/.pkgcheck
	chmod u+x $($(cuda-toolkit-10.1)-src)
	cd $($(cuda-toolkit-10.1)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cuda-toolkit-10.1)-builddeps) && \
		$($(cuda-toolkit-10.1)-src) --silent --toolkit \
			--toolkitpath=$($(cuda-toolkit-10.1)-prefix) \
			--defaultroot=$($(cuda-toolkit-10.1)-prefix)
	@touch $@

$($(cuda-toolkit-10.1)-modulefile): $(modulefilesdir)/.markerfile $($(cuda-toolkit-10.1)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cuda-toolkit-10.1)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cuda-toolkit-10.1)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cuda-toolkit-10.1)-description)\"" >>$@
	echo "module-whatis \"$($(cuda-toolkit-10.1)-url)\"" >>$@
	printf "$(foreach prereq,$($(cuda-toolkit-10.1)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CUDA_TOOLKIT_ROOT $($(cuda-toolkit-10.1)-prefix)" >>$@
	echo "setenv CUDA_TOOLKIT_INCDIR $($(cuda-toolkit-10.1)-prefix)/include" >>$@
	echo "setenv CUDA_TOOLKIT_INCLUDEDIR $($(cuda-toolkit-10.1)-prefix)/include" >>$@
	echo "setenv CUDA_TOOLKIT_LIBDIR $($(cuda-toolkit-10.1)-prefix)/lib64" >>$@
	echo "setenv CUDA_TOOLKIT_LIBRARYDIR $($(cuda-toolkit-10.1)-prefix)/lib64" >>$@
	echo "prepend-path PATH $($(cuda-toolkit-10.1)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(cuda-toolkit-10.1)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(cuda-toolkit-10.1)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(cuda-toolkit-10.1)-prefix)/lib" >>$@
	echo "prepend-path LIBRARY_PATH $($(cuda-toolkit-10.1)-prefix)/lib64" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cuda-toolkit-10.1)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(cuda-toolkit-10.1)-prefix)/lib64" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(cuda-toolkit-10.1)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(cuda-toolkit-10.1)-prefix)/lib64/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(cuda-toolkit-10.1)-prefix)/share/man" >>$@
	echo "set MSG \"$(cuda-toolkit-10.1)\"" >>$@

$(cuda-toolkit-10.1)-src: $($(cuda-toolkit-10.1)-src)
$(cuda-toolkit-10.1)-unpack: $($(cuda-toolkit-10.1)-prefix)/.pkgunpack
$(cuda-toolkit-10.1)-patch: $($(cuda-toolkit-10.1)-prefix)/.pkgpatch
$(cuda-toolkit-10.1)-build: $($(cuda-toolkit-10.1)-prefix)/.pkgbuild
$(cuda-toolkit-10.1)-check: $($(cuda-toolkit-10.1)-prefix)/.pkgcheck
$(cuda-toolkit-10.1)-install: $($(cuda-toolkit-10.1)-prefix)/.pkginstall
$(cuda-toolkit-10.1)-modulefile: $($(cuda-toolkit-10.1)-modulefile)
$(cuda-toolkit-10.1)-clean:
	rm -rf $($(cuda-toolkit-10.1)-modulefile)
	rm -rf $($(cuda-toolkit-10.1)-prefix)
	rm -rf $($(cuda-toolkit-10.1)-srcdir)
	rm -rf $($(cuda-toolkit-10.1)-src)
$(cuda-toolkit-10.1): $(cuda-toolkit-10.1)-src $(cuda-toolkit-10.1)-unpack $(cuda-toolkit-10.1)-patch $(cuda-toolkit-10.1)-build $(cuda-toolkit-10.1)-check $(cuda-toolkit-10.1)-install $(cuda-toolkit-10.1)-modulefile
endif
