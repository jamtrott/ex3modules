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
# parmetis-src-4.0.3

parmetis-src-version = 4.0.3
parmetis-src = parmetis-src-$(parmetis-src-version)
$(parmetis-src)-description = Parallel Graph Partitioning and Fill-reducing Matrix Ordering
$(parmetis-src)-url = http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview
$(parmetis-src)-srcurl = http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/parmetis-$(parmetis-src-version).tar.gz
$(parmetis-src)-builddeps =
$(parmetis-src)-prereqs =
$(parmetis-src)-src = $(pkgsrcdir)/$(notdir $($(parmetis-src)-srcurl))

$($(parmetis-src)-src): $(dir $($(parmetis-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(parmetis-src)-srcurl)

$(parmetis-src)-src: $($(parmetis-src)-src)
$(parmetis-src)-unpack:
$(parmetis-src)-patch:
$(parmetis-src)-build:
$(parmetis-src)-check:
$(parmetis-src)-install:
$(parmetis-src)-modulefile:
$(parmetis-src)-clean:
	rm -rf $($(parmetis-src)-src)
$(parmetis-src): $(parmetis-src)-src $(parmetis-src)-unpack $(parmetis-src)-patch $(parmetis-src)-build $(parmetis-src)-check $(parmetis-src)-install $(parmetis-src)-modulefile
