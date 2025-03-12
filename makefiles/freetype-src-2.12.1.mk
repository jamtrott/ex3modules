# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2025 James D. Trotter
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
# freetype-src-2.12.1

freetype-src-version = 2.12.1
freetype-src = freetype-src-$(freetype-src-version)
$(freetype-src)-description = Font rendering library
$(freetype-src)-url = https://www.freetype.org/
$(freetype-src)-srcurl = https://download.savannah.gnu.org/releases/freetype/freetype-$(freetype-src-version).tar.gz
$(freetype-src)-builddeps =
$(freetype-src)-prereqs =
$(freetype-src)-src = $(pkgsrcdir)/freetype-$(notdir $($(freetype-src)-srcurl))

$($(freetype-src)-src): $(dir $($(freetype-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(freetype-src)-srcurl)

$(freetype-src)-src: $($(freetype-src)-src)
$(freetype-src)-unpack:
$(freetype-src)-patch:
$(freetype-src)-build:
$(freetype-src)-check:
$(freetype-src)-install:
$(freetype-src)-modulefile:
$(freetype-src)-clean:
	rm -rf $($(freetype-src)-src)
$(freetype-src): $(freetype-src)-src $(freetype-src)-unpack $(freetype-src)-patch $(freetype-src)-build $(freetype-src)-check $(freetype-src)-install $(freetype-src)-modulefile
