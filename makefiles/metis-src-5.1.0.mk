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
# metis-src-5.1.0

metis-src-version = 5.1.0
metis-src = metis-src-$(metis-src-version)
$(metis-src)-description = Serial Graph Partitioning and Fill-reducing Matrix Ordering
$(metis-src)-url = http://glaros.dtc.umn.edu/gkhome/metis/metis/overview
$(metis-src)-srcurl = http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-$(metis-src-version).tar.gz
$(metis-src)-builddeps =
$(metis-src)-prereqs =
$(metis-src)-src = $(pkgsrcdir)/$(notdir $($(metis-src)-srcurl))

$($(metis-src)-src): $(dir $($(metis-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(metis-src)-srcurl)

$(metis-src)-src: $($(metis-src)-src)
$(metis-src)-unpack:
$(metis-src)-patch:
$(metis-src)-build:
$(metis-src)-check:
$(metis-src)-install:
$(metis-src)-modulefile:
$(metis-src)-clean:
	rm -rf $($(metis-src)-src)
$(metis-src): $(metis-src)-src $(metis-src)-unpack $(metis-src)-patch $(metis-src)-build $(metis-src)-check $(metis-src)-install $(metis-src)-modulefile
