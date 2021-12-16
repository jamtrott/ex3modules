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

slurm-18.08-version = 18.08.9
slurm-18.08 = slurm-$(slurm-18.08-version)
$(slurm-18.08)-description = Highly configurable open-source workload manager
$(slurm-18.08)-url = https://www.schedmd.com/
$(slurm-18.08)-srcurl = https://download.schedmd.com/slurm/slurm-$(slurm-18.08-version).tar.bz2
$(slurm-18.08)-builddeps = $(ucx) $(numactl) $(hwloc) $(freeipmi) $(munge) $(openssl) $(curl) $(readline)
$(slurm-18.08)-prereqs = $(ucx) $(numactl) $(hwloc) $(freeipmi) $(munge) $(openssl) $(curl) $(readline)
$(slurm-18.08)-src = $(pkgsrcdir)/$(notdir $($(slurm-18.08)-srcurl))
$(slurm-18.08)-srcdir = $(pkgsrcdir)/$(slurm-18.08)
$(slurm-18.08)-builddir = $($(slurm-18.08)-srcdir)
$(slurm-18.08)-modulefile = $(modulefilesdir)/$(slurm-18.08)
$(slurm-18.08)-prefix = $(pkgdir)/$(slurm-18.08)

$($(slurm-18.08)-src): $(dir $($(slurm-18.08)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(slurm-18.08)-srcurl)

$($(slurm-18.08)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(slurm-18.08)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(slurm-18.08)-prefix)/.pkgunpack: $($(slurm-18.08)-src) $($(slurm-18.08)-srcdir)/.markerfile $($(slurm-18.08)-prefix)/.markerfile $$(foreach dep,$$($(slurm-18.08)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(slurm-18.08)-srcdir) --strip-components 1 -xj -f $<
	@touch $@

$($(slurm-18.08)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-18.08)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-18.08)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(slurm-18.08)-builddir),$($(slurm-18.08)-srcdir))
$($(slurm-18.08)-builddir)/.markerfile: $($(slurm-18.08)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(slurm-18.08)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-18.08)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-18.08)-builddir)/.markerfile $($(slurm-18.08)-prefix)/.pkgpatch
	cd $($(slurm-18.08)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm-18.08)-builddeps) && \
		./configure --prefix=$($(slurm-18.08)-prefix) \
			--sysconfdir=/etc/slurm \
			--with-hwloc=$${HWLOC_ROOT} \
			--with-freeipmi=$${FREEIPMI_ROOT} \
			--with-ucx=$${UCX_ROOT} \
			--with-ssl=$${OPENSSL_ROOT} \
			--with-munge=$${MUNGE_ROOT} \
			--with-libcurl=$${CURL_ROOT} && \
		$(MAKE)
	@touch $@

$($(slurm-18.08)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-18.08)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-18.08)-builddir)/.markerfile $($(slurm-18.08)-prefix)/.pkgbuild
	cd $($(slurm-18.08)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm-18.08)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(slurm-18.08)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(slurm-18.08)-builddeps),$(modulefilesdir)/$$(dep)) $($(slurm-18.08)-builddir)/.markerfile $($(slurm-18.08)-prefix)/.pkgcheck
	cd $($(slurm-18.08)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(slurm-18.08)-builddeps) && \
		$(MAKE) install && \
		$(MAKE) -C contribs/pmi install && \
		$(MAKE) -C contribs/pmi2 install
	@touch $@

$($(slurm-18.08)-modulefile): $(modulefilesdir)/.markerfile $($(slurm-18.08)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(slurm-18.08)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(slurm-18.08)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(slurm-18.08)-description)\"" >>$@
	echo "module-whatis \"$($(slurm-18.08)-url)\"" >>$@
	printf "$(foreach prereq,$($(slurm-18.08)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SLURM_ROOT $($(slurm-18.08)-prefix)" >>$@
	echo "setenv SLURM_INCDIR $($(slurm-18.08)-prefix)/include" >>$@
	echo "setenv SLURM_INCLUDEDIR $($(slurm-18.08)-prefix)/include" >>$@
	echo "setenv SLURM_LIBDIR $($(slurm-18.08)-prefix)/lib" >>$@
	echo "setenv SLURM_LIBRARYDIR $($(slurm-18.08)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(slurm-18.08)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(slurm-18.08)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(slurm-18.08)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(slurm-18.08)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(slurm-18.08)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(slurm-18.08)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(slurm-18.08)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(slurm-18.08)-prefix)/share/info" >>$@
	echo "set MSG \"$(slurm-18.08)\"" >>$@

$(slurm-18.08)-src: $($(slurm-18.08)-src)
$(slurm-18.08)-unpack: $($(slurm-18.08)-prefix)/.pkgunpack
$(slurm-18.08)-patch: $($(slurm-18.08)-prefix)/.pkgpatch
$(slurm-18.08)-build: $($(slurm-18.08)-prefix)/.pkgbuild
$(slurm-18.08)-check: $($(slurm-18.08)-prefix)/.pkgcheck
$(slurm-18.08)-install: $($(slurm-18.08)-prefix)/.pkginstall
$(slurm-18.08)-modulefile: $($(slurm-18.08)-modulefile)
$(slurm-18.08)-clean:
	rm -rf $($(slurm-18.08)-modulefile)
	rm -rf $($(slurm-18.08)-prefix)
	rm -rf $($(slurm-18.08)-srcdir)
	rm -rf $($(slurm-18.08)-src)
$(slurm-18.08): $(slurm-18.08)-src $(slurm-18.08)-unpack $(slurm-18.08)-patch $(slurm-18.08)-build $(slurm-18.08)-check $(slurm-18.08)-install $(slurm-18.08)-modulefile
