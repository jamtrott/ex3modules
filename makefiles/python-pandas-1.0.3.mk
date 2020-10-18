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
# python-pandas-1.0.3

python-pandas-version = 1.0.3
python-pandas = python-pandas-$(python-pandas-version)
$(python-pandas)-description = Python data analysis library
$(python-pandas)-url = https://pandas.pydata.org/
$(python-pandas)-srcurl = https://github.com/pandas-dev/pandas/releases/download/v$(python-pandas-version)/pandas-$(python-pandas-version).tar.gz
$(python-pandas)-src = $(pkgsrcdir)/$(notdir $($(python-pandas)-srcurl))
$(python-pandas)-srcdir = $(pkgsrcdir)/$(python-pandas)
$(python-pandas)-builddeps = $(python) $(python-cython) $(blas) $(mpi) $(python-numpy) $(pyhon-pytz) $(python-dateutil) $(python-six) $(python-pytest)
$(python-pandas)-prereqs = $(python)  $(python-cython) $(python-numpy) $(pyhon-pytz) $(python-dateutil) $(python-six)
$(python-pandas)-modulefile = $(modulefilesdir)/$(python-pandas)
$(python-pandas)-prefix = $(pkgdir)/$(python-pandas)
$(python-pandas)-site-packages = $($(python-pandas)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-pandas)-src): $(dir $($(python-pandas)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pandas)-srcurl)

$($(python-pandas)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-pandas)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(python-pandas)-prefix)/.pkgunpack: $$($(python-pandas)-src) $($(python-pandas)-srcdir)/.markerfile $($(python-pandas)-prefix)/.markerfile
	tar -C $($(python-pandas)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pandas)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pandas)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pandas)-prefix)/.pkgunpack
	@touch $@

$($(python-pandas)-site-packages)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@)
	@touch $@

$($(python-pandas)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pandas)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pandas)-prefix)/.pkgpatch
	cd $($(python-pandas)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pandas)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pandas)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pandas)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pandas)-prefix)/.pkgbuild
	# cd $($(python-pandas)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-pandas)-builddeps) && \
	# 	python3 setup.py test
	@touch $@

$($(python-pandas)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pandas)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pandas)-prefix)/.pkgcheck $($(python-pandas)-site-packages)/.markerfile
	cd $($(python-pandas)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pandas)-builddeps) && \
		PYTHONPATH=$($(python-pandas)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pandas)-prefix)
	@touch $@

$($(python-pandas)-modulefile): $(modulefilesdir)/.markerfile $($(python-pandas)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pandas)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pandas)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pandas)-description)\"" >>$@
	echo "module-whatis \"$($(python-pandas)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pandas)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PANDAS_ROOT $($(python-pandas)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pandas)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pandas)-site-packages)" >>$@
	echo "set MSG \"$(python-pandas)\"" >>$@

$(python-pandas)-src: $($(python-pandas)-src)
$(python-pandas)-unpack: $($(python-pandas)-prefix)/.pkgunpack
$(python-pandas)-patch: $($(python-pandas)-prefix)/.pkgpatch
$(python-pandas)-build: $($(python-pandas)-prefix)/.pkgbuild
$(python-pandas)-check: $($(python-pandas)-prefix)/.pkgcheck
$(python-pandas)-install: $($(python-pandas)-prefix)/.pkginstall
$(python-pandas)-modulefile: $($(python-pandas)-modulefile)
$(python-pandas)-clean:
	rm -rf $($(python-pandas)-modulefile)
	rm -rf $($(python-pandas)-prefix)
	rm -rf $($(python-pandas)-srcdir)
	rm -rf $($(python-pandas)-src)
$(python-pandas): $(python-pandas)-src $(python-pandas)-unpack $(python-pandas)-patch $(python-pandas)-build $(python-pandas)-check $(python-pandas)-install $(python-pandas)-modulefile
