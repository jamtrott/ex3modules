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
# pybind11-2.8.1

pybind11-version = 2.8.1
pybind11 = pybind11-$(pybind11-version)
$(pybind11)-description = Seamless operability between C++11 and Python
$(pybind11)-url = https://github.com/pybind/pybind11
$(pybind11)-srcurl = https://github.com/pybind/pybind11/archive/v$(pybind11-version).tar.gz
$(pybind11)-builddeps = $(boost) $(cmake) $(python) $(python-pytest)
$(pybind11)-prereqs =
$(pybind11)-src = $(pkgsrcdir)/pybind11-$(notdir $($(pybind11)-srcurl))
$(pybind11)-srcdir = $(pkgsrcdir)/$(pybind11)
$(pybind11)-builddir = $($(pybind11)-srcdir)/build
$(pybind11)-modulefile = $(modulefilesdir)/$(pybind11)
$(pybind11)-prefix = $(pkgdir)/$(pybind11)

$($(pybind11)-src): $(dir $($(pybind11)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pybind11)-srcurl)

$($(pybind11)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pybind11)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(pybind11)-prefix)/.pkgunpack: $($(pybind11)-src) $($(pybind11)-srcdir)/.markerfile $($(pybind11)-prefix)/.markerfile $$(foreach dep,$$($(pybind11)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(pybind11)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(pybind11)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pybind11)-builddeps),$(modulefilesdir)/$$(dep)) $($(pybind11)-prefix)/.pkgunpack
	@touch $@

$($(pybind11)-builddir)/.markerfile: $($(pybind11)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@

$($(pybind11)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pybind11)-builddeps),$(modulefilesdir)/$$(dep)) $($(pybind11)-builddir)/.markerfile $($(pybind11)-prefix)/.pkgpatch
	cd $($(pybind11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pybind11)-builddeps) && \
		$(CMAKE) .. -DCMAKE_INSTALL_PREFIX=$($(pybind11)-prefix) \
			-DCMAKE_INSTALL_LIBDIR=lib \
			-DBUILD_SHARED_LIBS=TRUE \
			-DPYTHON_EXECUTABLE=$(PYTHON) && \
		$(MAKE)
	@touch $@

$($(pybind11)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pybind11)-builddeps),$(modulefilesdir)/$$(dep)) $($(pybind11)-builddir)/.markerfile $($(pybind11)-prefix)/.pkgbuild
	cd $($(pybind11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pybind11)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(pybind11)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(pybind11)-builddeps),$(modulefilesdir)/$$(dep)) $($(pybind11)-builddir)/.markerfile $($(pybind11)-prefix)/.pkgcheck
	cd $($(pybind11)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pybind11)-builddeps) && \
		$(MAKE) install
	cd $($(pybind11)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(pybind11)-builddeps) && \
		PYTHONPATH=$($(pybind11)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(pybind11)-prefix)
	@touch $@

$($(pybind11)-modulefile): $(modulefilesdir)/.markerfile $($(pybind11)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(pybind11)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(pybind11)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(pybind11)-description)\"" >>$@
	echo "module-whatis \"$($(pybind11)-url)\"" >>$@
	printf "$(foreach prereq,$($(pybind11)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYBIND11_ROOT $($(pybind11)-prefix)" >>$@
	echo "setenv PYBIND11_INCDIR $($(pybind11)-prefix)/include" >>$@
	echo "setenv PYBIND11_INCLUDEDIR $($(pybind11)-prefix)/include" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(pybind11)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(pybind11)-prefix)/include" >>$@
	echo "prepend-path CMAKE_MODULE_PATH $($(pybind11)-prefix)/share/cmake/pybind11" >>$@
	echo "prepend-path PYTHONPATH $($(pybind11)-prefix)" >>$@
	echo "set MSG \"$(pybind11)\"" >>$@

$(pybind11)-src: $($(pybind11)-src)
$(pybind11)-unpack: $($(pybind11)-prefix)/.pkgunpack
$(pybind11)-patch: $($(pybind11)-prefix)/.pkgpatch
$(pybind11)-build: $($(pybind11)-prefix)/.pkgbuild
$(pybind11)-check: $($(pybind11)-prefix)/.pkgcheck
$(pybind11)-install: $($(pybind11)-prefix)/.pkginstall
$(pybind11)-modulefile: $($(pybind11)-modulefile)
$(pybind11)-clean:
	rm -rf $($(pybind11)-modulefile)
	rm -rf $($(pybind11)-prefix)
	rm -rf $($(pybind11)-srcdir)
	rm -rf $($(pybind11)-src)
$(pybind11): $(pybind11)-src $(pybind11)-unpack $(pybind11)-patch $(pybind11)-build $(pybind11)-check $(pybind11)-install $(pybind11)-modulefile
