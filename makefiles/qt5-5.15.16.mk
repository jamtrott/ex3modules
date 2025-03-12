# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2025 James D. Trotter
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
# qt5-5.15.16

qt5-version = 5.15.16
qt5 = qt5-$(qt5-version)
$(qt5)-description = Cross-platform framework and graphical toolkit
$(qt5)-url = https://www.qt.io/
$(qt5)-srcurl = http://download.qt.io/official_releases/qt/5.15/$(qt5-version)/single/qt-everywhere-opensource-src-$(qt5-version).tar.xz
$(qt5)-builddeps = $(libxrender) $(libxcb) $(xcb-util) $(xcb-util-renderutil) $(xcb-util-keysyms) $(xcb-util-image) $(xcb-util-wm) $(xcbproto) $(xkbcommon) $(libxkbfile) $(libxext) $(libx11) $(libsm) $(libice) $(libxi) $(glib) $(fontconfig) $(freetype) $(libjpeg-turbo) $(libpng) $(pcre) $(mesa)
$(qt5)-prereqs = $(libxrender) $(libxcb) $(xcb-util) $(xcb-util-renderutil) $(xcb-util-keysyms) $(xcb-util-image) $(xcb-util-wm) $(xcbproto) $(xkbcommon) $(libxkbfile) $(libxext) $(libx11) $(libsm) $(libice) $(libxi) $(glib) $(fontconfig) $(freetype) $(libjpeg-turbo) $(libpng) $(pcre) $(mesa)
$(qt5)-src = $(pkgsrcdir)/$(notdir $($(qt5)-srcurl))
$(qt5)-srcdir = $(pkgsrcdir)/$(qt5)
$(qt5)-builddir = $($(qt5)-srcdir)
$(qt5)-modulefile = $(modulefilesdir)/$(qt5)
$(qt5)-prefix = $(pkgdir)/$(qt5)

$($(qt5)-src): $(dir $($(qt5)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(qt5)-srcurl)

$($(qt5)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(qt5)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(qt5)-prefix)/.pkgunpack: $$($(qt5)-src) $($(qt5)-srcdir)/.markerfile $($(qt5)-prefix)/.markerfile $$(foreach dep,$$($(qt5)-builddeps),$(modulefilesdir)/$$(dep))
	tar -C $($(qt5)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(qt5)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(qt5)-builddeps),$(modulefilesdir)/$$(dep)) $($(qt5)-prefix)/.pkgunpack
	cd $($(qt5)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(qt5)-builddeps) # && \
		#sed -i "s,QMAKE_CC.*=.*,QMAKE_CC = $${CC}," qtbase/mkspecs/common/g++-base.conf && \
		#sed -i "s,QMAKE_CXX.*=.*,QMAKE_CXX = $${CXX}," qtbase/mkspecs/common/g++-base.conf
	@touch $@

ifneq ($($(qt5)-builddir),$($(qt5)-srcdir))
$($(qt5)-builddir)/.markerfile: $($(qt5)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(qt5)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(qt5)-builddeps),$(modulefilesdir)/$$(dep)) $($(qt5)-builddir)/.markerfile $($(qt5)-prefix)/.pkgpatch
	cd $($(qt5)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(qt5)-builddeps) && \
		./configure \
			--prefix=$($(qt5)-prefix) \
			-platform linux-g++ \
			-verbose \
			-opensource \
			-confirm-license \
			-system-zlib \
			-system-libjpeg \
			-system-libpng \
			-system-freetype \
			-system-pcre \
			-no-avx512 \
			-skip qtactiveqt \
			-skip qtandroidextras \
			-skip qtcharts \
			-skip qtconnectivity \
			-skip qtdatavis3d \
			-skip qtgamepad \
			-skip qtgraphicaleffects \
			-skip qtimageformats \
			-skip qtlocation \
			-skip qtlottie \
			-skip qtmacextras \
			-skip qtnetworkauth \
			-skip qtpurchasing \
			-skip qtquick3d \
			-skip qtquickcontrols \
			-skip qtquicktimeline \
			-skip qtremoteobjects \
			-skip qtscript \
			-skip qtscxml \
			-skip qtsensors \
			-skip qtserialbus \
			-skip qtserialport \
			-skip qtspeech \
			-skip qtvirtualkeyboard \
			-skip qtwayland \
			-skip qtwebchannel \
			-skip qtwebengine \
			-skip qtwebglplugin \
			-skip qtwebsockets \
			-skip qtwebview \
			-skip qtwinextras \
			-skip qtx11extras && \
		$(MAKE)
	@touch $@

$($(qt5)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(qt5)-builddeps),$(modulefilesdir)/$$(dep)) $($(qt5)-builddir)/.markerfile $($(qt5)-prefix)/.pkgbuild
	cd $($(qt5)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(qt5)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(qt5)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(qt5)-builddeps),$(modulefilesdir)/$$(dep)) $($(qt5)-builddir)/.markerfile $($(qt5)-prefix)/.pkgcheck
	cd $($(qt5)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(qt5)-builddeps) && \
		$(MAKE) install
	@touch $@

$($(qt5)-modulefile): $(modulefilesdir)/.markerfile $($(qt5)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(qt5)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(qt5)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(qt5)-description)\"" >>$@
	echo "module-whatis \"$($(qt5)-url)\"" >>$@
	printf "$(foreach prereq,$($(qt5)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv QT5_ROOT $($(qt5)-prefix)" >>$@
	echo "setenv QT5_INCDIR $($(qt5)-prefix)/include" >>$@
	echo "setenv QT5_INCLUDEDIR $($(qt5)-prefix)/include" >>$@
	echo "setenv QT5_LIBDIR $($(qt5)-prefix)/lib" >>$@
	echo "setenv QT5_LIBRARYDIR $($(qt5)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(qt5)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(qt5)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(qt5)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(qt5)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(qt5)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(qt5)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path CMAKE_PREFIX_PATH $($(qt5)-prefix)" >>$@
	echo "set MSG \"$(qt5)\"" >>$@

$(qt5)-src: $$($(qt5)-src)
$(qt5)-unpack: $($(qt5)-prefix)/.pkgunpack
$(qt5)-patch: $($(qt5)-prefix)/.pkgpatch
$(qt5)-build: $($(qt5)-prefix)/.pkgbuild
$(qt5)-check: $($(qt5)-prefix)/.pkgcheck
$(qt5)-install: $($(qt5)-prefix)/.pkginstall
$(qt5)-modulefile: $($(qt5)-modulefile)
$(qt5)-clean:
	rm -rf $($(qt5)-modulefile)
	rm -rf $($(qt5)-prefix)
	rm -rf $($(qt5)-builddir)
	rm -rf $($(qt5)-srcdir)
	rm -rf $($(qt5)-src)
$(qt5): $(qt5)-src $(qt5)-unpack $(qt5)-patch $(qt5)-build $(qt5)-check $(qt5)-install $(qt5)-modulefile
