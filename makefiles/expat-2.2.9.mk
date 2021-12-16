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
# expat-2.2.9

expat-version = 2.2.9
expat = expat-$(expat-version)
$(expat)-description = C library for parsing XML
$(expat)-url = https://libexpat.github.io/
$(expat)-srcurl = https://github.com/libexpat/libexpat/releases/download/R_$(subst .,_,$(expat-version))/expat-$(expat-version).tar.gz
$(expat)-src = $(pkgsrcdir)/$(expat).tar.gz
$(expat)-srcdir = $(pkgsrcdir)/$(expat)
$(expat)-builddeps =
$(expat)-prereqs =
$(expat)-modulefile = $(modulefilesdir)/$(expat)
$(expat)-prefix = $(pkgdir)/$(expat)

$($(expat)-src): $(dir $($(expat)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(expat)-srcurl)

$($(expat)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(expat)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(expat)-prefix)/.pkgunpack: $($(expat)-src) $($(expat)-srcdir)/.markerfile $($(expat)-prefix)/.markerfile $$(foreach dep,$$($(expat)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(expat)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(expat)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(expat)-builddeps),$(modulefilesdir)/$$(dep)) $($(expat)-prefix)/.pkgunpack
	@touch $@

$($(expat)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(expat)-builddeps),$(modulefilesdir)/$$(dep)) $($(expat)-prefix)/.pkgpatch
	cd $($(expat)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(expat)-builddeps) && \
		./configure --prefix=$($(expat)-prefix) \
		--without-docbook && \
		$(MAKE)
	@touch $@

$($(expat)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(expat)-builddeps),$(modulefilesdir)/$$(dep)) $($(expat)-prefix)/.pkgbuild
	cd $($(expat)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(expat)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(expat)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(expat)-builddeps),$(modulefilesdir)/$$(dep)) $($(expat)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(expat)-prefix) -C $($(expat)-srcdir) install
	@touch $@

$($(expat)-modulefile): $(modulefilesdir)/.markerfile $($(expat)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(expat)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(expat)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(expat)-description)\"" >>$@
	echo "module-whatis \"$($(expat)-url)\"" >>$@
	printf "$(foreach prereq,$($(expat)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv EXPAT_ROOT $($(expat)-prefix)" >>$@
	echo "setenv EXPAT_INCDIR $($(expat)-prefix)/include" >>$@
	echo "setenv EXPAT_INCLUDEDIR $($(expat)-prefix)/include" >>$@
	echo "setenv EXPAT_LIBDIR $($(expat)-prefix)/lib" >>$@
	echo "setenv EXPAT_LIBRARYDIR $($(expat)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(expat)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(expat)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(expat)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(expat)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(expat)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(expat)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(expat)\"" >>$@

$(expat)-src: $($(expat)-src)
$(expat)-unpack: $($(expat)-prefix)/.pkgunpack
$(expat)-patch: $($(expat)-prefix)/.pkgpatch
$(expat)-build: $($(expat)-prefix)/.pkgbuild
$(expat)-check: $($(expat)-prefix)/.pkgcheck
$(expat)-install: $($(expat)-prefix)/.pkginstall
$(expat)-modulefile: $($(expat)-modulefile)
$(expat)-clean:
	rm -rf $($(expat)-modulefile)
	rm -rf $($(expat)-prefix)
	rm -rf $($(expat)-srcdir)
	rm -rf $($(expat)-src)
$(expat): $(expat)-src $(expat)-unpack $(expat)-patch $(expat)-build $(expat)-check $(expat)-install $(expat)-modulefile
