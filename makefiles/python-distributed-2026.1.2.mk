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
# python-distributed-2026.1.2

python-distributed-version = 2026.1.2
python-distributed = python-distributed-$(python-distributed-version)
$(python-distributed)-description = Distributed scheduler for Dask
$(python-distributed)-url = https://distributed.dask.org/
$(python-distributed)-srcurl = https://files.pythonhosted.org/packages/4e/75/b6e5b77229097ff03dd5ba6a07c77e2da87e7e991ccfef412549bba78746/distributed-2026.1.2.tar.gz
$(python-distributed)-src = $(pkgsrcdir)/$(notdir $($(python-distributed)-srcurl))
$(python-distributed)-builddeps = $(python) $(python-pip) $(python-click) $(python-cloudpickle) $(python-jinja2) $(python-packaging) $(python-psutil) $(python-pyyaml) $(python-sortedcontainers) $(python-tblib) $(python-toolz) $(python-tornado) $(python-urllib3) $(python-locket) $(python-msgpack) $(python-zict)
$(python-distributed)-prereqs = $(python) $(python-click) $(python-cloudpickle) $(python-jinja2) $(python-packaging) $(python-psutil) $(python-pyyaml) $(python-sortedcontainers) $(python-tblib) $(python-toolz) $(python-tornado) $(python-urllib3) $(python-locket) $(python-msgpack) $(python-zict)
$(python-distributed)-srcdir = $(pkgsrcdir)/$(python-distributed)
$(python-distributed)-modulefile = $(modulefilesdir)/$(python-distributed)
$(python-distributed)-prefix = $(pkgdir)/$(python-distributed)

$($(python-distributed)-src): $(dir $($(python-distributed)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-distributed)-srcurl)

$($(python-distributed)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-distributed)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-distributed)-prefix)/.pkgunpack: $$($(python-distributed)-src) $($(python-distributed)-srcdir)/.markerfile $($(python-distributed)-prefix)/.markerfile $$(foreach dep,$$($(python-distributed)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-distributed)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-distributed)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-distributed)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-distributed)-prefix)/.pkgunpack
	@touch $@

$($(python-distributed)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-distributed)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-distributed)-prefix)/.pkgpatch
	@touch $@

$($(python-distributed)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-distributed)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-distributed)-prefix)/.pkgbuild
	@touch $@

$($(python-distributed)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-distributed)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-distributed)-prefix)/.pkgcheck
	cd $($(python-distributed)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-distributed)-builddeps) && \
		PYTHONPATH=$($(python-distributed)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-distributed)-prefix)
	@touch $@

$($(python-distributed)-modulefile): $(modulefilesdir)/.markerfile $($(python-distributed)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-distributed)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-distributed)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-distributed)-description)\"" >>$@
	echo "module-whatis \"$($(python-distributed)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-distributed)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_DISTRIBUTED_ROOT $($(python-distributed)-prefix)" >>$@
	echo "prepend-path PATH $($(python-distributed)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-distributed)-prefix)" >>$@
	echo "set MSG \"$(python-distributed)\"" >>$@

$(python-distributed)-src: $($(python-distributed)-src)
$(python-distributed)-unpack: $($(python-distributed)-prefix)/.pkgunpack
$(python-distributed)-patch: $($(python-distributed)-prefix)/.pkgpatch
$(python-distributed)-build: $($(python-distributed)-prefix)/.pkgbuild
$(python-distributed)-check: $($(python-distributed)-prefix)/.pkgcheck
$(python-distributed)-install: $($(python-distributed)-prefix)/.pkginstall
$(python-distributed)-modulefile: $($(python-distributed)-modulefile)
$(python-distributed)-clean:
	rm -rf $($(python-distributed)-modulefile)
	rm -rf $($(python-distributed)-prefix)
	rm -rf $($(python-distributed)-srcdir)
	rm -rf $($(python-distributed)-src)
$(python-distributed): $(python-distributed)-src $(python-distributed)-unpack $(python-distributed)-patch $(python-distributed)-build $(python-distributed)-check $(python-distributed)-install $(python-distributed)-modulefile
