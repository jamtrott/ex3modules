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
# ocaml-opam-2.0.5

ocaml-opam-version = 2.0.5
ocaml-opam = ocaml-opam-$(ocaml-opam-version)
$(ocaml-opam)-description = Source-based package manager for OCaml
$(ocaml-opam)-url = https://opam.ocaml.org/
$(ocaml-opam)-srcurl = https://github.com/ocaml/opam/archive/$(ocaml-opam-version).tar.gz
$(ocaml-opam)-builddeps = $(ocaml)
$(ocaml-opam)-prereqs = $(ocaml)
$(ocaml-opam)-src = $(pkgsrcdir)/$(notdir $($(ocaml-opam)-srcurl))
$(ocaml-opam)-srcdir = $(pkgsrcdir)/$(ocaml-opam)
$(ocaml-opam)-builddir = $($(ocaml-opam)-srcdir)
$(ocaml-opam)-modulefile = $(modulefilesdir)/$(ocaml-opam)
$(ocaml-opam)-prefix = $(pkgdir)/$(ocaml-opam)

$($(ocaml-opam)-src): $(dir $($(ocaml-opam)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ocaml-opam)-srcurl)

$($(ocaml-opam)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ocaml-opam)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ocaml-opam)-prefix)/.pkgunpack: $($(ocaml-opam)-src) $($(ocaml-opam)-srcdir)/.markerfile $($(ocaml-opam)-prefix)/.markerfile $$(foreach dep,$$($(ocaml-opam)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(ocaml-opam)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ocaml-opam)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ocaml-opam)-builddeps),$(modulefilesdir)/$$(dep)) $($(ocaml-opam)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(ocaml-opam)-builddir),$($(ocaml-opam)-srcdir))
$($(ocaml-opam)-builddir)/.markerfile: $($(ocaml-opam)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(ocaml-opam)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ocaml-opam)-builddeps),$(modulefilesdir)/$$(dep)) $($(ocaml-opam)-builddir)/.markerfile $($(ocaml-opam)-prefix)/.pkgpatch
	cd $($(ocaml-opam)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ocaml-opam)-builddeps) && \
		./configure --prefix=$($(ocaml-opam)-prefix) && \
		$(MAKE) lib-ext all
	@touch $@

$($(ocaml-opam)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ocaml-opam)-builddeps),$(modulefilesdir)/$$(dep)) $($(ocaml-opam)-builddir)/.markerfile $($(ocaml-opam)-prefix)/.pkgbuild
	cd $($(ocaml-opam)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ocaml-opam)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(ocaml-opam)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ocaml-opam)-builddeps),$(modulefilesdir)/$$(dep)) $($(ocaml-opam)-builddir)/.markerfile $($(ocaml-opam)-prefix)/.pkgcheck
	cd $($(ocaml-opam)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ocaml-opam)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(ocaml-opam)-modulefile): $(modulefilesdir)/.markerfile $($(ocaml-opam)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ocaml-opam)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ocaml-opam)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ocaml-opam)-description)\"" >>$@
	echo "module-whatis \"$($(ocaml-opam)-url)\"" >>$@
	printf "$(foreach prereq,$($(ocaml-opam)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OCAML_OPAM_ROOT $($(ocaml-opam)-prefix)" >>$@
	echo 'set HOME [getenv HOME ""]' >>$@
	echo "prepend-path PATH $($(ocaml-opam)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(ocaml-opam)-prefix)/share/man" >>$@
	echo "set MSG \"$(ocaml-opam)\"" >>$@

$(ocaml-opam)-src: $($(ocaml-opam)-src)
$(ocaml-opam)-unpack: $($(ocaml-opam)-prefix)/.pkgunpack
$(ocaml-opam)-patch: $($(ocaml-opam)-prefix)/.pkgpatch
$(ocaml-opam)-build: $($(ocaml-opam)-prefix)/.pkgbuild
$(ocaml-opam)-check: $($(ocaml-opam)-prefix)/.pkgcheck
$(ocaml-opam)-install: $($(ocaml-opam)-prefix)/.pkginstall
$(ocaml-opam)-modulefile: $($(ocaml-opam)-modulefile)
$(ocaml-opam)-clean:
	rm -rf $($(ocaml-opam)-modulefile)
	rm -rf $($(ocaml-opam)-prefix)
	rm -rf $($(ocaml-opam)-srcdir)
	rm -rf $($(ocaml-opam)-src)
$(ocaml-opam): $(ocaml-opam)-src $(ocaml-opam)-unpack $(ocaml-opam)-patch $(ocaml-opam)-build $(ocaml-opam)-check $(ocaml-opam)-install $(ocaml-opam)-modulefile
