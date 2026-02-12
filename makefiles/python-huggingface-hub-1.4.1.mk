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
# python-huggingface-hub-1.4.1

python-huggingface-hub-version = 1.4.1
python-huggingface-hub = python-huggingface-hub-$(python-huggingface-hub-version)
$(python-huggingface-hub)-description = Client library to download and publish models, datasets and other repos on the huggingface.co hub
$(python-huggingface-hub)-url = https://github.com/huggingface/huggingface_hub
$(python-huggingface-hub)-srcurl = https://files.pythonhosted.org/packages/c4/fc/eb9bc06130e8bbda6a616e1b80a7aa127681c448d6b49806f61db2670b61/huggingface_hub-1.4.1.tar.gz
$(python-huggingface-hub)-src = $(pkgsrcdir)/$(notdir $($(python-huggingface-hub)-srcurl))
$(python-huggingface-hub)-builddeps = $(python) $(python-pip) $(python-httpx) $(python-pyyaml) $(python-packaging) $(python-tqdm) $(python-typing_extensions) $(python-typer-slim) $(python-shellingham)
$(python-huggingface-hub)-prereqs = $(python) $(python-httpx) $(python-pyyaml) $(python-packaging) $(python-tqdm) $(python-typing_extensions) $(python-typer-slim) $(python-shellingham)
$(python-huggingface-hub)-srcdir = $(pkgsrcdir)/$(python-huggingface-hub)
$(python-huggingface-hub)-modulefile = $(modulefilesdir)/$(python-huggingface-hub)
$(python-huggingface-hub)-prefix = $(pkgdir)/$(python-huggingface-hub)

$($(python-huggingface-hub)-src): $(dir $($(python-huggingface-hub)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-huggingface-hub)-srcurl)

$($(python-huggingface-hub)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-huggingface-hub)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-huggingface-hub)-prefix)/.pkgunpack: $$($(python-huggingface-hub)-src) $($(python-huggingface-hub)-srcdir)/.markerfile $($(python-huggingface-hub)-prefix)/.markerfile $$(foreach dep,$$($(python-huggingface-hub)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-huggingface-hub)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-huggingface-hub)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-huggingface-hub)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-huggingface-hub)-prefix)/.pkgunpack
	@touch $@

$($(python-huggingface-hub)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-huggingface-hub)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-huggingface-hub)-prefix)/.pkgpatch
	@touch $@

$($(python-huggingface-hub)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-huggingface-hub)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-huggingface-hub)-prefix)/.pkgbuild
	@touch $@

$($(python-huggingface-hub)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-huggingface-hub)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-huggingface-hub)-prefix)/.pkgcheck
	cd $($(python-huggingface-hub)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-huggingface-hub)-builddeps) && \
		PYTHONPATH=$($(python-huggingface-hub)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-huggingface-hub)-prefix)
	@touch $@

$($(python-huggingface-hub)-modulefile): $(modulefilesdir)/.markerfile $($(python-huggingface-hub)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-huggingface-hub)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-huggingface-hub)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-huggingface-hub)-description)\"" >>$@
	echo "module-whatis \"$($(python-huggingface-hub)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-huggingface-hub)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_HUGGINGFACE_HUB_ROOT $($(python-huggingface-hub)-prefix)" >>$@
	echo "prepend-path PATH $($(python-huggingface-hub)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-huggingface-hub)-prefix)" >>$@
	echo "set MSG \"$(python-huggingface-hub)\"" >>$@

$(python-huggingface-hub)-src: $($(python-huggingface-hub)-src)
$(python-huggingface-hub)-unpack: $($(python-huggingface-hub)-prefix)/.pkgunpack
$(python-huggingface-hub)-patch: $($(python-huggingface-hub)-prefix)/.pkgpatch
$(python-huggingface-hub)-build: $($(python-huggingface-hub)-prefix)/.pkgbuild
$(python-huggingface-hub)-check: $($(python-huggingface-hub)-prefix)/.pkgcheck
$(python-huggingface-hub)-install: $($(python-huggingface-hub)-prefix)/.pkginstall
$(python-huggingface-hub)-modulefile: $($(python-huggingface-hub)-modulefile)
$(python-huggingface-hub)-clean:
	rm -rf $($(python-huggingface-hub)-modulefile)
	rm -rf $($(python-huggingface-hub)-prefix)
	rm -rf $($(python-huggingface-hub)-srcdir)
	rm -rf $($(python-huggingface-hub)-src)
$(python-huggingface-hub): $(python-huggingface-hub)-src $(python-huggingface-hub)-unpack $(python-huggingface-hub)-patch $(python-huggingface-hub)-build $(python-huggingface-hub)-check $(python-huggingface-hub)-install $(python-huggingface-hub)-modulefile
