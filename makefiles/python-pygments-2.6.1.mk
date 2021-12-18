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
# python-pygments-2.6.1

python-pygments-version = 2.6.1
python-pygments = python-pygments-$(python-pygments-version)
$(python-pygments)-description = Syntax highlighting package written in Python
$(python-pygments)-url = https://pygments.org/
$(python-pygments)-srcurl = https://files.pythonhosted.org/packages/6e/4d/4d2fe93a35dfba417311a4ff627489a947b01dc0cc377a3673c00cf7e4b2/Pygments-2.6.1.tar.gz
$(python-pygments)-src = $(pkgsrcdir)/$(notdir $($(python-pygments)-srcurl))
$(python-pygments)-srcdir = $(pkgsrcdir)/$(python-pygments)
$(python-pygments)-builddeps = $(python)
$(python-pygments)-prereqs = $(python)
$(python-pygments)-modulefile = $(modulefilesdir)/$(python-pygments)
$(python-pygments)-prefix = $(pkgdir)/$(python-pygments)
$(python-pygments)-site-packages = $($(python-pygments)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pygments)-src): $(dir $($(python-pygments)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pygments)-srcurl)

$($(python-pygments)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pygments)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pygments)-prefix)/.pkgunpack: $$($(python-pygments)-src) $($(python-pygments)-srcdir)/.markerfile $($(python-pygments)-prefix)/.markerfile $$(foreach dep,$$($(python-pygments)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pygments)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pygments)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pygments)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pygments)-prefix)/.pkgunpack
	@touch $@

$($(python-pygments)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pygments)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pygments)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pygments)-prefix)/.pkgpatch
	cd $($(python-pygments)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pygments)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pygments)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pygments)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pygments)-prefix)/.pkgbuild
	@touch $@

$($(python-pygments)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pygments)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pygments)-prefix)/.pkgcheck $($(python-pygments)-site-packages)/.markerfile
	cd $($(python-pygments)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pygments)-builddeps) && \
		PYTHONPATH=$($(python-pygments)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --prefix=$($(python-pygments)-prefix)
	@touch $@

$($(python-pygments)-modulefile): $(modulefilesdir)/.markerfile $($(python-pygments)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pygments)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pygments)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pygments)-description)\"" >>$@
	echo "module-whatis \"$($(python-pygments)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pygments)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYGMENTS_ROOT $($(python-pygments)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pygments)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pygments)-site-packages)" >>$@
	echo "set MSG \"$(python-pygments)\"" >>$@

$(python-pygments)-src: $($(python-pygments)-src)
$(python-pygments)-unpack: $($(python-pygments)-prefix)/.pkgunpack
$(python-pygments)-patch: $($(python-pygments)-prefix)/.pkgpatch
$(python-pygments)-build: $($(python-pygments)-prefix)/.pkgbuild
$(python-pygments)-check: $($(python-pygments)-prefix)/.pkgcheck
$(python-pygments)-install: $($(python-pygments)-prefix)/.pkginstall
$(python-pygments)-modulefile: $($(python-pygments)-modulefile)
$(python-pygments)-clean:
	rm -rf $($(python-pygments)-modulefile)
	rm -rf $($(python-pygments)-prefix)
	rm -rf $($(python-pygments)-srcdir)
	rm -rf $($(python-pygments)-src)
$(python-pygments): $(python-pygments)-src $(python-pygments)-unpack $(python-pygments)-patch $(python-pygments)-build $(python-pygments)-check $(python-pygments)-install $(python-pygments)-modulefile
