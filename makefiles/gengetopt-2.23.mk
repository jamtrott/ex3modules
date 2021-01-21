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
# Authors: Kristian Gregorius Hustad <kghustad@simula.no>
# Authors: James D. Trotter <james@simula.no>
#
# gengetopt-2.23

gengetopt-version = 2.23
gengetopt = gengetopt-$(gengetopt-version)
$(gengetopt)-description = Gengetopt is a tool to write command line option parsing code for C programs.
$(gengetopt)-url = https://www.gnu.org/software/gengetopt/
$(gengetopt)-srcurl = http://ftpmirror.gnu.org/gengetopt/gengetopt-$(gengetopt-version).tar.xz
$(gengetopt)-builddeps =
$(gengetopt)-prereqs =
$(gengetopt)-src = $(pkgsrcdir)/$(notdir $($(gengetopt)-srcurl))
$(gengetopt)-srcdir = $(pkgsrcdir)/$(gengetopt)
$(gengetopt)-builddir = $($(gengetopt)-srcdir)
$(gengetopt)-modulefile = $(modulefilesdir)/$(gengetopt)
$(gengetopt)-prefix = $(pkgdir)/$(gengetopt)

$($(gengetopt)-src): $(dir $($(gengetopt)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gengetopt)-srcurl)

$($(gengetopt)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gengetopt)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(gengetopt)-prefix)/.pkgunpack: $$($(gengetopt)-src) $($(gengetopt)-srcdir)/.markerfile $($(gengetopt)-prefix)/.markerfile
	tar -C $($(gengetopt)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(gengetopt)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gengetopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(gengetopt)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(gengetopt)-builddir),$($(gengetopt)-srcdir))
$($(gengetopt)-builddir)/.markerfile: $($(gengetopt)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(gengetopt)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gengetopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(gengetopt)-builddir)/.markerfile $($(gengetopt)-prefix)/.pkgpatch
	cd $($(gengetopt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gengetopt)-builddeps) && \
		./configure --prefix=$($(gengetopt)-prefix) && \
		$(MAKE)
	@touch $@

$($(gengetopt)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gengetopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(gengetopt)-builddir)/.markerfile $($(gengetopt)-prefix)/.pkgbuild
	cd $($(gengetopt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gengetopt)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(gengetopt)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gengetopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(gengetopt)-builddir)/.markerfile $($(gengetopt)-prefix)/.pkgcheck
	cd $($(gengetopt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gengetopt)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(gengetopt)-modulefile): $(modulefilesdir)/.markerfile $($(gengetopt)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gengetopt)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gengetopt)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gengetopt)-description)\"" >>$@
	echo "module-whatis \"$($(gengetopt)-url)\"" >>$@
	printf "$(foreach prereq,$($(gengetopt)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv gengetopt_ROOT $($(gengetopt)-prefix)" >>$@
	echo "prepend-path PATH $($(gengetopt)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(gengetopt)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gengetopt)-prefix)/share/info" >>$@
	echo "set MSG \"$(gengetopt)\"" >>$@

$(gengetopt)-src: $$($(gengetopt)-src)
$(gengetopt)-unpack: $($(gengetopt)-prefix)/.pkgunpack
$(gengetopt)-patch: $($(gengetopt)-prefix)/.pkgpatch
$(gengetopt)-build: $($(gengetopt)-prefix)/.pkgbuild
$(gengetopt)-check: $($(gengetopt)-prefix)/.pkgcheck
$(gengetopt)-install: $($(gengetopt)-prefix)/.pkginstall
$(gengetopt)-modulefile: $($(gengetopt)-modulefile)
$(gengetopt)-clean:
	rm -rf $($(gengetopt)-modulefile)
	rm -rf $($(gengetopt)-prefix)
	rm -rf $($(gengetopt)-builddir)
	rm -rf $($(gengetopt)-srcdir)
	rm -rf $($(gengetopt)-src)
$(gengetopt): $(gengetopt)-src $(gengetopt)-unpack $(gengetopt)-patch $(gengetopt)-build $(gengetopt)-check $(gengetopt)-install $(gengetopt)-modulefile
