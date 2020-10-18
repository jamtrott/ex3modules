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
# pcre-8.44

pcre-version = 8.44
pcre = pcre-$(pcre-version)
$(pcre)-description = Library for regular expression pattern matching
$(pcre)-url = https://www.pcre.org/
$(pcre)-srcurl = https://ftp.pcre.org/pub/pcre/pcre-$(pcre-version).tar.gz
$(pcre)-src = $(pkgsrcdir)/$(notdir $($(pcre)-srcurl))
$(pcre)-srcdir = $(pkgsrcdir)/$(pcre)
$(pcre)-builddeps = $(readline)
$(pcre)-prereqs = $(readline)
$(pcre)-modulefile = $(modulefilesdir)/$(pcre)
$(pcre)-prefix = $(pkgdir)/$(pcre)

$($(pcre)-src): $(dir $($(pcre)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pcre)-srcurl)

$($(pcre)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(pcre)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(pcre)-prefix)/.pkgunpack: $($(pcre)-src) $($(pcre)-srcdir)/.markerfile $($(pcre)-prefix)/.markerfile
	tar -C $($(pcre)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pcre)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pcre)-builddeps),$(modulefilesdir)/$$(dep)) $($(pcre)-prefix)/.pkgunpack
	@touch $@

$($(pcre)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pcre)-builddeps),$(modulefilesdir)/$$(dep)) $($(pcre)-prefix)/.pkgpatch
	cd $($(pcre)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pcre)-builddeps) && \
		./configure --prefix=$($(pcre)-prefix) && \
		$(MAKE)
	@touch $@

$($(pcre)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pcre)-builddeps),$(modulefilesdir)/$$(dep)) $($(pcre)-prefix)/.pkgbuild
	cd $($(pcre)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pcre)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(pcre)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pcre)-builddeps),$(modulefilesdir)/$$(dep)) $($(pcre)-prefix)/.pkgcheck
	$(MAKE) -C $($(pcre)-srcdir) install
	@touch $@

$($(pcre)-modulefile): $(modulefilesdir)/.markerfile $($(pcre)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pcre)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pcre)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pcre)-description)\"" >>$@
	echo "module-whatis \"$($(pcre)-url)\"" >>$@
	printf "$(foreach prereq,$($(pcre)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PCRE_ROOT $($(pcre)-prefix)" >>$@
	echo "setenv PCRE_INCDIR $($(pcre)-prefix)/include" >>$@
	echo "setenv PCRE_INCLUDEDIR $($(pcre)-prefix)/include" >>$@
	echo "setenv PCRE_LIBDIR $($(pcre)-prefix)/lib" >>$@
	echo "setenv PCRE_LIBRARYDIR $($(pcre)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(pcre)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pcre)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pcre)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(pcre)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(pcre)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(pcre)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(pcre)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(pcre)-prefix)/share/info" >>$@
	echo "set MSG \"$(pcre)\"" >>$@

$(pcre)-src: $($(pcre)-src)
$(pcre)-unpack: $($(pcre)-prefix)/.pkgunpack
$(pcre)-patch: $($(pcre)-prefix)/.pkgpatch
$(pcre)-build: $($(pcre)-prefix)/.pkgbuild
$(pcre)-check: $($(pcre)-prefix)/.pkgcheck
$(pcre)-install: $($(pcre)-prefix)/.pkginstall
$(pcre)-modulefile: $($(pcre)-modulefile)
$(pcre)-clean:
	rm -rf $($(pcre)-modulefile)
	rm -rf $($(pcre)-prefix)
	rm -rf $($(pcre)-srcdir)
	rm -rf $($(pcre)-src)
$(pcre): $(pcre)-src $(pcre)-unpack $(pcre)-patch $(pcre)-build $(pcre)-check $(pcre)-install $(pcre)-modulefile
