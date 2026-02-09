# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2026 James D. Trotter
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
# openblas-src-0.3.21

openblas-src-0.3.21-version = 0.3.21
openblas-src-0.3.21 = openblas-src-$(openblas-src-0.3.21-version)
$(openblas-src-0.3.21)-description = Optimized BLAS library (sources)
$(openblas-src-0.3.21)-url = http://www.openblas.net/
$(openblas-src-0.3.21)-srcurl = https://github.com/xianyi/OpenBLAS/archive/v$(openblas-src-0.3.21-version).tar.gz
$(openblas-src-0.3.21)-builddeps =
$(openblas-src-0.3.21)-prereqs =
$(openblas-src-0.3.21)-src = $(pkgsrcdir)/openblas-$(notdir $($(openblas-src-0.3.21)-srcurl))

$($(openblas-src-0.3.21)-src): $(dir $($(openblas-src-0.3.21)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(openblas-src-0.3.21)-srcurl)

$(openblas-src-0.3.21)-src: $($(openblas-src-0.3.21)-src)
$(openblas-src-0.3.21)-unpack:
$(openblas-src-0.3.21)-patch:
$(openblas-src-0.3.21)-build:
$(openblas-src-0.3.21)-check:
$(openblas-src-0.3.21)-install:
$(openblas-src-0.3.21)-modulefile:
$(openblas-src-0.3.21)-clean:
	rm -rf $($(openblas-src-0.3.21)-src)
$(openblas-src-0.3.21): $(openblas-src-0.3.21)-src $(openblas-src-0.3.21)-unpack $(openblas-src-0.3.21)-patch $(openblas-src-0.3.21)-build $(openblas-src-0.3.21)-check $(openblas-src-0.3.21)-install $(openblas-src-0.3.21)-modulefile
