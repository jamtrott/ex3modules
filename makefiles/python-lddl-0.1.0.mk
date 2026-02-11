# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# python-lddl-0.1.0

python-lddl-version = 0.1.0
python-lddl = python-lddl-$(python-lddl-version)
$(python-lddl)-description = Language Datasets and Data Loaders for NVIDIA Deep Learning Examples
$(python-lddl)-url = https://github.com/NVIDIA/LDDL
$(python-lddl)-srcurl = https://files.pythonhosted.org/packages/b2/65/c511cda5b1ea43415e301a8c8c68e8926709775ca7fb5714748c0032de9e/lddl-0.1.0.tar.gz
$(python-lddl)-src = $(pkgsrcdir)/$(notdir $($(python-lddl)-srcurl))
$(python-lddl)-builddeps = $(python) $(python-pip) $(python-tqdm) $(python-requests) $(python-pyarrow)
$(python-lddl)-prereqs = $(python) $(python-tqdm) $(python-requests) $(python-pyarrow) $(python-wikiextractor)
$(python-lddl)-srcdir = $(pkgsrcdir)/$(python-lddl)
$(python-lddl)-modulefile = $(modulefilesdir)/$(python-lddl)
$(python-lddl)-prefix = $(pkgdir)/$(python-lddl)

$($(python-lddl)-src): $(dir $($(python-lddl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-lddl)-srcurl)

$($(python-lddl)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-lddl)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-lddl)-prefix)/.pkgunpack: $$($(python-lddl)-src) $($(python-lddl)-srcdir)/.markerfile $($(python-lddl)-prefix)/.markerfile $$(foreach dep,$$($(python-lddl)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-lddl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-lddl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-lddl)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-lddl)-prefix)/.pkgunpack
	@touch $@

$($(python-lddl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-lddl)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-lddl)-prefix)/.pkgpatch
	cd $($(python-lddl)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-lddl)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-lddl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-lddl)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-lddl)-prefix)/.pkgbuild
	@touch $@

$($(python-lddl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-lddl)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-lddl)-prefix)/.pkgcheck
	cd $($(python-lddl)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-lddl)-builddeps) && \
		PYTHONPATH=$($(python-lddl)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-lddl)-prefix)
	@touch $@

$($(python-lddl)-modulefile): $(modulefilesdir)/.markerfile $($(python-lddl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-lddl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-lddl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-lddl)-description)\"" >>$@
	echo "module-whatis \"$($(python-lddl)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-lddl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_LDDL_ROOT $($(python-lddl)-prefix)" >>$@
	echo "prepend-path PATH $($(python-lddl)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-lddl)-prefix)" >>$@
	echo "set MSG \"$(python-lddl)\"" >>$@

$(python-lddl)-src: $($(python-lddl)-src)
$(python-lddl)-unpack: $($(python-lddl)-prefix)/.pkgunpack
$(python-lddl)-patch: $($(python-lddl)-prefix)/.pkgpatch
$(python-lddl)-build: $($(python-lddl)-prefix)/.pkgbuild
$(python-lddl)-check: $($(python-lddl)-prefix)/.pkgcheck
$(python-lddl)-install: $($(python-lddl)-prefix)/.pkginstall
$(python-lddl)-modulefile: $($(python-lddl)-modulefile)
$(python-lddl)-clean:
	rm -rf $($(python-lddl)-modulefile)
	rm -rf $($(python-lddl)-prefix)
	rm -rf $($(python-lddl)-srcdir)
	rm -rf $($(python-lddl)-src)
$(python-lddl): $(python-lddl)-src $(python-lddl)-unpack $(python-lddl)-patch $(python-lddl)-build $(python-lddl)-check $(python-lddl)-install $(python-lddl)-modulefile
