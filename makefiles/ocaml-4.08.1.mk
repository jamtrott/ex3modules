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
# ocaml-4.08.1

ocaml-version = 4.08.1
ocaml = ocaml-$(ocaml-version)
$(ocaml)-description = Core OCaml system with compilers, runtime system, and base libraries
$(ocaml)-url = https://ocaml.org/
$(ocaml)-srcurl = https://github.com/ocaml/ocaml/archive/$(ocaml-version).tar.gz
$(ocaml)-builddeps =
$(ocaml)-prereqs =
$(ocaml)-src = $(pkgsrcdir)/ocaml-$(notdir $($(ocaml)-srcurl))
$(ocaml)-srcdir = $(pkgsrcdir)/$(ocaml)
$(ocaml)-builddir = $($(ocaml)-srcdir)
$(ocaml)-modulefile = $(modulefilesdir)/$(ocaml)
$(ocaml)-prefix = $(pkgdir)/$(ocaml)

$($(ocaml)-src): $(dir $($(ocaml)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ocaml)-srcurl)

$($(ocaml)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ocaml)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ocaml)-prefix)/.pkgunpack: $($(ocaml)-src) $($(ocaml)-srcdir)/.markerfile $($(ocaml)-prefix)/.markerfile
	tar -C $($(ocaml)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ocaml)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ocaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(ocaml)-prefix)/.pkgunpack
# 	Temporarily disable testpreempt, which doesn't seem to work.
# 	Could be related to https://github.com/ocaml/ocaml/pull/8849
	cd $($(ocaml)-srcdir) && \
		sed -i /testpreempt.ml/d testsuite/tests/lib-systhreads/ocamltests && \
		rm -f testsuite/tests/lib-systhreads/testpreempt.ml
	@touch $@

ifneq ($($(ocaml)-builddir),$($(ocaml)-srcdir))
$($(ocaml)-builddir)/.markerfile: $($(ocaml)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(ocaml)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ocaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(ocaml)-builddir)/.markerfile $($(ocaml)-prefix)/.pkgpatch
	cd $($(ocaml)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ocaml)-builddeps) && \
		./configure --prefix=$($(ocaml)-prefix) && \
		$(MAKE) world.opt
	@touch $@

$($(ocaml)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ocaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(ocaml)-builddir)/.markerfile $($(ocaml)-prefix)/.pkgbuild
	# cd $($(ocaml)-builddir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(ocaml)-builddeps) && \
	# 	$(MAKE) tests
	@touch $@

$($(ocaml)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ocaml)-builddeps),$(modulefilesdir)/$$(dep)) $($(ocaml)-builddir)/.markerfile $($(ocaml)-prefix)/.markerfile $($(ocaml)-prefix)/.pkgcheck
	cd $($(ocaml)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ocaml)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(ocaml)-modulefile): $(modulefilesdir)/.markerfile $($(ocaml)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ocaml)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ocaml)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ocaml)-description)\"" >>$@
	echo "module-whatis \"$($(ocaml)-url)\"" >>$@
	printf "$(foreach prereq,$($(ocaml)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OCAML_ROOT $($(ocaml)-prefix)" >>$@
	echo "setenv OCAML_LIBDIR $($(ocaml)-prefix)/lib" >>$@
	echo "setenv OCAML_LIBRARYDIR $($(ocaml)-prefix)/lib" >>$@
	echo "setenv OCAMLLIB $($(ocaml)-prefix)}/lib/ocaml" >>$@
	echo "prepend-path PATH $($(ocaml)-prefix)/bin" >>$@
	echo "prepend-path LIBRARY_PATH $($(ocaml)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(ocaml)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(ocaml)-prefix)/share/man" >>$@
	echo "set MSG \"$(ocaml)\"" >>$@

$(ocaml)-src: $($(ocaml)-src)
$(ocaml)-unpack: $($(ocaml)-prefix)/.pkgunpack
$(ocaml)-patch: $($(ocaml)-prefix)/.pkgpatch
$(ocaml)-build: $($(ocaml)-prefix)/.pkgbuild
$(ocaml)-check: $($(ocaml)-prefix)/.pkgcheck
$(ocaml)-install: $($(ocaml)-prefix)/.pkginstall
$(ocaml)-modulefile: $($(ocaml)-modulefile)
$(ocaml)-clean:
	rm -rf $($(ocaml)-modulefile)
	rm -rf $($(ocaml)-prefix)
	rm -rf $($(ocaml)-srcdir)
	rm -rf $($(ocaml)-src)
$(ocaml): $(ocaml)-src $(ocaml)-unpack $(ocaml)-patch $(ocaml)-build $(ocaml)-check $(ocaml)-install $(ocaml)-modulefile
