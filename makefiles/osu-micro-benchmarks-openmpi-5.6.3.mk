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
# osu-micro-benchmarks-5.6.3-openmpi

osu-micro-benchmarks-openmpi-version = 5.6.3
osu-micro-benchmarks-openmpi = osu-micro-benchmarks-openmpi-$(osu-micro-benchmarks-openmpi-version)
$(osu-micro-benchmarks-openmpi)-description = Benchmarks for MPI, OpenSHMEM, UPC and UPC++
$(osu-micro-benchmarks-openmpi)-url = http://mvapich.cse.ohio-state.edu/benchmarks/
$(osu-micro-benchmarks-openmpi)-srcurl =
$(osu-micro-benchmarks-openmpi)-builddeps = $(openmpi)
$(osu-micro-benchmarks-openmpi)-prereqs = $(openmpi)
$(osu-micro-benchmarks-openmpi)-src = $($(osu-micro-benchmarks-src)-src)
$(osu-micro-benchmarks-openmpi)-srcdir = $(pkgsrcdir)/$(osu-micro-benchmarks-openmpi)
$(osu-micro-benchmarks-openmpi)-modulefile = $(modulefilesdir)/$(osu-micro-benchmarks-openmpi)
$(osu-micro-benchmarks-openmpi)-prefix = $(pkgdir)/$(osu-micro-benchmarks-openmpi)

$($(osu-micro-benchmarks-openmpi)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(osu-micro-benchmarks-openmpi)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(osu-micro-benchmarks-openmpi)-prefix)/.pkgunpack: $$($(osu-micro-benchmarks-openmpi)-src) $($(osu-micro-benchmarks-openmpi)-srcdir)/.markerfile $($(osu-micro-benchmarks-openmpi)-prefix)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-openmpi)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(osu-micro-benchmarks-openmpi)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(osu-micro-benchmarks-openmpi)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-openmpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-openmpi)-prefix)/.pkgunpack
	@touch $@

$($(osu-micro-benchmarks-openmpi)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-openmpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-openmpi)-prefix)/.pkgpatch
	cd $($(osu-micro-benchmarks-openmpi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(osu-micro-benchmarks-openmpi)-builddeps) && \
		./configure --prefix=$($(osu-micro-benchmarks-openmpi)-prefix) \
			CC=$${MPICC} CXX=$${MPICXX} && \
		$(MAKE)
	@touch $@

$($(osu-micro-benchmarks-openmpi)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-openmpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-openmpi)-prefix)/.pkgbuild
	cd $($(osu-micro-benchmarks-openmpi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(osu-micro-benchmarks-openmpi)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(osu-micro-benchmarks-openmpi)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(osu-micro-benchmarks-openmpi)-builddeps),$(modulefilesdir)/$$(dep)) $($(osu-micro-benchmarks-openmpi)-prefix)/.pkgcheck
	cd $($(osu-micro-benchmarks-openmpi)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(osu-micro-benchmarks-openmpi)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(osu-micro-benchmarks-openmpi)-modulefile): $(modulefilesdir)/.markerfile $($(osu-micro-benchmarks-openmpi)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(osu-micro-benchmarks-openmpi)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(osu-micro-benchmarks-openmpi)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(osu-micro-benchmarks-openmpi)-description)\"" >>$@
	echo "module-whatis \"$($(osu-micro-benchmarks-openmpi)-url)\"" >>$@
	printf "$(foreach prereq,$($(osu-micro-benchmarks-openmpi)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv OSU_MICRO_BENCHMARKS_ROOT $($(osu-micro-benchmarks-openmpi)-prefix)" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-openmpi)-prefix)/libexec/osu-micro-benchmarks/mpi/collective" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-openmpi)-prefix)/libexec/osu-micro-benchmarks/mpi/one-sided" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-openmpi)-prefix)/libexec/osu-micro-benchmarks/mpi/pt2pt" >>$@
	echo "prepend-path PATH $($(osu-micro-benchmarks-openmpi)-prefix)/libexec/osu-micro-benchmarks/mpi/startup" >>$@
	echo "set MSG \"$(osu-micro-benchmarks-openmpi)\"" >>$@

$(osu-micro-benchmarks-openmpi)-src: $$($(osu-micro-benchmarks-openmpi)-src)
$(osu-micro-benchmarks-openmpi)-unpack: $($(osu-micro-benchmarks-openmpi)-prefix)/.pkgunpack
$(osu-micro-benchmarks-openmpi)-patch: $($(osu-micro-benchmarks-openmpi)-prefix)/.pkgpatch
$(osu-micro-benchmarks-openmpi)-build: $($(osu-micro-benchmarks-openmpi)-prefix)/.pkgbuild
$(osu-micro-benchmarks-openmpi)-check: $($(osu-micro-benchmarks-openmpi)-prefix)/.pkgcheck
$(osu-micro-benchmarks-openmpi)-install: $($(osu-micro-benchmarks-openmpi)-prefix)/.pkginstall
$(osu-micro-benchmarks-openmpi)-modulefile: $($(osu-micro-benchmarks-openmpi)-modulefile)
$(osu-micro-benchmarks-openmpi)-clean:
	rm -rf $($(osu-micro-benchmarks-openmpi)-modulefile)
	rm -rf $($(osu-micro-benchmarks-openmpi)-prefix)
	rm -rf $($(osu-micro-benchmarks-openmpi)-srcdir)
$(osu-micro-benchmarks-openmpi): $(osu-micro-benchmarks-openmpi)-src $(osu-micro-benchmarks-openmpi)-unpack $(osu-micro-benchmarks-openmpi)-patch $(osu-micro-benchmarks-openmpi)-build $(osu-micro-benchmarks-openmpi)-check $(osu-micro-benchmarks-openmpi)-install $(osu-micro-benchmarks-openmpi)-modulefile
