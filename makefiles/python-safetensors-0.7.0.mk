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
# python-safetensors-0.7.0

python-safetensors-version = 0.7.0
python-safetensors = python-safetensors-$(python-safetensors-version)
$(python-safetensors)-description =
$(python-safetensors)-url = https://github.com/huggingface/safetensors
$(python-safetensors)-srcurl = https://files.pythonhosted.org/packages/29/9c/6e74567782559a63bd040a236edca26fd71bc7ba88de2ef35d75df3bca5e/safetensors-0.7.0.tar.gz
$(python-safetensors)-src = $(pkgsrcdir)/$(notdir $($(python-safetensors)-srcurl))
$(python-safetensors)-builddeps = $(python) $(python-pip)
$(python-safetensors)-prereqs = $(python)
$(python-safetensors)-srcdir = $(pkgsrcdir)/$(python-safetensors)
$(python-safetensors)-modulefile = $(modulefilesdir)/$(python-safetensors)
$(python-safetensors)-prefix = $(pkgdir)/$(python-safetensors)

$($(python-safetensors)-src): $(dir $($(python-safetensors)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-safetensors)-srcurl)

$($(python-safetensors)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-safetensors)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-safetensors)-prefix)/.pkgunpack: $$($(python-safetensors)-src) $($(python-safetensors)-srcdir)/.markerfile $($(python-safetensors)-prefix)/.markerfile $$(foreach dep,$$($(python-safetensors)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-safetensors)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-safetensors)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-safetensors)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-safetensors)-prefix)/.pkgunpack
	@touch $@

$($(python-safetensors)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-safetensors)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-safetensors)-prefix)/.pkgpatch
	@touch $@

$($(python-safetensors)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-safetensors)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-safetensors)-prefix)/.pkgbuild
	@touch $@

$($(python-safetensors)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-safetensors)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-safetensors)-prefix)/.pkgcheck
	cd $($(python-safetensors)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-safetensors)-builddeps) && \
		PYTHONPATH=$($(python-safetensors)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-safetensors)-prefix)
	@touch $@

$($(python-safetensors)-modulefile): $(modulefilesdir)/.markerfile $($(python-safetensors)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-safetensors)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-safetensors)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-safetensors)-description)\"" >>$@
	echo "module-whatis \"$($(python-safetensors)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-safetensors)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SAFETENSORS_ROOT $($(python-safetensors)-prefix)" >>$@
	echo "prepend-path PATH $($(python-safetensors)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-safetensors)-prefix)" >>$@
	echo "set MSG \"$(python-safetensors)\"" >>$@

$(python-safetensors)-src: $($(python-safetensors)-src)
$(python-safetensors)-unpack: $($(python-safetensors)-prefix)/.pkgunpack
$(python-safetensors)-patch: $($(python-safetensors)-prefix)/.pkgpatch
$(python-safetensors)-build: $($(python-safetensors)-prefix)/.pkgbuild
$(python-safetensors)-check: $($(python-safetensors)-prefix)/.pkgcheck
$(python-safetensors)-install: $($(python-safetensors)-prefix)/.pkginstall
$(python-safetensors)-modulefile: $($(python-safetensors)-modulefile)
$(python-safetensors)-clean:
	rm -rf $($(python-safetensors)-modulefile)
	rm -rf $($(python-safetensors)-prefix)
	rm -rf $($(python-safetensors)-srcdir)
	rm -rf $($(python-safetensors)-src)
$(python-safetensors): $(python-safetensors)-src $(python-safetensors)-unpack $(python-safetensors)-patch $(python-safetensors)-build $(python-safetensors)-check $(python-safetensors)-install $(python-safetensors)-modulefile
