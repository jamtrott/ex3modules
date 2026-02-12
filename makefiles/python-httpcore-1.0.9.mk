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
# python-httpcore-1.0.9

python-httpcore-version = 1.0.9
python-httpcore = python-httpcore-$(python-httpcore-version)
$(python-httpcore)-description = A minimal low-level HTTP client
$(python-httpcore)-url = https://www.encode.io/httpcore/
$(python-httpcore)-srcurl = https://files.pythonhosted.org/packages/06/94/82699a10bca87a5556c9c59b5963f2d039dbd239f25bc2a63907a05a14cb/httpcore-1.0.9.tar.gz
$(python-httpcore)-src = $(pkgsrcdir)/$(notdir $($(python-httpcore)-srcurl))
$(python-httpcore)-builddeps = $(python) $(python-pip) $(python-h11)
$(python-httpcore)-prereqs = $(python) $(python-h11)
$(python-httpcore)-srcdir = $(pkgsrcdir)/$(python-httpcore)
$(python-httpcore)-modulefile = $(modulefilesdir)/$(python-httpcore)
$(python-httpcore)-prefix = $(pkgdir)/$(python-httpcore)

$($(python-httpcore)-src): $(dir $($(python-httpcore)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-httpcore)-srcurl)

$($(python-httpcore)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-httpcore)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-httpcore)-prefix)/.pkgunpack: $$($(python-httpcore)-src) $($(python-httpcore)-srcdir)/.markerfile $($(python-httpcore)-prefix)/.markerfile $$(foreach dep,$$($(python-httpcore)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-httpcore)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-httpcore)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-httpcore)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-httpcore)-prefix)/.pkgunpack
	@touch $@

$($(python-httpcore)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-httpcore)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-httpcore)-prefix)/.pkgpatch
	@touch $@

$($(python-httpcore)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-httpcore)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-httpcore)-prefix)/.pkgbuild
	@touch $@

$($(python-httpcore)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-httpcore)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-httpcore)-prefix)/.pkgcheck
	cd $($(python-httpcore)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-httpcore)-builddeps) && \
		PYTHONPATH=$($(python-httpcore)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-httpcore)-prefix)
	@touch $@

$($(python-httpcore)-modulefile): $(modulefilesdir)/.markerfile $($(python-httpcore)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-httpcore)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-httpcore)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-httpcore)-description)\"" >>$@
	echo "module-whatis \"$($(python-httpcore)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-httpcore)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_HTTPCORE_ROOT $($(python-httpcore)-prefix)" >>$@
	echo "prepend-path PATH $($(python-httpcore)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-httpcore)-prefix)" >>$@
	echo "set MSG \"$(python-httpcore)\"" >>$@

$(python-httpcore)-src: $($(python-httpcore)-src)
$(python-httpcore)-unpack: $($(python-httpcore)-prefix)/.pkgunpack
$(python-httpcore)-patch: $($(python-httpcore)-prefix)/.pkgpatch
$(python-httpcore)-build: $($(python-httpcore)-prefix)/.pkgbuild
$(python-httpcore)-check: $($(python-httpcore)-prefix)/.pkgcheck
$(python-httpcore)-install: $($(python-httpcore)-prefix)/.pkginstall
$(python-httpcore)-modulefile: $($(python-httpcore)-modulefile)
$(python-httpcore)-clean:
	rm -rf $($(python-httpcore)-modulefile)
	rm -rf $($(python-httpcore)-prefix)
	rm -rf $($(python-httpcore)-srcdir)
	rm -rf $($(python-httpcore)-src)
$(python-httpcore): $(python-httpcore)-src $(python-httpcore)-unpack $(python-httpcore)-patch $(python-httpcore)-build $(python-httpcore)-check $(python-httpcore)-install $(python-httpcore)-modulefile
