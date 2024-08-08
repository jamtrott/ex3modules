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
# python-scipy-1.7.3

python-scipy-version = 1.7.3
python-scipy = python-scipy-$(python-scipy-version)
$(python-scipy)-description = Fundamental package for scientific computing with Python
$(python-scipy)-url = https://www.scipy.org/
$(python-scipy)-srcurl = https://files.pythonhosted.org/packages/61/67/1a654b96309c991762ee9bc39c363fc618076b155fe52d295211cf2536c7/scipy-1.7.3.tar.gz
$(python-scipy)-src = $(pkgsrcdir)/python-scipy-$(notdir $($(python-scipy)-srcurl))
$(python-scipy)-srcdir = $(pkgsrcdir)/$(python-scipy)
$(python-scipy)-builddeps = $(python) $(python-cython) $(openblas) $(mpi) $(python-numpy) $(python-wheel) $(pybind11) $(python-pip) $(python-pythran)
$(python-scipy)-prereqs = $(python) $(python-cython) $(python-numpy) $(openblas) $(python-pythran)
$(python-scipy)-modulefile = $(modulefilesdir)/$(python-scipy)
$(python-scipy)-prefix = $(pkgdir)/$(python-scipy)
$(python-scipy)-site-packages = $($(python-scipy)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-scipy)-src): $(dir $($(python-scipy)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-scipy)-srcurl)

$($(python-scipy)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-scipy)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-scipy)-prefix)/.pkgunpack: $$($(python-scipy)-src) $($(python-scipy)-srcdir)/.markerfile $($(python-scipy)-prefix)/.markerfile $$(foreach dep,$$($(python-scipy)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-scipy)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-scipy)-srcdir)/site.cfg: $$(foreach dep,$$($(python-scipy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-scipy)-prefix)/.pkgunpack
	cd $($(python-scipy)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-scipy)-builddeps) && \
		printf '' >$@.tmp && \
		echo "[openblas]" >>$@.tmp && \
		echo "libraries = $${BLASLIB}" >>$@.tmp && \
		echo "library_dirs = $${BLASDIR}" >>$@.tmp && \
		echo "include_dirs = $${OPENBLAS_ROOT}/include" >>$@.tmp
	mv $@.tmp $@

$($(python-scipy)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-scipy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-scipy)-prefix)/.pkgunpack $($(python-scipy)-srcdir)/site.cfg
	@touch $@

$($(python-scipy)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-scipy)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-scipy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-scipy)-prefix)/.pkgpatch
	@touch $@

$($(python-scipy)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-scipy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-scipy)-prefix)/.pkgbuild
	# cd $($(python-scipy)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-scipy)-builddeps) && \
	# 	$(PYTHON) runtests.py
	@touch $@

$($(python-scipy)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-scipy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-scipy)-prefix)/.pkgcheck $($(python-scipy)-site-packages)/.markerfile
	cd $($(python-scipy)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-scipy)-builddeps) && \
		PYTHONPATH=$($(python-scipy)-site-packages):$${PYTHONPATH} \
		$(PYTHON) -m pip install . --no-deps --ignore-installed --prefix=$($(python-scipy)-prefix)
	@touch $@

$($(python-scipy)-modulefile): $(modulefilesdir)/.markerfile $($(python-scipy)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-scipy)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-scipy)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-scipy)-description)\"" >>$@
	echo "module-whatis \"$($(python-scipy)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-scipy)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_SCIPY_ROOT $($(python-scipy)-prefix)" >>$@
	echo "prepend-path PATH $($(python-scipy)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-scipy)-site-packages)" >>$@
	echo "set MSG \"$(python-scipy)\"" >>$@

$(python-scipy)-src: $($(python-scipy)-src)
$(python-scipy)-unpack: $($(python-scipy)-prefix)/.pkgunpack
$(python-scipy)-patch: $($(python-scipy)-prefix)/.pkgpatch
$(python-scipy)-build: $($(python-scipy)-prefix)/.pkgbuild
$(python-scipy)-check: $($(python-scipy)-prefix)/.pkgcheck
$(python-scipy)-install: $($(python-scipy)-prefix)/.pkginstall
$(python-scipy)-modulefile: $($(python-scipy)-modulefile)
$(python-scipy)-clean:
	rm -rf $($(python-scipy)-modulefile)
	rm -rf $($(python-scipy)-prefix)
	rm -rf $($(python-scipy)-srcdir)
	rm -rf $($(python-scipy)-src)
$(python-scipy): $(python-scipy)-src $(python-scipy)-unpack $(python-scipy)-patch $(python-scipy)-build $(python-scipy)-check $(python-scipy)-install $(python-scipy)-modulefile
