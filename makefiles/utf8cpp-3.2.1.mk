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
# utf8cpp-3.2.1

utf8cpp-version = 3.2.1
utf8cpp = utf8cpp-$(utf8cpp-version)
$(utf8cpp)-description = UTF-8 with C++ in a Portable Way
$(utf8cpp)-url = https://github.com/nemtrif/utfcpp
$(utf8cpp)-srcurl = https://github.com/nemtrif/utfcpp/archive/refs/tags/v$(utf8cpp-version).tar.gz
$(utf8cpp)-builddeps = $(cmake) $(gcc-10.1)
$(utf8cpp)-prereqs =
$(utf8cpp)-src = $(pkgsrcdir)/$(notdir $($(utf8cpp)-srcurl))
$(utf8cpp)-srcdir = $(pkgsrcdir)/$(utf8cpp)
$(utf8cpp)-builddir = $($(utf8cpp)-srcdir)/build
$(utf8cpp)-modulefile = $(modulefilesdir)/$(utf8cpp)
$(utf8cpp)-prefix = $(pkgdir)/$(utf8cpp)

$($(utf8cpp)-src): $(dir $($(utf8cpp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(utf8cpp)-srcurl)

$($(utf8cpp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(utf8cpp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(utf8cpp)-prefix)/.pkgunpack: $$($(utf8cpp)-src) $($(utf8cpp)-srcdir)/.markerfile $($(utf8cpp)-prefix)/.markerfile
	tar -C $($(utf8cpp)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(utf8cpp)-srcdir)/extern/ftest/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(utf8cpp)-srcdir)/extern/ftest/ftest.h: $($(utf8cpp)-srcdir)/extern/ftest/.markerfile
	$(CURL) $(curl_options) --output $($(utf8cpp)-srcdir)/extern/ftest/ftest.h https://github.com/nemtrif/ftest/raw/9c7e60cc1b7c76f59e2ffbbc3dad15bafc5cdac5/ftest.h

$($(utf8cpp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(utf8cpp)-builddeps),$(modulefilesdir)/$$(dep)) $($(utf8cpp)-prefix)/.pkgunpack $($(utf8cpp)-srcdir)/extern/ftest/ftest.h
	@touch $@

ifneq ($($(utf8cpp)-builddir),$($(utf8cpp)-srcdir))
$($(utf8cpp)-builddir)/.markerfile: $($(utf8cpp)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(utf8cpp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(utf8cpp)-builddeps),$(modulefilesdir)/$$(dep)) $($(utf8cpp)-builddir)/.markerfile $($(utf8cpp)-prefix)/.pkgpatch
	cd $($(utf8cpp)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(utf8cpp)-builddeps) && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$($(utf8cpp)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=ON && \
		$(MAKE)
	@touch $@

$($(utf8cpp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(utf8cpp)-builddeps),$(modulefilesdir)/$$(dep)) $($(utf8cpp)-builddir)/.markerfile $($(utf8cpp)-prefix)/.pkgbuild
	@touch $@

$($(utf8cpp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(utf8cpp)-builddeps),$(modulefilesdir)/$$(dep)) $($(utf8cpp)-builddir)/.markerfile $($(utf8cpp)-prefix)/.pkgcheck
	cd $($(utf8cpp)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(utf8cpp)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(utf8cpp)-modulefile): $(modulefilesdir)/.markerfile $($(utf8cpp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(utf8cpp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(utf8cpp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(utf8cpp)-description)\"" >>$@
	echo "module-whatis \"$($(utf8cpp)-url)\"" >>$@
	printf "$(foreach prereq,$($(utf8cpp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv UTF8CPP_ROOT $($(utf8cpp)-prefix)" >>$@
	echo "setenv UTF8CPP_INCDIR $($(utf8cpp)-prefix)/include" >>$@
	echo "setenv UTF8CPP_INCLUDEDIR $($(utf8cpp)-prefix)/include" >>$@
	echo "setenv UTF8CPP_LIBDIR $($(utf8cpp)-prefix)/lib" >>$@
	echo "setenv UTF8CPP_LIBRARYDIR $($(utf8cpp)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(utf8cpp)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(utf8cpp)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(utf8cpp)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(utf8cpp)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(utf8cpp)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(utf8cpp)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(utf8cpp)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(utf8cpp)-prefix)/share/info" >>$@
	echo "set MSG \"$(utf8cpp)\"" >>$@

$(utf8cpp)-src: $$($(utf8cpp)-src)
$(utf8cpp)-unpack: $($(utf8cpp)-prefix)/.pkgunpack
$(utf8cpp)-patch: $($(utf8cpp)-prefix)/.pkgpatch
$(utf8cpp)-build: $($(utf8cpp)-prefix)/.pkgbuild
$(utf8cpp)-check: $($(utf8cpp)-prefix)/.pkgcheck
$(utf8cpp)-install: $($(utf8cpp)-prefix)/.pkginstall
$(utf8cpp)-modulefile: $($(utf8cpp)-modulefile)
$(utf8cpp)-clean:
	rm -rf $($(utf8cpp)-modulefile)
	rm -rf $($(utf8cpp)-prefix)
	rm -rf $($(utf8cpp)-builddir)
	rm -rf $($(utf8cpp)-srcdir)
	rm -rf $($(utf8cpp)-src)
$(utf8cpp): $(utf8cpp)-src $(utf8cpp)-unpack $(utf8cpp)-patch $(utf8cpp)-build $(utf8cpp)-check $(utf8cpp)-install $(utf8cpp)-modulefile
