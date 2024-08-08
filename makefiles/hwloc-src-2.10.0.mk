# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2024 James D. Trotter
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
# hwloc-src-2.10.0

hwloc-src-2.10.0-version = 2.10.0
hwloc-src-2.10.0 = hwloc-src-$(hwloc-src-2.10.0-version)
$(hwloc-src-2.10.0)-description = Portable abstraction of hierarchical topology of modern architectures (source)
$(hwloc-src-2.10.0)-url = https://www.open-mpi.org/projects/hwloc/
$(hwloc-src-2.10.0)-srcurl = https://download.open-mpi.org/release/hwloc/v2.10/hwloc-$(hwloc-src-2.10.0-version).tar.gz
$(hwloc-src-2.10.0)-builddeps =
$(hwloc-src-2.10.0)-prereqs =
$(hwloc-src-2.10.0)-src = $(pkgsrcdir)/$(notdir $($(hwloc-src-2.10.0)-srcurl))

$($(hwloc-src-2.10.0)-src): $(dir $($(hwloc-src-2.10.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hwloc-src-2.10.0)-srcurl)

$(hwloc-src-2.10.0)-src: $($(hwloc-src-2.10.0)-src)
$(hwloc-src-2.10.0)-unpack:
$(hwloc-src-2.10.0)-patch:
$(hwloc-src-2.10.0)-build:
$(hwloc-src-2.10.0)-check:
$(hwloc-src-2.10.0)-install:
$(hwloc-src-2.10.0)-modulefile:
$(hwloc-src-2.10.0)-clean:
	rm -rf $($(hwloc-src-2.10.0)-src)
$(hwloc-src-2.10.0): $(hwloc-src-2.10.0)-src $(hwloc-src-2.10.0)-unpack $(hwloc-src-2.10.0)-patch $(hwloc-src-2.10.0)-build $(hwloc-src-2.10.0)-check $(hwloc-src-2.10.0)-install $(hwloc-src-2.10.0)-modulefile
