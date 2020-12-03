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
# qperf-0.4.11

qperf-version = 0.4.11
qperf = qperf-$(qperf-version)
$(qperf)-description = Tool for measuring socket and RDMA performance
$(qperf)-url = https://github.com/linux-rdma/qperf/
$(qperf)-srcurl = https://github.com/linux-rdma/qperf/archive/v$(qperf-version).tar.gz
$(qperf)-builddeps =
$(qperf)-prereqs =
$(qperf)-src = $(pkgsrcdir)/$(notdir $($(qperf)-srcurl))
$(qperf)-srcdir = $(pkgsrcdir)/$(qperf)
$(qperf)-builddir = $($(qperf)-srcdir)
$(qperf)-modulefile = $(modulefilesdir)/$(qperf)
$(qperf)-prefix = $(pkgdir)/$(qperf)

$($(qperf)-src): $(dir $($(qperf)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(qperf)-srcurl)

$($(qperf)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(qperf)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(qperf)-prefix)/.pkgunpack: $($(qperf)-src) $($(qperf)-srcdir)/.markerfile $($(qperf)-prefix)/.markerfile
	tar -C $($(qperf)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(qperf)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(qperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(qperf)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(qperf)-builddir),$($(qperf)-srcdir))
$($(qperf)-builddir)/.markerfile: $($(qperf)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(qperf)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(qperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(qperf)-builddir)/.markerfile $($(qperf)-prefix)/.pkgpatch
	cd $($(qperf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(qperf)-builddeps) && \
		./autogen.sh && \
		./configure --prefix=$($(qperf)-prefix) && \
		$(MAKE)
	@touch $@

$($(qperf)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(qperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(qperf)-builddir)/.markerfile $($(qperf)-prefix)/.pkgbuild
	cd $($(qperf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(qperf)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(qperf)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(qperf)-builddeps),$(modulefilesdir)/$$(dep)) $($(qperf)-builddir)/.markerfile $($(qperf)-prefix)/.pkgcheck
	cd $($(qperf)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(qperf)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(qperf)-modulefile): $(modulefilesdir)/.markerfile $($(qperf)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(qperf)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(qperf)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(qperf)-description)\"" >>$@
	echo "module-whatis \"$($(qperf)-url)\"" >>$@
	printf "$(foreach prereq,$($(qperf)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv QPERF_ROOT $($(qperf)-prefix)" >>$@
	echo "prepend-path PATH $($(qperf)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(qperf)-prefix)/share/man" >>$@
	echo "set MSG \"$(qperf)\"" >>$@

$(qperf)-src: $($(qperf)-src)
$(qperf)-unpack: $($(qperf)-prefix)/.pkgunpack
$(qperf)-patch: $($(qperf)-prefix)/.pkgpatch
$(qperf)-build: $($(qperf)-prefix)/.pkgbuild
$(qperf)-check: $($(qperf)-prefix)/.pkgcheck
$(qperf)-install: $($(qperf)-prefix)/.pkginstall
$(qperf)-modulefile: $($(qperf)-modulefile)
$(qperf)-clean:
	rm -rf $($(qperf)-modulefile)
	rm -rf $($(qperf)-prefix)
	rm -rf $($(qperf)-srcdir)
	rm -rf $($(qperf)-src)
$(qperf): $(qperf)-src $(qperf)-unpack $(qperf)-patch $(qperf)-build $(qperf)-check $(qperf)-install $(qperf)-modulefile
