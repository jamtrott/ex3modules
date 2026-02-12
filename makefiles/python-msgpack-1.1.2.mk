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
# python-msgpack-1.1.2

python-msgpack-version = 1.1.2
python-msgpack = python-msgpack-$(python-msgpack-version)
$(python-msgpack)-description = MessagePack is an efficient binary serialization format
$(python-msgpack)-url = https://github.com/msgpack/msgpack-python
$(python-msgpack)-srcurl = https://files.pythonhosted.org/packages/4d/f2/bfb55a6236ed8725a96b0aa3acbd0ec17588e6a2c3b62a93eb513ed8783f/msgpack-1.1.2.tar.gz
$(python-msgpack)-src = $(pkgsrcdir)/$(notdir $($(python-msgpack)-srcurl))
$(python-msgpack)-builddeps = $(python) $(python-pip)
$(python-msgpack)-prereqs = $(python)
$(python-msgpack)-srcdir = $(pkgsrcdir)/$(python-msgpack)
$(python-msgpack)-modulefile = $(modulefilesdir)/$(python-msgpack)
$(python-msgpack)-prefix = $(pkgdir)/$(python-msgpack)

$($(python-msgpack)-src): $(dir $($(python-msgpack)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-msgpack)-srcurl)

$($(python-msgpack)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-msgpack)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-msgpack)-prefix)/.pkgunpack: $$($(python-msgpack)-src) $($(python-msgpack)-srcdir)/.markerfile $($(python-msgpack)-prefix)/.markerfile $$(foreach dep,$$($(python-msgpack)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-msgpack)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-msgpack)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-msgpack)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-msgpack)-prefix)/.pkgunpack
	@touch $@

$($(python-msgpack)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-msgpack)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-msgpack)-prefix)/.pkgpatch
	@touch $@

$($(python-msgpack)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-msgpack)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-msgpack)-prefix)/.pkgbuild
	@touch $@

$($(python-msgpack)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-msgpack)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-msgpack)-prefix)/.pkgcheck
	cd $($(python-msgpack)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-msgpack)-builddeps) && \
		PYTHONPATH=$($(python-msgpack)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-msgpack)-prefix)
	@touch $@

$($(python-msgpack)-modulefile): $(modulefilesdir)/.markerfile $($(python-msgpack)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-msgpack)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-msgpack)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-msgpack)-description)\"" >>$@
	echo "module-whatis \"$($(python-msgpack)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-msgpack)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_MSGPACK_ROOT $($(python-msgpack)-prefix)" >>$@
	echo "prepend-path PATH $($(python-msgpack)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-msgpack)-prefix)" >>$@
	echo "set MSG \"$(python-msgpack)\"" >>$@

$(python-msgpack)-src: $($(python-msgpack)-src)
$(python-msgpack)-unpack: $($(python-msgpack)-prefix)/.pkgunpack
$(python-msgpack)-patch: $($(python-msgpack)-prefix)/.pkgpatch
$(python-msgpack)-build: $($(python-msgpack)-prefix)/.pkgbuild
$(python-msgpack)-check: $($(python-msgpack)-prefix)/.pkgcheck
$(python-msgpack)-install: $($(python-msgpack)-prefix)/.pkginstall
$(python-msgpack)-modulefile: $($(python-msgpack)-modulefile)
$(python-msgpack)-clean:
	rm -rf $($(python-msgpack)-modulefile)
	rm -rf $($(python-msgpack)-prefix)
	rm -rf $($(python-msgpack)-srcdir)
	rm -rf $($(python-msgpack)-src)
$(python-msgpack): $(python-msgpack)-src $(python-msgpack)-unpack $(python-msgpack)-patch $(python-msgpack)-build $(python-msgpack)-check $(python-msgpack)-install $(python-msgpack)-modulefile
