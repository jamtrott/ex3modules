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
# protobuf-python-3.17.0

protobuf-python-version = 3.17.0
protobuf-python = protobuf-python-$(protobuf-python-version)
$(protobuf-python)-description = Language- and platform-neutral, extensible mechanism for serializing structured data (Python bindings)
$(protobuf-python)-url = https://developers.google.com/protocol-buffers
$(protobuf-python)-srcurl = https://github.com/protocolbuffers/protobuf/releases/download/v$(protobuf-python-version)/protobuf-python-$(protobuf-python-version).tar.gz
$(protobuf-python)-src = $(pkgsrcdir)/$(notdir $($(protobuf-python)-srcurl))
$(protobuf-python)-srcdir = $(pkgsrcdir)/$(protobuf-python)
$(protobuf-python)-builddeps = $(python) $(protobuf-cpp) $(python-six)
$(protobuf-python)-prereqs = $(python) $(protobuf-cpp) $(python-six)
$(protobuf-python)-modulefile = $(modulefilesdir)/$(protobuf-python)
$(protobuf-python)-prefix = $(pkgdir)/$(protobuf-python)
$(protobuf-python)-site-packages = $($(protobuf-python)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(protobuf-python)-src): $(dir $($(protobuf-python)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(protobuf-python)-srcurl)

$($(protobuf-python)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(protobuf-python)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(protobuf-python)-prefix)/.pkgunpack: $$($(protobuf-python)-src) $($(protobuf-python)-srcdir)/.markerfile $($(protobuf-python)-prefix)/.markerfile $$(foreach dep,$$($(protobuf-python)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(protobuf-python)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(protobuf-python)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(protobuf-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(protobuf-python)-prefix)/.pkgunpack
	@touch $@

$($(protobuf-python)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(protobuf-python)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(protobuf-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(protobuf-python)-prefix)/.pkgpatch
	cd $($(protobuf-python)-srcdir)/python && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(protobuf-python)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(protobuf-python)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(protobuf-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(protobuf-python)-prefix)/.pkgbuild
	cd $($(protobuf-python)-srcdir)/python && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(protobuf-python)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(protobuf-python)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(protobuf-python)-builddeps),$(modulefilesdir)/$$(dep)) $($(protobuf-python)-prefix)/.pkgcheck $($(protobuf-python)-site-packages)/.markerfile
	cd $($(protobuf-python)-srcdir)/python && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(protobuf-python)-builddeps) && \
		PYTHONPATH=$($(protobuf-python)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --ignore-installed --prefix=$($(protobuf-python)-prefix)
	@touch $@

$($(protobuf-python)-modulefile): $(modulefilesdir)/.markerfile $($(protobuf-python)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(protobuf-python)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(protobuf-python)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(protobuf-python)-description)\"" >>$@
	echo "module-whatis \"$($(protobuf-python)-url)\"" >>$@
	printf "$(foreach prereq,$($(protobuf-python)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PROTOBUF_PYTHON_ROOT $($(protobuf-python)-prefix)" >>$@
	echo "prepend-path PATH $($(protobuf-python)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(protobuf-python)-site-packages)" >>$@
	echo "set MSG \"$(protobuf-python)\"" >>$@

$(protobuf-python)-src: $($(protobuf-python)-src)
$(protobuf-python)-unpack: $($(protobuf-python)-prefix)/.pkgunpack
$(protobuf-python)-patch: $($(protobuf-python)-prefix)/.pkgpatch
$(protobuf-python)-build: $($(protobuf-python)-prefix)/.pkgbuild
$(protobuf-python)-check: $($(protobuf-python)-prefix)/.pkgcheck
$(protobuf-python)-install: $($(protobuf-python)-prefix)/.pkginstall
$(protobuf-python)-modulefile: $($(protobuf-python)-modulefile)
$(protobuf-python)-clean:
	rm -rf $($(protobuf-python)-modulefile)
	rm -rf $($(protobuf-python)-prefix)
	rm -rf $($(protobuf-python)-srcdir)
	rm -rf $($(protobuf-python)-src)
$(protobuf-python): $(protobuf-python)-src $(protobuf-python)-unpack $(protobuf-python)-patch $(protobuf-python)-build $(protobuf-python)-check $(protobuf-python)-install $(protobuf-python)-modulefile
