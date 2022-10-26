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
# mumps-src-5.5.1

mumps-src-5.5.1-version = 5.5.1
mumps-src-5.5.1 = mumps-src-$(mumps-src-5.5.1-version)
$(mumps-src-5.5.1)-description = MUltifrontal Massively Parallel sparse direct Solver
$(mumps-src-5.5.1)-url = http://mumps.enseeiht.fr/
#$(mumps-src-5.5.1)-srcurl = http://mumps.enseeiht.fr/MUMPS_$(mumps-src-5.5.1-version).tar.gz
$(mumps-src-5.5.1)-srcurl = http://deb.debian.org/debian/pool/main/m/mumps/mumps_$(mumps-src-5.5.1-version).orig.tar.gz
$(mumps-src-5.5.1)-builddeps =
$(mumps-src-5.5.1)-prereqs =
$(mumps-src-5.5.1)-src = $(pkgsrcdir)/$(notdir $($(mumps-src-5.5.1)-srcurl))

$($(mumps-src-5.5.1)-src): $(dir $($(mumps-src-5.5.1)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mumps-src-5.5.1)-srcurl)

$(mumps-src-5.5.1)-src: $($(mumps-src-5.5.1)-src)
$(mumps-src-5.5.1)-unpack:
$(mumps-src-5.5.1)-patch:
$(mumps-src-5.5.1)-build:
$(mumps-src-5.5.1)-check:
$(mumps-src-5.5.1)-install:
$(mumps-src-5.5.1)-modulefile:
$(mumps-src-5.5.1)-clean:
	rm -rf $($(mumps-src-5.5.1)-src)
$(mumps-src-5.5.1): $(mumps-src-5.5.1)-src $(mumps-src-5.5.1)-unpack $(mumps-src-5.5.1)-patch $(mumps-src-5.5.1)-build $(mumps-src-5.5.1)-check $(mumps-src-5.5.1)-install $(mumps-src-5.5.1)-modulefile
