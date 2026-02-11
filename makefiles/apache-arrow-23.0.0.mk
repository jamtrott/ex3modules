# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# apache-arrow-23.0.0

apache-arrow-version = 23.0.0
apache-arrow = apache-arrow-$(apache-arrow-version)
$(apache-arrow)-description = Apache Arrow is a universal columnar format and multi-language toolbox
$(apache-arrow)-url = https://arrow.apache.org/
$(apache-arrow)-srcurl = https://github.com/apache/arrow/releases/download/apache-arrow-23.0.0/apache-arrow-23.0.0.tar.gz
$(apache-arrow)-builddeps = $(cmake) $(python)
$(apache-arrow)-prereqs =
$(apache-arrow)-src = $(pkgsrcdir)/$(notdir $($(apache-arrow)-srcurl))
$(apache-arrow)-srcdir = $(pkgsrcdir)/$(apache-arrow)
$(apache-arrow)-builddir = $($(apache-arrow)-srcdir)/build
$(apache-arrow)-modulefile = $(modulefilesdir)/$(apache-arrow)
$(apache-arrow)-prefix = $(pkgdir)/$(apache-arrow)

$($(apache-arrow)-src): $(dir $($(apache-arrow)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(apache-arrow)-srcurl)

$($(apache-arrow)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(apache-arrow)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(apache-arrow)-prefix)/.pkgunpack: $$($(apache-arrow)-src) $($(apache-arrow)-srcdir)/.markerfile $($(apache-arrow)-prefix)/.markerfile $$(foreach dep,$$($(apache-arrow)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(apache-arrow)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(apache-arrow)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(apache-arrow)-builddeps),$(modulefilesdir)/$$(dep)) $($(apache-arrow)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(apache-arrow)-builddir),$($(apache-arrow)-srcdir))
$($(apache-arrow)-builddir)/.markerfile: $($(apache-arrow)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(apache-arrow)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(apache-arrow)-builddeps),$(modulefilesdir)/$$(dep)) $($(apache-arrow)-builddir)/.markerfile $($(apache-arrow)-prefix)/.pkgpatch
	cd $($(apache-arrow)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(apache-arrow)-builddeps) && \
		$(CMAKE) ../cpp \
			-DCMAKE_INSTALL_PREFIX=$($(apache-arrow)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DCMAKE_BUILD_TYPE=Release \
			-DARROW_COMPUTE=ON \
			-DARROW_CSV=ON \
			-DARROW_FILESYSTEM=ON \
			-DARROW_PARQUET=ON \
			-DARROW_HDFS=ON \
			-DARROW_JSON=ON \
			-DARROW_SUBSTRAIT=ON \
			-DARROW_TENSORFLOW=ON \
			-DARROW_DATASET=ON && \
		$(MAKE)
	@touch $@

$($(apache-arrow)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(apache-arrow)-builddeps),$(modulefilesdir)/$$(dep)) $($(apache-arrow)-builddir)/.markerfile $($(apache-arrow)-prefix)/.pkgbuild
	@touch $@

$($(apache-arrow)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(apache-arrow)-builddeps),$(modulefilesdir)/$$(dep)) $($(apache-arrow)-builddir)/.markerfile $($(apache-arrow)-prefix)/.pkgcheck
	cd $($(apache-arrow)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(apache-arrow)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(apache-arrow)-modulefile): $(modulefilesdir)/.markerfile $($(apache-arrow)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(apache-arrow)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(apache-arrow)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(apache-arrow)-description)\"" >>$@
	echo "module-whatis \"$($(apache-arrow)-url)\"" >>$@
	printf "$(foreach prereq,$($(apache-arrow)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv APACHE_ARROW_ROOT $($(apache-arrow)-prefix)" >>$@
	echo "setenv APACHE_ARROW_INCDIR $($(apache-arrow)-prefix)/include" >>$@
	echo "setenv APACHE_ARROW_INCLUDEDIR $($(apache-arrow)-prefix)/include" >>$@
	echo "setenv APACHE_ARROW_LIBDIR $($(apache-arrow)-prefix)/lib" >>$@
	echo "setenv APACHE_ARROW_LIBRARYDIR $($(apache-arrow)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(apache-arrow)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(apache-arrow)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(apache-arrow)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(apache-arrow)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(apache-arrow)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(apache-arrow)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(apache-arrow)-prefix)/lib/cmake/Arrow" >>$@
	echo "prepend-path MANPATH $($(apache-arrow)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(apache-arrow)-prefix)/share/info" >>$@
	echo "set MSG \"$(apache-arrow)\"" >>$@

$(apache-arrow)-src: $$($(apache-arrow)-src)
$(apache-arrow)-unpack: $($(apache-arrow)-prefix)/.pkgunpack
$(apache-arrow)-patch: $($(apache-arrow)-prefix)/.pkgpatch
$(apache-arrow)-build: $($(apache-arrow)-prefix)/.pkgbuild
$(apache-arrow)-check: $($(apache-arrow)-prefix)/.pkgcheck
$(apache-arrow)-install: $($(apache-arrow)-prefix)/.pkginstall
$(apache-arrow)-modulefile: $($(apache-arrow)-modulefile)
$(apache-arrow)-clean:
	rm -rf $($(apache-arrow)-modulefile)
	rm -rf $($(apache-arrow)-prefix)
	rm -rf $($(apache-arrow)-builddir)
	rm -rf $($(apache-arrow)-srcdir)
	rm -rf $($(apache-arrow)-src)
$(apache-arrow): $(apache-arrow)-src $(apache-arrow)-unpack $(apache-arrow)-patch $(apache-arrow)-build $(apache-arrow)-check $(apache-arrow)-install $(apache-arrow)-modulefile
