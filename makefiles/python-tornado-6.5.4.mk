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
# python-tornado-6.5.4

python-tornado-version = 6.5.4
python-tornado = python-tornado-$(python-tornado-version)
$(python-tornado)-description = Tornado is a Python web framework and asynchronous networking library
$(python-tornado)-url = http://www.tornadoweb.org/
$(python-tornado)-srcurl = https://files.pythonhosted.org/packages/37/1d/0a336abf618272d53f62ebe274f712e213f5a03c0b2339575430b8362ef2/tornado-6.5.4.tar.gz
$(python-tornado)-src = $(pkgsrcdir)/$(notdir $($(python-tornado)-srcurl))
$(python-tornado)-builddeps = $(python) $(python-pip)
$(python-tornado)-prereqs = $(python)
$(python-tornado)-srcdir = $(pkgsrcdir)/$(python-tornado)
$(python-tornado)-modulefile = $(modulefilesdir)/$(python-tornado)
$(python-tornado)-prefix = $(pkgdir)/$(python-tornado)

$($(python-tornado)-src): $(dir $($(python-tornado)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-tornado)-srcurl)

$($(python-tornado)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tornado)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tornado)-prefix)/.pkgunpack: $$($(python-tornado)-src) $($(python-tornado)-srcdir)/.markerfile $($(python-tornado)-prefix)/.markerfile $$(foreach dep,$$($(python-tornado)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-tornado)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-tornado)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tornado)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tornado)-prefix)/.pkgunpack
	@touch $@

$($(python-tornado)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tornado)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tornado)-prefix)/.pkgpatch
	@touch $@

$($(python-tornado)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tornado)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tornado)-prefix)/.pkgbuild
	@touch $@

$($(python-tornado)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tornado)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tornado)-prefix)/.pkgcheck
	cd $($(python-tornado)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-tornado)-builddeps) && \
		PYTHONPATH=$($(python-tornado)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-tornado)-prefix)
	@touch $@

$($(python-tornado)-modulefile): $(modulefilesdir)/.markerfile $($(python-tornado)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-tornado)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-tornado)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-tornado)-description)\"" >>$@
	echo "module-whatis \"$($(python-tornado)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-tornado)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TORNADO_ROOT $($(python-tornado)-prefix)" >>$@
	echo "prepend-path PATH $($(python-tornado)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-tornado)-prefix)" >>$@
	echo "set MSG \"$(python-tornado)\"" >>$@

$(python-tornado)-src: $($(python-tornado)-src)
$(python-tornado)-unpack: $($(python-tornado)-prefix)/.pkgunpack
$(python-tornado)-patch: $($(python-tornado)-prefix)/.pkgpatch
$(python-tornado)-build: $($(python-tornado)-prefix)/.pkgbuild
$(python-tornado)-check: $($(python-tornado)-prefix)/.pkgcheck
$(python-tornado)-install: $($(python-tornado)-prefix)/.pkginstall
$(python-tornado)-modulefile: $($(python-tornado)-modulefile)
$(python-tornado)-clean:
	rm -rf $($(python-tornado)-modulefile)
	rm -rf $($(python-tornado)-prefix)
	rm -rf $($(python-tornado)-srcdir)
	rm -rf $($(python-tornado)-src)
$(python-tornado): $(python-tornado)-src $(python-tornado)-unpack $(python-tornado)-patch $(python-tornado)-build $(python-tornado)-check $(python-tornado)-install $(python-tornado)-modulefile
