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
# superlu_dist-src-6.4.0

superlu_dist-src-version = 6.4.0
superlu_dist-src = superlu_dist-src-$(superlu_dist-src-version)
$(superlu_dist-src)-description = MPI-based direct solver for large, sparse non-symmetric systems of equations in distributed memory
$(superlu_dist-src)-url = https://github.com/xiaoyeli/superlu_dist/
$(superlu_dist-src)-srcurl = https://github.com/xiaoyeli/superlu_dist/archive/v$(superlu_dist-src-version).tar.gz
$(superlu_dist-src)-builddeps =
$(superlu_dist-src)-prereqs =
$(superlu_dist-src)-src = $(pkgsrcdir)/$(notdir $($(superlu_dist-src)-srcurl))

$($(superlu_dist-src)-src): $(dir $($(superlu_dist-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(superlu_dist-src)-srcurl)

$(superlu_dist-src)-src: $($(superlu_dist-src)-src)
$(superlu_dist-src)-unpack:
$(superlu_dist-src)-patch:
$(superlu_dist-src)-build:
$(superlu_dist-src)-check:
$(superlu_dist-src)-install:
$(superlu_dist-src)-modulefile:
$(superlu_dist-src)-clean:
	rm -rf $($(superlu_dist-src)-src)
$(superlu_dist-src): $(superlu_dist-src)-src $(superlu_dist-src)-unpack $(superlu_dist-src)-patch $(superlu_dist-src)-build $(superlu_dist-src)-check $(superlu_dist-src)-install $(superlu_dist-src)-modulefile
