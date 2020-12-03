# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2020 James D. Trotter
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
# python-mpmath-1.1.0

python-mpmath-version = 1.1.0
python-mpmath = python-mpmath-$(python-mpmath-version)
$(python-mpmath)-description = Python library for arbitrary-precision floating-point arithmetic
$(python-mpmath)-url = https://www.mpmath.org/
$(python-mpmath)-srcurl = https://files.pythonhosted.org/packages/ca/63/3384ebb3b51af9610086b23ea976e6d27d6d97bf140a76a365bd77a3eb32/mpmath-1.1.0.tar.gz
$(python-mpmath)-src = $(pkgsrcdir)/$(notdir $($(python-mpmath)-srcurl))
$(python-mpmath)-srcdir = $(pkgsrcdir)/$(python-mpmath)
$(python-mpmath)-builddeps = $(python)
$(python-mpmath)-prereqs = $(python)
$(python-mpmath)-modulefile = $(modulefilesdir)/$(python-mpmath)
$(python-mpmath)-prefix = $(pkgdir)/$(python-mpmath)
$(python-mpmath)-site-packages = $($(python-mpmath)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-mpmath)-src): $(dir $($(python-mpmath)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-mpmath)-srcurl)

$($(python-mpmath)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-mpmath)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-mpmath)-prefix)/.pkgunpack: $$($(python-mpmath)-src) $($(python-mpmath)-srcdir)/.markerfile $($(python-mpmath)-prefix)/.markerfile
	tar -C $($(python-mpmath)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-mpmath)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mpmath)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mpmath)-prefix)/.pkgunpack
	@touch $@

$($(python-mpmath)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-mpmath)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mpmath)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mpmath)-prefix)/.pkgpatch
	cd $($(python-mpmath)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-mpmath)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-mpmath)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mpmath)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mpmath)-prefix)/.pkgbuild
	@touch $@

$($(python-mpmath)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-mpmath)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-mpmath)-prefix)/.pkgcheck $($(python-mpmath)-site-packages)/.markerfile
	cd $($(python-mpmath)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-mpmath)-builddeps) && \
		PYTHONPATH=$($(python-mpmath)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-mpmath)-prefix)
	@touch $@

$($(python-mpmath)-modulefile): $(modulefilesdir)/.markerfile $($(python-mpmath)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-mpmath)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-mpmath)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-mpmath)-description)\"" >>$@
	echo "module-whatis \"$($(python-mpmath)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-mpmath)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_MPMATH_ROOT $($(python-mpmath)-prefix)" >>$@
	echo "prepend-path PATH $($(python-mpmath)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-mpmath)-site-packages)" >>$@
	echo "set MSG \"$(python-mpmath)\"" >>$@

$(python-mpmath)-src: $($(python-mpmath)-src)
$(python-mpmath)-unpack: $($(python-mpmath)-prefix)/.pkgunpack
$(python-mpmath)-patch: $($(python-mpmath)-prefix)/.pkgpatch
$(python-mpmath)-build: $($(python-mpmath)-prefix)/.pkgbuild
$(python-mpmath)-check: $($(python-mpmath)-prefix)/.pkgcheck
$(python-mpmath)-install: $($(python-mpmath)-prefix)/.pkginstall
$(python-mpmath)-modulefile: $($(python-mpmath)-modulefile)
$(python-mpmath)-clean:
	rm -rf $($(python-mpmath)-modulefile)
	rm -rf $($(python-mpmath)-prefix)
	rm -rf $($(python-mpmath)-srcdir)
	rm -rf $($(python-mpmath)-src)
$(python-mpmath): $(python-mpmath)-src $(python-mpmath)-unpack $(python-mpmath)-patch $(python-mpmath)-build $(python-mpmath)-check $(python-mpmath)-install $(python-mpmath)-modulefile
