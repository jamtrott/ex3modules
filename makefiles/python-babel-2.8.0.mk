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
# python-babel-2.8.0

python-babel-version = 2.8.0
python-babel = python-babel-$(python-babel-version)
$(python-babel)-description = Internationalization utilities
$(python-babel)-url = http://babel.pocoo.org/
$(python-babel)-srcurl = https://files.pythonhosted.org/packages/34/18/8706cfa5b2c73f5a549fdc0ef2e24db71812a2685959cff31cbdfc010136/Babel-2.8.0.tar.gz
$(python-babel)-src = $(pkgsrcdir)/$(notdir $($(python-babel)-srcurl))
$(python-babel)-srcdir = $(pkgsrcdir)/$(python-babel)
$(python-babel)-builddeps = $(python) $(python-pytest) $(python-freezegun)
$(python-babel)-prereqs = $(python)
$(python-babel)-modulefile = $(modulefilesdir)/$(python-babel)
$(python-babel)-prefix = $(pkgdir)/$(python-babel)
$(python-babel)-site-packages = $($(python-babel)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-babel)-src): $(dir $($(python-babel)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-babel)-srcurl)

$($(python-babel)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-babel)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-babel)-prefix)/.pkgunpack: $$($(python-babel)-src) $($(python-babel)-srcdir)/.markerfile $($(python-babel)-prefix)/.markerfile $$(foreach dep,$$($(python-babel)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-babel)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-babel)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-babel)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-babel)-prefix)/.pkgunpack
	@touch $@

$($(python-babel)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-babel)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-babel)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-babel)-prefix)/.pkgpatch
	cd $($(python-babel)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-babel)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-babel)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-babel)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-babel)-prefix)/.pkgbuild
	# cd $($(python-babel)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-babel)-builddeps) && \
	# 	python3 setup.py test
	@touch $@

$($(python-babel)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-babel)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-babel)-prefix)/.pkgcheck $($(python-babel)-site-packages)/.markerfile
	cd $($(python-babel)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-babel)-builddeps) && \
		PYTHONPATH=$($(python-babel)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-babel)-prefix)
	@touch $@

$($(python-babel)-modulefile): $(modulefilesdir)/.markerfile $($(python-babel)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-babel)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-babel)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-babel)-description)\"" >>$@
	echo "module-whatis \"$($(python-babel)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-babel)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_BABEL_ROOT $($(python-babel)-prefix)" >>$@
	echo "prepend-path PATH $($(python-babel)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-babel)-site-packages)" >>$@
	echo "set MSG \"$(python-babel)\"" >>$@

$(python-babel)-src: $($(python-babel)-src)
$(python-babel)-unpack: $($(python-babel)-prefix)/.pkgunpack
$(python-babel)-patch: $($(python-babel)-prefix)/.pkgpatch
$(python-babel)-build: $($(python-babel)-prefix)/.pkgbuild
$(python-babel)-check: $($(python-babel)-prefix)/.pkgcheck
$(python-babel)-install: $($(python-babel)-prefix)/.pkginstall
$(python-babel)-modulefile: $($(python-babel)-modulefile)
$(python-babel)-clean:
	rm -rf $($(python-babel)-modulefile)
	rm -rf $($(python-babel)-prefix)
	rm -rf $($(python-babel)-srcdir)
	rm -rf $($(python-babel)-src)
$(python-babel): $(python-babel)-src $(python-babel)-unpack $(python-babel)-patch $(python-babel)-build $(python-babel)-check $(python-babel)-install $(python-babel)-modulefile
