# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# scotch-src-6.1.3

scotch-src-version = 6.1.3
scotch-src = scotch-src-$(scotch-src-version)
$(scotch-src)-description = Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package
$(scotch-src)-url = https://www.labri.fr/perso/pelegrin/scotch/
$(scotch-src)-srcurl = https://gitlab.inria.fr/scotch/scotch/-/archive/v$(scotch-src-version)/scotch-v$(scotch-src-version).tar.gz
$(scotch-src)-builddeps =
$(scotch-src)-prereqs =
$(scotch-src)-src = $(pkgsrcdir)/$(notdir $($(scotch-src)-srcurl))

$($(scotch-src)-src): $(dir $($(scotch-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(scotch-src)-srcurl)

$(scotch-src)-src: $($(scotch-src)-src)
$(scotch-src)-unpack:
$(scotch-src)-patch:
$(scotch-src)-build:
$(scotch-src)-check:
$(scotch-src)-install:
$(scotch-src)-modulefile:
$(scotch-src)-clean:
	rm -rf $($(scotch-src)-src)
$(scotch-src): $(scotch-src)-src $(scotch-src)-unpack $(scotch-src)-patch $(scotch-src)-build $(scotch-src)-check $(scotch-src)-install $(scotch-src)-modulefile
