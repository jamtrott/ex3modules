# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# cmake-3.31.11

cmake-3.31.11-version = 3.31.11
cmake-3.31.11 = cmake-$(cmake-3.31.11-version)
$(cmake-3.31.11)-description = Open-source, cross-platform tools to build, test and package software
$(cmake-3.31.11)-url = https://cmake.org/
$(cmake-3.31.11)-srcurl = https://github.com/Kitware/CMake/releases/download/v$(cmake-3.31.11-version)/cmake-$(cmake-3.31.11-version).tar.gz
$(cmake-3.31.11)-src = $(pkgsrcdir)/$(cmake-3.31.11).tar.gz
$(cmake-3.31.11)-srcdir = $(pkgsrcdir)/$(cmake-3.31.11)
$(cmake-3.31.11)-builddeps =
$(cmake-3.31.11)-prereqs =
$(cmake-3.31.11)-modulefile = $(modulefilesdir)/$(cmake-3.31.11)
$(cmake-3.31.11)-prefix = $(pkgdir)/$(cmake-3.31.11)

$($(cmake-3.31.11)-src): $(dir $($(cmake-3.31.11)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(cmake-3.31.11)-srcurl)

$($(cmake-3.31.11)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cmake-3.31.11)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(cmake-3.31.11)-prefix)/.pkgunpack: $($(cmake-3.31.11)-src) $($(cmake-3.31.11)-srcdir)/.markerfile $($(cmake-3.31.11)-prefix)/.markerfile $$(foreach dep,$$($(cmake-3.31.11)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(cmake-3.31.11)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(cmake-3.31.11)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.31.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.31.11)-prefix)/.pkgunpack
	@touch $@

$($(cmake-3.31.11)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.31.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.31.11)-prefix)/.pkgpatch
	cd $($(cmake-3.31.11)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cmake-3.31.11)-builddeps) && \
		./bootstrap --system-curl && \
		./configure --prefix=$($(cmake-3.31.11)-prefix) -- \
			-DCMAKE_BUILD_TYPE:STRING=Release \
			-DCMAKE_USE_OPENSSL=OFF && \
		$(MAKE)
	@touch $@

$($(cmake-3.31.11)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.31.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.31.11)-prefix)/.pkgbuild
	@touch $@

$($(cmake-3.31.11)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(cmake-3.31.11)-builddeps),$(modulefilesdir)/$$(dep)) $($(cmake-3.31.11)-prefix)/.pkgcheck
	cd $($(cmake-3.31.11)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(cmake-3.31.11)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(cmake-3.31.11)-modulefile): $(modulefilesdir)/.markerfile $($(cmake-3.31.11)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(cmake-3.31.11)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(cmake-3.31.11)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(cmake-3.31.11)-description)\"" >>$@
	echo "module-whatis \"$($(cmake-3.31.11)-url)\"" >>$@
	printf "$(foreach prereq,$($(cmake-3.31.11)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv CMAKE_ROOT $($(cmake-3.31.11)-prefix)" >>$@
	echo "prepend-path PATH $($(cmake-3.31.11)-prefix)/bin" >>$@
	echo "set MSG \"$(cmake-3.31.11)\"" >>$@

$(cmake-3.31.11)-src: $($(cmake-3.31.11)-src)
$(cmake-3.31.11)-unpack: $($(cmake-3.31.11)-prefix)/.pkgunpack
$(cmake-3.31.11)-patch: $($(cmake-3.31.11)-prefix)/.pkgpatch
$(cmake-3.31.11)-build: $($(cmake-3.31.11)-prefix)/.pkgbuild
$(cmake-3.31.11)-check: $($(cmake-3.31.11)-prefix)/.pkgcheck
$(cmake-3.31.11)-install: $($(cmake-3.31.11)-prefix)/.pkginstall
$(cmake-3.31.11)-modulefile: $($(cmake-3.31.11)-modulefile)
$(cmake-3.31.11)-clean:
	rm -rf $($(cmake-3.31.11)-modulefile)
	rm -rf $($(cmake-3.31.11)-prefix)
	rm -rf $($(cmake-3.31.11)-srcdir)
	rm -rf $($(cmake-3.31.11)-src)
$(cmake-3.31.11): $(cmake-3.31.11)-src $(cmake-3.31.11)-unpack $(cmake-3.31.11)-patch $(cmake-3.31.11)-build $(cmake-3.31.11)-check $(cmake-3.31.11)-install $(cmake-3.31.11)-modulefile
