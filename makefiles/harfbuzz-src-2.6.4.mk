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
# harfbuzz-src-2.6.4

harfbuzz-src-version = 2.6.4
harfbuzz-src = harfbuzz-src-$(harfbuzz-src-version)
$(harfbuzz-src)-description = Text shaping engine
$(harfbuzz-src)-url = https://www.freedesktop.org/wiki/Software/HarfBuzz/
$(harfbuzz-src)-srcurl = https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-$(harfbuzz-version).tar.xz
$(harfbuzz-src)-builddeps =
$(harfbuzz-src)-prereqs =
$(harfbuzz-src)-src = $(pkgsrcdir)/harfbuzz-$(notdir $($(harfbuzz-src)-srcurl))

$($(harfbuzz-src)-src): $(dir $($(harfbuzz-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(harfbuzz-src)-srcurl)

$(harfbuzz-src)-src: $($(harfbuzz-src)-src)
$(harfbuzz-src)-unpack:
$(harfbuzz-src)-patch:
$(harfbuzz-src)-build:
$(harfbuzz-src)-check:
$(harfbuzz-src)-install:
$(harfbuzz-src)-modulefile:
$(harfbuzz-src)-clean:
	rm -rf $($(harfbuzz-src)-src)
$(harfbuzz-src): $(harfbuzz-src)-src $(harfbuzz-src)-unpack $(harfbuzz-src)-patch $(harfbuzz-src)-build $(harfbuzz-src)-check $(harfbuzz-src)-install $(harfbuzz-src)-modulefile
