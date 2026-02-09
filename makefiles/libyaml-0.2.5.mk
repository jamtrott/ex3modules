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
# libyaml-0.2.5

libyaml-version = 0.2.5
libyaml = libyaml-$(libyaml-version)
$(libyaml)-description = YAML parser and emitter library.
$(libyaml)-url = https://pyyaml.org/wiki/LibYAML
$(libyaml)-srcurl = http://pyyaml.org/download/libyaml/yaml-0.2.5.tar.gz
$(libyaml)-builddeps =
$(libyaml)-prereqs =
$(libyaml)-src = $(pkgsrcdir)/$(notdir $($(libyaml)-srcurl))
$(libyaml)-srcdir = $(pkgsrcdir)/$(libyaml)
$(libyaml)-builddir = $($(libyaml)-srcdir)/build
$(libyaml)-modulefile = $(modulefilesdir)/$(libyaml)
$(libyaml)-prefix = $(pkgdir)/$(libyaml)

$($(libyaml)-src): $(dir $($(libyaml)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libyaml)-srcurl)

$($(libyaml)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libyaml)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libyaml)-prefix)/.pkgunpack: $$($(libyaml)-src) $($(libyaml)-srcdir)/.markerfile $($(libyaml)-prefix)/.markerfile $$(foreach dep,$$($(libyaml)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(libyaml)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libyaml)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libyaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(libyaml)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(libyaml)-builddir),$($(libyaml)-srcdir))
$($(libyaml)-builddir)/.markerfile: $($(libyaml)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(libyaml)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libyaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(libyaml)-builddir)/.markerfile $($(libyaml)-prefix)/.pkgpatch
	cd $($(libyaml)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libyaml)-builddeps) && \
		../configure --prefix=$($(libyaml)-prefix) && \
		$(MAKE)
	@touch $@

$($(libyaml)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libyaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(libyaml)-builddir)/.markerfile $($(libyaml)-prefix)/.pkgbuild
	cd $($(libyaml)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libyaml)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libyaml)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libyaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(libyaml)-builddir)/.markerfile $($(libyaml)-prefix)/.pkgcheck
	cd $($(libyaml)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libyaml)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(libyaml)-modulefile): $(modulefilesdir)/.markerfile $($(libyaml)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libyaml)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libyaml)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libyaml)-description)\"" >>$@
	echo "module-whatis \"$($(libyaml)-url)\"" >>$@
	printf "$(foreach prereq,$($(libyaml)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBYAML_ROOT $($(libyaml)-prefix)" >>$@
	echo "setenv LIBYAML_INCDIR $($(libyaml)-prefix)/include" >>$@
	echo "setenv LIBYAML_INCLUDEDIR $($(libyaml)-prefix)/include" >>$@
	echo "setenv LIBYAML_LIBDIR $($(libyaml)-prefix)/lib" >>$@
	echo "setenv LIBYAML_LIBRARYDIR $($(libyaml)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libyaml)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libyaml)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libyaml)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libyaml)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libyaml)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libyaml)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libyaml)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(libyaml)-prefix)/share/info" >>$@
	echo "set MSG \"$(libyaml)\"" >>$@

$(libyaml)-src: $$($(libyaml)-src)
$(libyaml)-unpack: $($(libyaml)-prefix)/.pkgunpack
$(libyaml)-patch: $($(libyaml)-prefix)/.pkgpatch
$(libyaml)-build: $($(libyaml)-prefix)/.pkgbuild
$(libyaml)-check: $($(libyaml)-prefix)/.pkgcheck
$(libyaml)-install: $($(libyaml)-prefix)/.pkginstall
$(libyaml)-modulefile: $($(libyaml)-modulefile)
$(libyaml)-clean:
	rm -rf $($(libyaml)-modulefile)
	rm -rf $($(libyaml)-prefix)
	rm -rf $($(libyaml)-builddir)
	rm -rf $($(libyaml)-srcdir)
	rm -rf $($(libyaml)-src)
$(libyaml): $(libyaml)-src $(libyaml)-unpack $(libyaml)-patch $(libyaml)-build $(libyaml)-check $(libyaml)-install $(libyaml)-modulefile
