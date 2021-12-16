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
# opencl-headers-2020.06.16

opencl-headers-version = 2020.06.16
opencl-headers = opencl-headers-$(opencl-headers-version)
$(opencl-headers)-description = Khronos OpenCL-Headers
$(opencl-headers)-url = https://github.com/KhronosGroup/OpenCL-Headers
$(opencl-headers)-srcurl = https://github.com/KhronosGroup/OpenCL-Headers/archive/v$(opencl-headers-version).tar.gz
$(opencl-headers)-builddeps =
$(opencl-headers)-prereqs =
$(opencl-headers)-src = $(pkgsrcdir)/opencl-headers-$(notdir $($(opencl-headers)-srcurl))
$(opencl-headers)-srcdir = $(pkgsrcdir)/$(opencl-headers)
$(opencl-headers)-builddir = $($(opencl-headers)-srcdir)/build
$(opencl-headers)-modulefile = $(modulefilesdir)/$(opencl-headers)
$(opencl-headers)-prefix = $(pkgdir)/$(opencl-headers)

$($(opencl-headers)-src): $(dir $($(opencl-headers)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(opencl-headers)-srcurl)

$($(opencl-headers)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(opencl-headers)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(opencl-headers)-prefix)/.pkgunpack: $$($(opencl-headers)-src) $($(opencl-headers)-srcdir)/.markerfile $($(opencl-headers)-prefix)/.markerfile $$(foreach dep,$$($(opencl-headers)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(opencl-headers)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(opencl-headers)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(opencl-headers)-builddeps),$(modulefilesdir)/$$(dep)) $($(opencl-headers)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(opencl-headers)-builddir),$($(opencl-headers)-srcdir))
$($(opencl-headers)-builddir)/.markerfile: $($(opencl-headers)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(opencl-headers)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(opencl-headers)-builddeps),$(modulefilesdir)/$$(dep)) $($(opencl-headers)-builddir)/.markerfile $($(opencl-headers)-prefix)/.pkgpatch
	@touch $@

$($(opencl-headers)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(opencl-headers)-builddeps),$(modulefilesdir)/$$(dep)) $($(opencl-headers)-builddir)/.markerfile $($(opencl-headers)-prefix)/.pkgbuild
	@touch $@

$($(opencl-headers)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(opencl-headers)-builddeps),$(modulefilesdir)/$$(dep)) $($(opencl-headers)-builddir)/.markerfile $($(opencl-headers)-prefix)/.pkgcheck
	$(INSTALL) -d $($(opencl-headers)-prefix)/include/CL
	$(INSTALL) -m=644 -t $($(opencl-headers)-prefix)/include/CL $($(opencl-headers)-srcdir)/CL/*
	@touch $@

$($(opencl-headers)-modulefile): $(modulefilesdir)/.markerfile $($(opencl-headers)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(opencl-headers)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(opencl-headers)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(opencl-headers)-description)\"" >>$@
	echo "module-whatis \"$($(opencl-headers)-url)\"" >>$@
	printf "$(foreach prereq,$($(opencl-headers)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OPENCL_HEADERS_ROOT $($(opencl-headers)-prefix)" >>$@
	echo "setenv OPENCL_HEADERS_INCDIR $($(opencl-headers)-prefix)/include" >>$@
	echo "setenv OPENCL_HEADERS_INCLUDEDIR $($(opencl-headers)-prefix)/include" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(opencl-headers)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(opencl-headers)-prefix)/include" >>$@
	echo "set MSG \"$(opencl-headers)\"" >>$@

$(opencl-headers)-src: $$($(opencl-headers)-src)
$(opencl-headers)-unpack: $($(opencl-headers)-prefix)/.pkgunpack
$(opencl-headers)-patch: $($(opencl-headers)-prefix)/.pkgpatch
$(opencl-headers)-build: $($(opencl-headers)-prefix)/.pkgbuild
$(opencl-headers)-check: $($(opencl-headers)-prefix)/.pkgcheck
$(opencl-headers)-install: $($(opencl-headers)-prefix)/.pkginstall
$(opencl-headers)-modulefile: $($(opencl-headers)-modulefile)
$(opencl-headers)-clean:
	rm -rf $($(opencl-headers)-modulefile)
	rm -rf $($(opencl-headers)-prefix)
	rm -rf $($(opencl-headers)-builddir)
	rm -rf $($(opencl-headers)-srcdir)
	rm -rf $($(opencl-headers)-src)
$(opencl-headers): $(opencl-headers)-src $(opencl-headers)-unpack $(opencl-headers)-patch $(opencl-headers)-build $(opencl-headers)-check $(opencl-headers)-install $(opencl-headers)-modulefile
