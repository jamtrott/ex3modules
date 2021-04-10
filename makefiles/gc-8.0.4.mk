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
# gc-8.0.4

gc-version = 8.0.4
gc = gc-$(gc-version)
$(gc)-description = A garbage collector for C and C++
$(gc)-url = https://www.hboehm.info/gc/
$(gc)-srcurl = https://www.hboehm.info/gc/gc_source/gc-8.0.4.tar.gz
$(gc)-builddeps = $(libatomic_ops)
$(gc)-prereqs = $(libatomic_ops)
$(gc)-src = $(pkgsrcdir)/$(notdir $($(gc)-srcurl))
$(gc)-srcdir = $(pkgsrcdir)/$(gc)
$(gc)-builddir = $($(gc)-srcdir)
$(gc)-modulefile = $(modulefilesdir)/$(gc)
$(gc)-prefix = $(pkgdir)/$(gc)

$($(gc)-src): $(dir $($(gc)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gc)-srcurl)

$($(gc)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gc)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gc)-prefix)/.pkgunpack: $$($(gc)-src) $($(gc)-srcdir)/.markerfile $($(gc)-prefix)/.markerfile
	tar -C $($(gc)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gc)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gc)-builddeps),$(modulefilesdir)/$$(dep)) $($(gc)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gc)-builddir),$($(gc)-srcdir))
$($(gc)-builddir)/.markerfile: $($(gc)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gc)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gc)-builddeps),$(modulefilesdir)/$$(dep)) $($(gc)-builddir)/.markerfile $($(gc)-prefix)/.pkgpatch
	cd $($(gc)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gc)-builddeps) && \
		./configure --prefix=$($(gc)-prefix) \
			--enable-cplusplus \
			--disable-static && \
		$(MAKE)
	@touch $@

$($(gc)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gc)-builddeps),$(modulefilesdir)/$$(dep)) $($(gc)-builddir)/.markerfile $($(gc)-prefix)/.pkgbuild
	cd $($(gc)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gc)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(gc)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gc)-builddeps),$(modulefilesdir)/$$(dep)) $($(gc)-builddir)/.markerfile $($(gc)-prefix)/.pkgcheck
	cd $($(gc)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gc)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gc)-modulefile): $(modulefilesdir)/.markerfile $($(gc)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gc)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gc)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gc)-description)\"" >>$@
	echo "module-whatis \"$($(gc)-url)\"" >>$@
	printf "$(foreach prereq,$($(gc)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GC_ROOT $($(gc)-prefix)" >>$@
	echo "setenv GC_INCDIR $($(gc)-prefix)/include" >>$@
	echo "setenv GC_INCLUDEDIR $($(gc)-prefix)/include" >>$@
	echo "setenv GC_LIBDIR $($(gc)-prefix)/lib" >>$@
	echo "setenv GC_LIBRARYDIR $($(gc)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gc)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gc)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gc)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gc)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(gc)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(gc)-prefix)/share/man" >>$@
	echo "set MSG \"$(gc)\"" >>$@

$(gc)-src: $$($(gc)-src)
$(gc)-unpack: $($(gc)-prefix)/.pkgunpack
$(gc)-patch: $($(gc)-prefix)/.pkgpatch
$(gc)-build: $($(gc)-prefix)/.pkgbuild
$(gc)-check: $($(gc)-prefix)/.pkgcheck
$(gc)-install: $($(gc)-prefix)/.pkginstall
$(gc)-modulefile: $($(gc)-modulefile)
$(gc)-clean:
	rm -rf $($(gc)-modulefile)
	rm -rf $($(gc)-prefix)
	rm -rf $($(gc)-builddir)
	rm -rf $($(gc)-srcdir)
	rm -rf $($(gc)-src)
$(gc): $(gc)-src $(gc)-unpack $(gc)-patch $(gc)-build $(gc)-check $(gc)-install $(gc)-modulefile
