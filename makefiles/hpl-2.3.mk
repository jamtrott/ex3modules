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
# hpl-2.3

hpl-version = 2.3
hpl = hpl-$(hpl-version)
$(hpl)-description = Portable implementation of the High-Performance Linpack Benchmark for distributed-memory computers
$(hpl)-url = http://www.netlib.org/benchmark/hpl/
$(hpl)-srcurl = http://www.netlib.org/benchmark/hpl/hpl-$(hpl-version).tar.gz
$(hpl)-builddeps = $(blas) $(mpi)
$(hpl)-prereqs = $(blas) $(mpi)
$(hpl)-src = $(pkgsrcdir)/$(notdir $($(hpl)-srcurl))
$(hpl)-srcdir = $(pkgsrcdir)/$(hpl)
$(hpl)-builddir = $($(hpl)-srcdir)
$(hpl)-modulefile = $(modulefilesdir)/$(hpl)
$(hpl)-prefix = $(pkgdir)/$(hpl)

$($(hpl)-src): $(dir $($(hpl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hpl)-srcurl)

$($(hpl)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(hpl)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(hpl)-prefix)/.pkgunpack: $($(hpl)-src) $($(hpl)-srcdir)/.markerfile $($(hpl)-prefix)/.markerfile
	tar -C $($(hpl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(hpl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hpl)-builddeps),$(modulefilesdir)/$$(dep)) $($(hpl)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(example)-builddir),$($(example)-srcdir))
$($(hpl)-builddir)/.markerfile: $($(hpl)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(hpl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hpl)-builddeps),$(modulefilesdir)/$$(dep)) $($(hpl)-builddir)/.markerfile $($(hpl)-prefix)/.pkgpatch
	cd $($(hpl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hpl)-builddeps) && \
		./configure --prefix=$($(hpl)-prefix) && \
		$(MAKE)
	@touch $@

$($(hpl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hpl)-builddeps),$(modulefilesdir)/$$(dep)) $($(hpl)-builddir)/.markerfile $($(hpl)-prefix)/.pkgbuild
	cd $($(hpl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hpl)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(hpl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(hpl)-builddeps),$(modulefilesdir)/$$(dep)) $($(hpl)-builddir)/.markerfile $($(hpl)-prefix)/.pkgcheck
	cd $($(hpl)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(hpl)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(hpl)-modulefile): $(modulefilesdir)/.markerfile $($(hpl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(hpl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(hpl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(hpl)-description)\"" >>$@
	echo "module-whatis \"$($(hpl)-url)\"" >>$@
	printf "$(foreach prereq,$($(hpl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv HPL_ROOT $($(hpl)-prefix)" >>$@
	echo "setenv HPL_LIBDIR $($(hpl)-prefix)/lib" >>$@
	echo "setenv HPL_LIBRARYDIR $($(hpl)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(hpl)-prefix)/bin" >>$@
	echo "prepend-path LIBRARY_PATH $($(hpl)-prefix)/lib" >>$@
	echo "set MSG \"$(hpl)\"" >>$@

$(hpl)-src: $($(hpl)-src)
$(hpl)-unpack: $($(hpl)-prefix)/.pkgunpack
$(hpl)-patch: $($(hpl)-prefix)/.pkgpatch
$(hpl)-build: $($(hpl)-prefix)/.pkgbuild
$(hpl)-check: $($(hpl)-prefix)/.pkgcheck
$(hpl)-install: $($(hpl)-prefix)/.pkginstall
$(hpl)-modulefile: $($(hpl)-modulefile)
$(hpl)-clean:
	rm -rf $($(hpl)-modulefile)
	rm -rf $($(hpl)-prefix)
	rm -rf $($(hpl)-srcdir)
	rm -rf $($(hpl)-src)
$(hpl): $(hpl)-src $(hpl)-unpack $(hpl)-patch $(hpl)-build $(hpl)-check $(hpl)-install $(hpl)-modulefile
