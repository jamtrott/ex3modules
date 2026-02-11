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
# python-filelock-3.0.12

python-filelock-version = 3.0.12
python-filelock = python-filelock-$(python-filelock-version)
$(python-filelock)-description = A platform independent file lock
$(python-filelock)-url = https://github.com/benediktschmitt/py-filelock
$(python-filelock)-srcurl = https://files.pythonhosted.org/packages/14/ec/6ee2168387ce0154632f856d5cc5592328e9cf93127c5c9aeca92c8c16cb/filelock-3.0.12.tar.gz
$(python-filelock)-src = $(pkgsrcdir)/$(notdir $($(python-filelock)-srcurl))
$(python-filelock)-srcdir = $(pkgsrcdir)/$(python-filelock)
$(python-filelock)-builddeps = $(python) $(python-pip)
$(python-filelock)-prereqs = $(python)
$(python-filelock)-modulefile = $(modulefilesdir)/$(python-filelock)
$(python-filelock)-prefix = $(pkgdir)/$(python-filelock)
$(python-filelock)-site-packages = $($(python-filelock)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-filelock)-src): $(dir $($(python-filelock)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-filelock)-srcurl)

$($(python-filelock)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-filelock)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-filelock)-prefix)/.pkgunpack: $$($(python-filelock)-src) $($(python-filelock)-srcdir)/.markerfile $($(python-filelock)-prefix)/.markerfile $$(foreach dep,$$($(python-filelock)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-filelock)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-filelock)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-filelock)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-filelock)-prefix)/.pkgunpack
	@touch $@

$($(python-filelock)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-filelock)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-filelock)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-filelock)-prefix)/.pkgpatch
	cd $($(python-filelock)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-filelock)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-filelock)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-filelock)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-filelock)-prefix)/.pkgbuild
	@touch $@

$($(python-filelock)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-filelock)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-filelock)-prefix)/.pkgcheck $($(python-filelock)-site-packages)/.markerfile
	cd $($(python-filelock)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-filelock)-builddeps) && \
		PYTHONPATH=$($(python-filelock)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-filelock)-prefix)
	@touch $@

$($(python-filelock)-modulefile): $(modulefilesdir)/.markerfile $($(python-filelock)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-filelock)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-filelock)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-filelock)-description)\"" >>$@
	echo "module-whatis \"$($(python-filelock)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-filelock)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FILELOCK_ROOT $($(python-filelock)-prefix)" >>$@
	echo "prepend-path PATH $($(python-filelock)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-filelock)-site-packages)" >>$@
	echo "set MSG \"$(python-filelock)\"" >>$@

$(python-filelock)-src: $($(python-filelock)-src)
$(python-filelock)-unpack: $($(python-filelock)-prefix)/.pkgunpack
$(python-filelock)-patch: $($(python-filelock)-prefix)/.pkgpatch
$(python-filelock)-build: $($(python-filelock)-prefix)/.pkgbuild
$(python-filelock)-check: $($(python-filelock)-prefix)/.pkgcheck
$(python-filelock)-install: $($(python-filelock)-prefix)/.pkginstall
$(python-filelock)-modulefile: $($(python-filelock)-modulefile)
$(python-filelock)-clean:
	rm -rf $($(python-filelock)-modulefile)
	rm -rf $($(python-filelock)-prefix)
	rm -rf $($(python-filelock)-srcdir)
	rm -rf $($(python-filelock)-src)
$(python-filelock): $(python-filelock)-src $(python-filelock)-unpack $(python-filelock)-patch $(python-filelock)-build $(python-filelock)-check $(python-filelock)-install $(python-filelock)-modulefile
