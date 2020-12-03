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
# knem-1.1.4

knem-version = 1.1.4
knem = knem-$(knem-version)
$(knem)-description = High-Performance Intra-Node MPI Communication
$(knem)-url = http://knem.gforge.inria.fr/
$(knem)-srcurl = https://gitlab.inria.fr/knem/knem/uploads/4a43e3eb860cda2bbd5bf5c7c04a24b6/knem-$(knem-version).tar.gz
$(knem)-src = $(pkgsrcdir)/$(notdir $($(knem)-srcurl))
$(knem)-srcdir = $(pkgsrcdir)/$(knem)
$(knem)-builddeps = $(hwloc)
$(knem)-prereqs = $(hwloc)
$(knem)-modulefile = $(modulefilesdir)/$(knem)
$(knem)-prefix = $(pkgdir)/$(knem)

$($(knem)-src): $(dir $($(knem)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(knem)-srcurl)

$($(knem)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(knem)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(knem)-prefix)/.pkgunpack: $($(knem)-src) $($(knem)-srcdir)/.markerfile $($(knem)-prefix)/.markerfile
	tar -C $($(knem)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(knem)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(knem)-builddeps),$(modulefilesdir)/$$(dep)) $($(knem)-prefix)/.pkgunpack
	@touch $@

$($(knem)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(knem)-builddeps),$(modulefilesdir)/$$(dep)) $($(knem)-prefix)/.pkgpatch
	cd $($(knem)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(knem)-builddeps) && \
		./configure --prefix=$($(knem)-prefix) && \
		$(MAKE)
	@touch $@

$($(knem)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(knem)-builddeps),$(modulefilesdir)/$$(dep)) $($(knem)-prefix)/.pkgbuild
# 	Disable tests, since they require interaction and superuser privileges
# 	cd $($(knem)-srcdir) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(knem)-builddeps) && \
# 		$(MAKE) check
	@touch $@

$($(knem)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(knem)-builddeps),$(modulefilesdir)/$$(dep)) $($(knem)-prefix)/.pkgcheck
	$(MAKE) -C $($(knem)-srcdir) install
	@touch $@

$($(knem)-modulefile): $(modulefilesdir)/.markerfile $($(knem)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(knem)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(knem)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(knem)-description)\"" >>$@
	echo "module-whatis \"$($(knem)-url)\"" >>$@
	printf "$(foreach prereq,$($(knem)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv KNEM_ROOT $($(knem)-prefix)" >>$@
	echo "setenv KNEM_INCDIR $($(knem)-prefix)/include" >>$@
	echo "setenv KNEM_INCLUDEDIR $($(knem)-prefix)/include" >>$@
	echo "setenv KNEM_LIBDIR $($(knem)-prefix)/lib" >>$@
	echo "setenv KNEM_LIBRARYDIR $($(knem)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(knem)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(knem)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(knem)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(knem)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(knem)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(knem)-prefix)/lib/pkgconfig" >>$@
	echo "set MSG \"$(knem)\"" >>$@

$(knem)-src: $($(knem)-src)
$(knem)-unpack: $($(knem)-prefix)/.pkgunpack
$(knem)-patch: $($(knem)-prefix)/.pkgpatch
$(knem)-build: $($(knem)-prefix)/.pkgbuild
$(knem)-check: $($(knem)-prefix)/.pkgcheck
$(knem)-install: $($(knem)-prefix)/.pkginstall
$(knem)-modulefile: $($(knem)-modulefile)
$(knem)-clean:
	rm -rf $($(knem)-modulefile)
	rm -rf $($(knem)-prefix)
	rm -rf $($(knem)-srcdir)
	rm -rf $($(knem)-src)
$(knem): $(knem)-src $(knem)-unpack $(knem)-patch $(knem)-build $(knem)-check $(knem)-install $(knem)-modulefile
