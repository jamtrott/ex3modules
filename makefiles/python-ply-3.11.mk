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
# python-ply-3.11

python-ply-version = 3.11
python-ply = python-ply-$(python-ply-version)
$(python-ply)-description = lex and yacc parsing tools for Python
$(python-ply)-url = https://www.dabeaz.com/ply/
$(python-ply)-srcurl = https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz
$(python-ply)-src = $(pkgsrcdir)/$(notdir $($(python-ply)-srcurl))
$(python-ply)-srcdir = $(pkgsrcdir)/$(python-ply)
$(python-ply)-builddeps = $(python)
$(python-ply)-prereqs = $(python)
$(python-ply)-modulefile = $(modulefilesdir)/$(python-ply)
$(python-ply)-prefix = $(pkgdir)/$(python-ply)
$(python-ply)-site-packages = $($(python-ply)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-ply)-src): $(dir $($(python-ply)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-ply)-srcurl)

$($(python-ply)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-ply)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-ply)-prefix)/.pkgunpack: $$($(python-ply)-src) $($(python-ply)-srcdir)/.markerfile $($(python-ply)-prefix)/.markerfile $$(foreach dep,$$($(python-ply)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-ply)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-ply)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ply)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ply)-prefix)/.pkgunpack
	@touch $@

$($(python-ply)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-ply)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ply)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ply)-prefix)/.pkgpatch
	cd $($(python-ply)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ply)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-ply)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ply)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ply)-prefix)/.pkgbuild
	cd $($(python-ply)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ply)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-ply)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-ply)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-ply)-prefix)/.pkgcheck $($(python-ply)-site-packages)/.markerfile
	cd $($(python-ply)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-ply)-builddeps) && \
		PYTHONPATH=$($(python-ply)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-ply)-prefix)
	@touch $@

$($(python-ply)-modulefile): $(modulefilesdir)/.markerfile $($(python-ply)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-ply)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-ply)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-ply)-description)\"" >>$@
	echo "module-whatis \"$($(python-ply)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-ply)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PLY_ROOT $($(python-ply)-prefix)" >>$@
	echo "prepend-path PATH $($(python-ply)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-ply)-site-packages)" >>$@
	echo "set MSG \"$(python-ply)\"" >>$@

$(python-ply)-src: $($(python-ply)-src)
$(python-ply)-unpack: $($(python-ply)-prefix)/.pkgunpack
$(python-ply)-patch: $($(python-ply)-prefix)/.pkgpatch
$(python-ply)-build: $($(python-ply)-prefix)/.pkgbuild
$(python-ply)-check: $($(python-ply)-prefix)/.pkgcheck
$(python-ply)-install: $($(python-ply)-prefix)/.pkginstall
$(python-ply)-modulefile: $($(python-ply)-modulefile)
$(python-ply)-clean:
	rm -rf $($(python-ply)-modulefile)
	rm -rf $($(python-ply)-prefix)
	rm -rf $($(python-ply)-srcdir)
	rm -rf $($(python-ply)-src)
$(python-ply): $(python-ply)-src $(python-ply)-unpack $(python-ply)-patch $(python-ply)-build $(python-ply)-check $(python-ply)-install $(python-ply)-modulefile
