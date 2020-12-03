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
# ninja-1.10.0

ninja-version = 1.10.0
ninja = ninja-$(ninja-version)
$(ninja)-description = Small build system with a focus on speed
$(ninja)-url = https://ninja-build.org/
$(ninja)-srcurl = https://github.com/ninja-build/ninja/archive/v$(ninja-version).tar.gz
$(ninja)-src = $(pkgsrcdir)/$(ninja).tar.gz
$(ninja)-srcdir = $(pkgsrcdir)/$(ninja)
$(ninja)-builddeps = $(python)
$(ninja)-prereqs =
$(ninja)-modulefile = $(modulefilesdir)/$(ninja)
$(ninja)-prefix = $(pkgdir)/$(ninja)

$($(ninja)-src): $(dir $($(ninja)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ninja)-srcurl)

$($(ninja)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ninja)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ninja)-prefix)/.pkgunpack: $($(ninja)-src) $($(ninja)-srcdir)/.markerfile $($(ninja)-prefix)/.markerfile
	tar -C $($(ninja)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ninja)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ninja)-builddeps),$(modulefilesdir)/$$(dep)) $($(ninja)-prefix)/.pkgunpack
	@touch $@

$($(ninja)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ninja)-builddeps),$(modulefilesdir)/$$(dep)) $($(ninja)-prefix)/.pkgpatch
	cd $($(ninja)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ninja)-builddeps) && \
		python3 configure.py --bootstrap
	@touch $@

$($(ninja)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ninja)-builddeps),$(modulefilesdir)/$$(dep)) $($(ninja)-prefix)/.pkgbuild
	@touch $@

$($(ninja)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ninja)-builddeps),$(modulefilesdir)/$$(dep)) $($(ninja)-prefix)/.pkgcheck
	$(INSTALL) -d $($(ninja)-prefix)
	$(INSTALL) -d $($(ninja)-prefix)/bin
	$(INSTALL) $($(ninja)-srcdir)/ninja $($(ninja)-prefix)/bin
	@touch $@

$($(ninja)-modulefile): $(modulefilesdir)/.markerfile $($(ninja)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ninja)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ninja)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ninja)-description)\"" >>$@
	echo "module-whatis \"$($(ninja)-url)\"" >>$@
	printf "$(foreach prereq,$($(ninja)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv NINJA_ROOT $($(ninja)-prefix)" >>$@
	echo "prepend-path PATH $($(ninja)-prefix)/bin" >>$@
	echo "set MSG \"$(ninja)\"" >>$@

$(ninja)-src: $($(ninja)-src)
$(ninja)-unpack: $($(ninja)-prefix)/.pkgunpack
$(ninja)-patch: $($(ninja)-prefix)/.pkgpatch
$(ninja)-build: $($(ninja)-prefix)/.pkgbuild
$(ninja)-check: $($(ninja)-prefix)/.pkgcheck
$(ninja)-install: $($(ninja)-prefix)/.pkginstall
$(ninja)-modulefile: $($(ninja)-modulefile)
$(ninja)-clean:
	rm -rf $($(ninja)-modulefile)
	rm -rf $($(ninja)-prefix)
	rm -rf $($(ninja)-srcdir)
	rm -rf $($(ninja)-src)
$(ninja): $(ninja)-src $(ninja)-unpack $(ninja)-patch $(ninja)-build $(ninja)-check $(ninja)-install $(ninja)-modulefile
