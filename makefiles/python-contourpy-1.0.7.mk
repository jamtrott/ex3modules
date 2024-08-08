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
# python-contourpy-1.0.7

python-contourpy-version = 1.0.7
python-contourpy = python-contourpy-$(python-contourpy-version)
$(python-contourpy)-description = Python library for calculating contours of 2D quadrilateral grids
$(python-contourpy)-url = https://github.com/contourpy/contourpy
$(python-contourpy)-srcurl = https://files.pythonhosted.org/packages/b4/9b/6edb9d3e334a70a212f66a844188fcb57ddbd528cbc3b1fe7abfc317ddd7/contourpy-1.0.7.tar.gz
$(python-contourpy)-src = $(pkgsrcdir)/$(notdir $($(python-contourpy)-srcurl))
$(python-contourpy)-builddeps = $(python) $(python-pip) $(pybind11)
$(python-contourpy)-prereqs = $(python) $(pybind11)
$(python-contourpy)-srcdir = $(pkgsrcdir)/$(python-contourpy)
$(python-contourpy)-modulefile = $(modulefilesdir)/$(python-contourpy)
$(python-contourpy)-prefix = $(pkgdir)/$(python-contourpy)

$($(python-contourpy)-src): $(dir $($(python-contourpy)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-contourpy)-srcurl)

$($(python-contourpy)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-contourpy)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-contourpy)-prefix)/.pkgunpack: $$($(python-contourpy)-src) $($(python-contourpy)-srcdir)/.markerfile $($(python-contourpy)-prefix)/.markerfile $$(foreach dep,$$($(python-contourpy)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-contourpy)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-contourpy)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-contourpy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-contourpy)-prefix)/.pkgunpack
	@touch $@

$($(python-contourpy)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-contourpy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-contourpy)-prefix)/.pkgpatch
	cd $($(python-contourpy)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-contourpy)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-contourpy)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-contourpy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-contourpy)-prefix)/.pkgbuild
	@touch $@

$($(python-contourpy)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-contourpy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-contourpy)-prefix)/.pkgcheck
	cd $($(python-contourpy)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-contourpy)-builddeps) && \
		PYTHONPATH=$($(python-contourpy)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-contourpy)-prefix)
	@touch $@

$($(python-contourpy)-modulefile): $(modulefilesdir)/.markerfile $($(python-contourpy)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-contourpy)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-contourpy)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-contourpy)-description)\"" >>$@
	echo "module-whatis \"$($(python-contourpy)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-contourpy)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_CONTOURPY_ROOT $($(python-contourpy)-prefix)" >>$@
	echo "prepend-path PATH $($(python-contourpy)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-contourpy)-prefix)" >>$@
	echo "set MSG \"$(python-contourpy)\"" >>$@

$(python-contourpy)-src: $($(python-contourpy)-src)
$(python-contourpy)-unpack: $($(python-contourpy)-prefix)/.pkgunpack
$(python-contourpy)-patch: $($(python-contourpy)-prefix)/.pkgpatch
$(python-contourpy)-build: $($(python-contourpy)-prefix)/.pkgbuild
$(python-contourpy)-check: $($(python-contourpy)-prefix)/.pkgcheck
$(python-contourpy)-install: $($(python-contourpy)-prefix)/.pkginstall
$(python-contourpy)-modulefile: $($(python-contourpy)-modulefile)
$(python-contourpy)-clean:
	rm -rf $($(python-contourpy)-modulefile)
	rm -rf $($(python-contourpy)-prefix)
	rm -rf $($(python-contourpy)-srcdir)
	rm -rf $($(python-contourpy)-src)
$(python-contourpy): $(python-contourpy)-src $(python-contourpy)-unpack $(python-contourpy)-patch $(python-contourpy)-build $(python-contourpy)-check $(python-contourpy)-install $(python-contourpy)-modulefile
