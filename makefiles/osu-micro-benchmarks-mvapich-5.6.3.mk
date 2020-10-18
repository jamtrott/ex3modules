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
# osu-micro-benchmarks-5.6.3-mvapich

osu-micro-benchmarks-mvapich-version = 5.6.3
osu-micro-benchmarks-mvapich = osu-micro-benchmarks-mvapich-$(osu-micro-benchmarks-mvapich-version)
$(osu-micro-benchmarks-mvapich)-description = Benchmarks for MPI, OpenSHMEM, UPC and UPC++
$(osu-micro-benchmarks-mvapich)-url = http://mvapich.cse.ohio-state.edu/benchmarks/
$(osu-micro-benchmarks-mvapich)-srcurl =
$(osu-micro-benchmarks-mvapich)-builddeps = $(mvapich)
$(osu-micro-benchmarks-mvapich)-prereqs = $(mvapich)
$(osu-micro-benchmarks-mvapich)-src = $($(osu-micro-benchmarks-src)-src)
$(osu-micro-benchmarks-mvapich)-srcdir = $(pkgsrcdir)/$(osu-micro-benchmarks-mvapich)
$(osu-micro-benchmarks-mvapich)-modulefile = $(modulefilesdir)/$(osu-micro-benchmarks-mvapich)
$(osu-micro-benchmarks-mvapich)-prefix = $(pkgdir)/$(osu-micro-benchmarks-mvapich)

$($(osu-micro-benchmarks-mvapich)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(osu-micro-benchmarks-mvapich)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(osu-micro-benchmarks-mvapich)-prefix)/.pkgunpack: $$($(osu-micro-benchmarks-mvapich)-src) $($(osu-micro-benchmarks-mvapich)-srcdir)/.markerfile $($(osu-micro-benchmarks-mvapich)-prefix)/.markerfile
	tar -C $($(osu-micro-benchmarks-mvapich)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(osu-micro-benchmarks-mvapich)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-mvapich)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-mvapich)-prefix)/.pkgunpack
	@touch $@

$($(osu-micro-benchmarks-mvapich)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-mvapich)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-mvapich)-prefix)/.pkgpatch
	cd $($(osu-micro-benchmarks-mvapich)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(osu-micro-benchmarks-mvapich)-builddeps) && \
		./configure --prefix=$($(osu-micro-benchmarks-mvapich)-prefix) \
			CC=$${MPICC} CXX=$${MPICXX} && \
		$(MAKE)
	@touch $@

$($(osu-micro-benchmarks-mvapich)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-mvapich)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-mvapich)-prefix)/.pkgbuild
	cd $($(osu-micro-benchmarks-mvapich)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(osu-micro-benchmarks-mvapich)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(osu-micro-benchmarks-mvapich)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-mvapich)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-mvapich)-prefix)/.pkgcheck
	cd $($(osu-micro-benchmarks-mvapich)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(osu-micro-benchmarks-mvapich)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(osu-micro-benchmarks-mvapich)-modulefile): $(modulefilesdir)/.markerfile $($(osu-micro-benchmarks-mvapich)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(osu-micro-benchmarks-mvapich)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(osu-micro-benchmarks-mvapich)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(osu-micro-benchmarks-mvapich)-description)\"" >>$@
	echo "module-whatis \"$($(osu-micro-benchmarks-mvapich)-url)\"" >>$@
	printf "$(foreach prereq,$($(osu-micro-benchmarks-mvapich)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OSU_MICRO_BENCHMARKS_ROOT $($(osu-micro-benchmarks-mvapich)-prefix)" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-mvapich)-prefix)/libexec/osu-micro-benchmarks/mpi/collective" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-mvapich)-prefix)/libexec/osu-micro-benchmarks/mpi/one-sided" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-mvapich)-prefix)/libexec/osu-micro-benchmarks/mpi/pt2pt" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-mvapich)-prefix)/libexec/osu-micro-benchmarks/mpi/startup" >>$@
	echo "set MSG \"$(osu-micro-benchmarks-mvapich)\"" >>$@

$(osu-micro-benchmarks-mvapich)-src: $$($(osu-micro-benchmarks-mvapich)-src)
$(osu-micro-benchmarks-mvapich)-unpack: $($(osu-micro-benchmarks-mvapich)-prefix)/.pkgunpack
$(osu-micro-benchmarks-mvapich)-patch: $($(osu-micro-benchmarks-mvapich)-prefix)/.pkgpatch
$(osu-micro-benchmarks-mvapich)-build: $($(osu-micro-benchmarks-mvapich)-prefix)/.pkgbuild
$(osu-micro-benchmarks-mvapich)-check: $($(osu-micro-benchmarks-mvapich)-prefix)/.pkgcheck
$(osu-micro-benchmarks-mvapich)-install: $($(osu-micro-benchmarks-mvapich)-prefix)/.pkginstall
$(osu-micro-benchmarks-mvapich)-modulefile: $($(osu-micro-benchmarks-mvapich)-modulefile)
$(osu-micro-benchmarks-mvapich)-clean:
	rm -rf $($(osu-micro-benchmarks-mvapich)-modulefile)
	rm -rf $($(osu-micro-benchmarks-mvapich)-prefix)
	rm -rf $($(osu-micro-benchmarks-mvapich)-srcdir)
$(osu-micro-benchmarks-mvapich): $(osu-micro-benchmarks-mvapich)-src $(osu-micro-benchmarks-mvapich)-unpack $(osu-micro-benchmarks-mvapich)-patch $(osu-micro-benchmarks-mvapich)-build $(osu-micro-benchmarks-mvapich)-check $(osu-micro-benchmarks-mvapich)-install $(osu-micro-benchmarks-mvapich)-modulefile
