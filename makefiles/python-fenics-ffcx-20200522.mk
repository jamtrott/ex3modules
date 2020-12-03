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
# python-fenics-ffcx-20200522

python-fenics-ffcx-20200522-version = 20200522
python-fenics-ffcx-20200522 = python-fenics-ffcx-$(python-fenics-ffcx-20200522-version)
$(python-fenics-ffcx-20200522)-description = FEniCS Project: FEniCS Form Compiler (Experimental)
$(python-fenics-ffcx-20200522)-url = https://github.com/FEniCS/ffcx/
$(python-fenics-ffcx-20200522)-srcurl = https://github.com/FEniCS/ffcx/archive/91671fecc0e4e356f355eb9ce7a8b6a1d1734dd5.zip
$(python-fenics-ffcx-20200522)-src = $(pkgsrcdir)/$(notdir $($(python-fenics-ffcx-20200522)-srcurl))
$(python-fenics-ffcx-20200522)-srcdir = $(pkgsrcdir)/$(python-fenics-ffcx-20200522)
$(python-fenics-ffcx-20200522)-builddir = $($(python-fenics-ffcx-20200522)-srcdir)/ffcx-91671fecc0e4e356f355eb9ce7a8b6a1d1734dd5
$(python-fenics-ffcx-20200522)-builddeps = $(python) $(blas) $(mpi) $(python-numpy) $(python-mpmath) $(python-sympy-1.4) $(python-fenics-dijitso-2019) $(python-fenics-fiat-20200518) $(python-fenics-ufl-20200512)
$(python-fenics-ffcx-20200522)-prereqs = $(python) $(python-numpy) $(python-mpmath) $(python-sympy-1.4) $(python-fenics-dijitso-2019) $(python-fenics-fiat-20200518) $(python-fenics-ufl-20200512)
$(python-fenics-ffcx-20200522)-modulefile = $(modulefilesdir)/$(python-fenics-ffcx-20200522)
$(python-fenics-ffcx-20200522)-prefix = $(pkgdir)/$(python-fenics-ffcx-20200522)
$(python-fenics-ffcx-20200522)-site-packages = $($(python-fenics-ffcx-20200522)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-fenics-ffcx-20200522)-src): $(dir $($(python-fenics-ffcx-20200522)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-fenics-ffcx-20200522)-srcurl)

$($(python-fenics-ffcx-20200522)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

ifneq ($($(python-fenics-ffcx-20200522)-builddir),$($(python-fenics-ffcx-20200522)-srcdir))
$($(python-fenics-ffcx-20200522)-builddir)/.markerfile: $($(python-fenics-ffcx-20200522)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(python-fenics-ffcx-20200522)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-fenics-ffcx-20200522)-prefix)/.pkgunpack: $$($(python-fenics-ffcx-20200522)-src) $($(python-fenics-ffcx-20200522)-srcdir)/.markerfile $($(python-fenics-ffcx-20200522)-prefix)/.markerfile
	cd $($(python-fenics-ffcx-20200522)-srcdir) && unzip -o $<
	@touch $@

$($(python-fenics-ffcx-20200522)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ffcx-20200522)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ffcx-20200522)-prefix)/.pkgunpack
	@touch $@

$($(python-fenics-ffcx-20200522)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ffcx-20200522)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ffcx-20200522)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ffcx-20200522)-prefix)/.pkgpatch $($(python-fenics-ffcx-20200522)-builddir)/.markerfile
	cd $($(python-fenics-ffcx-20200522)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ffcx-20200522)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-fenics-ffcx-20200522)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ffcx-20200522)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ffcx-20200522)-prefix)/.pkgbuild $($(python-fenics-ffcx-20200522)-builddir)/.markerfile
#	cd $($(python-fenics-ffcx-20200522)-builddir) && \
#		$(MODULE) use $(modulefilesdir) && \
#		$(MODULE) load $($(python-fenics-ffcx-20200522)-builddeps) && \
#		python3 test/test.py
	@touch $@

$($(python-fenics-ffcx-20200522)-prefix)/include/.markerfile: $($(python-fenics-ffcx-20200522)-prefix)/.pkgcheck
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-fenics-ffcx-20200522)-prefix)/include/ufc.h: $($(python-fenics-ffcx-20200522)-prefix)/include/.markerfile $($(python-fenics-ffcx-20200522)-prefix)/.pkgcheck
	$(INSTALL) $($(python-fenics-ffcx-20200522)-builddir)/ffcx/codegeneration/ufc.h $@

$($(python-fenics-ffcx-20200522)-prefix)/include/ufc_geometry.h: $($(python-fenics-ffcx-20200522)-prefix)/include/.markerfile $($(python-fenics-ffcx-20200522)-prefix)/.pkgcheck
	$(INSTALL) $($(python-fenics-ffcx-20200522)-builddir)/ffcx/codegeneration/ufc_geometry.h $@

$($(python-fenics-ffcx-20200522)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-fenics-ffcx-20200522)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-fenics-ffcx-20200522)-prefix)/.pkgcheck $($(python-fenics-ffcx-20200522)-site-packages)/.markerfile $($(python-fenics-ffcx-20200522)-prefix)/include/ufc.h $($(python-fenics-ffcx-20200522)-prefix)/include/ufc_geometry.h $($(python-fenics-ffcx-20200522)-builddir)/.markerfile
	cd $($(python-fenics-ffcx-20200522)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-fenics-ffcx-20200522)-builddeps) && \
		PYTHONPATH=$($(python-fenics-ffcx-20200522)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-fenics-ffcx-20200522)-prefix)
	@touch $@

$($(python-fenics-ffcx-20200522)-modulefile): $(modulefilesdir)/.markerfile $($(python-fenics-ffcx-20200522)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-fenics-ffcx-20200522)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-fenics-ffcx-20200522)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-fenics-ffcx-20200522)-description)\"" >>$@
	echo "module-whatis \"$($(python-fenics-ffcx-20200522)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-fenics-ffcx-20200522)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_FENICS_FFCX_ROOT $($(python-fenics-ffcx-20200522)-prefix)" >>$@
	echo "prepend-path PATH $($(python-fenics-ffcx-20200522)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(python-fenics-ffcx-20200522)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(python-fenics-ffcx-20200522)-prefix)/include" >>$@
	echo "prepend-path PYTHONPATH $($(python-fenics-ffcx-20200522)-site-packages)" >>$@
	echo "set MSG \"$(python-fenics-ffcx-20200522)\"" >>$@

$(python-fenics-ffcx-20200522)-src: $($(python-fenics-ffcx-20200522)-src)
$(python-fenics-ffcx-20200522)-unpack: $($(python-fenics-ffcx-20200522)-prefix)/.pkgunpack
$(python-fenics-ffcx-20200522)-patch: $($(python-fenics-ffcx-20200522)-prefix)/.pkgpatch
$(python-fenics-ffcx-20200522)-build: $($(python-fenics-ffcx-20200522)-prefix)/.pkgbuild
$(python-fenics-ffcx-20200522)-check: $($(python-fenics-ffcx-20200522)-prefix)/.pkgcheck
$(python-fenics-ffcx-20200522)-install: $($(python-fenics-ffcx-20200522)-prefix)/.pkginstall
$(python-fenics-ffcx-20200522)-modulefile: $($(python-fenics-ffcx-20200522)-modulefile)
$(python-fenics-ffcx-20200522)-clean:
	rm -rf $($(python-fenics-ffcx-20200522)-modulefile)
	rm -rf $($(python-fenics-ffcx-20200522)-prefix)
	rm -rf $($(python-fenics-ffcx-20200522)-builddir)
	rm -rf $($(python-fenics-ffcx-20200522)-srcdir)
	rm -rf $($(python-fenics-ffcx-20200522)-src)
$(python-fenics-ffcx-20200522): $(python-fenics-ffcx-20200522)-src $(python-fenics-ffcx-20200522)-unpack $(python-fenics-ffcx-20200522)-patch $(python-fenics-ffcx-20200522)-build $(python-fenics-ffcx-20200522)-check $(python-fenics-ffcx-20200522)-install $(python-fenics-ffcx-20200522)-modulefile
