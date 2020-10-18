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
# perl-5.30.2

perl-version = 5.30.2
perl = perl-$(perl-version)
$(perl)-description = Perl programming language
$(perl)-url = https://www.perl.org/
$(perl)-srcurl = https://www.cpan.org/src/5.0/$(perl).tar.gz
$(perl)-src = $(pkgsrcdir)/$(notdir $($(perl)-srcurl))
$(perl)-srcdir = $(pkgsrcdir)/$(perl)
$(perl)-builddeps =
$(perl)-prereqs =
$(perl)-modulefile = $(modulefilesdir)/$(perl)
$(perl)-prefix = $(pkgdir)/$(perl)

$($(perl)-src): $(dir $($(perl)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(perl)-srcurl)

$($(perl)-srcdir)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(perl)-prefix)/.markerfile:
	$(INSTALL) -m=6755 -d $(dir $@) && touch $@

$($(perl)-prefix)/.pkgunpack: $($(perl)-src) $($(perl)-srcdir)/.markerfile $($(perl)-prefix)/.markerfile
	tar -C $($(perl)-srcdir) --strip-components 1 -xz -f $<
	@touch $@

$($(perl)-srcdir)/0001-avoid-spurious-test-failure.patch: $($(perl)-srcdir)/.markerfile
	@printf '' >$@
	@echo 'From b197f9a55e2ae877b3089282cfe07f3647d240f9 Mon Sep 17 00:00:00 2001' >>$@.tmp
	@echo 'From: James E Keenan <jkeenan@cpan.org>' >>$@.tmp
	@echo 'Date: Mon, 22 Aug 2016 09:25:08 -0400' >>$@.tmp
	@echo 'Subject: [PATCH] Avoid spurious test failure due to PATH line > 1000' >>$@.tmp
	@echo ' characters.' >>$@.tmp
	@echo '' >>$@.tmp
	@echo '---' >>$@.tmp
	@echo ' lib/perlbug.t | 2 +-' >>$@.tmp
	@echo ' 1 file changed, 1 insertion(+), 1 deletion(-)' >>$@.tmp
	@echo '' >>$@.tmp
	@echo 'diff --git a/lib/perlbug.t b/lib/perlbug.t' >>$@.tmp
	@echo 'index ed32c04..8ff8991 100644' >>$@.tmp
	@echo '--- a/lib/perlbug.t' >>$@.tmp
	@echo '+++ b/lib/perlbug.t' >>$@.tmp
	@echo '@@ -148,7 +148,7 @@ my $$maxlen1 = 0; # body' >>$@.tmp
	@echo ' my $$maxlen2 = 0; # attachment' >>$@.tmp
	@echo ' for (split(/\\n/, $$contents)) {' >>$@.tmp
	@echo '         my $$len = length;' >>$@.tmp
	@echo '-        $$maxlen1 = $$len if $$len > $$maxlen1 and !/$$B/;' >>$@.tmp
	@echo '+        $$maxlen1 = $$len if $$len > $$maxlen1 and ! (/(?:$$B|PATH)/);' >>$@.tmp
	@echo '         $$maxlen2 = $$len if $$len > $$maxlen2 and  /$$B/;' >>$@.tmp
	@echo ' }' >>$@.tmp
	@echo ' ok($$maxlen1 < 1000, "[perl #128020] long body lines are wrapped: maxlen $$maxlen1");' >>$@.tmp
	@echo '-- ' >>$@.tmp
	@echo '2.7.4' >>$@.tmp
	@mv $@.tmp $@

$($(perl)-prefix)/.pkgpatch: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(perl)-builddeps),$(modulefilesdir)/$$(dep)) $($(perl)-prefix)/.pkgunpack $($(perl)-srcdir)/0001-avoid-spurious-test-failure.patch
	cd $($(perl)-srcdir) && \
		patch -t -p1 <0001-avoid-spurious-test-failure.patch
	@touch $@

$($(perl)-prefix)/.pkgbuild: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(perl)-builddeps),$(modulefilesdir)/$$(dep)) $($(perl)-prefix)/.pkgpatch
	cd $($(perl)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(perl)-builddeps) && \
		sh Configure -des \
			-Dprefix="$($(perl)-prefix)" \
			-Dvendorprefix="$($(perl)-prefix)" \
			-Dman1dir="$($(perl)-prefix)/share/man/man1" \
			-Dman3dir="$($(perl)-prefix)/share/man/man3" \
			-Dpager="$($(perl)-prefix)/bin/less -isR" \
			-Duseshrplib \
			-Dusethreads && \
		$(MAKE)
	@touch $@

$($(perl)-prefix)/.pkgcheck: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(perl)-builddeps),$(modulefilesdir)/$$(dep)) $($(perl)-prefix)/.pkgbuild
	cd $($(perl)-srcdir) && \
		$(MODULESINIT) && \
		$(MODULE) use $(modulefilesdir) && \
		$(MODULE) load $($(perl)-builddeps) && \
		$(MAKE) check
	@touch $@

$($(perl)-prefix)/.pkginstall: $(modulefilesdir)/.markerfile $$(foreach dep,$$($(perl)-builddeps),$(modulefilesdir)/$$(dep)) $($(perl)-prefix)/.pkgcheck
	$(MAKE) -C $($(perl)-srcdir) install
	@touch $@

$($(perl)-modulefile): $(modulefilesdir)/.markerfile $($(perl)-prefix)/.pkginstall
	printf "" >$@
	echo "#%Module" >>$@
	echo "# $(perl)" >>$@
	echo "" >>$@
	echo "proc ModulesHelp { } {" >>$@
	echo "     puts stderr \"\tSets up the environment for $(perl)\\n\"" >>$@
	echo "}" >>$@
	echo "" >>$@
	echo "module-whatis \"$($(perl)-description)\"" >>$@
	echo "module-whatis \"$($(perl)-url)\"" >>$@
	printf "$(foreach prereq,$($(perl)-prereqs),\n$(MODULE) load $(prereq))" >>$@
	echo "" >>$@
	echo "" >>$@
	echo "setenv PERL_ROOT $($(perl)-prefix)" >>$@
	echo "setenv PERL_INCDIR $($(perl)-prefix)/include" >>$@
	echo "setenv PERL_INCLUDEDIR $($(perl)-prefix)/include" >>$@
	echo "setenv PERL_LIBDIR $($(perl)-prefix)/lib" >>$@
	echo "setenv PERL_LIBRARYDIR $($(perl)-prefix)/lib" >>$@
	echo "prepend-path PATH $($(perl)-prefix)/bin" >>$@
	echo "prepend-path C_INCLUDE_PATH $($(perl)-prefix)/include" >>$@
	echo "prepend-path CPLUS_INCLUDE_PATH $($(perl)-prefix)/include" >>$@
	echo "prepend-path LIBRARY_PATH $($(perl)-prefix)/lib" >>$@
	echo "prepend-path LD_LIBRARY_PATH $($(perl)-prefix)/lib" >>$@
	echo "prepend-path PKG_CONFIG_PATH $($(perl)-prefix)/lib/pkgconfig" >>$@
	echo "prepend-path MANPATH $($(perl)-prefix)/share/man" >>$@
	echo "prepend-path INFOPATH $($(perl)-prefix)/share/info" >>$@
	echo "set MSG \"$(perl)\"" >>$@

$(perl)-src: $($(perl)-src)
$(perl)-unpack: $($(perl)-prefix)/.pkgunpack
$(perl)-patch: $($(perl)-prefix)/.pkgpatch
$(perl)-build: $($(perl)-prefix)/.pkgbuild
$(perl)-check: $($(perl)-prefix)/.pkgcheck
$(perl)-install: $($(perl)-prefix)/.pkginstall
$(perl)-modulefile: $($(perl)-modulefile)
$(perl)-clean:
	rm -rf $($(perl)-modulefile)
	rm -rf $($(perl)-prefix)
	rm -rf $($(perl)-srcdir)
	rm -rf $($(perl)-src)
$(perl): $(perl)-src $(perl)-unpack $(perl)-patch $(perl)-build $(perl)-check $(perl)-install $(perl)-modulefile
