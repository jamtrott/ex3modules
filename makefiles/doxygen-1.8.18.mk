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
# doxygen-1.8.18

doxygen-version = 1.8.18
doxygen = doxygen-$(doxygen-version)
$(doxygen)-description = Tool for generating documentation from annotated C++ source code
$(doxygen)-url = http://www.doxygen.nl/
$(doxygen)-srcurl = https://github.com/doxygen/doxygen/archive/Release_$(subst .,_,$(doxygen-version)).tar.gz
$(doxygen)-builddeps = $(cmake) $(python) $(flex) $(bison) $(gcc-10.1.0)
$(doxygen)-prereqs = $(libstdcxx)
$(doxygen)-src = $(pkgsrcdir)/$(notdir $($(doxygen)-srcurl))
$(doxygen)-srcdir = $(pkgsrcdir)/$(doxygen)
$(doxygen)-builddir = $($(doxygen)-srcdir)/build
$(doxygen)-modulefile = $(modulefilesdir)/$(doxygen)
$(doxygen)-prefix = $(pkgdir)/$(doxygen)

$($(doxygen)-src): $(dir $($(doxygen)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(doxygen)-srcurl)

$($(doxygen)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(doxygen)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(doxygen)-prefix)/.pkgunpack: $($(doxygen)-src) $($(doxygen)-srcdir)/.markerfile $($(doxygen)-prefix)/.markerfile
	tar -C $($(doxygen)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(doxygen)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(doxygen)-builddeps),$(modulefilesdir)/$$(dep)) $($(doxygen)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(doxygen)-builddir),$($(doxygen)-srcdir))
$($(doxygen)-builddir)/.markerfile: $($(doxygen)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(doxygen)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(doxygen)-builddeps),$(modulefilesdir)/$$(dep)) $($(doxygen)-builddir)/.markerfile $($(doxygen)-prefix)/.pkgpatch
	cd $($(doxygen)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(doxygen)-builddeps) && \
		cmake -G "Unix Makefiles" \
			-DCMAKE_INSTALL_PREFIX=$($(doxygen)-prefix) \
			-DPYTHON_EXECUTABLE=$${PYTHON_ROOT}/bin/python3 \
			.. && \
		$(MAKE)
	@touch $@

$($(doxygen)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(doxygen)-builddeps),$(modulefilesdir)/$$(dep)) $($(doxygen)-builddir)/.markerfile $($(doxygen)-prefix)/.pkgbuild
# Test currently fails, see https://github.com/doxygen/doxygen/issues/6839.
#	cd $($(doxygen)-builddir) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(doxygen)-builddeps) && \
#		$(MAKE) test tests
	@touch $@

$($(doxygen)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(doxygen)-builddeps),$(modulefilesdir)/$$(dep)) $($(doxygen)-builddir)/.markerfile $($(doxygen)-prefix)/.pkgcheck
	cd $($(doxygen)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(doxygen)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(doxygen)-modulefile): $(modulefilesdir)/.markerfile $($(doxygen)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(doxygen)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(doxygen)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(doxygen)-description)\"" >>$@
	echo "module-whatis \"$($(doxygen)-url)\"" >>$@
	printf "$(foreach prereq,$($(doxygen)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv DOXYGEN_ROOT $($(doxygen)-prefix)" >>$@
	echo "prepend-path PATH $($(doxygen)-prefix)/bin" >>$@
	echo "set MSG \"$(doxygen)\"" >>$@

$(doxygen)-src: $($(doxygen)-src)
$(doxygen)-unpack: $($(doxygen)-prefix)/.pkgunpack
$(doxygen)-patch: $($(doxygen)-prefix)/.pkgpatch
$(doxygen)-build: $($(doxygen)-prefix)/.pkgbuild
$(doxygen)-check: $($(doxygen)-prefix)/.pkgcheck
$(doxygen)-install: $($(doxygen)-prefix)/.pkginstall
$(doxygen)-modulefile: $($(doxygen)-modulefile)
$(doxygen)-clean:
	rm -rf $($(doxygen)-modulefile)
	rm -rf $($(doxygen)-prefix)
	rm -rf $($(doxygen)-srcdir)
	rm -rf $($(doxygen)-src)
$(doxygen): $(doxygen)-src $(doxygen)-unpack $(doxygen)-patch $(doxygen)-build $(doxygen)-check $(doxygen)-install $(doxygen)-modulefile
