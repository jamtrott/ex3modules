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
# python-typer-slim-0.23.0

python-typer-slim-version = 0.23.0
python-typer-slim = python-typer-slim-$(python-typer-slim-version)
$(python-typer-slim)-description = Typer, build great CLIs. Easy to code. Based on Python type hints.
$(python-typer-slim)-url = Typer, build great CLIs. Easy to code. Based on Python type hints.
$(python-typer-slim)-srcurl = https://files.pythonhosted.org/packages/1f/8a/881cfd399a119db89619dc1b93d36e2fb6720ddb112bceff41203f1abd72/typer_slim-0.23.0.tar.gz
$(python-typer-slim)-src = $(pkgsrcdir)/$(notdir $($(python-typer-slim)-srcurl))
$(python-typer-slim)-builddeps = $(python) $(python-pip)
$(python-typer-slim)-prereqs = $(python)
$(python-typer-slim)-srcdir = $(pkgsrcdir)/$(python-typer-slim)
$(python-typer-slim)-modulefile = $(modulefilesdir)/$(python-typer-slim)
$(python-typer-slim)-prefix = $(pkgdir)/$(python-typer-slim)

$($(python-typer-slim)-src): $(dir $($(python-typer-slim)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-typer-slim)-srcurl)

$($(python-typer-slim)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-typer-slim)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-typer-slim)-prefix)/.pkgunpack: $$($(python-typer-slim)-src) $($(python-typer-slim)-srcdir)/.markerfile $($(python-typer-slim)-prefix)/.markerfile $$(foreach dep,$$($(python-typer-slim)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-typer-slim)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-typer-slim)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-typer-slim)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-typer-slim)-prefix)/.pkgunpack
	@touch $@

$($(python-typer-slim)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-typer-slim)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-typer-slim)-prefix)/.pkgpatch
	@touch $@

$($(python-typer-slim)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-typer-slim)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-typer-slim)-prefix)/.pkgbuild
	@touch $@

$($(python-typer-slim)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-typer-slim)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-typer-slim)-prefix)/.pkgcheck
	cd $($(python-typer-slim)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-typer-slim)-builddeps) && \
		PYTHONPATH=$($(python-typer-slim)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-typer-slim)-prefix)
	@touch $@

$($(python-typer-slim)-modulefile): $(modulefilesdir)/.markerfile $($(python-typer-slim)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-typer-slim)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-typer-slim)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-typer-slim)-description)\"" >>$@
	echo "module-whatis \"$($(python-typer-slim)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-typer-slim)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TYPER_SLIM_ROOT $($(python-typer-slim)-prefix)" >>$@
	echo "prepend-path PATH $($(python-typer-slim)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-typer-slim)-prefix)" >>$@
	echo "set MSG \"$(python-typer-slim)\"" >>$@

$(python-typer-slim)-src: $($(python-typer-slim)-src)
$(python-typer-slim)-unpack: $($(python-typer-slim)-prefix)/.pkgunpack
$(python-typer-slim)-patch: $($(python-typer-slim)-prefix)/.pkgpatch
$(python-typer-slim)-build: $($(python-typer-slim)-prefix)/.pkgbuild
$(python-typer-slim)-check: $($(python-typer-slim)-prefix)/.pkgcheck
$(python-typer-slim)-install: $($(python-typer-slim)-prefix)/.pkginstall
$(python-typer-slim)-modulefile: $($(python-typer-slim)-modulefile)
$(python-typer-slim)-clean:
	rm -rf $($(python-typer-slim)-modulefile)
	rm -rf $($(python-typer-slim)-prefix)
	rm -rf $($(python-typer-slim)-srcdir)
	rm -rf $($(python-typer-slim)-src)
$(python-typer-slim): $(python-typer-slim)-src $(python-typer-slim)-unpack $(python-typer-slim)-patch $(python-typer-slim)-build $(python-typer-slim)-check $(python-typer-slim)-install $(python-typer-slim)-modulefile
