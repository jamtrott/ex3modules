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
# slurm-18.08.9

slurm-version = 18.08.9
slurm = slurm-$(slurm-version)
$(slurm)-description = Highly configurable open-source workload manager
$(slurm)-url = https://www.schedmd.com/
$(slurm)-srcurl = https://download.schedmd.com/slurm/slurm-$(slurm-version).tar.bz2
$(slurm)-builddeps = $(ucx) $(numactl) $(hwloc) $(freeipmi) $(munge) $(openssl) $(curl) $(readline)
$(slurm)-prereqs = $(ucx) $(numactl) $(hwloc) $(freeipmi) $(munge) $(openssl) $(curl) $(readline)
$(slurm)-src = $(pkgsrcdir)/$(notdir $($(slurm)-srcurl))
$(slurm)-srcdir = $(pkgsrcdir)/$(slurm)
$(slurm)-builddir = $($(slurm)-srcdir)
$(slurm)-modulefile = $(modulefilesdir)/$(slurm)
$(slurm)-prefix = $(pkgdir)/$(slurm)

$($(slurm)-src): $(dir $($(slurm)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(slurm)-srcurl)

$($(slurm)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(slurm)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(slurm)-prefix)/.pkgunpack: $($(slurm)-src) $($(slurm)-srcdir)/.markerfile $($(slurm)-prefix)/.markerfile
	tar -C $($(slurm)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(slurm)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(slurm)-builddir),$($(slurm)-srcdir))
$($(slurm)-builddir)/.markerfile: $($(slurm)-prefix)/.pkgunpack
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@
endif

$($(slurm)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm)-builddir)/.markerfile $($(slurm)-prefix)/.pkgpatch
	cd $($(slurm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm)-builddeps) && \
		./configure --prefix=$($(slurm)-prefix) \
			--sysconfdir=/etc/slurm \
			--with-hwloc=$${HWLOC_ROOT} \
			--with-freeipmi=$${FREEIPMI_ROOT} \
			--with-ucx=$${UCX_ROOT} \
			--with-ssl=$${OPENSSL_ROOT} \
			--with-munge=$${MUNGE_ROOT} \
			--with-libcurl=$${CURL_ROOT} && \
		$(MAKE)
	@touch $@

$($(slurm)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm)-builddir)/.markerfile $($(slurm)-prefix)/.pkgbuild
	cd $($(slurm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(slurm)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm)-builddir)/.markerfile $($(slurm)-prefix)/.pkgcheck
	cd $($(slurm)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm)-builddeps) && \
		$(MAKE) install && \
		$(MAKE) -C contribs/pmi install && \
		$(MAKE) -C contribs/pmi2 install
	@touch $@

$($(slurm)-modulefile): $(modulefilesdir)/.markerfile $($(slurm)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(slurm)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(slurm)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(slurm)-description)\"" >>$@
	echo "module-whatis \"$($(slurm)-url)\"" >>$@
	printf "$(foreach prereq,$($(slurm)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SLURM_ROOT $($(slurm)-prefix)" >>$@
	echo "setenv SLURM_INCDIR $($(slurm)-prefix)/include" >>$@
	echo "setenv SLURM_INCLUDEDIR $($(slurm)-prefix)/include" >>$@
	echo "setenv SLURM_LIBDIR $($(slurm)-prefix)/lib" >>$@
	echo "setenv SLURM_LIBRARYDIR $($(slurm)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(slurm)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(slurm)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(slurm)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(slurm)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(slurm)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(slurm)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(slurm)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(slurm)-prefix)/share/info" >>$@
	echo "set MSG \"$(slurm)\"" >>$@

$(slurm)-src: $($(slurm)-src)
$(slurm)-unpack: $($(slurm)-prefix)/.pkgunpack
$(slurm)-patch: $($(slurm)-prefix)/.pkgpatch
$(slurm)-build: $($(slurm)-prefix)/.pkgbuild
$(slurm)-check: $($(slurm)-prefix)/.pkgcheck
$(slurm)-install: $($(slurm)-prefix)/.pkginstall
$(slurm)-modulefile: $($(slurm)-modulefile)
$(slurm)-clean:
	rm -rf $($(slurm)-modulefile)
	rm -rf $($(slurm)-prefix)
	rm -rf $($(slurm)-srcdir)
	rm -rf $($(slurm)-src)
$(slurm): $(slurm)-src $(slurm)-unpack $(slurm)-patch $(slurm)-build $(slurm)-check $(slurm)-install $(slurm)-modulefile
