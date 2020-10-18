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
# example-1.0

example-version = 1.0
example = example-$(example-version)
$(example)-description =
$(example)-url =
$(example)-srcurl =
$(example)-builddeps =
$(example)-prereqs =
$(example)-src = $(pkgsrcdir)/$(notdir $($(example)-srcurl))
$(example)-srcdir = $(pkgsrcdir)/$(example)
$(example)-builddir = $($(example)-srcdir)
$(example)-modulefile = $(modulefilesdir)/$(example)
$(example)-prefix = $(pkgdir)/$(example)

$($(example)-src): $(dir $($(example)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(example)-srcurl)

$($(example)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(example)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(example)-prefix)/.pkgunpack: $$($(example)-src) $($(example)-srcdir)/.markerfile $($(example)-prefix)/.markerfile
	tar -C $($(example)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(example)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(example)-builddeps),$(modulefilesdir)/$$(dep)) $($(example)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(example)-builddir),$($(example)-srcdir))
$($(example)-builddir)/.markerfile: $($(example)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(example)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(example)-builddeps),$(modulefilesdir)/$$(dep)) $($(example)-builddir)/.markerfile $($(example)-prefix)/.pkgpatch
	cd $($(example)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(example)-builddeps) && \
		./configure --prefix=$($(example)-prefix) && \
		$(MAKE)
	@touch $@

$($(example)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(example)-builddeps),$(modulefilesdir)/$$(dep)) $($(example)-builddir)/.markerfile $($(example)-prefix)/.pkgbuild
	cd $($(example)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(example)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(example)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(example)-builddeps),$(modulefilesdir)/$$(dep)) $($(example)-builddir)/.markerfile $($(example)-prefix)/.pkgcheck
	cd $($(example)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(example)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(example)-modulefile): $(modulefilesdir)/.markerfile $($(example)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(example)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(example)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(example)-description)\"" >>$@
	echo "module-whatis \"$($(example)-url)\"" >>$@
	printf "$(foreach prereq,$($(example)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv EXAMPLE_ROOT $($(example)-prefix)" >>$@
	echo "setenv EXAMPLE_INCDIR $($(example)-prefix)/include" >>$@
	echo "setenv EXAMPLE_INCLUDEDIR $($(example)-prefix)/include" >>$@
	echo "setenv EXAMPLE_LIBDIR $($(example)-prefix)/lib" >>$@
	echo "setenv EXAMPLE_LIBRARYDIR $($(example)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(example)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(example)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(example)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(example)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(example)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(example)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(example)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(example)-prefix)/share/info" >>$@
	echo "set MSG \"$(example)\"" >>$@

$(example)-src: $$($(example)-src)
$(example)-unpack: $($(example)-prefix)/.pkgunpack
$(example)-patch: $($(example)-prefix)/.pkgpatch
$(example)-build: $($(example)-prefix)/.pkgbuild
$(example)-check: $($(example)-prefix)/.pkgcheck
$(example)-install: $($(example)-prefix)/.pkginstall
$(example)-modulefile: $($(example)-modulefile)
$(example)-clean:
	rm -rf $($(example)-modulefile)
	rm -rf $($(example)-prefix)
	rm -rf $($(example)-srcdir)
	rm -rf $($(example)-src)
$(example): $(example)-src $(example)-unpack $(example)-patch $(example)-build $(example)-check $(example)-install $(example)-modulefile
