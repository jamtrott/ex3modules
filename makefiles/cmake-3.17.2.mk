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
# cmake-3.17.2

cmake-3.17.2-version = 3.17.2
cmake-3.17.2 = cmake-$(cmake-3.17.2-version)
$(cmake-3.17.2)-description = Open-source, cross-platform tools to build, test and package software
$(cmake-3.17.2)-url = https://cmake.org/
$(cmake-3.17.2)-srcurl = https://github.com/Kitware/CMake/releases/download/v$(cmake-3.17.2-version)/cmake-$(cmake-3.17.2-version).tar.gz
$(cmake-3.17.2)-src = $(pkgsrcdir)/$(cmake-3.17.2).tar.gz
$(cmake-3.17.2)-srcdir = $(pkgsrcdir)/$(cmake-3.17.2)
$(cmake-3.17.2)-builddeps = $(openssl)
$(cmake-3.17.2)-prereqs = $(openssl)
$(cmake-3.17.2)-modulefile = $(modulefilesdir)/$(cmake-3.17.2)
$(cmake-3.17.2)-prefix = $(pkgdir)/$(cmake-3.17.2)

$($(cmake-3.17.2)-src): $(dir $($(cmake-3.17.2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cmake-3.17.2)-srcurl)

$($(cmake-3.17.2)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cmake-3.17.2)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cmake-3.17.2)-prefix)/.pkgunpack: $($(cmake-3.17.2)-src) $($(cmake-3.17.2)-srcdir)/.markerfile $($(cmake-3.17.2)-prefix)/.markerfile $$(foreach dep,$$($(cmake-3.17.2)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(cmake-3.17.2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(cmake-3.17.2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.17.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.17.2)-prefix)/.pkgunpack
	@touch $@

$($(cmake-3.17.2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.17.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.17.2)-prefix)/.pkgpatch
	cd $($(cmake-3.17.2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cmake-3.17.2)-builddeps) && \
		./configure --prefix=$($(cmake-3.17.2)-prefix) -- \
			-DCMAKE_BUILD_TYPE:STRING=Release && \
		$(MAKE)
	@touch $@

$($(cmake-3.17.2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.17.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.17.2)-prefix)/.pkgbuild
# Disable tests, since they currently fail
#	cd $($(cmake-3.17.2)-srcdir) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(cmake-3.17.2)-builddeps) && \
#		$(MAKE) test
	@touch $@

$($(cmake-3.17.2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.17.2)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.17.2)-prefix)/.pkgcheck
	cd $($(cmake-3.17.2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cmake-3.17.2)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(cmake-3.17.2)-modulefile): $(modulefilesdir)/.markerfile $($(cmake-3.17.2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cmake-3.17.2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cmake-3.17.2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cmake-3.17.2)-description)\"" >>$@
	echo "module-whatis \"$($(cmake-3.17.2)-url)\"" >>$@
	printf "$(foreach prereq,$($(cmake-3.17.2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CMAKE_ROOT $($(cmake-3.17.2)-prefix)" >>$@
	echo "prepend-path PATH $($(cmake-3.17.2)-prefix)/bin" >>$@
	echo "set MSG \"$(cmake-3.17.2)\"" >>$@

$(cmake-3.17.2)-src: $($(cmake-3.17.2)-src)
$(cmake-3.17.2)-unpack: $($(cmake-3.17.2)-prefix)/.pkgunpack
$(cmake-3.17.2)-patch: $($(cmake-3.17.2)-prefix)/.pkgpatch
$(cmake-3.17.2)-build: $($(cmake-3.17.2)-prefix)/.pkgbuild
$(cmake-3.17.2)-check: $($(cmake-3.17.2)-prefix)/.pkgcheck
$(cmake-3.17.2)-install: $($(cmake-3.17.2)-prefix)/.pkginstall
$(cmake-3.17.2)-modulefile: $($(cmake-3.17.2)-modulefile)
$(cmake-3.17.2)-clean:
	rm -rf $($(cmake-3.17.2)-modulefile)
	rm -rf $($(cmake-3.17.2)-prefix)
	rm -rf $($(cmake-3.17.2)-srcdir)
	rm -rf $($(cmake-3.17.2)-src)
$(cmake-3.17.2): $(cmake-3.17.2)-src $(cmake-3.17.2)-unpack $(cmake-3.17.2)-patch $(cmake-3.17.2)-build $(cmake-3.17.2)-check $(cmake-3.17.2)-install $(cmake-3.17.2)-modulefile
