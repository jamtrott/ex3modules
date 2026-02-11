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
# python-pyarrow-23.0.0

python-pyarrow-version = 23.0.0
python-pyarrow = python-pyarrow-$(python-pyarrow-version)
$(python-pyarrow)-description = Python library for Apache Arrow
$(python-pyarrow)-url = https://arrow.apache.org/
$(python-pyarrow)-srcurl = https://files.pythonhosted.org/packages/01/33/ffd9c3eb087fa41dd79c3cf20c4c0ae3cdb877c4f8e1107a446006344924/pyarrow-23.0.0.tar.gz
$(python-pyarrow)-src = $(pkgsrcdir)/$(notdir $($(python-pyarrow)-srcurl))
$(python-pyarrow)-builddeps = $(python) $(python-pip) $(cmake) $(python-numpy) $(python-cython) $(python-setuptools_scm) $(apache-arrow)
$(python-pyarrow)-prereqs = $(python) $(python-numpy) $(apache-arrow)
$(python-pyarrow)-srcdir = $(pkgsrcdir)/$(python-pyarrow)
$(python-pyarrow)-modulefile = $(modulefilesdir)/$(python-pyarrow)
$(python-pyarrow)-prefix = $(pkgdir)/$(python-pyarrow)

$($(python-pyarrow)-src): $(dir $($(python-pyarrow)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pyarrow)-srcurl)

$($(python-pyarrow)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyarrow)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pyarrow)-prefix)/.pkgunpack: $$($(python-pyarrow)-src) $($(python-pyarrow)-srcdir)/.markerfile $($(python-pyarrow)-prefix)/.markerfile $$(foreach dep,$$($(python-pyarrow)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pyarrow)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pyarrow)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyarrow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyarrow)-prefix)/.pkgunpack
	@touch $@

$($(python-pyarrow)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyarrow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyarrow)-prefix)/.pkgpatch
	@touch $@

$($(python-pyarrow)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyarrow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyarrow)-prefix)/.pkgbuild
	@touch $@

$($(python-pyarrow)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pyarrow)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pyarrow)-prefix)/.pkgcheck
	cd $($(python-pyarrow)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pyarrow)-builddeps) && \
		PYTHONPATH=$($(python-pyarrow)-prefix):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-pyarrow)-prefix)
	@touch $@

$($(python-pyarrow)-modulefile): $(modulefilesdir)/.markerfile $($(python-pyarrow)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pyarrow)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pyarrow)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pyarrow)-description)\"" >>$@
	echo "module-whatis \"$($(python-pyarrow)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pyarrow)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYARROW_ROOT $($(python-pyarrow)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pyarrow)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pyarrow)-prefix)" >>$@
	echo "set MSG \"$(python-pyarrow)\"" >>$@

$(python-pyarrow)-src: $($(python-pyarrow)-src)
$(python-pyarrow)-unpack: $($(python-pyarrow)-prefix)/.pkgunpack
$(python-pyarrow)-patch: $($(python-pyarrow)-prefix)/.pkgpatch
$(python-pyarrow)-build: $($(python-pyarrow)-prefix)/.pkgbuild
$(python-pyarrow)-check: $($(python-pyarrow)-prefix)/.pkgcheck
$(python-pyarrow)-install: $($(python-pyarrow)-prefix)/.pkginstall
$(python-pyarrow)-modulefile: $($(python-pyarrow)-modulefile)
$(python-pyarrow)-clean:
	rm -rf $($(python-pyarrow)-modulefile)
	rm -rf $($(python-pyarrow)-prefix)
	rm -rf $($(python-pyarrow)-srcdir)
	rm -rf $($(python-pyarrow)-src)
$(python-pyarrow): $(python-pyarrow)-src $(python-pyarrow)-unpack $(python-pyarrow)-patch $(python-pyarrow)-build $(python-pyarrow)-check $(python-pyarrow)-install $(python-pyarrow)-modulefile
