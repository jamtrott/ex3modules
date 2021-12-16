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
# protobuf-cpp-3.17.0

protobuf-cpp-version = 3.17.0
protobuf-cpp = protobuf-cpp-$(protobuf-cpp-version)
$(protobuf-cpp)-description = Language- and platform-neutral, extensible mechanism for serializing structured data (C++ bindings)
$(protobuf-cpp)-url = https://developers.google.com/protocol-buffers
$(protobuf-cpp)-srcurl = https://github.com/protocolbuffers/protobuf/releases/download/v$(protobuf-cpp-version)/protobuf-cpp-$(protobuf-cpp-version).tar.gz
$(protobuf-cpp)-builddeps =
$(protobuf-cpp)-prereqs =
$(protobuf-cpp)-src = $(pkgsrcdir)/$(notdir $($(protobuf-cpp)-srcurl))
$(protobuf-cpp)-srcdir = $(pkgsrcdir)/$(protobuf-cpp)
$(protobuf-cpp)-builddir = $($(protobuf-cpp)-srcdir)
$(protobuf-cpp)-modulefile = $(modulefilesdir)/$(protobuf-cpp)
$(protobuf-cpp)-prefix = $(pkgdir)/$(protobuf-cpp)

$($(protobuf-cpp)-src): $(dir $($(protobuf-cpp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(protobuf-cpp)-srcurl)

$($(protobuf-cpp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(protobuf-cpp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(protobuf-cpp)-prefix)/.pkgunpack: $$($(protobuf-cpp)-src) $($(protobuf-cpp)-srcdir)/.markerfile $($(protobuf-cpp)-prefix)/.markerfile $$(foreach dep,$$($(protobuf-cpp)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(protobuf-cpp)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(protobuf-cpp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(protobuf-cpp)-builddeps),$(modulefilesdir)/$$(dep)) $($(protobuf-cpp)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(protobuf-cpp)-builddir),$($(protobuf-cpp)-srcdir))
$($(protobuf-cpp)-builddir)/.markerfile: $($(protobuf-cpp)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(protobuf-cpp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(protobuf-cpp)-builddeps),$(modulefilesdir)/$$(dep)) $($(protobuf-cpp)-builddir)/.markerfile $($(protobuf-cpp)-prefix)/.pkgpatch
	cd $($(protobuf-cpp)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(protobuf-cpp)-builddeps) && \
		./configure --prefix=$($(protobuf-cpp)-prefix) && \
		$(MAKE)
	@touch $@

$($(protobuf-cpp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(protobuf-cpp)-builddeps),$(modulefilesdir)/$$(dep)) $($(protobuf-cpp)-builddir)/.markerfile $($(protobuf-cpp)-prefix)/.pkgbuild
	cd $($(protobuf-cpp)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(protobuf-cpp)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(protobuf-cpp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(protobuf-cpp)-builddeps),$(modulefilesdir)/$$(dep)) $($(protobuf-cpp)-builddir)/.markerfile $($(protobuf-cpp)-prefix)/.pkgcheck
	cd $($(protobuf-cpp)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(protobuf-cpp)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(protobuf-cpp)-modulefile): $(modulefilesdir)/.markerfile $($(protobuf-cpp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(protobuf-cpp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(protobuf-cpp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(protobuf-cpp)-description)\"" >>$@
	echo "module-whatis \"$($(protobuf-cpp)-url)\"" >>$@
	printf "$(foreach prereq,$($(protobuf-cpp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PROTOBUF_CPP_ROOT $($(protobuf-cpp)-prefix)" >>$@
	echo "setenv PROTOBUF_CPP_INCDIR $($(protobuf-cpp)-prefix)/include" >>$@
	echo "setenv PROTOBUF_CPP_INCLUDEDIR $($(protobuf-cpp)-prefix)/include" >>$@
	echo "setenv PROTOBUF_CPP_LIBDIR $($(protobuf-cpp)-prefix)/lib" >>$@
	echo "setenv PROTOBUF_CPP_LIBRARYDIR $($(protobuf-cpp)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(protobuf-cpp)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(protobuf-cpp)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(protobuf-cpp)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(protobuf-cpp)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(protobuf-cpp)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(protobuf-cpp)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(protobuf-cpp)\"" >>$@

$(protobuf-cpp)-src: $$($(protobuf-cpp)-src)
$(protobuf-cpp)-unpack: $($(protobuf-cpp)-prefix)/.pkgunpack
$(protobuf-cpp)-patch: $($(protobuf-cpp)-prefix)/.pkgpatch
$(protobuf-cpp)-build: $($(protobuf-cpp)-prefix)/.pkgbuild
$(protobuf-cpp)-check: $($(protobuf-cpp)-prefix)/.pkgcheck
$(protobuf-cpp)-install: $($(protobuf-cpp)-prefix)/.pkginstall
$(protobuf-cpp)-modulefile: $($(protobuf-cpp)-modulefile)
$(protobuf-cpp)-clean:
	rm -rf $($(protobuf-cpp)-modulefile)
	rm -rf $($(protobuf-cpp)-prefix)
	rm -rf $($(protobuf-cpp)-builddir)
	rm -rf $($(protobuf-cpp)-srcdir)
	rm -rf $($(protobuf-cpp)-src)
$(protobuf-cpp): $(protobuf-cpp)-src $(protobuf-cpp)-unpack $(protobuf-cpp)-patch $(protobuf-cpp)-build $(protobuf-cpp)-check $(protobuf-cpp)-install $(protobuf-cpp)-modulefile
