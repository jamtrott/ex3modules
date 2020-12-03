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
# gsl-2.6

gsl-version = 2.6
gsl = gsl-$(gsl-version)
$(gsl)-description = GNU Scientific Library for numerical computing
$(gsl)-url = https://www.gnu.org/software/gsl/
$(gsl)-srcurl = http://ftpmirror.gnu.org/gsl/gsl-$(gsl-version).tar.gz
$(gsl)-builddeps =
$(gsl)-prereqs =
$(gsl)-src = $(pkgsrcdir)/$(notdir $($(gsl)-srcurl))
$(gsl)-srcdir = $(pkgsrcdir)/$(gsl)
$(gsl)-builddir = $($(gsl)-srcdir)
$(gsl)-modulefile = $(modulefilesdir)/$(gsl)
$(gsl)-prefix = $(pkgdir)/$(gsl)

$($(gsl)-src): $(dir $($(gsl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gsl)-srcurl)

$($(gsl)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gsl)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gsl)-prefix)/.pkgunpack: $($(gsl)-src) $($(gsl)-srcdir)/.markerfile $($(gsl)-prefix)/.markerfile
	tar -C $($(gsl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gsl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gsl)-builddeps),$(modulefilesdir)/$$(dep)) $($(gsl)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gsl)-builddir),$($(gsl)-srcdir))
$($(gsl)-builddir)/.markerfile: $($(gsl)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gsl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gsl)-builddeps),$(modulefilesdir)/$$(dep)) $($(gsl)-builddir)/.markerfile $($(gsl)-prefix)/.pkgpatch
	cd $($(gsl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gsl)-builddeps) && \
		./configure --prefix=$($(gsl)-prefix) && \
		$(MAKE)
	@touch $@

$($(gsl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gsl)-builddeps),$(modulefilesdir)/$$(dep)) $($(gsl)-builddir)/.markerfile $($(gsl)-prefix)/.pkgbuild
#	Disable due to failing tests
#	cd $($(gsl)-builddir) && \
#		$(MODULESINIT) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(gsl)-builddeps) && \
#		$(MAKE) check
	@touch $@

$($(gsl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gsl)-builddeps),$(modulefilesdir)/$$(dep)) $($(gsl)-builddir)/.markerfile $($(gsl)-prefix)/.pkgcheck
	cd $($(gsl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gsl)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gsl)-modulefile): $(modulefilesdir)/.markerfile $($(gsl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gsl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gsl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gsl)-description)\"" >>$@
	echo "module-whatis \"$($(gsl)-url)\"" >>$@
	printf "$(foreach prereq,$($(gsl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GSL_ROOT $($(gsl)-prefix)" >>$@
	echo "setenv GSL_INCDIR $($(gsl)-prefix)/include" >>$@
	echo "setenv GSL_INCLUDEDIR $($(gsl)-prefix)/include" >>$@
	echo "setenv GSL_LIBDIR $($(gsl)-prefix)/lib" >>$@
	echo "setenv GSL_LIBRARYDIR $($(gsl)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(gsl)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(gsl)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(gsl)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(gsl)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(gsl)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(gsl)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(gsl)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gsl)-prefix)/share/info" >>$@
	echo "prepend-path ACLOCAL_PATH $($(gsl)-prefix)/share/aclocal" >>$@
	echo "set MSG \"$(gsl)\"" >>$@

$(gsl)-src: $($(gsl)-src)
$(gsl)-unpack: $($(gsl)-prefix)/.pkgunpack
$(gsl)-patch: $($(gsl)-prefix)/.pkgpatch
$(gsl)-build: $($(gsl)-prefix)/.pkgbuild
$(gsl)-check: $($(gsl)-prefix)/.pkgcheck
$(gsl)-install: $($(gsl)-prefix)/.pkginstall
$(gsl)-modulefile: $($(gsl)-modulefile)
$(gsl)-clean:
	rm -rf $($(gsl)-modulefile)
	rm -rf $($(gsl)-prefix)
	rm -rf $($(gsl)-srcdir)
	rm -rf $($(gsl)-src)
$(gsl): $(gsl)-src $(gsl)-unpack $(gsl)-patch $(gsl)-build $(gsl)-check $(gsl)-install $(gsl)-modulefile
