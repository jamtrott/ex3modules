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
# boost-src-1.73.0

boost-src-1.73.0-version = 1.73.0
boost-src-1.73.0 = boost-src-$(boost-src-1.73.0-version)
$(boost-src-1.73.0)-description = Libraries for the C++ programming language
$(boost-src-1.73.0)-url = https://www.boost.org/
$(boost-src-1.73.0)-srcurl = https://boostorg.jfrog.io/artifactory/main/release/${boost-src-1.73.0-version}/source/boost_$(subst .,_,$(boost-src-1.73.0-version)).tar.bz2
$(boost-src-1.73.0)-builddeps =
$(boost-src-1.73.0)-prereqs =
$(boost-src-1.73.0)-src = $(pkgsrcdir)/$(notdir $($(boost-src-1.73.0)-srcurl))

$($(boost-src-1.73.0)-src): $(dir $($(boost-src-1.73.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(boost-src-1.73.0)-srcurl)

$(boost-src-1.73.0)-src: $($(boost-src-1.73.0)-src)
$(boost-src-1.73.0)-unpack:
$(boost-src-1.73.0)-patch:
$(boost-src-1.73.0)-build:
$(boost-src-1.73.0)-check:
$(boost-src-1.73.0)-install:
$(boost-src-1.73.0)-modulefile:
$(boost-src-1.73.0)-clean:
	rm -rf $($(boost-src-1.73.0)-src)
$(boost-src-1.73.0): $(boost-src-1.73.0)-src $(boost-src-1.73.0)-unpack $(boost-src-1.73.0)-patch $(boost-src-1.73.0)-build $(boost-src-1.73.0)-check $(boost-src-1.73.0)-install $(boost-src-1.73.0)-modulefile
