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

scotch-src-6.1.3-version = 6.1.3
scotch-src-6.1.3 = scotch-src-$(scotch-src-6.1.3-version)
$(scotch-src-6.1.3)-description = Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package
$(scotch-src-6.1.3)-url = https://www.labri.fr/perso/pelegrin/scotch/
$(scotch-src-6.1.3)-srcurl = https://gitlab.inria.fr/scotch/scotch/-/archive/v$(scotch-src-6.1.3-version)/scotch-v$(scotch-src-6.1.3-version).tar.gz
$(scotch-src-6.1.3)-builddeps =
$(scotch-src-6.1.3)-prereqs =
$(scotch-src-6.1.3)-src = $(pkgsrcdir)/$(notdir $($(scotch-src-6.1.3)-srcurl))

$($(scotch-src-6.1.3)-src): $(dir $($(scotch-src-6.1.3)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(scotch-src-6.1.3)-srcurl)

$(scotch-src-6.1.3)-src: $($(scotch-src-6.1.3)-src)
$(scotch-src-6.1.3)-unpack:
$(scotch-src-6.1.3)-patch:
$(scotch-src-6.1.3)-build:
$(scotch-src-6.1.3)-check:
$(scotch-src-6.1.3)-install:
$(scotch-src-6.1.3)-modulefile:
$(scotch-src-6.1.3)-clean:
	rm -rf $($(scotch-src-6.1.3)-src)
$(scotch-src-6.1.3): $(scotch-src-6.1.3)-src $(scotch-src-6.1.3)-unpack $(scotch-src-6.1.3)-patch $(scotch-src-6.1.3)-build $(scotch-src-6.1.3)-check $(scotch-src-6.1.3)-install $(scotch-src-6.1.3)-modulefile
