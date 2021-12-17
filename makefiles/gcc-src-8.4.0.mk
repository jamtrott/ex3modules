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
# gcc-src-8.4.0

gcc-src-8.4.0-version = 8.4.0
gcc-src-8.4.0 = gcc-src-$(gcc-src-8.4.0-version)
$(gcc-src-8.4.0)-description = GNU Compiler Collection (source)
$(gcc-src-8.4.0)-url = https://gcc.gnu.org/
$(gcc-src-8.4.0)-srcurl = ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-$(gcc-src-8.4.0-version)/gcc-$(gcc-src-8.4.0-version).tar.gz
$(gcc-src-8.4.0)-builddeps =
$(gcc-src-8.4.0)-prereqs =
$(gcc-src-8.4.0)-src = $(pkgsrcdir)/$(notdir $($(gcc-src-8.4.0)-srcurl))

$($(gcc-src-8.4.0)-src): $(dir $($(gcc-src-8.4.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(gcc-src-8.4.0)-srcurl)

$(gcc-src-8.4.0)-src: $($(gcc-src-8.4.0)-src)
$(gcc-src-8.4.0)-unpack:
$(gcc-src-8.4.0)-patch:
$(gcc-src-8.4.0)-build:
$(gcc-src-8.4.0)-check:
$(gcc-src-8.4.0)-install:
$(gcc-src-8.4.0)-modulefile:
$(gcc-src-8.4.0)-clean:
	rm -rf $($(gcc-src-8.4.0)-src)
$(gcc-src-8.4.0): $(gcc-src-8.4.0)-src $(gcc-src-8.4.0)-unpack $(gcc-src-8.4.0)-patch $(gcc-src-8.4.0)-build $(gcc-src-8.4.0)-check $(gcc-src-8.4.0)-install $(gcc-src-8.4.0)-modulefile
