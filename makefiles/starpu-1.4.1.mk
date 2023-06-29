# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# starpu-1.4.1

starpu-version = 1.4.1
starpu = starpu-$(starpu-version)
$(starpu)-description = task programming library for hybrid architectures
$(starpu)-url = https://starpu.gitlabpages.inria.fr/
$(starpu)-srcurl = https://files.inria.fr/starpu/starpu-1.4.1/starpu-1.4.1.tar.gz
$(starpu)-builddeps = $(mpi)
$(starpu)-prereqs = $(hwloc) $(mpi)
$(starpu)-src = $(pkgsrcdir)/$(notdir $($(starpu)-srcurl))
$(starpu)-srcdir = $(pkgsrcdir)/$(starpu)
$(starpu)-builddir = $($(starpu)-srcdir)/build
$(starpu)-modulefile = $(modulefilesdir)/$(starpu)
$(starpu)-prefix = $(pkgdir)/$(starpu)

$($(starpu)-src): $(dir $($(starpu)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(starpu)-srcurl)

$($(starpu)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(starpu)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(starpu)-prefix)/.pkgunpack: $$($(starpu)-src) $($(starpu)-srcdir)/.markerfile $($(starpu)-prefix)/.markerfile $$(foreach dep,$$($(starpu)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(starpu)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(starpu)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(starpu)-builddeps),$(modulefilesdir)/$$(dep)) $($(starpu)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(starpu)-builddir),$($(starpu)-srcdir))
$($(starpu)-builddir)/.markerfile: $($(starpu)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(starpu)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(starpu)-builddeps),$(modulefilesdir)/$$(dep)) $($(starpu)-builddir)/.markerfile $($(starpu)-prefix)/.pkgpatch
	cd $($(starpu)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(starpu)-builddeps) && \
		../configure --prefix=$($(starpu)-prefix) \
			$$([ ! -z "$${HWLOC_ROOT}" ] && echo --with-hwloc="$${HWLOC_ROOT}") \
			$$([ ! -z "$${CUDA_TOOLKIT_ROOT}" ] && echo "--enable-cuda --with-cuda-dir=$${CUDA_TOOLKIT_ROOT}" || echo "--disable-cuda") \
			$$([ ! -z "$${ROCM_ROOT}" ] && echo "--enable-hip" || echo "--disable-hip") && \
		$(MAKE)
	@touch $@

$($(starpu)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(starpu)-builddeps),$(modulefilesdir)/$$(dep)) $($(starpu)-builddir)/.markerfile $($(starpu)-prefix)/.pkgbuild
	# cd $($(starpu)-builddir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(starpu)-builddeps) && \
	# 	$(MAKE) check
	@touch $@

$($(starpu)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(starpu)-builddeps),$(modulefilesdir)/$$(dep)) $($(starpu)-builddir)/.markerfile $($(starpu)-prefix)/.pkgcheck
	cd $($(starpu)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(starpu)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(starpu)-modulefile): $(modulefilesdir)/.markerfile $($(starpu)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(starpu)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(starpu)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(starpu)-description)\"" >>$@
	echo "module-whatis \"$($(starpu)-url)\"" >>$@
	printf "$(foreach prereq,$($(starpu)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv STARPU_ROOT $($(starpu)-prefix)" >>$@
	echo "setenv STARPU_INCDIR $($(starpu)-prefix)/include" >>$@
	echo "setenv STARPU_INCLUDEDIR $($(starpu)-prefix)/include" >>$@
	echo "setenv STARPU_LIBDIR $($(starpu)-prefix)/lib" >>$@
	echo "setenv STARPU_LIBRARYDIR $($(starpu)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(starpu)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(starpu)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(starpu)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(starpu)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(starpu)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(starpu)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(starpu)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(starpu)-prefix)/share/info" >>$@
	echo "set MSG \"$(starpu)\"" >>$@

$(starpu)-src: $$($(starpu)-src)
$(starpu)-unpack: $($(starpu)-prefix)/.pkgunpack
$(starpu)-patch: $($(starpu)-prefix)/.pkgpatch
$(starpu)-build: $($(starpu)-prefix)/.pkgbuild
$(starpu)-check: $($(starpu)-prefix)/.pkgcheck
$(starpu)-install: $($(starpu)-prefix)/.pkginstall
$(starpu)-modulefile: $($(starpu)-modulefile)
$(starpu)-clean:
	rm -rf $($(starpu)-modulefile)
	rm -rf $($(starpu)-prefix)
	rm -rf $($(starpu)-builddir)
	rm -rf $($(starpu)-srcdir)
	rm -rf $($(starpu)-src)
$(starpu): $(starpu)-src $(starpu)-unpack $(starpu)-patch $(starpu)-build $(starpu)-check $(starpu)-install $(starpu)-modulefile
