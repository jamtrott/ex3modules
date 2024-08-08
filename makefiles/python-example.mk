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
# python-example-1.0

python-example-version = 1.0
python-example = python-example-$(python-example-version)
$(python-example)-description =
$(python-example)-url =
$(python-example)-srcurl =
$(python-example)-src = $(pkgsrcdir)/$(notdir $($(python-example)-srcurl))
$(python-example)-builddeps = $(python) $(python-pip)
$(python-example)-prereqs = $(python)
$(python-example)-srcdir = $(pkgsrcdir)/$(python-example)
$(python-example)-modulefile = $(modulefilesdir)/$(python-example)
$(python-example)-prefix = $(pkgdir)/$(python-example)

$($(python-example)-src): $(dir $($(python-example)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-example)-srcurl)

$($(python-example)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-example)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-example)-prefix)/.pkgunpack: $$($(python-example)-src) $($(python-example)-srcdir)/.markerfile $($(python-example)-prefix)/.markerfile $$(foreach dep,$$($(python-example)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-example)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-example)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-example)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-example)-prefix)/.pkgunpack
	@touch $@

$($(python-example)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-example)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-example)-prefix)/.pkgpatch
	cd $($(python-example)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-example)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-example)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-example)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-example)-prefix)/.pkgbuild
	cd $($(python-example)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-example)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-example)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-example)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-example)-prefix)/.pkgcheck
	cd $($(python-example)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-example)-builddeps) && \
		PYTHONPATH=$($(python-example)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-example)-prefix)
	@touch $@

$($(python-example)-modulefile): $(modulefilesdir)/.markerfile $($(python-example)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-example)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-example)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-example)-description)\"" >>$@
	echo "module-whatis \"$($(python-example)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-example)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_EXAMPLE_ROOT $($(python-example)-prefix)" >>$@
	echo "prepend-path PATH $($(python-example)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-example)-prefix)" >>$@
	echo "set MSG \"$(python-example)\"" >>$@

$(python-example)-src: $($(python-example)-src)
$(python-example)-unpack: $($(python-example)-prefix)/.pkgunpack
$(python-example)-patch: $($(python-example)-prefix)/.pkgpatch
$(python-example)-build: $($(python-example)-prefix)/.pkgbuild
$(python-example)-check: $($(python-example)-prefix)/.pkgcheck
$(python-example)-install: $($(python-example)-prefix)/.pkginstall
$(python-example)-modulefile: $($(python-example)-modulefile)
$(python-example)-clean:
	rm -rf $($(python-example)-modulefile)
	rm -rf $($(python-example)-prefix)
	rm -rf $($(python-example)-srcdir)
	rm -rf $($(python-example)-src)
$(python-example): $(python-example)-src $(python-example)-unpack $(python-example)-patch $(python-example)-build $(python-example)-check $(python-example)-install $(python-example)-modulefile
