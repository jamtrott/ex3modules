# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# python-marshmallow-3.17.1

python-marshmallow-version = 3.17.1
python-marshmallow = python-marshmallow-$(python-marshmallow-version)
$(python-marshmallow)-description = A lightweight library for converting complex datatypes to and from native Python datatypes
$(python-marshmallow)-url =
$(python-marshmallow)-srcurl = https://files.pythonhosted.org/packages/fa/12/f69c512928f2974f050cfb08c437b57b643586447ba0baaa99ef1fc44c7a/marshmallow-3.17.1.tar.gz
$(python-marshmallow)-src = $(pkgsrcdir)/$(notdir $($(python-marshmallow)-srcurl))
$(python-marshmallow)-builddeps = $(python) $(python-pip) $(python-pytest) $(python-simplejson) $(python-pytz)
$(python-marshmallow)-prereqs = $(python)
$(python-marshmallow)-srcdir = $(pkgsrcdir)/$(python-marshmallow)
$(python-marshmallow)-modulefile = $(modulefilesdir)/$(python-marshmallow)
$(python-marshmallow)-prefix = $(pkgdir)/$(python-marshmallow)
$(python-marshmallow)-site-packages = $($(python-marshmallow)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-marshmallow)-src): $(dir $($(python-marshmallow)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-marshmallow)-srcurl)

$($(python-marshmallow)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-marshmallow)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-marshmallow)-prefix)/.pkgunpack: $$($(python-marshmallow)-src) $($(python-marshmallow)-srcdir)/.markerfile $($(python-marshmallow)-prefix)/.markerfile $$(foreach dep,$$($(python-marshmallow)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-marshmallow)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-marshmallow)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-marshmallow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-marshmallow)-prefix)/.pkgunpack
	@touch $@

$($(python-marshmallow)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-marshmallow)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-marshmallow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-marshmallow)-prefix)/.pkgpatch
	cd $($(python-marshmallow)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-marshmallow)-builddeps) && \
		$(PYTHON) setup.py build
	@touch $@

$($(python-marshmallow)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-marshmallow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-marshmallow)-prefix)/.pkgbuild
	cd $($(python-marshmallow)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-marshmallow)-builddeps) && \
		$(PYTHON) setup.py test
	@touch $@

$($(python-marshmallow)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-marshmallow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-marshmallow)-prefix)/.pkgcheck $($(python-marshmallow)-site-packages)/.markerfile
	cd $($(python-marshmallow)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-marshmallow)-builddeps) && \
		PYTHONPATH=$($(python-marshmallow)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-marshmallow)-prefix)
	@touch $@

$($(python-marshmallow)-modulefile): $(modulefilesdir)/.markerfile $($(python-marshmallow)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-marshmallow)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-marshmallow)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-marshmallow)-description)\"" >>$@
	echo "module-whatis \"$($(python-marshmallow)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-marshmallow)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_MARSHMALLOW_ROOT $($(python-marshmallow)-prefix)" >>$@
	echo "prepend-path PATH $($(python-marshmallow)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-marshmallow)-site-packages)" >>$@
	echo "set MSG \"$(python-marshmallow)\"" >>$@

$(python-marshmallow)-src: $($(python-marshmallow)-src)
$(python-marshmallow)-unpack: $($(python-marshmallow)-prefix)/.pkgunpack
$(python-marshmallow)-patch: $($(python-marshmallow)-prefix)/.pkgpatch
$(python-marshmallow)-build: $($(python-marshmallow)-prefix)/.pkgbuild
$(python-marshmallow)-check: $($(python-marshmallow)-prefix)/.pkgcheck
$(python-marshmallow)-install: $($(python-marshmallow)-prefix)/.pkginstall
$(python-marshmallow)-modulefile: $($(python-marshmallow)-modulefile)
$(python-marshmallow)-clean:
	rm -rf $($(python-marshmallow)-modulefile)
	rm -rf $($(python-marshmallow)-prefix)
	rm -rf $($(python-marshmallow)-srcdir)
	rm -rf $($(python-marshmallow)-src)
$(python-marshmallow): $(python-marshmallow)-src $(python-marshmallow)-unpack $(python-marshmallow)-patch $(python-marshmallow)-build $(python-marshmallow)-check $(python-marshmallow)-install $(python-marshmallow)-modulefile
