# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2020 James D. Trotter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as puhwloched by
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
# hwloc-src-2.4.1

hwloc-src-version = 2.4.1
hwloc-src = hwloc-src-$(hwloc-src-version)
$(hwloc-src)-description = Portable abstraction of hierarchical topology of modern architectures (source)
$(hwloc-src)-url = https://www.open-mpi.org/projects/hwloc/
$(hwloc-src)-srcurl = https://download.open-mpi.org/release/hwloc/v2.4/hwloc-$(hwloc-version).tar.gz
$(hwloc-src)-builddeps =
$(hwloc-src)-prereqs =
$(hwloc-src)-src = $(pkgsrcdir)/$(notdir $($(hwloc-src)-srcurl))

$($(hwloc-src)-src): $(dir $($(hwloc-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hwloc-src)-srcurl)

$(hwloc-src)-src: $($(hwloc-src)-src)
$(hwloc-src)-unpack:
$(hwloc-src)-patch:
$(hwloc-src)-build:
$(hwloc-src)-check:
$(hwloc-src)-install:
$(hwloc-src)-modulefile:
$(hwloc-src)-clean:
	rm -rf $($(hwloc-src)-src)
$(hwloc-src): $(hwloc-src)-src $(hwloc-src)-unpack $(hwloc-src)-patch $(hwloc-src)-build $(hwloc-src)-check $(hwloc-src)-install $(hwloc-src)-modulefile
