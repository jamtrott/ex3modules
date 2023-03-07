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
# python-exceptiongroup-1.1.0

python-exceptiongroup-version = 1.1.0
python-exceptiongroup = python-exceptiongroup-$(python-exceptiongroup-version)
$(python-exceptiongroup)-description = Backport of PEP 654 (exception groups)
$(python-exceptiongroup)-url = https://github.com/agronholm/exceptiongroup
$(python-exceptiongroup)-srcurl = https://files.pythonhosted.org/packages/15/ab/dd27fb742b19a9d020338deb9ab9a28796524081bca880ac33c172c9a8f6/exceptiongroup-1.1.0.tar.gz
$(python-exceptiongroup)-src = $(pkgsrcdir)/$(notdir $($(python-exceptiongroup)-srcurl))
$(python-exceptiongroup)-builddeps = $(python) $(python-pip)
$(python-exceptiongroup)-prereqs = $(python)
$(python-exceptiongroup)-srcdir = $(pkgsrcdir)/$(python-exceptiongroup)
$(python-exceptiongroup)-modulefile = $(modulefilesdir)/$(python-exceptiongroup)
$(python-exceptiongroup)-prefix = $(pkgdir)/$(python-exceptiongroup)
$(python-exceptiongroup)-site-packages = $($(python-exceptiongroup)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-exceptiongroup)-src): $(dir $($(python-exceptiongroup)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-exceptiongroup)-srcurl)

$($(python-exceptiongroup)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-exceptiongroup)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-exceptiongroup)-prefix)/.pkgunpack: $$($(python-exceptiongroup)-src) $($(python-exceptiongroup)-srcdir)/.markerfile $($(python-exceptiongroup)-prefix)/.markerfile $$(foreach dep,$$($(python-exceptiongroup)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-exceptiongroup)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-exceptiongroup)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-exceptiongroup)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-exceptiongroup)-prefix)/.pkgunpack
	@touch $@

$($(python-exceptiongroup)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-exceptiongroup)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-exceptiongroup)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-exceptiongroup)-prefix)/.pkgpatch
	@touch $@

$($(python-exceptiongroup)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-exceptiongroup)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-exceptiongroup)-prefix)/.pkgbuild
	@touch $@

$($(python-exceptiongroup)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-exceptiongroup)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-exceptiongroup)-prefix)/.pkgcheck $($(python-exceptiongroup)-site-packages)/.markerfile
	cd $($(python-exceptiongroup)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-exceptiongroup)-builddeps) && \
		PYTHONPATH=$($(python-exceptiongroup)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-exceptiongroup)-prefix)
	@touch $@

$($(python-exceptiongroup)-modulefile): $(modulefilesdir)/.markerfile $($(python-exceptiongroup)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-exceptiongroup)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-exceptiongroup)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-exceptiongroup)-description)\"" >>$@
	echo "module-whatis \"$($(python-exceptiongroup)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-exceptiongroup)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_EXCEPTIONGROUP_ROOT $($(python-exceptiongroup)-prefix)" >>$@
	echo "prepend-path PATH $($(python-exceptiongroup)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-exceptiongroup)-site-packages)" >>$@
	echo "set MSG \"$(python-exceptiongroup)\"" >>$@

$(python-exceptiongroup)-src: $($(python-exceptiongroup)-src)
$(python-exceptiongroup)-unpack: $($(python-exceptiongroup)-prefix)/.pkgunpack
$(python-exceptiongroup)-patch: $($(python-exceptiongroup)-prefix)/.pkgpatch
$(python-exceptiongroup)-build: $($(python-exceptiongroup)-prefix)/.pkgbuild
$(python-exceptiongroup)-check: $($(python-exceptiongroup)-prefix)/.pkgcheck
$(python-exceptiongroup)-install: $($(python-exceptiongroup)-prefix)/.pkginstall
$(python-exceptiongroup)-modulefile: $($(python-exceptiongroup)-modulefile)
$(python-exceptiongroup)-clean:
	rm -rf $($(python-exceptiongroup)-modulefile)
	rm -rf $($(python-exceptiongroup)-prefix)
	rm -rf $($(python-exceptiongroup)-srcdir)
	rm -rf $($(python-exceptiongroup)-src)
$(python-exceptiongroup): $(python-exceptiongroup)-src $(python-exceptiongroup)-unpack $(python-exceptiongroup)-patch $(python-exceptiongroup)-build $(python-exceptiongroup)-check $(python-exceptiongroup)-install $(python-exceptiongroup)-modulefile
