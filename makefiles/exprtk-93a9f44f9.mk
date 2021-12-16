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
# exprtk-93a9f44

exprtk-version = 93a9f44f9
exprtk = exprtk-$(exprtk-version)
$(exprtk)-description = C++ Mathematical Expression Library (ExprTk)
$(exprtk)-url = https://www.partow.net/programming/exprtk/index.html
$(exprtk)-srcurl = https://github.com/ArashPartow/exprtk/archive/93a9f44f99b910bfe07cd1e933371e83cea3841c.zip
$(exprtk)-builddeps =
$(exprtk)-prereqs =
$(exprtk)-src = $(pkgsrcdir)/$(notdir $($(exprtk)-srcurl))
$(exprtk)-srcdir = $(pkgsrcdir)/$(exprtk)
$(exprtk)-builddir = $($(exprtk)-srcdir)
$(exprtk)-modulefile = $(modulefilesdir)/$(exprtk)
$(exprtk)-prefix = $(pkgdir)/$(exprtk)

$($(exprtk)-src): $(dir $($(exprtk)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(exprtk)-srcurl)

$($(exprtk)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(exprtk)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(exprtk)-prefix)/.pkgunpack: $$($(exprtk)-src) $($(exprtk)-srcdir)/.markerfile $($(exprtk)-prefix)/.markerfile $$(foreach dep,$$($(exprtk)-builddeps),$(modulefilesdir)/$$(dep))
	cd $($(exprtk)-srcdir) && unzip -o $<
	@touch $@

$($(exprtk)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(exprtk)-builddeps),$(modulefilesdir)/$$(dep)) $($(exprtk)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(exprtk)-builddir),$($(exprtk)-srcdir))
$($(exprtk)-builddir)/.markerfile: $($(exprtk)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(exprtk)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(exprtk)-builddeps),$(modulefilesdir)/$$(dep)) $($(exprtk)-builddir)/.markerfile $($(exprtk)-prefix)/.pkgpatch
	@touch $@

$($(exprtk)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(exprtk)-builddeps),$(modulefilesdir)/$$(dep)) $($(exprtk)-builddir)/.markerfile $($(exprtk)-prefix)/.pkgbuild
	@touch $@

$($(exprtk)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(exprtk)-builddeps),$(modulefilesdir)/$$(dep)) $($(exprtk)-builddir)/.markerfile $($(exprtk)-prefix)/.pkgcheck
	$(INSTALL) -d $($(exprtk)-prefix)/include/
	$(INSTALL) -m644 $($(exprtk)-srcdir)/exprtk-93a9f44f99b910bfe07cd1e933371e83cea3841c/exprtk.hpp $($(exprtk)-prefix)/include/
	@touch $@

$($(exprtk)-modulefile): $(modulefilesdir)/.markerfile $($(exprtk)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(exprtk)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(exprtk)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(exprtk)-description)\"" >>$@
	echo "module-whatis \"$($(exprtk)-url)\"" >>$@
	printf "$(foreach prereq,$($(exprtk)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv EXPRTK_ROOT $($(exprtk)-prefix)" >>$@
	echo "setenv EXPRTK_INCDIR $($(exprtk)-prefix)/include" >>$@
	echo "setenv EXPRTK_INCLUDEDIR $($(exprtk)-prefix)/include" >>$@
	echo "prepend-path PATH $($(exprtk)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(exprtk)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(exprtk)-prefix)/include" >>$@
	echo "set MSG \"$(exprtk)\"" >>$@

$(exprtk)-src: $$($(exprtk)-src)
$(exprtk)-unpack: $($(exprtk)-prefix)/.pkgunpack
$(exprtk)-patch: $($(exprtk)-prefix)/.pkgpatch
$(exprtk)-build: $($(exprtk)-prefix)/.pkgbuild
$(exprtk)-check: $($(exprtk)-prefix)/.pkgcheck
$(exprtk)-install: $($(exprtk)-prefix)/.pkginstall
$(exprtk)-modulefile: $($(exprtk)-modulefile)
$(exprtk)-clean:
	rm -rf $($(exprtk)-modulefile)
	rm -rf $($(exprtk)-prefix)
	rm -rf $($(exprtk)-builddir)
	rm -rf $($(exprtk)-srcdir)
	rm -rf $($(exprtk)-src)
$(exprtk): $(exprtk)-src $(exprtk)-unpack $(exprtk)-patch $(exprtk)-build $(exprtk)-check $(exprtk)-install $(exprtk)-modulefile
