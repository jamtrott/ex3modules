# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2020 James D. Trotter
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
# blis-src-0.7.0

blis-src-version = 0.7.0
blis-src = blis-src-$(blis-src-version)
$(blis-src)-description = Framework for instantiating high-performance BLAS-like dense linear algebra libraries
$(blis-src)-url = https://github.com/flame/blis
$(blis-src)-srcurl = https://github.com/flame/blis/archive/$(blis-src-version).tar.gz
$(blis-src)-builddeps =
$(blis-src)-prereqs =
$(blis-src)-src = $(pkgsrcdir)/blis-$(notdir $($(blis-src)-srcurl))

$($(blis-src)-src): $(dir $($(blis-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(blis-src)-srcurl)

$(blis-src)-src: $($(blis-src)-src)
$(blis-src)-unpack:
$(blis-src)-patch:
$(blis-src)-build:
$(blis-src)-check:
$(blis-src)-install:
$(blis-src)-modulefile:
$(blis-src)-clean:
	rm -rf $($(blis-src)-src)
$(blis-src): $(blis-src)-src $(blis-src)-unpack $(blis-src)-patch $(blis-src)-build $(blis-src)-check $(blis-src)-install $(blis-src)-modulefile
