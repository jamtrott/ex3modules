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
# python-idna-2.9

python-idna-version = 2.9
python-idna = python-idna-$(python-idna-version)
$(python-idna)-description = Internationalized Domain Names in Applications (IDNA)
$(python-idna)-url = https://github.com/kjd/idna/
$(python-idna)-srcurl = https://files.pythonhosted.org/packages/ea/b7/e0e3c1c467636186c39925827be42f16fee389dc404ac29e930e9136be70/idna-2.10.tar.gz
$(python-idna)-src = $(pkgsrcdir)/$(notdir $($(python-idna)-srcurl))
$(python-idna)-srcdir = $(pkgsrcdir)/$(python-idna)
$(python-idna)-builddeps = $(python)
$(python-idna)-prereqs = $(python)
$(python-idna)-modulefile = $(modulefilesdir)/$(python-idna)
$(python-idna)-prefix = $(pkgdir)/$(python-idna)
$(python-idna)-site-packages = $($(python-idna)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-idna)-src): $(dir $($(python-idna)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-idna)-srcurl)

$($(python-idna)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-idna)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-idna)-prefix)/.pkgunpack: $$($(python-idna)-src) $($(python-idna)-srcdir)/.markerfile $($(python-idna)-prefix)/.markerfile $$(foreach dep,$$($(python-idna)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-idna)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-idna)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-idna)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-idna)-prefix)/.pkgunpack
	@touch $@

$($(python-idna)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-idna)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-idna)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-idna)-prefix)/.pkgpatch
	cd $($(python-idna)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-idna)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-idna)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-idna)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-idna)-prefix)/.pkgbuild
	cd $($(python-idna)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-idna)-builddeps) && \
		python3 setup.py test
	@touch $@

$($(python-idna)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-idna)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-idna)-prefix)/.pkgcheck $($(python-idna)-site-packages)/.markerfile
	cd $($(python-idna)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-idna)-builddeps) && \
		PYTHONPATH=$($(python-idna)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-idna)-prefix)
	@touch $@

$($(python-idna)-modulefile): $(modulefilesdir)/.markerfile $($(python-idna)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-idna)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-idna)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-idna)-description)\"" >>$@
	echo "module-whatis \"$($(python-idna)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-idna)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_IDNA_ROOT $($(python-idna)-prefix)" >>$@
	echo "prepend-path PATH $($(python-idna)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-idna)-site-packages)" >>$@
	echo "set MSG \"$(python-idna)\"" >>$@

$(python-idna)-src: $($(python-idna)-src)
$(python-idna)-unpack: $($(python-idna)-prefix)/.pkgunpack
$(python-idna)-patch: $($(python-idna)-prefix)/.pkgpatch
$(python-idna)-build: $($(python-idna)-prefix)/.pkgbuild
$(python-idna)-check: $($(python-idna)-prefix)/.pkgcheck
$(python-idna)-install: $($(python-idna)-prefix)/.pkginstall
$(python-idna)-modulefile: $($(python-idna)-modulefile)
$(python-idna)-clean:
	rm -rf $($(python-idna)-modulefile)
	rm -rf $($(python-idna)-prefix)
	rm -rf $($(python-idna)-srcdir)
	rm -rf $($(python-idna)-src)
$(python-idna): $(python-idna)-src $(python-idna)-unpack $(python-idna)-patch $(python-idna)-build $(python-idna)-check $(python-idna)-install $(python-idna)-modulefile
