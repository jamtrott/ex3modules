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
# matio-1.5.17

matio-version = 1.5.17
matio = matio-$(matio-version)
$(matio)-description = MATLAB MAT file I/O library
$(matio)-url = https://sourceforge.net/projects/matio/
$(matio)-srcurl = https://github.com/tbeu/matio/releases/download/v$(matio-version)/matio-$(matio-version).tar.gz
$(matio)-builddeps = $(hdf5)
$(matio)-prereqs = $(hdf5)
$(matio)-src = $(pkgsrcdir)/$(notdir $($(matio)-srcurl))
$(matio)-srcdir = $(pkgsrcdir)/$(matio)
$(matio)-builddir = $($(matio)-srcdir)
$(matio)-modulefile = $(modulefilesdir)/$(matio)
$(matio)-prefix = $(pkgdir)/$(matio)

$($(matio)-src): $(dir $($(matio)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(matio)-srcurl)

$($(matio)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(matio)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(matio)-prefix)/.pkgunpack: $($(matio)-src) $($(matio)-srcdir)/.markerfile $($(matio)-prefix)/.markerfile $$(foreach dep,$$($(matio)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(matio)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(matio)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(matio)-builddeps),$(modulefilesdir)/$$(dep)) $($(matio)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(matio)-builddir),$($(matio)-srcdir))
$($(matio)-builddir)/.markerfile: $($(matio)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(matio)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(matio)-builddeps),$(modulefilesdir)/$$(dep)) $($(matio)-builddir)/.markerfile $($(matio)-prefix)/.pkgpatch
	cd $($(matio)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(matio)-builddeps) && \
		./configure --prefix=$($(matio)-prefix) && \
		$(MAKE)
	@touch $@

$($(matio)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(matio)-builddeps),$(modulefilesdir)/$$(dep)) $($(matio)-builddir)/.markerfile $($(matio)-prefix)/.pkgbuild
	cd $($(matio)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(matio)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(matio)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(matio)-builddeps),$(modulefilesdir)/$$(dep)) $($(matio)-builddir)/.markerfile $($(matio)-prefix)/.pkgcheck
	cd $($(matio)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(matio)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(matio)-modulefile): $(modulefilesdir)/.markerfile $($(matio)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(matio)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(matio)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(matio)-description)\"" >>$@
	echo "module-whatis \"$($(matio)-url)\"" >>$@
	printf "$(foreach prereq,$($(matio)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MATIO_ROOT $($(matio)-prefix)" >>$@
	echo "setenv MATIO_INCDIR $($(matio)-prefix)/include" >>$@
	echo "setenv MATIO_INCLUDEDIR $($(matio)-prefix)/include" >>$@
	echo "setenv MATIO_LIBDIR $($(matio)-prefix)/lib" >>$@
	echo "setenv MATIO_LIBRARYDIR $($(matio)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(matio)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(matio)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(matio)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(matio)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(matio)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(matio)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(matio)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(matio)-prefix)/share/info" >>$@
	echo "set MSG \"$(matio)\"" >>$@

$(matio)-src: $($(matio)-src)
$(matio)-unpack: $($(matio)-prefix)/.pkgunpack
$(matio)-patch: $($(matio)-prefix)/.pkgpatch
$(matio)-build: $($(matio)-prefix)/.pkgbuild
$(matio)-check: $($(matio)-prefix)/.pkgcheck
$(matio)-install: $($(matio)-prefix)/.pkginstall
$(matio)-modulefile: $($(matio)-modulefile)
$(matio)-clean:
	rm -rf $($(matio)-modulefile)
	rm -rf $($(matio)-prefix)
	rm -rf $($(matio)-srcdir)
	rm -rf $($(matio)-src)
$(matio): $(matio)-src $(matio)-unpack $(matio)-patch $(matio)-build $(matio)-check $(matio)-install $(matio)-modulefile
