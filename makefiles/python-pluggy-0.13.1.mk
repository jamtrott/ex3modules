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
# python-pluggy-0.13.1

python-pluggy-version = 0.13.1
python-pluggy = python-pluggy-$(python-pluggy-version)
$(python-pluggy)-description = Plugin and hook calling mechanisms for Ppython
$(python-pluggy)-url = https://github.com/pytest-dev/pluggy/
$(python-pluggy)-srcurl = https://files.pythonhosted.org/packages/f8/04/7a8542bed4b16a65c2714bf76cf5a0b026157da7f75e87cc88774aa10b14/pluggy-0.13.1.tar.gz
$(python-pluggy)-src = $(pkgsrcdir)/$(notdir $($(python-pluggy)-srcurl))
$(python-pluggy)-srcdir = $(pkgsrcdir)/$(python-pluggy)
$(python-pluggy)-builddeps = $(python) $(python-importlib_metadata)  $(python-zipp)
$(python-pluggy)-prereqs = $(python)
$(python-pluggy)-modulefile = $(modulefilesdir)/$(python-pluggy)
$(python-pluggy)-prefix = $(pkgdir)/$(python-pluggy)
$(python-pluggy)-site-packages = $($(python-pluggy)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-pluggy)-src): $(dir $($(python-pluggy)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pluggy)-srcurl)

$($(python-pluggy)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pluggy)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pluggy)-prefix)/.pkgunpack: $$($(python-pluggy)-src) $($(python-pluggy)-srcdir)/.markerfile $($(python-pluggy)-prefix)/.markerfile
	tar -C $($(python-pluggy)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pluggy)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pluggy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pluggy)-prefix)/.pkgunpack
	@touch $@

$($(python-pluggy)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pluggy)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pluggy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pluggy)-prefix)/.pkgpatch
	cd $($(python-pluggy)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pluggy)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pluggy)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pluggy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pluggy)-prefix)/.pkgbuild
	cd $($(python-pluggy)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pluggy)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-pluggy)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pluggy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pluggy)-prefix)/.pkgcheck $($(python-pluggy)-site-packages)/.markerfile
	cd $($(python-pluggy)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pluggy)-builddeps) && \
		PYTHONPATH=$($(python-pluggy)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pluggy)-prefix)
	@touch $@

$($(python-pluggy)-modulefile): $(modulefilesdir)/.markerfile $($(python-pluggy)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pluggy)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pluggy)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pluggy)-description)\"" >>$@
	echo "module-whatis \"$($(python-pluggy)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pluggy)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PLUGGY_ROOT $($(python-pluggy)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pluggy)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pluggy)-site-packages)" >>$@
	echo "set MSG \"$(python-pluggy)\"" >>$@

$(python-pluggy)-src: $($(python-pluggy)-src)
$(python-pluggy)-unpack: $($(python-pluggy)-prefix)/.pkgunpack
$(python-pluggy)-patch: $($(python-pluggy)-prefix)/.pkgpatch
$(python-pluggy)-build: $($(python-pluggy)-prefix)/.pkgbuild
$(python-pluggy)-check: $($(python-pluggy)-prefix)/.pkgcheck
$(python-pluggy)-install: $($(python-pluggy)-prefix)/.pkginstall
$(python-pluggy)-modulefile: $($(python-pluggy)-modulefile)
$(python-pluggy)-clean:
	rm -rf $($(python-pluggy)-modulefile)
	rm -rf $($(python-pluggy)-prefix)
	rm -rf $($(python-pluggy)-srcdir)
	rm -rf $($(python-pluggy)-src)
$(python-pluggy): $(python-pluggy)-src $(python-pluggy)-unpack $(python-pluggy)-patch $(python-pluggy)-build $(python-pluggy)-check $(python-pluggy)-install $(python-pluggy)-modulefile
