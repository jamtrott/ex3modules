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
# python-numpy-1.19.2

python-numpy-version = 1.19.2
python-numpy = python-numpy-$(python-numpy-version)
$(python-numpy)-description = Fundamental package for scientific computing with Python
$(python-numpy)-url = https://www.numpy.org/
$(python-numpy)-srcurl = https://github.com/numpy/numpy/releases/download/v$(python-numpy-version)/numpy-$(python-numpy-version).tar.gz
$(python-numpy)-src = $(pkgsrcdir)/$(notdir $($(python-numpy)-srcurl))
$(python-numpy)-srcdir = $(pkgsrcdir)/$(python-numpy)
$(python-numpy)-builddeps = $(python) $(python-cython) $(blas) $(fftw) $(suitesparse) $(python-pip)
$(python-numpy)-prereqs = $(python) $(blas) $(fftw) $(suitesparse)
ifneq ($(blas),$(openblas))
# OpenBLAS already contains LAPACK routines, so there is no need to
# add LAPACK as well.
$(python-numpy)-builddeps += $(lapack)
$(python-numpy)-prereqs += $(lapack)
endif
$(python-numpy)-modulefile = $(modulefilesdir)/$(python-numpy)
$(python-numpy)-prefix = $(pkgdir)/$(python-numpy)
$(python-numpy)-site-packages = $($(python-numpy)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-numpy)-src): $(dir $($(python-numpy)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-numpy)-srcurl)

$($(python-numpy)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-numpy)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-numpy)-prefix)/.pkgunpack: $$($(python-numpy)-src) $($(python-numpy)-srcdir)/.markerfile $($(python-numpy)-prefix)/.markerfile $$(foreach dep,$$($(python-numpy)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-numpy)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-numpy)-srcdir)/site.cfg: $$(foreach dep,$$($(python-numpy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numpy)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo '[DEFAULT]' >>$@.tmp
	@echo 'library_dirs =' >>$@.tmp
	@echo 'include_dirs =' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '[atlas]' >>$@.tmp
	@echo '' >>$@.tmp
ifeq ($(blas),$(netlib-blas))
	@echo '[blas]' >>$@.tmp
	@echo 'libraries = cblas' >>$@.tmp
	@echo 'library_dirs = $($(cblas)-prefix)/lib:$($(netlib-blas)-prefix)/lib' >>$@.tmp
	@echo 'include_dirs = $($(cblas)-prefix)/include' >>$@.tmp
	@echo 'runtime_library_dirs = $($(cblas)-prefix)/lib:$($(netlib-blas)-prefix)/lib' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '[lapack]' >>$@.tmp
	@echo 'libraries = lapack' >>$@.tmp
	@echo 'library_dirs = $($(lapack)-prefix)/lib' >>$@.tmp
	@echo 'include_dirs = $($(lapack)-prefix)/include' >>$@.tmp
	@echo 'runtime_library_dirs = $($(lapack)-prefix)/lib' >>$@.tmp
else ifeq ($(blas),$(openblas))
	@echo '' >>$@.tmp
	@echo '[openblas]' >>$@.tmp
	@echo 'libraries = openblas' >>$@.tmp
	@echo 'library_dirs = $($(openblas)-prefix)/lib' >>$@.tmp
	@echo 'include_dirs = $($(openblas)-prefix)/include' >>$@.tmp
	@echo 'runtime_library_dirs = $($(openblas)-prefix)/lib' >>$@.tmp
else
$(error Unsupported BLAS library)
endif
	@echo '' >>$@.tmp
	@echo '[amd]' >>$@.tmp
	@echo 'libraries = amd' >>$@.tmp
	@echo 'library_dirs = $($(suitesparse)-prefix)/lib' >>$@.tmp
	@echo 'include_dirs = $($(suitesparse)-prefix)/include' >>$@.tmp
	@echo 'runtime_library_dirs = $($(suitesparse)-prefix)/lib' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '[umfpack]' >>$@.tmp
	@echo 'libraries = umfpack' >>$@.tmp
	@echo 'library_dirs = $($(suitesparse)-prefix)/lib' >>$@.tmp
	@echo 'include_dirs = $($(suitesparse)-prefix)/include' >>$@.tmp
	@echo 'runtime_library_dirs = $($(suitesparse)-prefix)/lib' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '[fftw]' >>$@.tmp
	@echo 'libraries = fftw3' >>$@.tmp
	@echo 'library_dirs = $($(fftw)-prefix)/lib' >>$@.tmp
	@echo 'include_dirs = $($(fftw)-prefix)/include' >>$@.tmp
	@echo 'runtime_library_dirs = $($(fftw)-prefix)/lib' >>$@.tmp
	@mv $@.tmp $@

$($(python-numpy)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numpy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numpy)-prefix)/.pkgunpack $($(python-numpy)-srcdir)/site.cfg
	@touch $@

$($(python-numpy)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-numpy)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numpy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numpy)-prefix)/.pkgpatch
	cd $($(python-numpy)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-numpy)-builddeps) && \
		NPY_BLAS_ORDER=openblas,blas NPY_LAPACK_ORDER=openblas,lapack $(PYTHON) setup.py build
	@touch $@

$($(python-numpy)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numpy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numpy)-prefix)/.pkgbuild
# Requires pytest
#	 cd $($(python-numpy)-srcdir) && \
#	 	$(MODULE) use $(modulefilesdir) && \
#	 	$(MODULE) load $($(python-numpy)-builddeps) && \
#	 	$(PYTHON) runtests.py -v -m full
	@touch $@

$($(python-numpy)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-numpy)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-numpy)-prefix)/.pkgcheck $($(python-numpy)-site-packages)/.markerfile
	cd $($(python-numpy)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-numpy)-builddeps) && \
		PYTHONPATH=$($(python-numpy)-site-packages):$${PYTHONPATH} \
		NPY_BLAS_ORDER=openblas,blas NPY_LAPACK_ORDER=openblas,lapack $(PYTHON) -m pip install . --ignore-installed --prefix=$($(python-numpy)-prefix)
	@touch $@

$($(python-numpy)-modulefile): $(modulefilesdir)/.markerfile $($(python-numpy)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-numpy)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-numpy)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-numpy)-description)\"" >>$@
	echo "module-whatis \"$($(python-numpy)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-numpy)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_NUMPY_ROOT $($(python-numpy)-prefix)" >>$@
	echo "prepend-path PATH $($(python-numpy)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-numpy)-site-packages)" >>$@
	echo "set MSG \"$(python-numpy)\"" >>$@

$(python-numpy)-src: $($(python-numpy)-src)
$(python-numpy)-unpack: $($(python-numpy)-prefix)/.pkgunpack
$(python-numpy)-patch: $($(python-numpy)-prefix)/.pkgpatch
$(python-numpy)-build: $($(python-numpy)-prefix)/.pkgbuild
$(python-numpy)-check: $($(python-numpy)-prefix)/.pkgcheck
$(python-numpy)-install: $($(python-numpy)-prefix)/.pkginstall
$(python-numpy)-modulefile: $($(python-numpy)-modulefile)
$(python-numpy)-clean:
	rm -rf $($(python-numpy)-modulefile)
	rm -rf $($(python-numpy)-prefix)
	rm -rf $($(python-numpy)-srcdir)
	rm -rf $($(python-numpy)-src)
$(python-numpy): $(python-numpy)-src $(python-numpy)-unpack $(python-numpy)-patch $(python-numpy)-build $(python-numpy)-check $(python-numpy)-install $(python-numpy)-modulefile
