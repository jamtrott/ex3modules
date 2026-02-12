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
# python-h11-0.16.0

python-h11-version = 0.16.0
python-h11 = python-h11-$(python-h11-version)
$(python-h11)-description = A pure-Python, bring-your-own-I/O implementation of HTTP/1.1
$(python-h11)-url = https://github.com/python-hyper/h11
$(python-h11)-srcurl = https://files.pythonhosted.org/packages/01/ee/02a2c011bdab74c6fb3c75474d40b3052059d95df7e73351460c8588d963/h11-0.16.0.tar.gz
$(python-h11)-src = $(pkgsrcdir)/$(notdir $($(python-h11)-srcurl))
$(python-h11)-builddeps = $(python) $(python-pip)
$(python-h11)-prereqs = $(python)
$(python-h11)-srcdir = $(pkgsrcdir)/$(python-h11)
$(python-h11)-modulefile = $(modulefilesdir)/$(python-h11)
$(python-h11)-prefix = $(pkgdir)/$(python-h11)

$($(python-h11)-src): $(dir $($(python-h11)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-h11)-srcurl)

$($(python-h11)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-h11)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-h11)-prefix)/.pkgunpack: $$($(python-h11)-src) $($(python-h11)-srcdir)/.markerfile $($(python-h11)-prefix)/.markerfile $$(foreach dep,$$($(python-h11)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-h11)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-h11)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-h11)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-h11)-prefix)/.pkgunpack
	@touch $@

$($(python-h11)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-h11)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-h11)-prefix)/.pkgpatch
	@touch $@

$($(python-h11)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-h11)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-h11)-prefix)/.pkgbuild
	@touch $@

$($(python-h11)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-h11)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-h11)-prefix)/.pkgcheck
	cd $($(python-h11)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-h11)-builddeps) && \
		PYTHONPATH=$($(python-h11)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-h11)-prefix)
	@touch $@

$($(python-h11)-modulefile): $(modulefilesdir)/.markerfile $($(python-h11)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-h11)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-h11)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-h11)-description)\"" >>$@
	echo "module-whatis \"$($(python-h11)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-h11)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_H11_ROOT $($(python-h11)-prefix)" >>$@
	echo "prepend-path PATH $($(python-h11)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-h11)-prefix)" >>$@
	echo "set MSG \"$(python-h11)\"" >>$@

$(python-h11)-src: $($(python-h11)-src)
$(python-h11)-unpack: $($(python-h11)-prefix)/.pkgunpack
$(python-h11)-patch: $($(python-h11)-prefix)/.pkgpatch
$(python-h11)-build: $($(python-h11)-prefix)/.pkgbuild
$(python-h11)-check: $($(python-h11)-prefix)/.pkgcheck
$(python-h11)-install: $($(python-h11)-prefix)/.pkginstall
$(python-h11)-modulefile: $($(python-h11)-modulefile)
$(python-h11)-clean:
	rm -rf $($(python-h11)-modulefile)
	rm -rf $($(python-h11)-prefix)
	rm -rf $($(python-h11)-srcdir)
	rm -rf $($(python-h11)-src)
$(python-h11): $(python-h11)-src $(python-h11)-unpack $(python-h11)-patch $(python-h11)-build $(python-h11)-check $(python-h11)-install $(python-h11)-modulefile
