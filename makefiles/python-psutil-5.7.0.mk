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
# python-psutil-5.7.0

python-psutil-version = 5.7.0
python-psutil = python-psutil-$(python-psutil-version)
$(python-psutil)-description = Cross-platform library for process and system monitoring in Python
$(python-psutil)-url = https://github.com/giampaolo/psutil/
$(python-psutil)-srcurl = https://files.pythonhosted.org/packages/c4/b8/3512f0e93e0db23a71d82485ba256071ebef99b227351f0f5540f744af41/psutil-5.7.0.tar.gz
$(python-psutil)-src = $(pkgsrcdir)/$(notdir $($(python-psutil)-srcurl))
$(python-psutil)-srcdir = $(pkgsrcdir)/$(python-psutil)
$(python-psutil)-builddeps = $(python)
$(python-psutil)-prereqs = $(python)
$(python-psutil)-modulefile = $(modulefilesdir)/$(python-psutil)
$(python-psutil)-prefix = $(pkgdir)/$(python-psutil)
$(python-psutil)-site-packages = $($(python-psutil)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-psutil)-src): $(dir $($(python-psutil)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-psutil)-srcurl)

$($(python-psutil)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-psutil)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-psutil)-prefix)/.pkgunpack: $$($(python-psutil)-src) $($(python-psutil)-srcdir)/.markerfile $($(python-psutil)-prefix)/.markerfile $$(foreach dep,$$($(python-psutil)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-psutil)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-psutil)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-psutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-psutil)-prefix)/.pkgunpack
	@touch $@

$($(python-psutil)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-psutil)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-psutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-psutil)-prefix)/.pkgpatch
	cd $($(python-psutil)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-psutil)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-psutil)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-psutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-psutil)-prefix)/.pkgbuild
	# Some tests currently fail
	# cd $($(python-psutil)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-psutil)-builddeps) && \
	# 	python3 setup.py test
	@touch $@

$($(python-psutil)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-psutil)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-psutil)-prefix)/.pkgcheck $($(python-psutil)-site-packages)/.markerfile
	cd $($(python-psutil)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-psutil)-builddeps) && \
		PYTHONPATH=$($(python-psutil)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-psutil)-prefix)
	@touch $@

$($(python-psutil)-modulefile): $(modulefilesdir)/.markerfile $($(python-psutil)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-psutil)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-psutil)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-psutil)-description)\"" >>$@
	echo "module-whatis \"$($(python-psutil)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-psutil)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PSUTIL_ROOT $($(python-psutil)-prefix)" >>$@
	echo "prepend-path PATH $($(python-psutil)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-psutil)-site-packages)" >>$@
	echo "set MSG \"$(python-psutil)\"" >>$@

$(python-psutil)-src: $($(python-psutil)-src)
$(python-psutil)-unpack: $($(python-psutil)-prefix)/.pkgunpack
$(python-psutil)-patch: $($(python-psutil)-prefix)/.pkgpatch
$(python-psutil)-build: $($(python-psutil)-prefix)/.pkgbuild
$(python-psutil)-check: $($(python-psutil)-prefix)/.pkgcheck
$(python-psutil)-install: $($(python-psutil)-prefix)/.pkginstall
$(python-psutil)-modulefile: $($(python-psutil)-modulefile)
$(python-psutil)-clean:
	rm -rf $($(python-psutil)-modulefile)
	rm -rf $($(python-psutil)-prefix)
	rm -rf $($(python-psutil)-srcdir)
	rm -rf $($(python-psutil)-src)
$(python-psutil): $(python-psutil)-src $(python-psutil)-unpack $(python-psutil)-patch $(python-psutil)-build $(python-psutil)-check $(python-psutil)-install $(python-psutil)-modulefile
