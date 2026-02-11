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
# python-cloudpickle-3.1.2

python-cloudpickle-version = 3.1.2
python-cloudpickle = python-cloudpickle-$(python-cloudpickle-version)
$(python-cloudpickle)-description = Pickler class to extend the standard pickle.Pickler functionality
$(python-cloudpickle)-url = https://github.com/cloudpipe/cloudpickle
$(python-cloudpickle)-srcurl = https://files.pythonhosted.org/packages/27/fb/576f067976d320f5f0114a8d9fa1215425441bb35627b1993e5afd8111e5/cloudpickle-3.1.2.tar.gz
$(python-cloudpickle)-src = $(pkgsrcdir)/$(notdir $($(python-cloudpickle)-srcurl))
$(python-cloudpickle)-builddeps = $(python) $(python-pip)
$(python-cloudpickle)-prereqs = $(python)
$(python-cloudpickle)-srcdir = $(pkgsrcdir)/$(python-cloudpickle)
$(python-cloudpickle)-modulefile = $(modulefilesdir)/$(python-cloudpickle)
$(python-cloudpickle)-prefix = $(pkgdir)/$(python-cloudpickle)

$($(python-cloudpickle)-src): $(dir $($(python-cloudpickle)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-cloudpickle)-srcurl)

$($(python-cloudpickle)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-cloudpickle)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-cloudpickle)-prefix)/.pkgunpack: $$($(python-cloudpickle)-src) $($(python-cloudpickle)-srcdir)/.markerfile $($(python-cloudpickle)-prefix)/.markerfile $$(foreach dep,$$($(python-cloudpickle)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-cloudpickle)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-cloudpickle)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cloudpickle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cloudpickle)-prefix)/.pkgunpack
	@touch $@

$($(python-cloudpickle)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cloudpickle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cloudpickle)-prefix)/.pkgpatch
	@touch $@

$($(python-cloudpickle)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cloudpickle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cloudpickle)-prefix)/.pkgbuild
	@touch $@

$($(python-cloudpickle)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-cloudpickle)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-cloudpickle)-prefix)/.pkgcheck
	cd $($(python-cloudpickle)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-cloudpickle)-builddeps) && \
		PYTHONPATH=$($(python-cloudpickle)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-cloudpickle)-prefix)
	@touch $@

$($(python-cloudpickle)-modulefile): $(modulefilesdir)/.markerfile $($(python-cloudpickle)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-cloudpickle)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-cloudpickle)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-cloudpickle)-description)\"" >>$@
	echo "module-whatis \"$($(python-cloudpickle)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-cloudpickle)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_CLOUDPICKLE_ROOT $($(python-cloudpickle)-prefix)" >>$@
	echo "prepend-path PATH $($(python-cloudpickle)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-cloudpickle)-prefix)" >>$@
	echo "set MSG \"$(python-cloudpickle)\"" >>$@

$(python-cloudpickle)-src: $($(python-cloudpickle)-src)
$(python-cloudpickle)-unpack: $($(python-cloudpickle)-prefix)/.pkgunpack
$(python-cloudpickle)-patch: $($(python-cloudpickle)-prefix)/.pkgpatch
$(python-cloudpickle)-build: $($(python-cloudpickle)-prefix)/.pkgbuild
$(python-cloudpickle)-check: $($(python-cloudpickle)-prefix)/.pkgcheck
$(python-cloudpickle)-install: $($(python-cloudpickle)-prefix)/.pkginstall
$(python-cloudpickle)-modulefile: $($(python-cloudpickle)-modulefile)
$(python-cloudpickle)-clean:
	rm -rf $($(python-cloudpickle)-modulefile)
	rm -rf $($(python-cloudpickle)-prefix)
	rm -rf $($(python-cloudpickle)-srcdir)
	rm -rf $($(python-cloudpickle)-src)
$(python-cloudpickle): $(python-cloudpickle)-src $(python-cloudpickle)-unpack $(python-cloudpickle)-patch $(python-cloudpickle)-build $(python-cloudpickle)-check $(python-cloudpickle)-install $(python-cloudpickle)-modulefile
