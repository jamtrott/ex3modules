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
# osu-micro-benchmarks-5.6.3-mpich

osu-micro-benchmarks-mpich-version = 5.6.3
osu-micro-benchmarks-mpich = osu-micro-benchmarks-mpich-$(osu-micro-benchmarks-mpich-version)
$(osu-micro-benchmarks-mpich)-description = Benchmarks for MPI, OpenSHMEM, UPC and UPC++
$(osu-micro-benchmarks-mpich)-url = http://mvapich.cse.ohio-state.edu/benchmarks/
$(osu-micro-benchmarks-mpich)-srcurl =
$(osu-micro-benchmarks-mpich)-builddeps = $(mpich)
$(osu-micro-benchmarks-mpich)-prereqs = $(mpich)
$(osu-micro-benchmarks-mpich)-src = $($(osu-micro-benchmarks-src)-src)
$(osu-micro-benchmarks-mpich)-srcdir = $(pkgsrcdir)/$(osu-micro-benchmarks-mpich)
$(osu-micro-benchmarks-mpich)-modulefile = $(modulefilesdir)/$(osu-micro-benchmarks-mpich)
$(osu-micro-benchmarks-mpich)-prefix = $(pkgdir)/$(osu-micro-benchmarks-mpich)

$($(osu-micro-benchmarks-mpich)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(osu-micro-benchmarks-mpich)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(osu-micro-benchmarks-mpich)-prefix)/.pkgunpack: $$($(osu-micro-benchmarks-mpich)-src) $($(osu-micro-benchmarks-mpich)-srcdir)/.markerfile $($(osu-micro-benchmarks-mpich)-prefix)/.markerfile
	tar -C $($(osu-micro-benchmarks-mpich)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(osu-micro-benchmarks-mpich)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-mpich)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-mpich)-prefix)/.pkgunpack
	@touch $@

$($(osu-micro-benchmarks-mpich)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-mpich)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-mpich)-prefix)/.pkgpatch
	cd $($(osu-micro-benchmarks-mpich)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(osu-micro-benchmarks-mpich)-builddeps) && \
		./configure --prefix=$($(osu-micro-benchmarks-mpich)-prefix) \
			CC=$${MPICC} CXX=$${MPICXX} && \
		$(MAKE)
	@touch $@

$($(osu-micro-benchmarks-mpich)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-mpich)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-mpich)-prefix)/.pkgbuild
	cd $($(osu-micro-benchmarks-mpich)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(osu-micro-benchmarks-mpich)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(osu-micro-benchmarks-mpich)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-mpich)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-mpich)-prefix)/.pkgcheck
	cd $($(osu-micro-benchmarks-mpich)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(osu-micro-benchmarks-mpich)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(osu-micro-benchmarks-mpich)-modulefile): $(modulefilesdir)/.markerfile $($(osu-micro-benchmarks-mpich)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(osu-micro-benchmarks-mpich)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(osu-micro-benchmarks-mpich)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(osu-micro-benchmarks-mpich)-description)\"" >>$@
	echo "module-whatis \"$($(osu-micro-benchmarks-mpich)-url)\"" >>$@
	printf "$(foreach prereq,$($(osu-micro-benchmarks-mpich)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OSU_MICRO_BENCHMARKS_ROOT $($(osu-micro-benchmarks-mpich)-prefix)" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-mpich)-prefix)/libexec/osu-micro-benchmarks/mpi/collective" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-mpich)-prefix)/libexec/osu-micro-benchmarks/mpi/one-sided" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-mpich)-prefix)/libexec/osu-micro-benchmarks/mpi/pt2pt" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-mpich)-prefix)/libexec/osu-micro-benchmarks/mpi/startup" >>$@
	echo "set MSG \"$(osu-micro-benchmarks-mpich)\"" >>$@

$(osu-micro-benchmarks-mpich)-src: $$($(osu-micro-benchmarks-mpich)-src)
$(osu-micro-benchmarks-mpich)-unpack: $($(osu-micro-benchmarks-mpich)-prefix)/.pkgunpack
$(osu-micro-benchmarks-mpich)-patch: $($(osu-micro-benchmarks-mpich)-prefix)/.pkgpatch
$(osu-micro-benchmarks-mpich)-build: $($(osu-micro-benchmarks-mpich)-prefix)/.pkgbuild
$(osu-micro-benchmarks-mpich)-check: $($(osu-micro-benchmarks-mpich)-prefix)/.pkgcheck
$(osu-micro-benchmarks-mpich)-install: $($(osu-micro-benchmarks-mpich)-prefix)/.pkginstall
$(osu-micro-benchmarks-mpich)-modulefile: $($(osu-micro-benchmarks-mpich)-modulefile)
$(osu-micro-benchmarks-mpich)-clean:
	rm -rf $($(osu-micro-benchmarks-mpich)-modulefile)
	rm -rf $($(osu-micro-benchmarks-mpich)-prefix)
	rm -rf $($(osu-micro-benchmarks-mpich)-srcdir)
$(osu-micro-benchmarks-mpich): $(osu-micro-benchmarks-mpich)-src $(osu-micro-benchmarks-mpich)-unpack $(osu-micro-benchmarks-mpich)-patch $(osu-micro-benchmarks-mpich)-build $(osu-micro-benchmarks-mpich)-check $(osu-micro-benchmarks-mpich)-install $(osu-micro-benchmarks-mpich)-modulefile
