# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# ipopt-3.13.3

ipopt-version = 3.13.3
ipopt = ipopt-$(ipopt-version)
$(ipopt)-description = Interior Point Optimizer for large-scale nonlinear optimization
$(ipopt)-url = https://coin-or.github.io/Ipopt/
$(ipopt)-srcurl = https://www.coin-or.org/download/source/Ipopt/Ipopt-$(ipopt-version).tgz
$(ipopt)-builddeps = $(blas) $(lapack) $(mumps) $(metis)
$(ipopt)-prereqs = $(blas) $(lapack) $(mumps) $(metis)
$(ipopt)-src = $(pkgsrcdir)/$(notdir $($(ipopt)-srcurl))
$(ipopt)-srcdir = $(pkgsrcdir)/$(ipopt)
$(ipopt)-builddir = $($(ipopt)-srcdir)
$(ipopt)-modulefile = $(modulefilesdir)/$(ipopt)
$(ipopt)-prefix = $(pkgdir)/$(ipopt)

$($(ipopt)-src): $(dir $($(ipopt)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ipopt)-srcurl)

$($(ipopt)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ipopt)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ipopt)-prefix)/.pkgunpack: $$($(ipopt)-src) $($(ipopt)-srcdir)/.markerfile $($(ipopt)-prefix)/.markerfile
	tar -C $($(ipopt)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ipopt)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ipopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(ipopt)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(ipopt)-builddir),$($(ipopt)-srcdir))
$($(ipopt)-builddir)/.markerfile: $($(ipopt)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(ipopt)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ipopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(ipopt)-builddir)/.markerfile $($(ipopt)-prefix)/.pkgpatch
	cd $($(ipopt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ipopt)-builddeps) && \
		./configure --prefix=$($(ipopt)-prefix) \
		--with-lapack="-L$${LAPACKDIR} -l$${LAPACKLIB} -L$${BLASDIR} -l$${BLASLIB}" && \
		$(MAKE)
	@touch $@

$($(ipopt)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ipopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(ipopt)-builddir)/.markerfile $($(ipopt)-prefix)/.pkgbuild
	cd $($(ipopt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ipopt)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(ipopt)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ipopt)-builddeps),$(modulefilesdir)/$$(dep)) $($(ipopt)-builddir)/.markerfile $($(ipopt)-prefix)/.pkgcheck
	cd $($(ipopt)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ipopt)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(ipopt)-modulefile): $(modulefilesdir)/.markerfile $($(ipopt)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ipopt)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ipopt)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ipopt)-description)\"" >>$@
	echo "module-whatis \"$($(ipopt)-url)\"" >>$@
	printf "$(foreach prereq,$($(ipopt)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv IPOPT_ROOT $($(ipopt)-prefix)" >>$@
	echo "setenv IPOPT_INCDIR $($(ipopt)-prefix)/include" >>$@
	echo "setenv IPOPT_INCLUDEDIR $($(ipopt)-prefix)/include" >>$@
	echo "setenv IPOPT_LIBDIR $($(ipopt)-prefix)/lib" >>$@
	echo "setenv IPOPT_LIBRARYDIR $($(ipopt)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(ipopt)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(ipopt)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(ipopt)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(ipopt)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(ipopt)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(ipopt)\"" >>$@

$(ipopt)-src: $$($(ipopt)-src)
$(ipopt)-unpack: $($(ipopt)-prefix)/.pkgunpack
$(ipopt)-patch: $($(ipopt)-prefix)/.pkgpatch
$(ipopt)-build: $($(ipopt)-prefix)/.pkgbuild
$(ipopt)-check: $($(ipopt)-prefix)/.pkgcheck
$(ipopt)-install: $($(ipopt)-prefix)/.pkginstall
$(ipopt)-modulefile: $($(ipopt)-modulefile)
$(ipopt)-clean:
	rm -rf $($(ipopt)-modulefile)
	rm -rf $($(ipopt)-prefix)
	rm -rf $($(ipopt)-builddir)
	rm -rf $($(ipopt)-srcdir)
	rm -rf $($(ipopt)-src)
$(ipopt): $(ipopt)-src $(ipopt)-unpack $(ipopt)-patch $(ipopt)-build $(ipopt)-check $(ipopt)-install $(ipopt)-modulefile
