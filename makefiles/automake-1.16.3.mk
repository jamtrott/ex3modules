# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# automake-1.16.3

automake-version = 1.16.3
automake = automake-$(automake-version)
$(automake)-description = Tool for automatically generating Makefile.in files
$(automake)-url = https://www.gnu.org/software/automake/
$(automake)-srcurl = https://ftp.gnu.org/gnu/automake/automake-$(automake-version).tar.gz
$(automake)-builddeps = 
$(automake)-prereqs =
$(automake)-src = $(pkgsrcdir)/$(notdir $($(automake)-srcurl))
$(automake)-srcdir = $(pkgsrcdir)/$(automake)
$(automake)-builddir = $($(automake)-srcdir)
$(automake)-modulefile = $(modulefilesdir)/$(automake)
$(automake)-prefix = $(pkgdir)/$(automake)

$($(automake)-src): $(dir $($(automake)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(automake)-srcurl)

$($(automake)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(automake)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(automake)-prefix)/.pkgunpack: $$($(automake)-src) $($(automake)-srcdir)/.markerfile $($(automake)-prefix)/.markerfile
	tar -C $($(automake)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(automake)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(automake)-builddeps),$(modulefilesdir)/$$(dep)) $($(automake)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(automake)-builddir),$($(automake)-srcdir))
$($(automake)-builddir)/.markerfile: $($(automake)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(automake)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(automake)-builddeps),$(modulefilesdir)/$$(dep)) $($(automake)-builddir)/.markerfile $($(automake)-prefix)/.pkgpatch
	cd $($(automake)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(automake)-builddeps) && \
		./configure --prefix=$($(automake)-prefix) && \
		$(MAKE)
	@touch $@

$($(automake)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(automake)-builddeps),$(modulefilesdir)/$$(dep)) $($(automake)-builddir)/.markerfile $($(automake)-prefix)/.pkgbuild
	cd $($(automake)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(automake)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(automake)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(automake)-builddeps),$(modulefilesdir)/$$(dep)) $($(automake)-builddir)/.markerfile $($(automake)-prefix)/.pkgcheck
	cd $($(automake)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(automake)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(automake)-modulefile): $(modulefilesdir)/.markerfile $($(automake)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(automake)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(automake)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(automake)-description)\"" >>$@
	echo "module-whatis \"$($(automake)-url)\"" >>$@
	printf "$(foreach prereq,$($(automake)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv AUTOMAKE_ROOT $($(automake)-prefix)" >>$@
	echo "prepend-path PATH $($(automake)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(automake)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(automake)-prefix)/share/info" >>$@
	echo "setenv AUTOMAKE_LIBDIR $($(automake)-prefix)/share/automake-$(shell echo $(automake-version) | cut -d. -f1-2)" >>$@
	echo "setenv ACLOCAL_AUTOMAKE_DIR $($(automake)-prefix)/share/aclocal-$(shell echo $(automake-version) | cut -d. -f1-2)" >>$@
	echo "set MSG \"$(automake)\"" >>$@

$(automake)-src: $$($(automake)-src)
$(automake)-unpack: $($(automake)-prefix)/.pkgunpack
$(automake)-patch: $($(automake)-prefix)/.pkgpatch
$(automake)-build: $($(automake)-prefix)/.pkgbuild
$(automake)-check: $($(automake)-prefix)/.pkgcheck
$(automake)-install: $($(automake)-prefix)/.pkginstall
$(automake)-modulefile: $($(automake)-modulefile)
$(automake)-clean:
	rm -rf $($(automake)-modulefile)
	rm -rf $($(automake)-prefix)
	rm -rf $($(automake)-builddir)
	rm -rf $($(automake)-srcdir)
	rm -rf $($(automake)-src)
$(automake): $(automake)-src $(automake)-unpack $(automake)-patch $(automake)-build $(automake)-check $(automake)-install $(automake)-modulefile
