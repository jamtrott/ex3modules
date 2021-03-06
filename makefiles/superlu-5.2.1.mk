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
# superlu-5.2.1

superlu-version = 5.2.1
superlu = superlu-$(superlu-version)
$(superlu)-description = Direct solver for large, sparse non-symmetric systems of linear equations
$(superlu)-url = https://github.com/xiaoyeli/superlu/
$(superlu)-srcurl = https://github.com/xiaoyeli/superlu/archive/v$(superlu-version).tar.gz
$(superlu)-src = $(pkgsrcdir)/superlu-$(notdir $($(superlu)-srcurl))
$(superlu)-srcdir = $(pkgsrcdir)/$(superlu)
$(superlu)-builddeps = $(cmake) $(blas)
$(superlu)-prereqs = $(blas)
$(superlu)-modulefile = $(modulefilesdir)/$(superlu)
$(superlu)-prefix = $(pkgdir)/$(superlu)

$($(superlu)-src): $(dir $($(superlu)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(superlu)-srcurl)

$($(superlu)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu)-prefix)/.pkgunpack: $($(superlu)-src) $($(superlu)-srcdir)/.markerfile $($(superlu)-prefix)/.markerfile
	tar -C $($(superlu)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(superlu)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu)-prefix)/.pkgunpack
	@touch $@

$($(superlu)-srcdir)/build/.markerfile: $($(superlu)-srcdir)/.markerfile
	$(INSTALL) -d $(dir $@) && touch $@

$($(superlu)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu)-prefix)/.pkgpatch $($(superlu)-srcdir)/build/.markerfile
	cd $($(superlu)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(superlu)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=TRUE \
			-Denable_blaslib=OFF \
			-DTPL_BLAS_LIBRARIES=$${BLASLIB} && \
		$(MAKE)
	@touch $@

$($(superlu)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu)-prefix)/.pkgbuild
	@touch $@

$($(superlu)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(superlu)-builddeps),$(modulefilesdir)/$$(dep)) $($(superlu)-prefix)/.pkgcheck
	cd $($(superlu)-srcdir)/build && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(superlu)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(superlu)-modulefile): $(modulefilesdir)/.markerfile $($(superlu)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(superlu)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(superlu)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(superlu)-description)\"" >>$@
	echo "module-whatis \"$($(superlu)-url)\"" >>$@
	printf "$(foreach prereq,$($(superlu)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SUPERLU_ROOT $($(superlu)-prefix)" >>$@
	echo "setenv SUPERLU_INCDIR $($(superlu)-prefix)/include" >>$@
	echo "setenv SUPERLU_INCLUDEDIR $($(superlu)-prefix)/include" >>$@
	echo "setenv SUPERLU_LIBDIR $($(superlu)-prefix)/lib" >>$@
	echo "setenv SUPERLU_LIBRARYDIR $($(superlu)-prefix)/lib" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(superlu)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(superlu)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(superlu)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(superlu)-prefix)/lib" >>$@
	echo "set MSG \"$(superlu)\"" >>$@

$(superlu)-src: $($(superlu)-src)
$(superlu)-unpack: $($(superlu)-prefix)/.pkgunpack
$(superlu)-patch: $($(superlu)-prefix)/.pkgpatch
$(superlu)-build: $($(superlu)-prefix)/.pkgbuild
$(superlu)-check: $($(superlu)-prefix)/.pkgcheck
$(superlu)-install: $($(superlu)-prefix)/.pkginstall
$(superlu)-modulefile: $($(superlu)-modulefile)
$(superlu)-clean:
	rm -rf $($(superlu)-modulefile)
	rm -rf $($(superlu)-prefix)
	rm -rf $($(superlu)-srcdir)
	rm -rf $($(superlu)-src)
$(superlu): $(superlu)-src $(superlu)-unpack $(superlu)-patch $(superlu)-build $(superlu)-check $(superlu)-install $(superlu)-modulefile
