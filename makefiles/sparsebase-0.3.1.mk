# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2024 James D. Trotter
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
# sparsebase-0.3.1

sparsebase-version = 0.3.1
sparsebase = sparsebase-$(sparsebase-version)
$(sparsebase)-description = Sparse data processing library with a generic, HPC-centric design, supports feature extraction, IO, reordering and partitioning
$(sparsebase)-url = https://github.com/sparcityeu/SparseBase
$(sparsebase)-srcurl = https://github.com/sparcityeu/SparseBase/archive/refs/tags/v0.3.1.tar.gz
$(sparsebase)-builddeps = $(cmake) $(metis-32) $(python)
$(sparsebase)-prereqs = $(metis-32) $(python)
$(sparsebase)-src = $(pkgsrcdir)/$(notdir $($(sparsebase)-srcurl))
$(sparsebase)-srcdir = $(pkgsrcdir)/$(sparsebase)
$(sparsebase)-builddir = $($(sparsebase)-srcdir)/build
$(sparsebase)-modulefile = $(modulefilesdir)/$(sparsebase)
$(sparsebase)-prefix = $(pkgdir)/$(sparsebase)

$($(sparsebase)-src): $(dir $($(sparsebase)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(sparsebase)-srcurl)

$($(sparsebase)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(sparsebase)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(sparsebase)-prefix)/.pkgunpack: $$($(sparsebase)-src) $($(sparsebase)-srcdir)/.markerfile $($(sparsebase)-prefix)/.markerfile $$(foreach dep,$$($(sparsebase)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(sparsebase)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(sparsebase)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sparsebase)-builddeps),$(modulefilesdir)/$$(dep)) $($(sparsebase)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(sparsebase)-builddir),$($(sparsebase)-srcdir))
$($(sparsebase)-builddir)/.markerfile: $($(sparsebase)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(sparsebase)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sparsebase)-builddeps),$(modulefilesdir)/$$(dep)) $($(sparsebase)-builddir)/.markerfile $($(sparsebase)-prefix)/.pkgpatch
	cd $($(sparsebase)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(sparsebase)-builddeps) && \
		$(CMAKE) .. \
			-DCMAKE_INSTALL_PREFIX=$($(sparsebase)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=RelWithDebInfo \
			-DUSE_METIS=1 -DMETIS_INC_DIR="$${METIS_INCDIR}" -DMETIS_LIB_DIR="$${METIS_LIBDIR}" && \
		$(MAKE)
	@touch $@

$($(sparsebase)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sparsebase)-builddeps),$(modulefilesdir)/$$(dep)) $($(sparsebase)-builddir)/.markerfile $($(sparsebase)-prefix)/.pkgbuild
	@touch $@

$($(sparsebase)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(sparsebase)-builddeps),$(modulefilesdir)/$$(dep)) $($(sparsebase)-builddir)/.markerfile $($(sparsebase)-prefix)/.pkgcheck
	cd $($(sparsebase)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(sparsebase)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(sparsebase)-modulefile): $(modulefilesdir)/.markerfile $($(sparsebase)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(sparsebase)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(sparsebase)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(sparsebase)-description)\"" >>$@
	echo "module-whatis \"$($(sparsebase)-url)\"" >>$@
	printf "$(foreach prereq,$($(sparsebase)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv SPARSEBASE_ROOT $($(sparsebase)-prefix)" >>$@
	echo "setenv SPARSEBASE_INCDIR $($(sparsebase)-prefix)/include" >>$@
	echo "setenv SPARSEBASE_INCLUDEDIR $($(sparsebase)-prefix)/include" >>$@
	echo "setenv SPARSEBASE_LIBDIR $($(sparsebase)-prefix)/lib" >>$@
	echo "setenv SPARSEBASE_LIBRARYDIR $($(sparsebase)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(sparsebase)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(sparsebase)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(sparsebase)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(sparsebase)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(sparsebase)-prefix)/lib" >>$@
	echo "prepend-path CMAKE_PREFIX_PATH $($(sparsebase)-prefix)/lib/cmake/sparsebase" >>$@
	echo "set MSG \"$(sparsebase)\"" >>$@

$(sparsebase)-src: $$($(sparsebase)-src)
$(sparsebase)-unpack: $($(sparsebase)-prefix)/.pkgunpack
$(sparsebase)-patch: $($(sparsebase)-prefix)/.pkgpatch
$(sparsebase)-build: $($(sparsebase)-prefix)/.pkgbuild
$(sparsebase)-check: $($(sparsebase)-prefix)/.pkgcheck
$(sparsebase)-install: $($(sparsebase)-prefix)/.pkginstall
$(sparsebase)-modulefile: $($(sparsebase)-modulefile)
$(sparsebase)-clean:
	rm -rf $($(sparsebase)-modulefile)
	rm -rf $($(sparsebase)-prefix)
	rm -rf $($(sparsebase)-builddir)
	rm -rf $($(sparsebase)-srcdir)
	rm -rf $($(sparsebase)-src)
$(sparsebase): $(sparsebase)-src $(sparsebase)-unpack $(sparsebase)-patch $(sparsebase)-build $(sparsebase)-check $(sparsebase)-install $(sparsebase)-modulefile
