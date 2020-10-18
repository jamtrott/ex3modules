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
# iperf-2.0.13

iperf-version = 2.0.13
iperf = iperf-$(iperf-version)
$(iperf)-description = Network traffic tool for measuring TCP and UDP performance
$(iperf)-url = https://sourceforge.net/projects/iperf2/
$(iperf)-srcurl = https://download.sourceforge.net/iperf2/iperf-$(iperf-version).tar.gz
$(iperf)-builddeps =
$(iperf)-prereqs =
$(iperf)-src = $(pkgsrcdir)/$(notdir $($(iperf)-srcurl))
$(iperf)-srcdir = $(pkgsrcdir)/$(iperf)
$(iperf)-builddir = $($(iperf)-srcdir)
$(iperf)-modulefile = $(modulefilesdir)/$(iperf)
$(iperf)-prefix = $(pkgdir)/$(iperf)

$($(iperf)-src): $(dir $($(iperf)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(iperf)-srcurl)

$($(iperf)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(iperf)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(iperf)-prefix)/.pkgunpack: $($(iperf)-src) $($(iperf)-srcdir)/.markerfile $($(iperf)-prefix)/.markerfile
	tar -C $($(iperf)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(iperf)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(iperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(iperf)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(iperf)-builddir),$($(iperf)-srcdir))
$($(iperf)-builddir)/.markerfile: $($(iperf)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(iperf)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(iperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(iperf)-builddir)/.markerfile $($(iperf)-prefix)/.pkgpatch
	cd $($(iperf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(iperf)-builddeps) && \
		./configure --prefix=$($(iperf)-prefix) && \
		$(MAKE)
	@touch $@

$($(iperf)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(iperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(iperf)-builddir)/.markerfile $($(iperf)-prefix)/.pkgbuild
	cd $($(iperf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(iperf)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(iperf)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(iperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(iperf)-builddir)/.markerfile $($(iperf)-prefix)/.pkgcheck
	cd $($(iperf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(iperf)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(iperf)-modulefile): $(modulefilesdir)/.markerfile $($(iperf)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(iperf)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(iperf)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(iperf)-description)\"" >>$@
	echo "module-whatis \"$($(iperf)-url)\"" >>$@
	printf "$(foreach prereq,$($(iperf)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv IPERF_ROOT $($(iperf)-prefix)" >>$@
	echo "prepend-path PATH $($(iperf)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(iperf)-prefix)/share/man" >>$@
	echo "set MSG \"$(iperf)\"" >>$@

$(iperf)-src: $($(iperf)-src)
$(iperf)-unpack: $($(iperf)-prefix)/.pkgunpack
$(iperf)-patch: $($(iperf)-prefix)/.pkgpatch
$(iperf)-build: $($(iperf)-prefix)/.pkgbuild
$(iperf)-check: $($(iperf)-prefix)/.pkgcheck
$(iperf)-install: $($(iperf)-prefix)/.pkginstall
$(iperf)-modulefile: $($(iperf)-modulefile)
$(iperf)-clean:
	rm -rf $($(iperf)-modulefile)
	rm -rf $($(iperf)-prefix)
	rm -rf $($(iperf)-srcdir)
	rm -rf $($(iperf)-src)
$(iperf): $(iperf)-src $(iperf)-unpack $(iperf)-patch $(iperf)-build $(iperf)-check $(iperf)-install $(iperf)-modulefile
