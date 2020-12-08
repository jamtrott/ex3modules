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
# libpng-1.6.37

libpng-version = 1.6.37
libpng = libpng-$(libpng-version)
$(libpng)-description = Official Portable Network Graphics reference library for handling PNG images
$(libpng)-url = http://www.libpng.org/pub/png/libpng.html
$(libpng)-srcurl = https://download.sourceforge.net/libpng/libpng-$(libpng-version).tar.xz
$(libpng)-src = $(pkgsrcdir)/$(libpng).tar.xz
$(libpng)-srcdir = $(pkgsrcdir)/$(libpng)
$(libpng)-builddeps =
$(libpng)-prereqs =
$(libpng)-modulefile = $(modulefilesdir)/$(libpng)
$(libpng)-prefix = $(pkgdir)/$(libpng)

$($(libpng)-src): $(dir $($(libpng)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(libpng)-srcurl)

$($(libpng)-srcdir)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpng)-prefix)/.markerfile:
	$(INSTALL) -d $(dir $@) && touch $@

$($(libpng)-prefix)/.pkgunpack: $($(libpng)-src) $($(libpng)-srcdir)/.markerfile $($(libpng)-prefix)/.markerfile
	tar -C $($(libpng)-srcdir) --strip-components 1 -x -f $<
	@touch $@

$($(libpng)-srcdir)/0001-Avoid-random-test-failures-by-running-pngtest-sequentially.patch: $($(libpng)-srcdir)/.markerfile
	@printf '' >$@.tmp
	@echo 'From 72fa126446460347a504f3d9b90f24aed1365595 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: Cosmin Truta <ctruta@gmail.com>' >>$@.tmp
	@echo 'Date: Sun, 21 Apr 2019 00:30:14 -0400' >>$@.tmp
	@echo 'Subject: [PATCH] Avoid random test failures by running pngtest sequentially' >>$@.tmp
	@echo ' only' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'It is unreliable to run pngtest in parallel, due to competing writes' >>$@.tmp
	@echo 'to the same intermediate/output file ("pngout.png").' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'Customization of this output file name should be possible, but it is' >>$@.tmp
	@echo 'currently broken.' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' Makefile.am                            |  3 +--' >>$@.tmp
	@echo ' Makefile.in                            | 16 ++++------------' >>$@.tmp
	@echo ' tests/pngtest                          |  2 --' >>$@.tmp
	@echo ' tests/{pngtest-badpngs => pngtest-all} |  7 +++++--' >>$@.tmp
	@echo ' 4 files changed, 10 insertions(+), 18 deletions(-)' >>$@.tmp
	@echo ' delete mode 100755 tests/pngtest' >>$@.tmp
	@echo ' rename tests/{pngtest-badpngs => pngtest-all} (80%)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/Makefile.am b/Makefile.am' >>$@.tmp
	@echo 'index 4f621aa4d6..f21107e65e 100644' >>$@.tmp
	@echo '--- a/Makefile.am' >>$@.tmp
	@echo '+++ b/Makefile.am' >>$@.tmp
	@echo '@@ -59,8 +59,7 @@ pngcp_LDADD = libpng@PNGLIB_MAJOR@@PNGLIB_MINOR@.la' >>$@.tmp
	@echo ' # Generally these are single line shell scripts to run a test with a particular' >>$@.tmp
	@echo ' # set of parameters:' >>$@.tmp
	@echo ' TESTS =\' >>$@.tmp
	@echo '-   tests/pngtest\' >>$@.tmp
	@echo '-   tests/pngtest-badpngs\' >>$@.tmp
	@echo '+   tests/pngtest-all\' >>$@.tmp
	@echo '    tests/pngvalid-gamma-16-to-8 tests/pngvalid-gamma-alpha-mode\' >>$@.tmp
	@echo '    tests/pngvalid-gamma-background tests/pngvalid-gamma-expand16-alpha-mode\' >>$@.tmp
	@echo '    tests/pngvalid-gamma-expand16-background\' >>$@.tmp
	@echo 'diff --git a/Makefile.in b/Makefile.in' >>$@.tmp
	@echo 'index 81ac1c8552..31a82d25a4 100644' >>$@.tmp
	@echo '--- a/Makefile.in' >>$@.tmp
	@echo '+++ b/Makefile.in' >>$@.tmp
	@echo '@@ -736,8 +736,7 @@ pngcp_LDADD = libpng@PNGLIB_MAJOR@@PNGLIB_MINOR@.la' >>$@.tmp
	@echo ' # Generally these are single line shell scripts to run a test with a particular' >>$@.tmp
	@echo ' # set of parameters:' >>$@.tmp
	@echo ' TESTS = \' >>$@.tmp
	@echo '-   tests/pngtest\' >>$@.tmp
	@echo '-   tests/pngtest-badpngs\' >>$@.tmp
	@echo '+   tests/pngtest-all\' >>$@.tmp
	@echo '    tests/pngvalid-gamma-16-to-8 tests/pngvalid-gamma-alpha-mode\' >>$@.tmp
	@echo '    tests/pngvalid-gamma-background tests/pngvalid-gamma-expand16-alpha-mode\' >>$@.tmp
	@echo '    tests/pngvalid-gamma-expand16-background\' >>$@.tmp
	@echo '@@ -1578,16 +1577,9 @@ recheck: all $$(check_PROGRAMS)' >>$@.tmp
	@echo ' 	        am__force_recheck=am--force-recheck \' >>$@.tmp
	@echo ' 	        TEST_LOGS="$$$$log_list"; \' >>$@.tmp
	@echo ' 	exit $$$$?' >>$@.tmp
	@echo '-tests/pngtest.log: tests/pngtest' >>$@.tmp
	@echo '-	@p='"'"'tests/pngtest'"'"'; \' >>$@.tmp
	@echo '-	b='"'"'tests/pngtest'"'"'; \' >>$@.tmp
	@echo '-	$$(am__check_pre) $$(LOG_DRIVER) --test-name "$$$$f" \' >>$@.tmp
	@echo '-	--log-file $$$$b.log --trs-file $$$$b.trs \' >>$@.tmp
	@echo '-	$$(am__common_driver_flags) $$(AM_LOG_DRIVER_FLAGS) $$(LOG_DRIVER_FLAGS) -- $$(LOG_COMPILE) \' >>$@.tmp
	@echo '-	"$$$$tst" $$(AM_TESTS_FD_REDIRECT)' >>$@.tmp
	@echo '-tests/pngtest-badpngs.log: tests/pngtest-badpngs' >>$@.tmp
	@echo '-	@p='"'"'tests/pngtest-badpngs'"'"'; \' >>$@.tmp
	@echo '-	b='"'"'tests/pngtest-badpngs'"'"'; \' >>$@.tmp
	@echo '+tests/pngtest-all.log: tests/pngtest-all' >>$@.tmp
	@echo '+	@p='"'"'tests/pngtest-all'"'"'; \' >>$@.tmp
	@echo '+	b='"'"'tests/pngtest-all'"'"'; \' >>$@.tmp
	@echo ' 	$$(am__check_pre) $$(LOG_DRIVER) --test-name "$$$$f" \' >>$@.tmp
	@echo ' 	--log-file $$$$b.log --trs-file $$$$b.trs \' >>$@.tmp
	@echo ' 	$$(am__common_driver_flags) $$(AM_LOG_DRIVER_FLAGS) $$(LOG_DRIVER_FLAGS) -- $$(LOG_COMPILE) \' >>$@.tmp
	@echo 'diff --git a/tests/pngtest b/tests/pngtest' >>$@.tmp
	@echo 'deleted file mode 100755' >>$@.tmp
	@echo 'index 813973b23e..0000000000' >>$@.tmp
	@echo '--- a/tests/pngtest' >>$@.tmp
	@echo '+++ /dev/null' >>$@.tmp
	@echo '@@ -1,2 +0,0 @@' >>$@.tmp
	@echo '-#!/bin/sh' >>$@.tmp
	@echo '-exec ./pngtest --strict $${srcdir}/pngtest.png' >>$@.tmp
	@echo 'diff --git a/tests/pngtest-badpngs b/tests/pngtest-all' >>$@.tmp
	@echo 'similarity index 80%' >>$@.tmp
	@echo 'rename from tests/pngtest-badpngs' >>$@.tmp
	@echo 'rename to tests/pngtest-all' >>$@.tmp
	@echo 'index 77775232b2..5e96451d37 100755' >>$@.tmp
	@echo '--- a/tests/pngtest-badpngs' >>$@.tmp
	@echo '+++ b/tests/pngtest-all' >>$@.tmp
	@echo '@@ -1,5 +1,9 @@' >>$@.tmp
	@echo ' #!/bin/sh' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '+# normal execution' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo '+./pngtest --strict $${srcdir}/pngtest.png' >>$@.tmp
	@echo '+' >>$@.tmp
	@echo ' # various crashers' >>$@.tmp
	@echo ' # using --relaxed because some come from fuzzers that don'"'"'t maintain CRC'"'"'s' >>$@.tmp
	@echo ' ' >>$@.tmp
	@echo '@@ -9,5 +13,4 @@' >>$@.tmp
	@echo ' ./pngtest --xfail $${srcdir}/contrib/testpngs/crashers/empty_ancillary_chunks.png' >>$@.tmp
	@echo ' ./pngtest --xfail $${srcdir}/contrib/testpngs/crashers/huge_*_chunk.png \' >>$@.tmp
	@echo '     $${srcdir}/contrib/testpngs/crashers/huge_*safe_to_copy.png' >>$@.tmp
	@echo '-' >>$@.tmp
	@echo '-exec ./pngtest --xfail $${srcdir}/contrib/testpngs/crashers/huge_IDAT.png' >>$@.tmp
	@echo '+./pngtest --xfail $${srcdir}/contrib/testpngs/crashers/huge_IDAT.png' >>$@.tmp
	@mv $@.tmp $@

$($(libpng)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpng)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpng)-prefix)/.pkgunpack
$($(libpng)-prefix)/.pkgpatch: $($(libpng)-srcdir)/0001-Avoid-random-test-failures-by-running-pngtest-sequentially.patch
	cd $($(libpng)-srcdir) && patch -t -p1 <0001-Avoid-random-test-failures-by-running-pngtest-sequentially.patch
	@touch $@

$($(libpng)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpng)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpng)-prefix)/.pkgpatch
	cd $($(libpng)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpng)-builddeps) && \
		./configure --prefix=$($(libpng)-prefix) && \
		$(MAKE)
	@touch $@

$($(libpng)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpng)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpng)-prefix)/.pkgbuild
	cd $($(libpng)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(libpng)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(libpng)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(libpng)-builddeps),$(modulefilesdir)/$$(dep)) $($(libpng)-prefix)/.pkgcheck
	$(MAKE) MAKEFLAGS= prefix=$($(libpng)-prefix) -C $($(libpng)-srcdir) install
	@touch $@

$($(libpng)-modulefile): $(modulefilesdir)/.markerfile $($(libpng)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(libpng)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(libpng)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(libpng)-description)\"" >>$@
	echo "module-whatis \"$($(libpng)-url)\"" >>$@
	printf "$(foreach prereq,$($(libpng)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv LIBPNG_ROOT $($(libpng)-prefix)" >>$@
	echo "setenv LIBPNG_INCDIR $($(libpng)-prefix)/include" >>$@
	echo "setenv LIBPNG_INCLUDEDIR $($(libpng)-prefix)/include" >>$@
	echo "setenv LIBPNG_LIBDIR $($(libpng)-prefix)/lib" >>$@
	echo "setenv LIBPNG_LIBRARYDIR $($(libpng)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(libpng)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(libpng)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(libpng)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(libpng)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(libpng)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(libpng)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(libpng)-prefix)/share/man" >>$@
	echo "set MSG \"$(libpng)\"" >>$@

$(libpng)-src: $($(libpng)-src)
$(libpng)-unpack: $($(libpng)-prefix)/.pkgunpack
$(libpng)-patch: $($(libpng)-prefix)/.pkgpatch
$(libpng)-build: $($(libpng)-prefix)/.pkgbuild
$(libpng)-check: $($(libpng)-prefix)/.pkgcheck
$(libpng)-install: $($(libpng)-prefix)/.pkginstall
$(libpng)-modulefile: $($(libpng)-modulefile)
$(libpng)-clean:
	rm -rf $($(libpng)-modulefile)
	rm -rf $($(libpng)-prefix)
	rm -rf $($(libpng)-srcdir)
	rm -rf $($(libpng)-src)
$(libpng): $(libpng)-src $(libpng)-unpack $(libpng)-patch $(libpng)-build $(libpng)-check $(libpng)-install $(libpng)-modulefile
