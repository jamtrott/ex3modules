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
# python-pygraphviz-1.5

python-pygraphviz-version = 1.5
python-pygraphviz = python-pygraphviz-$(python-pygraphviz-version)
$(python-pygraphviz)-description = Python interface to the Graphviz graph layout and visualization package
$(python-pygraphviz)-url = http://pygraphviz.github.io/
$(python-pygraphviz)-srcurl = https://github.com/pygraphviz/pygraphviz/archive/pygraphviz-1.5.tar.gz
$(python-pygraphviz)-src = $(pkgsrcdir)/$(notdir $($(python-pygraphviz)-srcurl))
$(python-pygraphviz)-srcdir = $(pkgsrcdir)/$(python-pygraphviz)
$(python-pygraphviz)-builddeps = $(python) $(graphviz) $(python-mock) $(python-nose)
$(python-pygraphviz)-prereqs = $(python) $(graphviz)
$(python-pygraphviz)-modulefile = $(modulefilesdir)/$(python-pygraphviz)
$(python-pygraphviz)-prefix = $(pkgdir)/$(python-pygraphviz)
$(python-pygraphviz)-site-packages = $($(python-pygraphviz)-prefix)/lib/python$(PYTHON_VERSION_SHORT)/site-packages

$($(python-pygraphviz)-src): $(dir $($(python-pygraphviz)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(python-pygraphviz)-srcurl)

$($(python-pygraphviz)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pygraphviz)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(python-pygraphviz)-prefix)/.pkgunpack: $$($(python-pygraphviz)-src) $($(python-pygraphviz)-srcdir)/.markerfile $($(python-pygraphviz)-prefix)/.markerfile $$(foreach dep,$$($(python-pygraphviz)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(python-pygraphviz)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(python-pygraphviz)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pygraphviz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pygraphviz)-prefix)/.pkgunpack
	@touch $@

$($(python-pygraphviz)-site-packages)/.markerfile:
	$(INSTALL) -d $(dir $@)
	@touch $@

$($(python-pygraphviz)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pygraphviz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pygraphviz)-prefix)/.pkgpatch
	cd $($(python-pygraphviz)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pygraphviz)-builddeps) && \
		python3 setup.py build
	@touch $@

$($(python-pygraphviz)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pygraphviz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pygraphviz)-prefix)/.pkgbuild
	# Failing tests
	# cd $($(python-pygraphviz)-srcdir) && \
	# 	$(MODULE) use $(modulefilesdir) && \
	# 	$(MODULE) load $($(python-pygraphviz)-builddeps) && \
	# 	python3 setup.py test
	@touch $@

$($(python-pygraphviz)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(python-pygraphviz)-builddeps),$(modulefilesdir)/$$(dep)) $($(python-pygraphviz)-prefix)/.pkgcheck $($(python-pygraphviz)-site-packages)/.markerfile
	cd $($(python-pygraphviz)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(python-pygraphviz)-builddeps) && \
		PYTHONPATH=$($(python-pygraphviz)-site-packages):$${PYTHONPATH} \
		python3 setup.py install --prefix=$($(python-pygraphviz)-prefix)
	@touch $@

$($(python-pygraphviz)-modulefile): $(modulefilesdir)/.markerfile $($(python-pygraphviz)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(python-pygraphviz)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(python-pygraphviz)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(python-pygraphviz)-description)\"" >>$@
	echo "module-whatis \"$($(python-pygraphviz)-url)\"" >>$@
	printf "$(foreach prereq,$($(python-pygraphviz)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PYTHON_PYGRAPHVIZ_ROOT $($(python-pygraphviz)-prefix)" >>$@
	echo "prepend-path PATH $($(python-pygraphviz)-prefix)/bin" >>$@
	echo "prepend-path PYTHONPATH $($(python-pygraphviz)-site-packages)" >>$@
	echo "set MSG \"$(python-pygraphviz)\"" >>$@

$(python-pygraphviz)-src: $($(python-pygraphviz)-src)
$(python-pygraphviz)-unpack: $($(python-pygraphviz)-prefix)/.pkgunpack
$(python-pygraphviz)-patch: $($(python-pygraphviz)-prefix)/.pkgpatch
$(python-pygraphviz)-build: $($(python-pygraphviz)-prefix)/.pkgbuild
$(python-pygraphviz)-check: $($(python-pygraphviz)-prefix)/.pkgcheck
$(python-pygraphviz)-install: $($(python-pygraphviz)-prefix)/.pkginstall
$(python-pygraphviz)-modulefile: $($(python-pygraphviz)-modulefile)
$(python-pygraphviz)-clean:
	rm -rf $($(python-pygraphviz)-modulefile)
	rm -rf $($(python-pygraphviz)-prefix)
	rm -rf $($(python-pygraphviz)-srcdir)
	rm -rf $($(python-pygraphviz)-src)
$(python-pygraphviz): $(python-pygraphviz)-src $(python-pygraphviz)-unpack $(python-pygraphviz)-patch $(python-pygraphviz)-build $(python-pygraphviz)-check $(python-pygraphviz)-install $(python-pygraphviz)-modulefile
