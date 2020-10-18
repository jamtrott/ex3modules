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
# python-pathlib2-2.3.5

python-pathlib2-version = 2.3.5
python-pathlib2 = python-pathlib2-$(python-pathlib2-version)
$(python-pathlib2)-description = Object-oriented filesystem paths
$(python-pathlib2)-url = https://github.com/mcmtroffaes/pathlib2/
$(python-pathlib2)-srcurl = https://files.pythonhosted.org/packages/94/d8/65c86584e7e97ef824a1845c72bbe95d79f5b306364fa778a3c3e401b309/pathlib2-2.3.5.tar.gz
$(python-pathlib2)-src = $(pkgsrcdir)/$(notdir $($(python-pathlib2)-srcurl))
$(python-pathlib2)-srcdir = $(pkgsrcdir)/$(python-pathlib2)
$(python-pathlib2)-builddeps = $(python) $(python-six)
$(python-pathlib2)-prereqs = $(python) $(python-six)
$(python-pathlib2)-modulefile = $(modulefilesdir)/$(python-pathlib2)
$(python-pathlib2)-prefix = $(pkgdir)/$(python-pathlib2)
$(python-pathlib2)-site-packages = $($(python-pathlib2)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-pathlib2)-src): $(dir $($(python-pathlib2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pathlib2)-srcurl)

$($(python-pathlib2)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-pathlib2)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-pathlib2)-prefix)/.pkgunpack: $$($(python-pathlib2)-src) $($(python-pathlib2)-srcdir)/.markerfile $($(python-pathlib2)-prefix)/.markerfile
	tar -C $($(python-pathlib2)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pathlib2)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pathlib2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pathlib2)-prefix)/.pkgunpack
	@touch $@

$($(python-pathlib2)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-pathlib2)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pathlib2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pathlib2)-prefix)/.pkgpatch
	cd $($(python-pathlib2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pathlib2)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pathlib2)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pathlib2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pathlib2)-prefix)/.pkgbuild
	cd $($(python-pathlib2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pathlib2)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-pathlib2)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pathlib2)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pathlib2)-prefix)/.pkgcheck $($(python-pathlib2)-site-packages)/.markerfile
	cd $($(python-pathlib2)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pathlib2)-builddeps) && \
		PYTHONPATH=$($(python-pathlib2)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pathlib2)-prefix)
	@touch $@

$($(python-pathlib2)-modulefile): $(modulefilesdir)/.markerfile $($(python-pathlib2)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pathlib2)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pathlib2)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pathlib2)-description)\"" >>$@
	echo "module-whatis \"$($(python-pathlib2)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pathlib2)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PATHLIB2_ROOT $($(python-pathlib2)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pathlib2)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pathlib2)-site-packages)" >>$@
	echo "set MSG \"$(python-pathlib2)\"" >>$@

$(python-pathlib2)-src: $($(python-pathlib2)-src)
$(python-pathlib2)-unpack: $($(python-pathlib2)-prefix)/.pkgunpack
$(python-pathlib2)-patch: $($(python-pathlib2)-prefix)/.pkgpatch
$(python-pathlib2)-build: $($(python-pathlib2)-prefix)/.pkgbuild
$(python-pathlib2)-check: $($(python-pathlib2)-prefix)/.pkgcheck
$(python-pathlib2)-install: $($(python-pathlib2)-prefix)/.pkginstall
$(python-pathlib2)-modulefile: $($(python-pathlib2)-modulefile)
$(python-pathlib2)-clean:
	rm -rf $($(python-pathlib2)-modulefile)
	rm -rf $($(python-pathlib2)-prefix)
	rm -rf $($(python-pathlib2)-srcdir)
	rm -rf $($(python-pathlib2)-src)
$(python-pathlib2): $(python-pathlib2)-src $(python-pathlib2)-unpack $(python-pathlib2)-patch $(python-pathlib2)-build $(python-pathlib2)-check $(python-pathlib2)-install $(python-pathlib2)-modulefile
