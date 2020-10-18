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
# gperf-3.1

gperf-version = 3.1
gperf = gperf-$(gperf-version)
$(gperf)-description = Perfect hash function generator
$(gperf)-url = https://www.gnu.org/software/gperf/
$(gperf)-srcurl = http://ftp.gnu.org/pub/gnu/gperf/gperf-$(gperf-version).tar.gz
$(gperf)-src = $(pkgsrcdir)/$(gperf).tar.gz
$(gperf)-srcdir = $(pkgsrcdir)/$(gperf)
$(gperf)-builddeps =
$(gperf)-prereqs =
$(gperf)-modulefile = $(modulefilesdir)/$(gperf)
$(gperf)-prefix = $(pkgdir)/$(gperf)

$($(gperf)-src): $(dir $($(gperf)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gperf)-srcurl)

$($(gperf)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(gperf)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(gperf)-prefix)/.pkgunpack: $($(gperf)-src) $($(gperf)-srcdir)/.markerfile $($(gperf)-prefix)/.markerfile
	tar -C $($(gperf)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(gperf)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(gperf)-prefix)/.pkgunpack
	@touch $@

$($(gperf)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(gperf)-prefix)/.pkgpatch
	cd $($(gperf)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gperf)-builddeps) && \
		./configure --prefix=$($(gperf)-prefix) && \
		$(MAKE)
	@touch $@

$($(gperf)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(gperf)-prefix)/.pkgbuild
	cd $($(gperf)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(gperf)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(gperf)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(gperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(gperf)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(gperf)-prefix) -C $($(gperf)-srcdir) install
	@touch $@

$($(gperf)-modulefile): $(modulefilesdir)/.markerfile $($(gperf)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(gperf)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(gperf)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(gperf)-description)\"" >>$@
	echo "module-whatis \"$($(gperf)-url)\"" >>$@
	printf "$(foreach prereq,$($(gperf)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GPERF_ROOT $($(gperf)-prefix)" >>$@
	echo "prepend-path PATH $($(gperf)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(gperf)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(gperf)-prefix)/share/info" >>$@
	echo "set MSG \"$(gperf)\"" >>$@

$(gperf)-src: $($(gperf)-src)
$(gperf)-unpack: $($(gperf)-prefix)/.pkgunpack
$(gperf)-patch: $($(gperf)-prefix)/.pkgpatch
$(gperf)-build: $($(gperf)-prefix)/.pkgbuild
$(gperf)-check: $($(gperf)-prefix)/.pkgcheck
$(gperf)-install: $($(gperf)-prefix)/.pkginstall
$(gperf)-modulefile: $($(gperf)-modulefile)
$(gperf)-clean:
	rm -rf $($(gperf)-modulefile)
	rm -rf $($(gperf)-prefix)
	rm -rf $($(gperf)-srcdir)
	rm -rf $($(gperf)-src)
$(gperf): $(gperf)-src $(gperf)-unpack $(gperf)-patch $(gperf)-build $(gperf)-check $(gperf)-install $(gperf)-modulefile
