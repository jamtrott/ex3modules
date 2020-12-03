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
# python-pydocstyle-5.0.2

python-pydocstyle-version = 5.0.2
python-pydocstyle = python-pydocstyle-$(python-pydocstyle-version)
$(python-pydocstyle)-description = Python docstring style checker
$(python-pydocstyle)-url = https://github.com/PyCQA/pydocstyle/
$(python-pydocstyle)-srcurl = https://files.pythonhosted.org/packages/39/f4/3f670e71f11c4c65f0d5f4153f5191fb38786483513c90de66f08ef6e810/pydocstyle-5.0.2.tar.gz
$(python-pydocstyle)-src = $(pkgsrcdir)/$(notdir $($(python-pydocstyle)-srcurl))
$(python-pydocstyle)-srcdir = $(pkgsrcdir)/$(python-pydocstyle)
$(python-pydocstyle)-builddeps = $(python) $(python-snowballstemmer)
$(python-pydocstyle)-prereqs = $(python) $(python-snowballstemmer)
$(python-pydocstyle)-modulefile = $(modulefilesdir)/$(python-pydocstyle)
$(python-pydocstyle)-prefix = $(pkgdir)/$(python-pydocstyle)
$(python-pydocstyle)-site-packages = $($(python-pydocstyle)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-pydocstyle)-src): $(dir $($(python-pydocstyle)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pydocstyle)-srcurl)

$($(python-pydocstyle)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pydocstyle)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pydocstyle)-prefix)/.pkgunpack: $$($(python-pydocstyle)-src) $($(python-pydocstyle)-srcdir)/.markerfile $($(python-pydocstyle)-prefix)/.markerfile
	tar -C $($(python-pydocstyle)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pydocstyle)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pydocstyle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pydocstyle)-prefix)/.pkgunpack
	@touch $@

$($(python-pydocstyle)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pydocstyle)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pydocstyle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pydocstyle)-prefix)/.pkgpatch
	cd $($(python-pydocstyle)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pydocstyle)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pydocstyle)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pydocstyle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pydocstyle)-prefix)/.pkgbuild
	cd $($(python-pydocstyle)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pydocstyle)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-pydocstyle)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pydocstyle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pydocstyle)-prefix)/.pkgcheck $($(python-pydocstyle)-site-packages)/.markerfile
	cd $($(python-pydocstyle)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pydocstyle)-builddeps) && \
		PYTHONPATH=$($(python-pydocstyle)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pydocstyle)-prefix)
	@touch $@

$($(python-pydocstyle)-modulefile): $(modulefilesdir)/.markerfile $($(python-pydocstyle)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pydocstyle)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pydocstyle)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pydocstyle)-description)\"" >>$@
	echo "module-whatis \"$($(python-pydocstyle)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pydocstyle)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYDOCSTYLE_ROOT $($(python-pydocstyle)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pydocstyle)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pydocstyle)-site-packages)" >>$@
	echo "set MSG \"$(python-pydocstyle)\"" >>$@

$(python-pydocstyle)-src: $($(python-pydocstyle)-src)
$(python-pydocstyle)-unpack: $($(python-pydocstyle)-prefix)/.pkgunpack
$(python-pydocstyle)-patch: $($(python-pydocstyle)-prefix)/.pkgpatch
$(python-pydocstyle)-build: $($(python-pydocstyle)-prefix)/.pkgbuild
$(python-pydocstyle)-check: $($(python-pydocstyle)-prefix)/.pkgcheck
$(python-pydocstyle)-install: $($(python-pydocstyle)-prefix)/.pkginstall
$(python-pydocstyle)-modulefile: $($(python-pydocstyle)-modulefile)
$(python-pydocstyle)-clean:
	rm -rf $($(python-pydocstyle)-modulefile)
	rm -rf $($(python-pydocstyle)-prefix)
	rm -rf $($(python-pydocstyle)-srcdir)
	rm -rf $($(python-pydocstyle)-src)
$(python-pydocstyle): $(python-pydocstyle)-src $(python-pydocstyle)-unpack $(python-pydocstyle)-patch $(python-pydocstyle)-build $(python-pydocstyle)-check $(python-pydocstyle)-install $(python-pydocstyle)-modulefile
