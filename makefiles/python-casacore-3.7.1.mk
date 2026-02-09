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
# python-casacore-3.7.1

python-casacore-version = 3.7.1
python-casacore = python-casacore-$(python-casacore-version)
$(python-casacore)-description = Python bindings for casacore, a library used in radio astronomy 
$(python-casacore)-url = https://github.com/casacore/python-casacore
$(python-casacore)-srcurl = https://files.pythonhosted.org/packages/24/93/2ccc937c1609d1ab051b6ca86b51983b94d79f9f097558ba11c9023d74e3/python_casacore-3.7.1.tar.gz
$(python-casacore)-src = $(pkgsrcdir)/$(notdir $($(python-casacore)-srcurl))
$(python-casacore)-builddeps = $(python) $(python-pip) $(casacore) $(boost-python) $(python-numpy) $(cfitsio) $(wcslib)
$(python-casacore)-prereqs = $(python) $(casacore) $(boost-python) $(python-numpy) $(cfitsio) $(wcslib)
$(python-casacore)-srcdir = $(pkgsrcdir)/$(python-casacore)
$(python-casacore)-modulefile = $(modulefilesdir)/$(python-casacore)
$(python-casacore)-prefix = $(pkgdir)/$(python-casacore)

$($(python-casacore)-src): $(dir $($(python-casacore)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-casacore)-srcurl)

$($(python-casacore)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-casacore)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-casacore)-prefix)/.pkgunpack: $$($(python-casacore)-src) $($(python-casacore)-srcdir)/.markerfile $($(python-casacore)-prefix)/.markerfile $$(foreach dep,$$($(python-casacore)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-casacore)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-casacore)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-casacore)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-casacore)-prefix)/.pkgunpack
	@touch $@

$($(python-casacore)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-casacore)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-casacore)-prefix)/.pkgpatch
	# cd $($(python-casacore)-srcdir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-casacore)-builddeps) && \
	# 	$(PYTHON) setup.py build
	@touch $@

$($(python-casacore)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-casacore)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-casacore)-prefix)/.pkgbuild
	# cd $($(python-casacore)-srcdir) && \
	# 	$(MODULESINIT) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-casacore)-builddeps) && \
	# 	$(PYTHON) setup.py test
	@touch $@

$($(python-casacore)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-casacore)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-casacore)-prefix)/.pkgcheck
	cd $($(python-casacore)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-casacore)-builddeps) && \
		PYTHONPATH=$($(python-casacore)-prefix):$${PYTHONPATH} \
		CMAKE_ARGS="-DCASACORE_ROOT_DIR=$${CASACORE_ROOT}" \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --target=$($(python-casacore)-prefix)
	@touch $@

$($(python-casacore)-modulefile): $(modulefilesdir)/.markerfile $($(python-casacore)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-casacore)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-casacore)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-casacore)-description)\"" >>$@
	echo "module-whatis \"$($(python-casacore)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-casacore)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_CASACORE_ROOT $($(python-casacore)-prefix)" >>$@
	echo "prepend-path PATH $($(python-casacore)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-casacore)-prefix)" >>$@
	echo "set MSG \"$(python-casacore)\"" >>$@

$(python-casacore)-src: $($(python-casacore)-src)
$(python-casacore)-unpack: $($(python-casacore)-prefix)/.pkgunpack
$(python-casacore)-patch: $($(python-casacore)-prefix)/.pkgpatch
$(python-casacore)-build: $($(python-casacore)-prefix)/.pkgbuild
$(python-casacore)-check: $($(python-casacore)-prefix)/.pkgcheck
$(python-casacore)-install: $($(python-casacore)-prefix)/.pkginstall
$(python-casacore)-modulefile: $($(python-casacore)-modulefile)
$(python-casacore)-clean:
	rm -rf $($(python-casacore)-modulefile)
	rm -rf $($(python-casacore)-prefix)
	rm -rf $($(python-casacore)-srcdir)
	rm -rf $($(python-casacore)-src)
$(python-casacore): $(python-casacore)-src $(python-casacore)-unpack $(python-casacore)-patch $(python-casacore)-build $(python-casacore)-check $(python-casacore)-install $(python-casacore)-modulefile
