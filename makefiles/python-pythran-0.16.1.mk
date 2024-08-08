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
# python-pythran-0.16.1

python-pythran-version = 0.16.1
python-pythran = python-pythran-$(python-pythran-version)
$(python-pythran)-description = Ahead of Time compiler for numeric kernels
$(python-pythran)-url = https://github.com/serge-sans-paille/pythran
$(python-pythran)-srcurl = https://files.pythonhosted.org/packages/73/32/f892675c5009cd4c1895ded3d6153476bf00adb5ad1634d03635620881f5/pythran-0.16.1.tar.gz
$(python-pythran)-src = $(pkgsrcdir)/$(notdir $($(python-pythran)-srcurl))
$(python-pythran)-builddeps = $(python) $(python-pip) $(python-numpy) $(python-gast)
$(python-pythran)-prereqs = $(python) $(python-numpy) $(python-gast)
$(python-pythran)-srcdir = $(pkgsrcdir)/$(python-pythran)
$(python-pythran)-modulefile = $(modulefilesdir)/$(python-pythran)
$(python-pythran)-prefix = $(pkgdir)/$(python-pythran)
$(python-pythran)-site-packages = $($(python-pythran)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pythran)-src): $(dir $($(python-pythran)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pythran)-srcurl)

$($(python-pythran)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pythran)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pythran)-prefix)/.pkgunpack: $$($(python-pythran)-src) $($(python-pythran)-srcdir)/.markerfile $($(python-pythran)-prefix)/.markerfile $$(foreach dep,$$($(python-pythran)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pythran)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pythran)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pythran)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pythran)-prefix)/.pkgunpack
	@touch $@

$($(python-pythran)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pythran)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pythran)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pythran)-prefix)/.pkgpatch
	cd $($(python-pythran)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pythran)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-pythran)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pythran)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pythran)-prefix)/.pkgbuild
	# cd $($(python-pythran)-srcdir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-pythran)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-pythran)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pythran)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pythran)-prefix)/.pkgcheck $($(python-pythran)-site-packages)/.markerfile
	cd $($(python-pythran)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pythran)-builddeps) && \
		PYTHONPATH=$($(python-pythran)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-pythran)-prefix)
	@touch $@

$($(python-pythran)-modulefile): $(modulefilesdir)/.markerfile $($(python-pythran)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pythran)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pythran)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pythran)-description)\"" >>$@
	echo "module-whatis \"$($(python-pythran)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pythran)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYTHRAN_ROOT $($(python-pythran)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pythran)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pythran)-site-packages)" >>$@
	echo "set MSG \"$(python-pythran)\"" >>$@

$(python-pythran)-src: $($(python-pythran)-src)
$(python-pythran)-unpack: $($(python-pythran)-prefix)/.pkgunpack
$(python-pythran)-patch: $($(python-pythran)-prefix)/.pkgpatch
$(python-pythran)-build: $($(python-pythran)-prefix)/.pkgbuild
$(python-pythran)-check: $($(python-pythran)-prefix)/.pkgcheck
$(python-pythran)-install: $($(python-pythran)-prefix)/.pkginstall
$(python-pythran)-modulefile: $($(python-pythran)-modulefile)
$(python-pythran)-clean:
	rm -rf $($(python-pythran)-modulefile)
	rm -rf $($(python-pythran)-prefix)
	rm -rf $($(python-pythran)-srcdir)
	rm -rf $($(python-pythran)-src)
$(python-pythran): $(python-pythran)-src $(python-pythran)-unpack $(python-pythran)-patch $(python-pythran)-build $(python-pythran)-check $(python-pythran)-install $(python-pythran)-modulefile
