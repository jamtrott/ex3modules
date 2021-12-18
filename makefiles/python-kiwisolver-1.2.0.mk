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
# python-kiwisolver-1.2.0

python-kiwisolver-version = 1.2.0
python-kiwisolver = python-kiwisolver-$(python-kiwisolver-version)
$(python-kiwisolver)-description = A fast implementation of the Cassowary constraint solver
$(python-kiwisolver)-url = https://github.com/nucleic/kiwi/
$(python-kiwisolver)-srcurl = https://files.pythonhosted.org/packages/62/b8/db619d97819afb52a3ff5ff6ad3f7de408cc83a8ec2dfb31a1731c0a97c2/kiwisolver-1.2.0.tar.gz
$(python-kiwisolver)-src = $(pkgsrcdir)/$(notdir $($(python-kiwisolver)-srcurl))
$(python-kiwisolver)-srcdir = $(pkgsrcdir)/$(python-kiwisolver)
$(python-kiwisolver)-builddeps = $(python)
$(python-kiwisolver)-prereqs = $(python)
$(python-kiwisolver)-modulefile = $(modulefilesdir)/$(python-kiwisolver)
$(python-kiwisolver)-prefix = $(pkgdir)/$(python-kiwisolver)
$(python-kiwisolver)-site-packages = $($(python-kiwisolver)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-kiwisolver)-src): $(dir $($(python-kiwisolver)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-kiwisolver)-srcurl)

$($(python-kiwisolver)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-kiwisolver)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-kiwisolver)-prefix)/.pkgunpack: $$($(python-kiwisolver)-src) $($(python-kiwisolver)-srcdir)/.markerfile $($(python-kiwisolver)-prefix)/.markerfile $$(foreach dep,$$($(python-kiwisolver)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-kiwisolver)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-kiwisolver)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-kiwisolver)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-kiwisolver)-prefix)/.pkgunpack
	@touch $@

$($(python-kiwisolver)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-kiwisolver)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-kiwisolver)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-kiwisolver)-prefix)/.pkgpatch
	cd $($(python-kiwisolver)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-kiwisolver)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-kiwisolver)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-kiwisolver)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-kiwisolver)-prefix)/.pkgbuild
	cd $($(python-kiwisolver)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-kiwisolver)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-kiwisolver)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-kiwisolver)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-kiwisolver)-prefix)/.pkgcheck $($(python-kiwisolver)-site-packages)/.markerfile
	cd $($(python-kiwisolver)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-kiwisolver)-builddeps) && \
		PYTHONPATH=$($(python-kiwisolver)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-kiwisolver)-prefix)
	@touch $@

$($(python-kiwisolver)-modulefile): $(modulefilesdir)/.markerfile $($(python-kiwisolver)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-kiwisolver)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-kiwisolver)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-kiwisolver)-description)\"" >>$@
	echo "module-whatis \"$($(python-kiwisolver)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-kiwisolver)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_KIWISOLVER_ROOT $($(python-kiwisolver)-prefix)" >>$@
	echo "prepend-path PATH $($(python-kiwisolver)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-kiwisolver)-site-packages)" >>$@
	echo "set MSG \"$(python-kiwisolver)\"" >>$@

$(python-kiwisolver)-src: $($(python-kiwisolver)-src)
$(python-kiwisolver)-unpack: $($(python-kiwisolver)-prefix)/.pkgunpack
$(python-kiwisolver)-patch: $($(python-kiwisolver)-prefix)/.pkgpatch
$(python-kiwisolver)-build: $($(python-kiwisolver)-prefix)/.pkgbuild
$(python-kiwisolver)-check: $($(python-kiwisolver)-prefix)/.pkgcheck
$(python-kiwisolver)-install: $($(python-kiwisolver)-prefix)/.pkginstall
$(python-kiwisolver)-modulefile: $($(python-kiwisolver)-modulefile)
$(python-kiwisolver)-clean:
	rm -rf $($(python-kiwisolver)-modulefile)
	rm -rf $($(python-kiwisolver)-prefix)
	rm -rf $($(python-kiwisolver)-srcdir)
	rm -rf $($(python-kiwisolver)-src)
$(python-kiwisolver): $(python-kiwisolver)-src $(python-kiwisolver)-unpack $(python-kiwisolver)-patch $(python-kiwisolver)-build $(python-kiwisolver)-check $(python-kiwisolver)-install $(python-kiwisolver)-modulefile
