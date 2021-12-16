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
# nspr-4.32

nspr-version = 4.32
nspr = nspr-$(nspr-version)
$(nspr)-description = Netscape Portable Runtime (NSPR) provides a platform-neutral API for system level and libc like functions
$(nspr)-url = https://www-archive.mozilla.org/projects/nspr/
$(nspr)-srcurl = https://archive.mozilla.org/pub/nspr/releases/v$(nspr-version)/src/nspr-$(nspr-version).tar.gz
$(nspr)-builddeps =
$(nspr)-prereqs =
$(nspr)-src = $(pkgsrcdir)/$(notdir $($(nspr)-srcurl))
$(nspr)-srcdir = $(pkgsrcdir)/$(nspr)
$(nspr)-builddir = $($(nspr)-srcdir)/nspr
$(nspr)-modulefile = $(modulefilesdir)/$(nspr)
$(nspr)-prefix = $(pkgdir)/$(nspr)

$($(nspr)-src): $(dir $($(nspr)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(nspr)-srcurl)

$($(nspr)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(nspr)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(nspr)-prefix)/.pkgunpack: $$($(nspr)-src) $($(nspr)-srcdir)/.markerfile $($(nspr)-prefix)/.markerfile $$(foreach dep,$$($(nspr)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(nspr)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(nspr)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nspr)-builddeps),$(modulefilesdir)/$$(dep)) $($(nspr)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(nspr)-builddir),$($(nspr)-srcdir))
$($(nspr)-builddir)/.markerfile: $($(nspr)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(nspr)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nspr)-builddeps),$(modulefilesdir)/$$(dep)) $($(nspr)-builddir)/.markerfile $($(nspr)-prefix)/.pkgpatch
	cd $($(nspr)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(nspr)-builddeps) && \
		sed -ri '/^RELEASE/s/^/#/' pr/src/misc/Makefile.in && \
		sed -i 's#$$(LIBRARY) ##' config/rules.mk && \
		./configure --prefix=$($(nspr)-prefix) \
			--with-mozilla \
			--with-pthreads \
			$$([ $$(uname -m) = x86_64 ] && echo --enable-64bit) && \
		$(MAKE)
	@touch $@

$($(nspr)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nspr)-builddeps),$(modulefilesdir)/$$(dep)) $($(nspr)-builddir)/.markerfile $($(nspr)-prefix)/.pkgbuild
	@touch $@

$($(nspr)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(nspr)-builddeps),$(modulefilesdir)/$$(dep)) $($(nspr)-builddir)/.markerfile $($(nspr)-prefix)/.pkgcheck
	cd $($(nspr)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(nspr)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(nspr)-modulefile): $(modulefilesdir)/.markerfile $($(nspr)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(nspr)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(nspr)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(nspr)-description)\"" >>$@
	echo "module-whatis \"$($(nspr)-url)\"" >>$@
	printf "$(foreach prereq,$($(nspr)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv NSPR_ROOT $($(nspr)-prefix)" >>$@
	echo "setenv NSPR_INCDIR $($(nspr)-prefix)/include" >>$@
	echo "setenv NSPR_INCLUDEDIR $($(nspr)-prefix)/include" >>$@
	echo "setenv NSPR_LIBDIR $($(nspr)-prefix)/lib" >>$@
	echo "setenv NSPR_LIBRARYDIR $($(nspr)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(nspr)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(nspr)-prefix)/include/nspr" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(nspr)-prefix)/include/nspr" >>$@
	echo "prepend-path LIBRARY_PATH $($(nspr)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(nspr)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(nspr)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path ACLOCAL_PATH $($(nspr)-prefix)/share/aclocal" >>$@
	echo "set MSG \"$(nspr)\"" >>$@

$(nspr)-src: $$($(nspr)-src)
$(nspr)-unpack: $($(nspr)-prefix)/.pkgunpack
$(nspr)-patch: $($(nspr)-prefix)/.pkgpatch
$(nspr)-build: $($(nspr)-prefix)/.pkgbuild
$(nspr)-check: $($(nspr)-prefix)/.pkgcheck
$(nspr)-install: $($(nspr)-prefix)/.pkginstall
$(nspr)-modulefile: $($(nspr)-modulefile)
$(nspr)-clean:
	rm -rf $($(nspr)-modulefile)
	rm -rf $($(nspr)-prefix)
	rm -rf $($(nspr)-builddir)
	rm -rf $($(nspr)-srcdir)
	rm -rf $($(nspr)-src)
$(nspr): $(nspr)-src $(nspr)-unpack $(nspr)-patch $(nspr)-build $(nspr)-check $(nspr)-install $(nspr)-modulefile
