# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2025 James D. Trotter
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
# pigz-2.8

pigz-version = 2.8
pigz = pigz-$(pigz-version)
$(pigz)-description = A parallel implementation of gzip
$(pigz)-url = https://zlib.net/pigz/
$(pigz)-srcurl = https://zlib.net/pigz/pigz-2.8.tar.gz
$(pigz)-builddeps = $(zlib)
$(pigz)-prereqs = $(zlib)
$(pigz)-src = $(pkgsrcdir)/$(notdir $($(pigz)-srcurl))
$(pigz)-srcdir = $(pkgsrcdir)/$(pigz)
$(pigz)-builddir = $($(pigz)-srcdir)/build
$(pigz)-modulefile = $(modulefilesdir)/$(pigz)
$(pigz)-prefix = $(pkgdir)/$(pigz)

$($(pigz)-src): $(dir $($(pigz)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pigz)-srcurl)

$($(pigz)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pigz)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pigz)-prefix)/.pkgunpack: $$($(pigz)-src) $($(pigz)-srcdir)/.markerfile $($(pigz)-prefix)/.markerfile $$(foreach dep,$$($(pigz)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(pigz)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pigz)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pigz)-builddeps),$(modulefilesdir)/$$(dep)) $($(pigz)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(pigz)-builddir),$($(pigz)-srcdir))
$($(pigz)-builddir)/.markerfile: $($(pigz)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(pigz)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pigz)-builddeps),$(modulefilesdir)/$$(dep)) $($(pigz)-builddir)/.markerfile $($(pigz)-prefix)/.pkgpatch
	cd $($(pigz)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pigz)-builddeps) && \
		$(MAKE) -C $($(pigz)-srcdir)
	@touch $@

$($(pigz)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pigz)-builddeps),$(modulefilesdir)/$$(dep)) $($(pigz)-builddir)/.markerfile $($(pigz)-prefix)/.pkgbuild
	@touch $@

$($(pigz)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pigz)-builddeps),$(modulefilesdir)/$$(dep)) $($(pigz)-builddir)/.markerfile $($(pigz)-prefix)/.pkgcheck
	mkdir -p $($(pigz)-prefix)/bin
	cp --verbose $($(pigz)-srcdir)/pigz $($(pigz)-prefix)/bin/
	@touch $@

$($(pigz)-modulefile): $(modulefilesdir)/.markerfile $($(pigz)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pigz)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pigz)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pigz)-description)\"" >>$@
	echo "module-whatis \"$($(pigz)-url)\"" >>$@
	printf "$(foreach prereq,$($(pigz)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "prepend-path PATH $($(pigz)-prefix)/bin" >>$@
	echo "set MSG \"$(pigz)\"" >>$@

$(pigz)-src: $$($(pigz)-src)
$(pigz)-unpack: $($(pigz)-prefix)/.pkgunpack
$(pigz)-patch: $($(pigz)-prefix)/.pkgpatch
$(pigz)-build: $($(pigz)-prefix)/.pkgbuild
$(pigz)-check: $($(pigz)-prefix)/.pkgcheck
$(pigz)-install: $($(pigz)-prefix)/.pkginstall
$(pigz)-modulefile: $($(pigz)-modulefile)
$(pigz)-clean:
	rm -rf $($(pigz)-modulefile)
	rm -rf $($(pigz)-prefix)
	rm -rf $($(pigz)-builddir)
	rm -rf $($(pigz)-srcdir)
	rm -rf $($(pigz)-src)
$(pigz): $(pigz)-src $(pigz)-unpack $(pigz)-patch $(pigz)-build $(pigz)-check $(pigz)-install $(pigz)-modulefile
