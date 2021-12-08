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
# combblas-src-1.6.2

combblas-src-version = 1.6.2
combblas-src = combblas-src-$(combblas-src-version)
$(combblas-src)-description = Distributed-memory parallel graph library
$(combblas-src)-url = https://people.eecs.berkeley.edu/~aydin/CombBLAS/html/
$(combblas-src)-srcurl = http://eecs.berkeley.edu/~aydin/CombBLAS_FILES/CombBLAS_beta_16_2.tgz
$(combblas-src)-builddeps =
$(combblas-src)-prereqs =
$(combblas-src)-src = $(pkgsrcdir)/$(notdir $($(combblas-src)-srcurl))

$($(combblas-src)-src): $(dir $($(combblas-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(combblas-src)-srcurl)

$(combblas-src)-src: $($(combblas-src)-src)
$(combblas-src)-unpack:
$(combblas-src)-patch:
$(combblas-src)-build:
$(combblas-src)-check:
$(combblas-src)-install:
$(combblas-src)-modulefile:
$(combblas-src)-clean:
	rm -rf $($(combblas-src)-src)
$(combblas-src): $(combblas-src)-src $(combblas-src)-unpack $(combblas-src)-patch $(combblas-src)-build $(combblas-src)-check $(combblas-src)-install $(combblas-src)-modulefile
