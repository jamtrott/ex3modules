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
# python-zipp-3.3.1

python-zipp-version = 3.3.1
python-zipp = python-zipp-$(python-zipp-version)
$(python-zipp)-description = Backport of pathlib-compatible object wrapper for zip files
$(python-zipp)-url = https://github.com/jaraco/zipp/
$(python-zipp)-srcurl = https://files.pythonhosted.org/packages/49/4d/374ccacda17692db1d93b00a637b8255ec97608b0c51f3b66bc9c57fe3e1/zipp-3.3.1.tar.gz
$(python-zipp)-src = $(pkgsrcdir)/$(notdir $($(python-zipp)-srcurl))
$(python-zipp)-srcdir = $(pkgsrcdir)/$(python-zipp)
$(python-zipp)-builddeps = $(python) $(python-setuptools) $(python-setuptools_scm) $(python-wheel)
$(python-zipp)-prereqs = $(python)
$(python-zipp)-modulefile = $(modulefilesdir)/$(python-zipp)
$(python-zipp)-prefix = $(pkgdir)/$(python-zipp)
$(python-zipp)-site-packages = $($(python-zipp)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-zipp)-src): $(dir $($(python-zipp)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-zipp)-srcurl)

$($(python-zipp)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-zipp)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-zipp)-prefix)/.pkgunpack: $$($(python-zipp)-src) $($(python-zipp)-srcdir)/.markerfile $($(python-zipp)-prefix)/.markerfile $$(foreach dep,$$($(python-zipp)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-zipp)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-zipp)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-zipp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-zipp)-prefix)/.pkgunpack
	@touch $@

$($(python-zipp)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-zipp)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-zipp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-zipp)-prefix)/.pkgpatch
	cd $($(python-zipp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-zipp)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-zipp)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-zipp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-zipp)-prefix)/.pkgbuild
# 	cd $($(python-zipp)-srcdir) && \
# 		$(MODULE) use $(modulefilesdir) && \
# 		$(MODULE) load $($(python-zipp)-builddeps) && \
# 		$(PYTHON) setup.py test
	@touch $@

$($(python-zipp)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-zipp)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-zipp)-prefix)/.pkgcheck $($(python-zipp)-site-packages)/.markerfile
	cd $($(python-zipp)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-zipp)-builddeps) && \
		PYTHONPATH=$($(python-zipp)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --prefix=$($(python-zipp)-prefix)
	@touch $@

$($(python-zipp)-modulefile): $(modulefilesdir)/.markerfile $($(python-zipp)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-zipp)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-zipp)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-zipp)-description)\"" >>$@
	echo "module-whatis \"$($(python-zipp)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-zipp)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_ZIPP_ROOT $($(python-zipp)-prefix)" >>$@
	echo "prepend-path PATH $($(python-zipp)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-zipp)-site-packages)" >>$@
	echo "set MSG \"$(python-zipp)\"" >>$@

$(python-zipp)-src: $($(python-zipp)-src)
$(python-zipp)-unpack: $($(python-zipp)-prefix)/.pkgunpack
$(python-zipp)-patch: $($(python-zipp)-prefix)/.pkgpatch
$(python-zipp)-build: $($(python-zipp)-prefix)/.pkgbuild
$(python-zipp)-check: $($(python-zipp)-prefix)/.pkgcheck
$(python-zipp)-install: $($(python-zipp)-prefix)/.pkginstall
$(python-zipp)-modulefile: $($(python-zipp)-modulefile)
$(python-zipp)-clean:
	rm -rf $($(python-zipp)-modulefile)
	rm -rf $($(python-zipp)-prefix)
	rm -rf $($(python-zipp)-srcdir)
	rm -rf $($(python-zipp)-src)
$(python-zipp): $(python-zipp)-src $(python-zipp)-unpack $(python-zipp)-patch $(python-zipp)-build $(python-zipp)-check $(python-zipp)-install $(python-zipp)-modulefile
