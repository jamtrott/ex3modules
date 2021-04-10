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
# ghostscript-9.54.0

ghostscript-version = 9.54.0
ghostscript = ghostscript-$(ghostscript-version)
$(ghostscript)-description = Interpreter for the PostScript language
$(ghostscript)-url = https://www.ghostscript.com/
$(ghostscript)-srcurl = https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs9540/ghostscript-9.54.0.tar.gz
$(ghostscript)-builddeps = $(fontconfig) $(freetype) $(libjpeg-turbo) $(libpng) $(libtiff) $(openjpeg) $(libpaper)
$(ghostscript)-prereqs = $(fontconfig) $(freetype) $(libjpeg-turbo) $(libpng) $(libtiff) $(openjpeg) $(libpaper)
$(ghostscript)-src = $(pkgsrcdir)/$(notdir $($(ghostscript)-srcurl))
$(ghostscript)-srcdir = $(pkgsrcdir)/$(ghostscript)
$(ghostscript)-builddir = $($(ghostscript)-srcdir)
$(ghostscript)-modulefile = $(modulefilesdir)/$(ghostscript)
$(ghostscript)-prefix = $(pkgdir)/$(ghostscript)

$($(ghostscript)-src): $(dir $($(ghostscript)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ghostscript)-srcurl)

$($(ghostscript)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ghostscript)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(ghostscript)-prefix)/.pkgunpack: $$($(ghostscript)-src) $($(ghostscript)-srcdir)/.markerfile $($(ghostscript)-prefix)/.markerfile
	tar -C $($(ghostscript)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(ghostscript)-srcdir)/ghostscript-9.53.3-freetype_fix-1.patch: $($(ghostscript)-prefix)/.pkgunpack
	@printf "" >$@.tmp

	@echo 'Submitted By: Ken Moffat <ken at linuxfromscratch dot org>' >>$@.tmp
	@echo 'Date: 2020-10-20' >>$@.tmp
	@echo 'Initial Package Version: 9.53.3' >>$@.tmp
	@echo 'Upstream Status: Applied' >>$@.tmp
	@echo 'Origin: https://git.ghostscript.com/?p=ghostpdl.git;a=commitdiff;h=41ef9a0bc36b#patch1' >>$@.tmp
	@echo 'Description: Fixes build failure with freetype-2.10.3 and later.' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/base/fapi_ft.c b/base/fapi_ft.c' >>$@.tmp
	@echo 'index 65fa6dc..21aef2f 100644 (file)' >>$@.tmp
	@echo '--- a/base/fapi_ft.c' >>$@.tmp
	@echo '+++ b/base/fapi_ft.c' >>$@.tmp
	@echo '@@ -125,7 +125,7 @@ static void' >>$@.tmp
	@echo ' delete_inc_int_info(gs_fapi_server * a_server,' >>$@.tmp
	@echo '                     FT_IncrementalRec * a_inc_int_info);' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-FT_CALLBACK_DEF(void *)' >>$@.tmp
	@echo '+static void *' >>$@.tmp
	@echo ' FF_alloc(FT_Memory memory, long size)' >>$@.tmp
	@echo ' {' >>$@.tmp
	@echo '     gs_memory_t *mem = (gs_memory_t *) memory->user;' >>$@.tmp
	@echo '@@ -133,7 +133,7 @@ FF_alloc(FT_Memory memory, long size)' >>$@.tmp
	@echo '     return (gs_malloc(mem, size, 1, "FF_alloc"));' >>$@.tmp
	@echo ' }' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-FT_CALLBACK_DEF(void *)' >>$@.tmp
	@echo '+static void *' >>$@.tmp
	@echo '     FF_realloc(FT_Memory memory, long cur_size, long new_size, void *block)' >>$@.tmp
	@echo ' {' >>$@.tmp
	@echo '     gs_memory_t *mem = (gs_memory_t *) memory->user;' >>$@.tmp
	@echo '@@ -153,7 +153,7 @@ FT_CALLBACK_DEF(void *)' >>$@.tmp
	@echo '     return (tmp);' >>$@.tmp
	@echo ' }' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '-FT_CALLBACK_DEF(void)' >>$@.tmp
	@echo '+static void' >>$@.tmp
	@echo '     FF_free(FT_Memory memory, void *block)' >>$@.tmp
	@echo ' {' >>$@.tmp
	@echo '     gs_memory_t *mem = (gs_memory_t *) memory->user;' >>$@.tmp
	@mv $@.tmp $@


$($(ghostscript)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ghostscript)-builddeps),$(modulefilesdir)/$$(dep)) $($(ghostscript)-prefix)/.pkgunpack $($(ghostscript)-srcdir)/ghostscript-9.53.3-freetype_fix-1.patch
	cd $($(ghostscript)-srcdir) && \
	rm -rf freetype lcms2mt jpeg libpng openjpeg zlib
	@touch $@

ifneq ($($(ghostscript)-builddir),$($(ghostscript)-srcdir))
$($(ghostscript)-builddir)/.markerfile: $($(ghostscript)-prefix)/.pkgunpack
	$(INSTALL) -d $(dir $@) && touch $@
endif

$($(ghostscript)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ghostscript)-builddeps),$(modulefilesdir)/$$(dep)) $($(ghostscript)-builddir)/.markerfile $($(ghostscript)-prefix)/.pkgpatch
	cd $($(ghostscript)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ghostscript)-builddeps) && \
		./configure --prefix=$($(ghostscript)-prefix) \
			--disable-compile-inits \
			--enable-dynamic \
			--with-system-libtiff && \
		$(MAKE) && \
		$(MAKE) so
	@touch $@

$($(ghostscript)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ghostscript)-builddeps),$(modulefilesdir)/$$(dep)) $($(ghostscript)-builddir)/.markerfile $($(ghostscript)-prefix)/.pkgbuild
	cd $($(ghostscript)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ghostscript)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(ghostscript)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(ghostscript)-builddeps),$(modulefilesdir)/$$(dep)) $($(ghostscript)-builddir)/.markerfile $($(ghostscript)-prefix)/.pkgcheck
	cd $($(ghostscript)-builddir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(ghostscript)-builddeps) && \
		$(MAKE) install && \
		$(MAKE) soinstall && \
		$(INSTALL) -v -m644 base/*.h $($(ghostscript)-prefix)/include/ghostscript && \
		ln -sfvn ghostscript $($(ghostscript)-prefix)/include/ps
	@touch $@

$($(ghostscript)-modulefile): $(modulefilesdir)/.markerfile $($(ghostscript)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(ghostscript)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(ghostscript)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(ghostscript)-description)\"" >>$@
	echo "module-whatis \"$($(ghostscript)-url)\"" >>$@
	printf "$(foreach prereq,$($(ghostscript)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv GHOSTSCRIPT_ROOT $($(ghostscript)-prefix)" >>$@
	echo "setenv GHOSTSCRIPT_INCDIR $($(ghostscript)-prefix)/include" >>$@
	echo "setenv GHOSTSCRIPT_INCLUDEDIR $($(ghostscript)-prefix)/include" >>$@
	echo "setenv GHOSTSCRIPT_LIBDIR $($(ghostscript)-prefix)/lib" >>$@
	echo "setenv GHOSTSCRIPT_LIBRARYDIR $($(ghostscript)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(ghostscript)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(ghostscript)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(ghostscript)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(ghostscript)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(ghostscript)-prefix)/lib" >>$@
	echo "prepend-path MANPATH $($(ghostscript)-prefix)/share/man" >>$@
	echo "set MSG \"$(ghostscript)\"" >>$@

$(ghostscript)-src: $$($(ghostscript)-src)
$(ghostscript)-unpack: $($(ghostscript)-prefix)/.pkgunpack
$(ghostscript)-patch: $($(ghostscript)-prefix)/.pkgpatch
$(ghostscript)-build: $($(ghostscript)-prefix)/.pkgbuild
$(ghostscript)-check: $($(ghostscript)-prefix)/.pkgcheck
$(ghostscript)-install: $($(ghostscript)-prefix)/.pkginstall
$(ghostscript)-modulefile: $($(ghostscript)-modulefile)
$(ghostscript)-clean:
	rm -rf $($(ghostscript)-modulefile)
	rm -rf $($(ghostscript)-prefix)
	rm -rf $($(ghostscript)-builddir)
	rm -rf $($(ghostscript)-srcdir)
	rm -rf $($(ghostscript)-src)
$(ghostscript): $(ghostscript)-src $(ghostscript)-unpack $(ghostscript)-patch $(ghostscript)-build $(ghostscript)-check $(ghostscript)-install $(ghostscript)-modulefile
