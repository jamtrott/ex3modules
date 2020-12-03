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
# parallel-20190922

parallel-version = 20190922
parallel = parallel-$(parallel-version)
$(parallel)-description = Shell tool for executing jobs in parallel using one or more computers
$(parallel)-url = https://www.gnu.org/software/parallel/
$(parallel)-srcurl = https://ftp.gnu.org/gnu/parallel/parallel-$(parallel-version).tar.bz2
$(parallel)-builddeps = 
$(parallel)-prereqs = 
$(parallel)-src = $(pkgsrcdir)/$(notdir $($(parallel)-srcurl))
$(parallel)-srcdir = $(pkgsrcdir)/$(parallel)
$(parallel)-builddir = $($(parallel)-srcdir)
$(parallel)-modulefile = $(modulefilesdir)/$(parallel)
$(parallel)-prefix = $(pkgdir)/$(parallel)

$($(parallel)-src): $(dir $($(parallel)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(parallel)-srcurl)

$($(parallel)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parallel)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(parallel)-prefix)/.pkgunpack: $($(parallel)-src) $($(parallel)-srcdir)/.markerfile $($(parallel)-prefix)/.markerfile
	tar -C $($(parallel)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(parallel)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parallel)-builddeps),$(modulefilesdir)/$$(dep)) $($(parallel)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(parallel)-builddir),$($(parallel)-srcdir))
$($(parallel)-builddir)/.markerfile: $($(parallel)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(parallel)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parallel)-builddeps),$(modulefilesdir)/$$(dep)) $($(parallel)-builddir)/.markerfile $($(parallel)-prefix)/.pkgpatch
	cd $($(parallel)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parallel)-builddeps) && \
		./configure --prefix=$($(parallel)-prefix) && \
		$(MAKE)
	@touch $@

$($(parallel)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parallel)-builddeps),$(modulefilesdir)/$$(dep)) $($(parallel)-builddir)/.markerfile $($(parallel)-prefix)/.pkgbuild
	cd $($(parallel)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parallel)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(parallel)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(parallel)-builddeps),$(modulefilesdir)/$$(dep)) $($(parallel)-builddir)/.markerfile $($(parallel)-prefix)/.pkgcheck
	cd $($(parallel)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(parallel)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(parallel)-modulefile): $(modulefilesdir)/.markerfile $($(parallel)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(parallel)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(parallel)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(parallel)-description)\"" >>$@
	echo "module-whatis \"$($(parallel)-url)\"" >>$@
	printf "$(foreach prereq,$($(parallel)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PARALLEL_ROOT $($(parallel)-prefix)" >>$@
	echo "prepend-path PATH $($(parallel)-prefix)/bin" >>$@
	echo "prepend-path MANPATH $($(parallel)-prefix)/share/man" >>$@
	echo "set MSG \"$(parallel)\"" >>$@

$(parallel)-src: $($(parallel)-src)
$(parallel)-unpack: $($(parallel)-prefix)/.pkgunpack
$(parallel)-patch: $($(parallel)-prefix)/.pkgpatch
$(parallel)-build: $($(parallel)-prefix)/.pkgbuild
$(parallel)-check: $($(parallel)-prefix)/.pkgcheck
$(parallel)-install: $($(parallel)-prefix)/.pkginstall
$(parallel)-modulefile: $($(parallel)-modulefile)
$(parallel)-clean:
	rm -rf $($(parallel)-modulefile)
	rm -rf $($(parallel)-prefix)
	rm -rf $($(parallel)-srcdir)
	rm -rf $($(parallel)-src)
$(parallel): $(parallel)-src $(parallel)-unpack $(parallel)-patch $(parallel)-build $(parallel)-check $(parallel)-install $(parallel)-modulefile
