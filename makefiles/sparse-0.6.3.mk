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
# sparse-0.6.3

sparse-version = 0.6.3
sparse = sparse-$(sparse-version)
$(sparse)-description = Semantic checker for C programs
$(sparse)-url = https://www.kernel.org/doc/html/latest/dev-tools/sparse.html
$(sparse)-srcurl = https://mirrors.edge.kernel.org/pub/software/devel/sparse/dist/sparse-0.6.3.tar.gz
$(sparse)-builddeps =
$(sparse)-prereqs =
$(sparse)-src = $(pkgsrcdir)/$(notdir $($(sparse)-srcurl))
$(sparse)-srcdir = $(pkgsrcdir)/$(sparse)
$(sparse)-builddir = $($(sparse)-srcdir)
$(sparse)-modulefile = $(modulefilesdir)/$(sparse)
$(sparse)-prefix = $(pkgdir)/$(sparse)

$($(sparse)-src): $(dir $($(sparse)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(sparse)-srcurl)

$($(sparse)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(sparse)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(sparse)-prefix)/.pkgunpack: $($(sparse)-src) $($(sparse)-srcdir)/.markerfile $($(sparse)-prefix)/.markerfile
	tar -C $($(sparse)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(sparse)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sparse)-builddeps),$(modulefilesdir)/$$(dep)) $($(sparse)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(sparse)-builddir),$($(sparse)-srcdir))
$($(sparse)-builddir)/.markerfile: $($(sparse)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(sparse)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sparse)-builddeps),$(modulefilesdir)/$$(dep)) $($(sparse)-builddir)/.markerfile $($(sparse)-prefix)/.pkgpatch
	cd $($(sparse)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(sparse)-builddeps) && \
		$(MAKE)
	@touch $@

$($(sparse)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sparse)-builddeps),$(modulefilesdir)/$$(dep)) $($(sparse)-builddir)/.markerfile $($(sparse)-prefix)/.pkgbuild
	cd $($(sparse)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(sparse)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(sparse)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sparse)-builddeps),$(modulefilesdir)/$$(dep)) $($(sparse)-builddir)/.markerfile $($(sparse)-prefix)/.pkgcheck
	cd $($(sparse)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(sparse)-builddeps) && \
		$(MAKE) PREFIX=$($(sparse)-prefix) install
	@touch $@

$($(sparse)-modulefile): $(modulefilesdir)/.markerfile $($(sparse)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(sparse)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(sparse)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(sparse)-description)\"" >>$@
	echo "module-whatis \"$($(sparse)-url)\"" >>$@
	printf "$(foreach prereq,$($(sparse)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SPARSE_ROOT $($(sparse)-prefix)" >>$@
	echo "setenv SPARSE_INCDIR $($(sparse)-prefix)/include" >>$@
	echo "setenv SPARSE_INCLUDEDIR $($(sparse)-prefix)/include" >>$@
	echo "setenv SPARSE_LIBDIR $($(sparse)-prefix)/lib" >>$@
	echo "setenv SPARSE_LIBRARYDIR $($(sparse)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(sparse)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(sparse)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(sparse)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(sparse)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(sparse)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(sparse)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(sparse)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(sparse)-prefix)/share/info" >>$@
	echo "set MSG \"$(sparse)\"" >>$@

$(sparse)-src: $($(sparse)-src)
$(sparse)-unpack: $($(sparse)-prefix)/.pkgunpack
$(sparse)-patch: $($(sparse)-prefix)/.pkgpatch
$(sparse)-build: $($(sparse)-prefix)/.pkgbuild
$(sparse)-check: $($(sparse)-prefix)/.pkgcheck
$(sparse)-install: $($(sparse)-prefix)/.pkginstall
$(sparse)-modulefile: $($(sparse)-modulefile)
$(sparse)-clean:
	rm -rf $($(sparse)-modulefile)
	rm -rf $($(sparse)-prefix)
	rm -rf $($(sparse)-srcdir)
	rm -rf $($(sparse)-src)
$(sparse): $(sparse)-src $(sparse)-unpack $(sparse)-patch $(sparse)-build $(sparse)-check $(sparse)-install $(sparse)-modulefile

