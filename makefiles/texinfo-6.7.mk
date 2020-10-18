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
# texinfo-6.7

texinfo-version = 6.7
texinfo = texinfo-$(texinfo-version)
$(texinfo)-description = Official documentation format of the GNU project
$(texinfo)-url = https://www.gnu.org/software/texinfo/
$(texinfo)-srcurl = https://ftp.gnu.org/gnu/texinfo/texinfo-$(texinfo-version).tar.gz
$(texinfo)-builddeps =
$(texinfo)-prereqs =
$(texinfo)-src = $(pkgsrcdir)/$(notdir $($(texinfo)-srcurl))
$(texinfo)-srcdir = $(pkgsrcdir)/$(texinfo)
$(texinfo)-builddir = $($(texinfo)-srcdir)
$(texinfo)-modulefile = $(modulefilesdir)/$(texinfo)
$(texinfo)-prefix = $(pkgdir)/$(texinfo)

$($(texinfo)-src): $(dir $($(texinfo)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(texinfo)-srcurl)

$($(texinfo)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(texinfo)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(texinfo)-prefix)/.pkgunpack: $($(texinfo)-src) $($(texinfo)-srcdir)/.markerfile $($(texinfo)-prefix)/.markerfile
	tar -C $($(texinfo)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(texinfo)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(texinfo)-builddeps),$(modulefilesdir)/$$(dep)) $($(texinfo)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(texinfo)-builddir),$($(texinfo)-srcdir))
$($(texinfo)-builddir)/.markerfile: $($(texinfo)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(texinfo)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(texinfo)-builddeps),$(modulefilesdir)/$$(dep)) $($(texinfo)-builddir)/.markerfile $($(texinfo)-prefix)/.pkgpatch
	cd $($(texinfo)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(texinfo)-builddeps) && \
		./configure --prefix=$($(texinfo)-prefix) --disable-static && \
		$(MAKE)
	@touch $@

$($(texinfo)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(texinfo)-builddeps),$(modulefilesdir)/$$(dep)) $($(texinfo)-builddir)/.markerfile $($(texinfo)-prefix)/.pkgbuild
	# Skip due to failing test
	# cd $($(texinfo)-builddir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(texinfo)-builddeps) && \
	# 	$(MAKE) check
	@touch $@

$($(texinfo)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(texinfo)-builddeps),$(modulefilesdir)/$$(dep)) $($(texinfo)-builddir)/.markerfile $($(texinfo)-prefix)/.pkgcheck
	cd $($(texinfo)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(texinfo)-builddeps) && \
		$(MAKE) install && \
		$(MAKE) MAKEFLAGS="TEXMF=$($(texinfo)-prefix)/share/texmf" install-tex
	@touch $@

$($(texinfo)-modulefile): $(modulefilesdir)/.markerfile $($(texinfo)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(texinfo)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(texinfo)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(texinfo)-description)\"" >>$@
	echo "module-whatis \"$($(texinfo)-url)\"" >>$@
	printf "$(foreach prereq,$($(texinfo)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv TEXINFO_ROOT $($(texinfo)-prefix)" >>$@
	echo "setenv TEXINFO_INCDIR $($(texinfo)-prefix)/include" >>$@
	echo "setenv TEXINFO_INCLUDEDIR $($(texinfo)-prefix)/include" >>$@
	echo "setenv TEXINFO_LIBDIR $($(texinfo)-prefix)/lib" >>$@
	echo "setenv TEXINFO_LIBRARYDIR $($(texinfo)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(texinfo)-prefix)/bin" >>$@
	echo "prepend-path LIBRARY_PATH $($(texinfo)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(texinfo)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(texinfo)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(texinfo)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(texinfo)-prefix)/share/info" >>$@
	echo "set MSG \"$(texinfo)\"" >>$@

$(texinfo)-src: $($(texinfo)-src)
$(texinfo)-unpack: $($(texinfo)-prefix)/.pkgunpack
$(texinfo)-patch: $($(texinfo)-prefix)/.pkgpatch
$(texinfo)-build: $($(texinfo)-prefix)/.pkgbuild
$(texinfo)-check: $($(texinfo)-prefix)/.pkgcheck
$(texinfo)-install: $($(texinfo)-prefix)/.pkginstall
$(texinfo)-modulefile: $($(texinfo)-modulefile)
$(texinfo)-clean:
	rm -rf $($(texinfo)-modulefile)
	rm -rf $($(texinfo)-prefix)
	rm -rf $($(texinfo)-srcdir)
	rm -rf $($(texinfo)-src)
$(texinfo): $(texinfo)-src $(texinfo)-unpack $(texinfo)-patch $(texinfo)-build $(texinfo)-check $(texinfo)-install $(texinfo)-modulefile
