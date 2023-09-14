# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# scotch-src-7.0.4

scotch-src-7.0.4-version = 7.0.4
scotch-src-7.0.4 = scotch-src-$(scotch-src-7.0.4-version)
$(scotch-src-7.0.4)-description = Static Mapping, Graph, Mesh and Hypergraph Partitioning, and Parallel and Sequential Sparse Matrix Ordering Package
$(scotch-src-7.0.4)-url = https://www.labri.fr/perso/pelegrin/scotch/
$(scotch-src-7.0.4)-srcurl = https://gitlab.inria.fr/scotch/scotch/-/archive/v$(scotch-src-7.0.4-version)/scotch-v$(scotch-src-7.0.4-version).tar.gz
$(scotch-src-7.0.4)-builddeps =
$(scotch-src-7.0.4)-prereqs =
$(scotch-src-7.0.4)-src = $(pkgsrcdir)/$(notdir $($(scotch-src-7.0.4)-srcurl))

$($(scotch-src-7.0.4)-src): $(dir $($(scotch-src-7.0.4)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(scotch-src-7.0.4)-srcurl)

$(scotch-src-7.0.4)-src: $($(scotch-src-7.0.4)-src)
$(scotch-src-7.0.4)-unpack:
$(scotch-src-7.0.4)-patch:
$(scotch-src-7.0.4)-build:
$(scotch-src-7.0.4)-check:
$(scotch-src-7.0.4)-install:
$(scotch-src-7.0.4)-modulefile:
$(scotch-src-7.0.4)-clean:
	rm -rf $($(scotch-src-7.0.4)-src)
$(scotch-src-7.0.4): $(scotch-src-7.0.4)-src $(scotch-src-7.0.4)-unpack $(scotch-src-7.0.4)-patch $(scotch-src-7.0.4)-build $(scotch-src-7.0.4)-check $(scotch-src-7.0.4)-install $(scotch-src-7.0.4)-modulefile
