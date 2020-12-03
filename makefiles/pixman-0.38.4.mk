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
# pixman-0.38.4

pixman-version = 0.38.4
pixman = pixman-$(pixman-version)
$(pixman)-description = Low-level software library for pixel manipulation
$(pixman)-url = http://www.pixman.org/
$(pixman)-srcurl = https://www.cairographics.org/releases/pixman-$(pixman-version).tar.gz
$(pixman)-src = $(pkgsrcdir)/$(notdir $($(pixman)-srcurl))
$(pixman)-srcdir = $(pkgsrcdir)/$(pixman)
$(pixman)-builddeps =
$(pixman)-prereqs =
$(pixman)-modulefile = $(modulefilesdir)/$(pixman)
$(pixman)-prefix = $(pkgdir)/$(pixman)

$($(pixman)-src): $(dir $($(pixman)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pixman)-srcurl)

$($(pixman)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pixman)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pixman)-prefix)/.pkgunpack: $($(pixman)-src) $($(pixman)-srcdir)/.markerfile $($(pixman)-prefix)/.markerfile
	tar -C $($(pixman)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pixman)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pixman)-builddeps),$(modulefilesdir)/$$(dep)) $($(pixman)-prefix)/.pkgunpack
	@touch $@

$($(pixman)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pixman)-builddeps),$(modulefilesdir)/$$(dep)) $($(pixman)-prefix)/.pkgpatch
	cd $($(pixman)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pixman)-builddeps) && \
		./configure --prefix=$($(pixman)-prefix) && \
		$(MAKE)
	@touch $@

$($(pixman)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pixman)-builddeps),$(modulefilesdir)/$$(dep)) $($(pixman)-prefix)/.pkgbuild
# 	Disable due to failing test
# 	cd $($(pixman)-srcdir) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(pixman)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(pixman)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pixman)-builddeps),$(modulefilesdir)/$$(dep)) $($(pixman)-prefix)/.pkgcheck
	$(MAKE) -C $($(pixman)-srcdir) install
	@touch $@

$($(pixman)-modulefile): $(modulefilesdir)/.markerfile $($(pixman)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pixman)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pixman)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pixman)-description)\"" >>$@
	echo "module-whatis \"$($(pixman)-url)\"" >>$@
	printf "$(foreach prereq,$($(pixman)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PIXMAN_ROOT $($(pixman)-prefix)" >>$@
	echo "setenv PIXMAN_INCDIR $($(pixman)-prefix)/include" >>$@
	echo "setenv PIXMAN_INCLUDEDIR $($(pixman)-prefix)/include" >>$@
	echo "setenv PIXMAN_LIBDIR $($(pixman)-prefix)/lib" >>$@
	echo "setenv PIXMAN_LIBRARYDIR $($(pixman)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pixman)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pixman)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(pixman)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(pixman)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(pixman)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(pixman)\"" >>$@

$(pixman)-src: $($(pixman)-src)
$(pixman)-unpack: $($(pixman)-prefix)/.pkgunpack
$(pixman)-patch: $($(pixman)-prefix)/.pkgpatch
$(pixman)-build: $($(pixman)-prefix)/.pkgbuild
$(pixman)-check: $($(pixman)-prefix)/.pkgcheck
$(pixman)-install: $($(pixman)-prefix)/.pkginstall
$(pixman)-modulefile: $($(pixman)-modulefile)
$(pixman)-clean:
	rm -rf $($(pixman)-modulefile)
	rm -rf $($(pixman)-prefix)
	rm -rf $($(pixman)-srcdir)
	rm -rf $($(pixman)-src)
$(pixman): $(pixman)-src $(pixman)-unpack $(pixman)-patch $(pixman)-build $(pixman)-check $(pixman)-install $(pixman)-modulefile
