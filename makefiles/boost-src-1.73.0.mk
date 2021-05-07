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
# boost-src-1.73.0

boost-src-version = 1.73.0
boost-src = boost-src-$(boost-src-version)
$(boost-src)-description = Libraries for the C++ programming language
$(boost-src)-url = https://www.boost.org/
$(boost-src)-srcurl = https://boostorg.jfrog.io/artifactory/main/release/${boost-src-version}/source/boost_$(subst .,_,$(boost-src-version)).tar.bz2
$(boost-src)-builddeps =
$(boost-src)-prereqs =
$(boost-src)-src = $(pkgsrcdir)/$(notdir $($(boost-src)-srcurl))

$($(boost-src)-src): $(dir $($(boost-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(boost-src)-srcurl)

$(boost-src)-src: $($(boost-src)-src)
$(boost-src)-unpack:
$(boost-src)-patch:
$(boost-src)-build:
$(boost-src)-check:
$(boost-src)-install:
$(boost-src)-modulefile:
$(boost-src)-clean:
	rm -rf $($(boost-src)-src)
$(boost-src): $(boost-src)-src $(boost-src)-unpack $(boost-src)-patch $(boost-src)-build $(boost-src)-check $(boost-src)-install $(boost-src)-modulefile
