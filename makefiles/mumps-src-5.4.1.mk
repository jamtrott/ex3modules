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
# mumps-src-5.4.1

mumps-src-version = 5.4.1
mumps-src = mumps-src-$(mumps-src-version)
$(mumps-src)-description = MUltifrontal Massively Parallel sparse direct Solver
$(mumps-src)-url = http://mumps.enseeiht.fr/
$(mumps-src)-srcurl = http://mumps.enseeiht.fr/MUMPS_$(mumps-src-version).tar.gz
$(mumps-src)-builddeps =
$(mumps-src)-prereqs =
$(mumps-src)-src = $(pkgsrcdir)/$(notdir $($(mumps-src)-srcurl))

$($(mumps-src)-src): $(dir $($(mumps-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(mumps-src)-srcurl)

$(mumps-src)-src: $($(mumps-src)-src)
$(mumps-src)-unpack:
$(mumps-src)-patch:
$(mumps-src)-build:
$(mumps-src)-check:
$(mumps-src)-install:
$(mumps-src)-modulefile:
$(mumps-src)-clean:
	rm -rf $($(mumps-src)-src)
$(mumps-src): $(mumps-src)-src $(mumps-src)-unpack $(mumps-src)-patch $(mumps-src)-build $(mumps-src)-check $(mumps-src)-install $(mumps-src)-modulefile
