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
# python-tblib-3.2.2

python-tblib-version = 3.2.2
python-tblib = python-tblib-$(python-tblib-version)
$(python-tblib)-description = Traceback serialization library
$(python-tblib)-url = https://github.com/ionelmc/python-tblib
$(python-tblib)-srcurl = https://files.pythonhosted.org/packages/f4/8a/14c15ae154895cc131174f858c707790d416c444fc69f93918adfd8c4c0b/tblib-3.2.2.tar.gz
$(python-tblib)-src = $(pkgsrcdir)/$(notdir $($(python-tblib)-srcurl))
$(python-tblib)-builddeps = $(python) $(python-pip)
$(python-tblib)-prereqs = $(python)
$(python-tblib)-srcdir = $(pkgsrcdir)/$(python-tblib)
$(python-tblib)-modulefile = $(modulefilesdir)/$(python-tblib)
$(python-tblib)-prefix = $(pkgdir)/$(python-tblib)

$($(python-tblib)-src): $(dir $($(python-tblib)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-tblib)-srcurl)

$($(python-tblib)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tblib)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-tblib)-prefix)/.pkgunpack: $$($(python-tblib)-src) $($(python-tblib)-srcdir)/.markerfile $($(python-tblib)-prefix)/.markerfile $$(foreach dep,$$($(python-tblib)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-tblib)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-tblib)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tblib)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tblib)-prefix)/.pkgunpack
	@touch $@

$($(python-tblib)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tblib)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tblib)-prefix)/.pkgpatch
	@touch $@

$($(python-tblib)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tblib)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tblib)-prefix)/.pkgbuild
	@touch $@

$($(python-tblib)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-tblib)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-tblib)-prefix)/.pkgcheck
	cd $($(python-tblib)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-tblib)-builddeps) && \
		PYTHONPATH=$($(python-tblib)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-tblib)-prefix)
	@touch $@

$($(python-tblib)-modulefile): $(modulefilesdir)/.markerfile $($(python-tblib)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-tblib)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-tblib)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-tblib)-description)\"" >>$@
	echo "module-whatis \"$($(python-tblib)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-tblib)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_TBLIB_ROOT $($(python-tblib)-prefix)" >>$@
	echo "prepend-path PATH $($(python-tblib)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-tblib)-prefix)" >>$@
	echo "set MSG \"$(python-tblib)\"" >>$@

$(python-tblib)-src: $($(python-tblib)-src)
$(python-tblib)-unpack: $($(python-tblib)-prefix)/.pkgunpack
$(python-tblib)-patch: $($(python-tblib)-prefix)/.pkgpatch
$(python-tblib)-build: $($(python-tblib)-prefix)/.pkgbuild
$(python-tblib)-check: $($(python-tblib)-prefix)/.pkgcheck
$(python-tblib)-install: $($(python-tblib)-prefix)/.pkginstall
$(python-tblib)-modulefile: $($(python-tblib)-modulefile)
$(python-tblib)-clean:
	rm -rf $($(python-tblib)-modulefile)
	rm -rf $($(python-tblib)-prefix)
	rm -rf $($(python-tblib)-srcdir)
	rm -rf $($(python-tblib)-src)
$(python-tblib): $(python-tblib)-src $(python-tblib)-unpack $(python-tblib)-patch $(python-tblib)-build $(python-tblib)-check $(python-tblib)-install $(python-tblib)-modulefile
