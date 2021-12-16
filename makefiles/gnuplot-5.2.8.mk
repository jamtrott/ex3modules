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
# gnuplot-5.2.8

gnuplot-version = 5.2.8
gnuplot = gnuplot-$(gnuplot-version)
$(gnuplot)-description = Command-line driven graphing utility
$(gnuplot)-url = http://www.gnuplot.info/
$(gnuplot)-srcurl = https://downloads.sourceforge.net/project/gnuplot/gnuplot/$(gnuplot-version)/gnuplot-$(gnuplot-version).tar.gz
$(gnuplot)-builddeps = $(libgd) $(libcerf) $(readline) $(cairo) $(pango)
$(gnuplot)-prereqs = $(libgd) $(libcerf) $(readline) $(cairo) $(pango)
$(gnuplot)-src = $(pkgsrcdir)/$(notdir $($(gnuplot)-srcurl))
$(gnuplot)-srcdir = $(pkgsrcdir)/$(gnuplot)
$(gnuplot)-builddir = $($(gnuplot)-srcdir)
$(gnuplot)-modulefile = $(modulefilesdir)/$(gnuplot)
$(gnuplot)-prefix = $(pkgdir)/$(gnuplot)

$($(gnuplot)-src): $(dir $($(gnuplot)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gnuplot)-srcurl)

$($(gnuplot)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gnuplot)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gnuplot)-prefix)/.pkgunpack: $($(gnuplot)-src) $($(gnuplot)-srcdir)/.markerfile $($(gnuplot)-prefix)/.markerfile $$(foreach dep,$$($(gnuplot)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(gnuplot)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gnuplot)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gnuplot)-builddeps),$(modulefilesdir)/$$(dep)) $($(gnuplot)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gnuplot)-builddir),$($(gnuplot)-srcdir))
$($(gnuplot)-builddir)/.markerfile: $($(gnuplot)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gnuplot)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gnuplot)-builddeps),$(modulefilesdir)/$$(dep)) $($(gnuplot)-builddir)/.markerfile $($(gnuplot)-prefix)/.pkgpatch
	cd $($(gnuplot)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gnuplot)-builddeps) && \
		./configure --prefix=$($(gnuplot)-prefix) \
			--with-texdir=$($(gnuplot)-prefix)/share \
			--disable-wxwidgets \
			--with-qt=no && \
		$(MAKE)
	@touch $@

$($(gnuplot)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gnuplot)-builddeps),$(modulefilesdir)/$$(dep)) $($(gnuplot)-builddir)/.markerfile $($(gnuplot)-prefix)/.pkgbuild
	cd $($(gnuplot)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gnuplot)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(gnuplot)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gnuplot)-builddeps),$(modulefilesdir)/$$(dep)) $($(gnuplot)-builddir)/.markerfile $($(gnuplot)-prefix)/.pkgcheck
	cd $($(gnuplot)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gnuplot)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gnuplot)-modulefile): $(modulefilesdir)/.markerfile $($(gnuplot)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gnuplot)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gnuplot)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gnuplot)-description)\"" >>$@
	echo "module-whatis \"$($(gnuplot)-url)\"" >>$@
	printf "$(foreach prereq,$($(gnuplot)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GNUPLOT_ROOT $($(gnuplot)-prefix)" >>$@
	echo "setenv GNUPLOT_INCDIR $($(gnuplot)-prefix)/include" >>$@
	echo "setenv GNUPLOT_INCLUDEDIR $($(gnuplot)-prefix)/include" >>$@
	echo "setenv GNUPLOT_LIBDIR $($(gnuplot)-prefix)/lib" >>$@
	echo "setenv GNUPLOT_LIBRARYDIR $($(gnuplot)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(gnuplot)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gnuplot)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gnuplot)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gnuplot)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gnuplot)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(gnuplot)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(gnuplot)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gnuplot)-prefix)/share/info" >>$@
	echo "set MSG \"$(gnuplot)\"" >>$@

$(gnuplot)-src: $($(gnuplot)-src)
$(gnuplot)-unpack: $($(gnuplot)-prefix)/.pkgunpack
$(gnuplot)-patch: $($(gnuplot)-prefix)/.pkgpatch
$(gnuplot)-build: $($(gnuplot)-prefix)/.pkgbuild
$(gnuplot)-check: $($(gnuplot)-prefix)/.pkgcheck
$(gnuplot)-install: $($(gnuplot)-prefix)/.pkginstall
$(gnuplot)-modulefile: $($(gnuplot)-modulefile)
$(gnuplot)-clean:
	rm -rf $($(gnuplot)-modulefile)
	rm -rf $($(gnuplot)-prefix)
	rm -rf $($(gnuplot)-srcdir)
	rm -rf $($(gnuplot)-src)
$(gnuplot): $(gnuplot)-src $(gnuplot)-unpack $(gnuplot)-patch $(gnuplot)-build $(gnuplot)-check $(gnuplot)-install $(gnuplot)-modulefile
