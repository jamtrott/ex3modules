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
# python-dateutil-2.0

python-dateutil-version = 2.0
python-dateutil = python-dateutil-$(python-dateutil-version)
$(python-dateutil)-description = Extensions to the standard datetime module
$(python-dateutil)-url = https://launchpad.net/dateutil/
$(python-dateutil)-srcurl = https://labix.org/download/python-dateutil/python-dateutil-$(python-dateutil-version).tar.gz
$(python-dateutil)-src = $(pkgsrcdir)/$(notdir $($(python-dateutil)-srcurl))
$(python-dateutil)-srcdir = $(pkgsrcdir)/$(python-dateutil)
$(python-dateutil)-builddeps = $(python) $(python-pip)
$(python-dateutil)-prereqs = $(python)
$(python-dateutil)-modulefile = $(modulefilesdir)/$(python-dateutil)
$(python-dateutil)-prefix = $(pkgdir)/$(python-dateutil)
$(python-dateutil)-site-packages = $($(python-dateutil)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-dateutil)-src): $(dir $($(python-dateutil)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-dateutil)-srcurl)

$($(python-dateutil)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-dateutil)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-dateutil)-prefix)/.pkgunpack: $$($(python-dateutil)-src) $($(python-dateutil)-srcdir)/.markerfile $($(python-dateutil)-prefix)/.markerfile $$(foreach dep,$$($(python-dateutil)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-dateutil)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-dateutil)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-dateutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-dateutil)-prefix)/.pkgunpack
	@touch $@

$($(python-dateutil)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-dateutil)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-dateutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-dateutil)-prefix)/.pkgpatch
	cd $($(python-dateutil)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-dateutil)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-dateutil)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-dateutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-dateutil)-prefix)/.pkgbuild
	# cd $($(python-dateutil)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-dateutil)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-dateutil)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-dateutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-dateutil)-prefix)/.pkgcheck $($(python-dateutil)-site-packages)/.markerfile
	cd $($(python-dateutil)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-dateutil)-builddeps) && \
		PYTHONPATH=$($(python-dateutil)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-dateutil)-prefix)
	@touch $@

$($(python-dateutil)-modulefile): $(modulefilesdir)/.markerfile $($(python-dateutil)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-dateutil)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-dateutil)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-dateutil)-description)\"" >>$@
	echo "module-whatis \"$($(python-dateutil)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-dateutil)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_DATEUTIL_ROOT $($(python-dateutil)-prefix)" >>$@
	echo "prepend-path PATH $($(python-dateutil)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-dateutil)-site-packages)" >>$@
	echo "set MSG \"$(python-dateutil)\"" >>$@

$(python-dateutil)-src: $($(python-dateutil)-src)
$(python-dateutil)-unpack: $($(python-dateutil)-prefix)/.pkgunpack
$(python-dateutil)-patch: $($(python-dateutil)-prefix)/.pkgpatch
$(python-dateutil)-build: $($(python-dateutil)-prefix)/.pkgbuild
$(python-dateutil)-check: $($(python-dateutil)-prefix)/.pkgcheck
$(python-dateutil)-install: $($(python-dateutil)-prefix)/.pkginstall
$(python-dateutil)-modulefile: $($(python-dateutil)-modulefile)
$(python-dateutil)-clean:
	rm -rf $($(python-dateutil)-modulefile)
	rm -rf $($(python-dateutil)-prefix)
	rm -rf $($(python-dateutil)-srcdir)
	rm -rf $($(python-dateutil)-src)
$(python-dateutil): $(python-dateutil)-src $(python-dateutil)-unpack $(python-dateutil)-patch $(python-dateutil)-build $(python-dateutil)-check $(python-dateutil)-install $(python-dateutil)-modulefile
