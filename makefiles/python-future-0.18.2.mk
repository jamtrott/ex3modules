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
# python-future-0.18.2

python-future-version = 0.18.2
python-future = python-future-$(python-future-version)
$(python-future)-description = Clean single-source support for Python 3 and 2
$(python-future)-url = https://python-future.org/
$(python-future)-srcurl = https://files.pythonhosted.org/packages/45/0b/38b06fd9b92dc2b68d58b75f900e97884c45bedd2ff83203d933cf5851c9/future-0.18.2.tar.gz
$(python-future)-src = $(pkgsrcdir)/$(notdir $($(python-future)-srcurl))
$(python-future)-srcdir = $(pkgsrcdir)/$(python-future)
$(python-future)-builddeps = $(python)
$(python-future)-prereqs = $(python)
$(python-future)-modulefile = $(modulefilesdir)/$(python-future)
$(python-future)-prefix = $(pkgdir)/$(python-future)
$(python-future)-site-packages = $($(python-future)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-future)-src): $(dir $($(python-future)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-future)-srcurl)

$($(python-future)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-future)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-future)-prefix)/.pkgunpack: $$($(python-future)-src) $($(python-future)-srcdir)/.markerfile $($(python-future)-prefix)/.markerfile $$(foreach dep,$$($(python-future)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-future)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-future)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-future)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-future)-prefix)/.pkgunpack
	@touch $@

$($(python-future)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-future)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-future)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-future)-prefix)/.pkgpatch
	cd $($(python-future)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-future)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-future)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-future)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-future)-prefix)/.pkgbuild
	@touch $@

$($(python-future)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-future)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-future)-prefix)/.pkgcheck $($(python-future)-site-packages)/.markerfile
	cd $($(python-future)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-future)-builddeps) && \
		PYTHONPATH=$($(python-future)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-future)-prefix)
	@touch $@

$($(python-future)-modulefile): $(modulefilesdir)/.markerfile $($(python-future)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-future)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-future)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-future)-description)\"" >>$@
	echo "module-whatis \"$($(python-future)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-future)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FUTURE_ROOT $($(python-future)-prefix)" >>$@
	echo "prepend-path PATH $($(python-future)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-future)-site-packages)" >>$@
	echo "set MSG \"$(python-future)\"" >>$@

$(python-future)-src: $($(python-future)-src)
$(python-future)-unpack: $($(python-future)-prefix)/.pkgunpack
$(python-future)-patch: $($(python-future)-prefix)/.pkgpatch
$(python-future)-build: $($(python-future)-prefix)/.pkgbuild
$(python-future)-check: $($(python-future)-prefix)/.pkgcheck
$(python-future)-install: $($(python-future)-prefix)/.pkginstall
$(python-future)-modulefile: $($(python-future)-modulefile)
$(python-future)-clean:
	rm -rf $($(python-future)-modulefile)
	rm -rf $($(python-future)-prefix)
	rm -rf $($(python-future)-srcdir)
	rm -rf $($(python-future)-src)
$(python-future): $(python-future)-src $(python-future)-unpack $(python-future)-patch $(python-future)-build $(python-future)-check $(python-future)-install $(python-future)-modulefile
