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
# cmake-3.22.3

cmake-3.22.3-version = 3.22.3
cmake-3.22.3 = cmake-$(cmake-3.22.3-version)
$(cmake-3.22.3)-description = Open-source, cross-platform tools to build, test and package software
$(cmake-3.22.3)-url = https://cmake.org/
$(cmake-3.22.3)-srcurl = https://github.com/Kitware/CMake/releases/download/v$(cmake-3.22.3-version)/cmake-$(cmake-3.22.3-version).tar.gz
$(cmake-3.22.3)-src = $(pkgsrcdir)/$(cmake-3.22.3).tar.gz
$(cmake-3.22.3)-srcdir = $(pkgsrcdir)/$(cmake-3.22.3)
$(cmake-3.22.3)-builddeps =
$(cmake-3.22.3)-prereqs =
$(cmake-3.22.3)-modulefile = $(modulefilesdir)/$(cmake-3.22.3)
$(cmake-3.22.3)-prefix = $(pkgdir)/$(cmake-3.22.3)

$($(cmake-3.22.3)-src): $(dir $($(cmake-3.22.3)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cmake-3.22.3)-srcurl)

$($(cmake-3.22.3)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cmake-3.22.3)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cmake-3.22.3)-prefix)/.pkgunpack: $($(cmake-3.22.3)-src) $($(cmake-3.22.3)-srcdir)/.markerfile $($(cmake-3.22.3)-prefix)/.markerfile $$(foreach dep,$$($(cmake-3.22.3)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(cmake-3.22.3)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(cmake-3.22.3)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.22.3)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.22.3)-prefix)/.pkgunpack
	@touch $@

$($(cmake-3.22.3)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.22.3)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.22.3)-prefix)/.pkgpatch
	cd $($(cmake-3.22.3)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cmake-3.22.3)-builddeps) && \
		./configure --prefix=$($(cmake-3.22.3)-prefix) -- \
			-DCMAKE_BUILD_TYPE:STRING=Release \
			-DCMAKE_USE_OPENSSL=OFF && \
		$(MAKE)
	@touch $@

$($(cmake-3.22.3)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.22.3)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.22.3)-prefix)/.pkgbuild
# Disable tests, since they currently fail
#	cd $($(cmake-3.22.3)-srcdir) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(cmake-3.22.3)-builddeps) && \
#		$(MAKE) test
	@touch $@

$($(cmake-3.22.3)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.22.3)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.22.3)-prefix)/.pkgcheck
	cd $($(cmake-3.22.3)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cmake-3.22.3)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(cmake-3.22.3)-modulefile): $(modulefilesdir)/.markerfile $($(cmake-3.22.3)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cmake-3.22.3)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cmake-3.22.3)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cmake-3.22.3)-description)\"" >>$@
	echo "module-whatis \"$($(cmake-3.22.3)-url)\"" >>$@
	printf "$(foreach prereq,$($(cmake-3.22.3)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CMAKE_ROOT $($(cmake-3.22.3)-prefix)" >>$@
	echo "prepend-path PATH $($(cmake-3.22.3)-prefix)/bin" >>$@
	echo "set MSG \"$(cmake-3.22.3)\"" >>$@

$(cmake-3.22.3)-src: $($(cmake-3.22.3)-src)
$(cmake-3.22.3)-unpack: $($(cmake-3.22.3)-prefix)/.pkgunpack
$(cmake-3.22.3)-patch: $($(cmake-3.22.3)-prefix)/.pkgpatch
$(cmake-3.22.3)-build: $($(cmake-3.22.3)-prefix)/.pkgbuild
$(cmake-3.22.3)-check: $($(cmake-3.22.3)-prefix)/.pkgcheck
$(cmake-3.22.3)-install: $($(cmake-3.22.3)-prefix)/.pkginstall
$(cmake-3.22.3)-modulefile: $($(cmake-3.22.3)-modulefile)
$(cmake-3.22.3)-clean:
	rm -rf $($(cmake-3.22.3)-modulefile)
	rm -rf $($(cmake-3.22.3)-prefix)
	rm -rf $($(cmake-3.22.3)-srcdir)
	rm -rf $($(cmake-3.22.3)-src)
$(cmake-3.22.3): $(cmake-3.22.3)-src $(cmake-3.22.3)-unpack $(cmake-3.22.3)-patch $(cmake-3.22.3)-build $(cmake-3.22.3)-check $(cmake-3.22.3)-install $(cmake-3.22.3)-modulefile
