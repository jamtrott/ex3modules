# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# python-sortedcontainers-2.2.2

python-sortedcontainers-version = 2.2.2
python-sortedcontainers = python-sortedcontainers-$(python-sortedcontainers-version)
$(python-sortedcontainers)-description = Python library for sorted collections
$(python-sortedcontainers)-url = http://www.grantjenks.com/docs/sortedcontainers/
$(python-sortedcontainers)-srcurl = https://github.com/grantjenks/python-sortedcontainers/archive/v$(python-sortedcontainers-version).tar.gz
$(python-sortedcontainers)-src = $(pkgsrcdir)/python-sortedcontainers-$(notdir $($(python-sortedcontainers)-srcurl))
$(python-sortedcontainers)-srcdir = $(pkgsrcdir)/$(python-sortedcontainers)
$(python-sortedcontainers)-builddeps = $(python) $(python-zipp) $(python-pyparsing) $(python-appdirs) $(python-distlib) $(python-filelock) $(python-importlib_metadata) $(python-packaging) $(python-pluggy) $(python-py) $(python-six) $(python-toml) $(python-virtualenv) $(python-tox) $(python-pip)
$(python-sortedcontainers)-prereqs = $(python) $(python-zipp) $(python-pyparsing) $(python-appdirs) $(python-distlib) $(python-filelock) $(python-importlib_metadata) $(python-packaging) $(python-pluggy) $(python-py) $(python-six) $(python-toml) $(python-virtualenv) $(python-tox)
$(python-sortedcontainers)-modulefile = $(modulefilesdir)/$(python-sortedcontainers)
$(python-sortedcontainers)-prefix = $(pkgdir)/$(python-sortedcontainers)
$(python-sortedcontainers)-site-packages = $($(python-sortedcontainers)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-sortedcontainers)-src): $(dir $($(python-sortedcontainers)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-sortedcontainers)-srcurl)

$($(python-sortedcontainers)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sortedcontainers)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-sortedcontainers)-prefix)/.pkgunpack: $$($(python-sortedcontainers)-src) $($(python-sortedcontainers)-srcdir)/.markerfile $($(python-sortedcontainers)-prefix)/.markerfile $$(foreach dep,$$($(python-sortedcontainers)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-sortedcontainers)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-sortedcontainers)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sortedcontainers)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sortedcontainers)-prefix)/.pkgunpack
	@touch $@

$($(python-sortedcontainers)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-sortedcontainers)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sortedcontainers)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sortedcontainers)-prefix)/.pkgpatch
	cd $($(python-sortedcontainers)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sortedcontainers)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-sortedcontainers)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sortedcontainers)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sortedcontainers)-prefix)/.pkgbuild
	# cd $($(python-sortedcontainers)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-sortedcontainers)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-sortedcontainers)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-sortedcontainers)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-sortedcontainers)-prefix)/.pkgcheck $($(python-sortedcontainers)-site-packages)/.markerfile
	cd $($(python-sortedcontainers)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-sortedcontainers)-builddeps) && \
		PYTHONPATH=$($(python-sortedcontainers)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-sortedcontainers)-prefix)
	@touch $@

$($(python-sortedcontainers)-modulefile): $(modulefilesdir)/.markerfile $($(python-sortedcontainers)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-sortedcontainers)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-sortedcontainers)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-sortedcontainers)-description)\"" >>$@
	echo "module-whatis \"$($(python-sortedcontainers)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-sortedcontainers)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SORTEDCONTAINERS_ROOT $($(python-sortedcontainers)-prefix)" >>$@
	echo "prepend-path PATH $($(python-sortedcontainers)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-sortedcontainers)-site-packages)" >>$@
	echo "set MSG \"$(python-sortedcontainers)\"" >>$@

$(python-sortedcontainers)-src: $($(python-sortedcontainers)-src)
$(python-sortedcontainers)-unpack: $($(python-sortedcontainers)-prefix)/.pkgunpack
$(python-sortedcontainers)-patch: $($(python-sortedcontainers)-prefix)/.pkgpatch
$(python-sortedcontainers)-build: $($(python-sortedcontainers)-prefix)/.pkgbuild
$(python-sortedcontainers)-check: $($(python-sortedcontainers)-prefix)/.pkgcheck
$(python-sortedcontainers)-install: $($(python-sortedcontainers)-prefix)/.pkginstall
$(python-sortedcontainers)-modulefile: $($(python-sortedcontainers)-modulefile)
$(python-sortedcontainers)-clean:
	rm -rf $($(python-sortedcontainers)-modulefile)
	rm -rf $($(python-sortedcontainers)-prefix)
	rm -rf $($(python-sortedcontainers)-srcdir)
	rm -rf $($(python-sortedcontainers)-src)
$(python-sortedcontainers): $(python-sortedcontainers)-src $(python-sortedcontainers)-unpack $(python-sortedcontainers)-patch $(python-sortedcontainers)-build $(python-sortedcontainers)-check $(python-sortedcontainers)-install $(python-sortedcontainers)-modulefile
