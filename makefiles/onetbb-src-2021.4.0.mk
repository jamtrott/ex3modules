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
# onetbb-src-2021.4.0

onetbb-src-version = 2021.4.0
onetbb-src = onetbb-src-$(onetbb-src-version)
$(onetbb-src)-description =  oneAPI Threading Building Blocks shared-memory parallel C++ framework (source)
$(onetbb-src)-url = https://oneapi-src.github.io/oneTBB/
$(onetbb-src)-srcurl = https://github.com/oneapi-src/oneTBB/archive/refs/tags/v$(onetbb-src-version).tar.gz
$(onetbb-src)-builddeps =
$(onetbb-src)-prereqs =
$(onetbb-src)-src = $(pkgsrcdir)/onetbb-$(notdir $($(onetbb-src)-srcurl))

$($(onetbb-src)-src): $(dir $($(onetbb-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(onetbb-src)-srcurl)

$(onetbb-src)-src: $($(onetbb-src)-src)
$(onetbb-src)-unpack:
$(onetbb-src)-patch:
$(onetbb-src)-build:
$(onetbb-src)-check:
$(onetbb-src)-install:
$(onetbb-src)-modulefile:
$(onetbb-src)-clean:
	rm -rf $($(onetbb-src)-src)
$(onetbb-src): $(onetbb-src)-src $(onetbb-src)-unpack $(onetbb-src)-patch $(onetbb-src)-build $(onetbb-src)-check $(onetbb-src)-install $(onetbb-src)-modulefile
