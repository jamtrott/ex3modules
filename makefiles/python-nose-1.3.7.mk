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
# python-nose-1.3.7

python-nose-version = 1.3.7
python-nose = python-nose-$(python-nose-version)
$(python-nose)-description = nose extends unittest to make testing easier
$(python-nose)-url = http://readthedocs.org/docs/nose/
$(python-nose)-srcurl = https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz
$(python-nose)-src = $(pkgsrcdir)/$(notdir $($(python-nose)-srcurl))
$(python-nose)-srcdir = $(pkgsrcdir)/$(python-nose)
$(python-nose)-builddeps = $(python)
$(python-nose)-prereqs = $(python)
$(python-nose)-modulefile = $(modulefilesdir)/$(python-nose)
$(python-nose)-prefix = $(pkgdir)/$(python-nose)
$(python-nose)-site-packages = $($(python-nose)-prefix)/lib/python$(python-version-short)/site-packages

$($(python-nose)-src): $(dir $($(python-nose)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-nose)-srcurl)

$($(python-nose)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-nose)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-nose)-prefix)/.pkgunpack: $$($(python-nose)-src) $($(python-nose)-srcdir)/.markerfile $($(python-nose)-prefix)/.markerfile
	tar -C $($(python-nose)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-nose)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-nose)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-nose)-prefix)/.pkgunpack
	@touch $@

$($(python-nose)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-nose)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-nose)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-nose)-prefix)/.pkgpatch
	cd $($(python-nose)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-nose)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-nose)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-nose)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-nose)-prefix)/.pkgbuild
	# cd $($(python-nose)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-nose)-builddeps) && \
	# 	python3 setup.py test
	@touch $@

$($(python-nose)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-nose)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-nose)-prefix)/.pkgcheck $($(python-nose)-site-packages)/.markerfile
	cd $($(python-nose)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-nose)-builddeps) && \
		PYTHONPATH=$($(python-nose)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-nose)-prefix)
	@touch $@

$($(python-nose)-modulefile): $(modulefilesdir)/.markerfile $($(python-nose)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-nose)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-nose)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-nose)-description)\"" >>$@
	echo "module-whatis \"$($(python-nose)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-nose)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_NOSE_ROOT $($(python-nose)-prefix)" >>$@
	echo "prepend-path PATH $($(python-nose)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-nose)-site-packages)" >>$@
	echo "set MSG \"$(python-nose)\"" >>$@

$(python-nose)-src: $($(python-nose)-src)
$(python-nose)-unpack: $($(python-nose)-prefix)/.pkgunpack
$(python-nose)-patch: $($(python-nose)-prefix)/.pkgpatch
$(python-nose)-build: $($(python-nose)-prefix)/.pkgbuild
$(python-nose)-check: $($(python-nose)-prefix)/.pkgcheck
$(python-nose)-install: $($(python-nose)-prefix)/.pkginstall
$(python-nose)-modulefile: $($(python-nose)-modulefile)
$(python-nose)-clean:
	rm -rf $($(python-nose)-modulefile)
	rm -rf $($(python-nose)-prefix)
	rm -rf $($(python-nose)-srcdir)
	rm -rf $($(python-nose)-src)
$(python-nose): $(python-nose)-src $(python-nose)-unpack $(python-nose)-patch $(python-nose)-build $(python-nose)-check $(python-nose)-install $(python-nose)-modulefile
