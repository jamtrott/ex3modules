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
# libevent-2.1.11-stable

libevent-version = 2.1.11-stable
libevent = libevent-$(libevent-version)
$(libevent)-description = Event notification library
$(libevent)-url = https://libevent.org/
$(libevent)-srcurl = https://github.com/libevent/libevent/releases/download/release-$(libevent-version)/libevent-$(libevent-version).tar.gz
$(libevent)-src = $(pkgsrcdir)/$(notdir $($(libevent)-srcurl))
$(libevent)-srcdir = $(pkgsrcdir)/$(libevent)
$(libevent)-builddeps = 
$(libevent)-prereqs =
$(libevent)-modulefile = $(modulefilesdir)/$(libevent)
$(libevent)-prefix = $(pkgdir)/$(libevent)

$($(libevent)-src): $(dir $($(libevent)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libevent)-srcurl)

$($(libevent)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libevent)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libevent)-prefix)/.pkgunpack: $($(libevent)-src) $($(libevent)-srcdir)/.markerfile $($(libevent)-prefix)/.markerfile
	tar -C $($(libevent)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(libevent)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libevent)-builddeps),$(modulefilesdir)/$$(dep)) $($(libevent)-prefix)/.pkgunpack
	@touch $@

$($(libevent)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libevent)-builddeps),$(modulefilesdir)/$$(dep)) $($(libevent)-prefix)/.pkgpatch
	cd $($(libevent)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libevent)-builddeps) && \
		./configure --prefix=$($(libevent)-prefix) && \
		$(MAKE)
	@touch $@

$($(libevent)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libevent)-builddeps),$(modulefilesdir)/$$(dep)) $($(libevent)-prefix)/.pkgbuild
	cd $($(libevent)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libevent)-builddeps) && \
		$(MAKE) verify
	@touch $@

$($(libevent)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libevent)-builddeps),$(modulefilesdir)/$$(dep)) $($(libevent)-prefix)/.pkgcheck
	$(MAKE) -C $($(libevent)-srcdir) install
	@touch $@

$($(libevent)-modulefile): $(modulefilesdir)/.markerfile $($(libevent)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libevent)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libevent)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libevent)-description)\"" >>$@
	echo "module-whatis \"$($(libevent)-url)\"" >>$@
	printf "$(foreach prereq,$($(libevent)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBEVENT_ROOT $($(libevent)-prefix)" >>$@
	echo "setenv LIBEVENT_INCDIR $($(libevent)-prefix)/include" >>$@
	echo "setenv LIBEVENT_INCLUDEDIR $($(libevent)-prefix)/include" >>$@
	echo "setenv LIBEVENT_LIBDIR $($(libevent)-prefix)/lib" >>$@
	echo "setenv LIBEVENT_LIBRARYDIR $($(libevent)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libevent)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libevent)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libevent)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libevent)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libevent)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libevent)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(libevent)\"" >>$@

$(libevent)-src: $($(libevent)-src)
$(libevent)-unpack: $($(libevent)-prefix)/.pkgunpack
$(libevent)-patch: $($(libevent)-prefix)/.pkgpatch
$(libevent)-build: $($(libevent)-prefix)/.pkgbuild
$(libevent)-check: $($(libevent)-prefix)/.pkgcheck
$(libevent)-install: $($(libevent)-prefix)/.pkginstall
$(libevent)-modulefile: $($(libevent)-modulefile)
$(libevent)-clean:
	rm -rf $($(libevent)-modulefile)
	rm -rf $($(libevent)-prefix)
	rm -rf $($(libevent)-srcdir)
	rm -rf $($(libevent)-src)
$(libevent): $(libevent)-src $(libevent)-unpack $(libevent)-patch $(libevent)-build $(libevent)-check $(libevent)-install $(libevent)-modulefile
