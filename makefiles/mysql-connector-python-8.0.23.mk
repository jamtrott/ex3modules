# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
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
# mysql-connector-python-8.0.23

mysql-connector-python-version = 8.0.23
mysql-connector-python = mysql-connector-python-$(mysql-connector-python-version)
$(mysql-connector-python)-description = Python driver for communicating with MySQL servers
$(mysql-connector-python)-url = https://dev.mysql.com/doc/connector-python/en/
$(mysql-connector-python)-srcurl = https://dev.mysql.com/get/Downloads/Connector-Python/mysql-connector-python-$(mysql-connector-python-version).tar.gz
$(mysql-connector-python)-builddeps = $(python) $(protobuf-python)
$(mysql-connector-python)-prereqs = $(python) $(protobuf-python)
$(mysql-connector-python)-src = $(pkgsrcdir)/$(notdir $($(mysql-connector-python)-srcurl))
$(mysql-connector-python)-srcdir = $(pkgsrcdir)/$(mysql-connector-python)
$(mysql-connector-python)-builddir = $($(mysql-connector-python)-srcdir)
$(mysql-connector-python)-modulefile = $(modulefilesdir)/$(mysql-connector-python)
$(mysql-connector-python)-prefix = $(pkgdir)/$(mysql-connector-python)

$($(mysql-connector-python)-src): $(dir $($(mysql-connector-python)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mysql-connector-python)-srcurl)

$($(mysql-connector-python)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mysql-connector-python)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(mysql-connector-python)-prefix)/.pkgunpack: $$($(mysql-connector-python)-src) $($(mysql-connector-python)-srcdir)/.markerfile $($(mysql-connector-python)-prefix)/.markerfile $$(foreach dep,$$($(mysql-connector-python)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(mysql-connector-python)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(mysql-connector-python)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mysql-connector-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(mysql-connector-python)-prefix)/.pkgunpack
	@touch $@

ifneq ($($(mysql-connector-python)-builddir),$($(mysql-connector-python)-srcdir))
$($(mysql-connector-python)-builddir)/.markerfile: $($(mysql-connector-python)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(mysql-connector-python)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mysql-connector-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(mysql-connector-python)-builddir)/.markerfile $($(mysql-connector-python)-prefix)/.pkgpatch
	cd $($(mysql-connector-python)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mysql-connector-python)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(mysql-connector-python)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mysql-connector-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(mysql-connector-python)-builddir)/.markerfile $($(mysql-connector-python)-prefix)/.pkgbuild
	@touch $@

$($(mysql-connector-python)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(mysql-connector-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(mysql-connector-python)-builddir)/.markerfile $($(mysql-connector-python)-prefix)/.pkgcheck
	cd $($(mysql-connector-python)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(mysql-connector-python)-builddeps) && \
		PYTHONPATH=$($(mysql-connector-python)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-index --ignore-installed --prefix=$($(mysql-connector-python)-prefix)
	@touch $@

$($(mysql-connector-python)-modulefile): $(modulefilesdir)/.markerfile $($(mysql-connector-python)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(mysql-connector-python)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(mysql-connector-python)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(mysql-connector-python)-description)\"" >>$@
	echo "module-whatis \"$($(mysql-connector-python)-url)\"" >>$@
	printf "$(foreach prereq,$($(mysql-connector-python)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv MYSQL_CONNECTOR_PYTHON_ROOT $($(mysql-connector-python)-prefix)" >>$@
	echo "prepend-path PATH $($(mysql-connector-python)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(mysql-connector-python)-site-packages)" >>$@
	echo "set MSG \"$(mysql-connector-python)\"" >>$@

$(mysql-connector-python)-src: $$($(mysql-connector-python)-src)
$(mysql-connector-python)-unpack: $($(mysql-connector-python)-prefix)/.pkgunpack
$(mysql-connector-python)-patch: $($(mysql-connector-python)-prefix)/.pkgpatch
$(mysql-connector-python)-build: $($(mysql-connector-python)-prefix)/.pkgbuild
$(mysql-connector-python)-check: $($(mysql-connector-python)-prefix)/.pkgcheck
$(mysql-connector-python)-install: $($(mysql-connector-python)-prefix)/.pkginstall
$(mysql-connector-python)-modulefile: $($(mysql-connector-python)-modulefile)
$(mysql-connector-python)-clean:
	rm -rf $($(mysql-connector-python)-modulefile)
	rm -rf $($(mysql-connector-python)-prefix)
	rm -rf $($(mysql-connector-python)-builddir)
	rm -rf $($(mysql-connector-python)-srcdir)
	rm -rf $($(mysql-connector-python)-src)
$(mysql-connector-python): $(mysql-connector-python)-src $(mysql-connector-python)-unpack $(mysql-connector-python)-patch $(mysql-connector-python)-build $(mysql-connector-python)-check $(mysql-connector-python)-install $(mysql-connector-python)-modulefile
