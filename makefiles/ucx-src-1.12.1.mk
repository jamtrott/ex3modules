# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# ucx-src-1.12.1

ucx-src-version = 1.12.1
ucx-src = ucx-src-$(ucx-src-version)
$(ucx-src)-description = Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications (source)
$(ucx-src)-url = http://www.openucx.org/
$(ucx-src)-srcurl = https://github.com/openucx/ucx/archive/v$(ucx-src-version).tar.gz
$(ucx-src)-builddeps =
$(ucx-src)-prereqs =
$(ucx-src)-src = $(pkgsrcdir)/ucx-$(notdir $($(ucx-src)-srcurl))

$($(ucx-src)-src): $(dir $($(ucx-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ucx-src)-srcurl)

$(ucx-src)-src: $($(ucx-src)-src)
$(ucx-src)-unpack:
$(ucx-src)-patch:
$(ucx-src)-build:
$(ucx-src)-check:
$(ucx-src)-install:
$(ucx-src)-modulefile:
$(ucx-src)-clean:
	rm -rf $($(ucx-src)-src)
$(ucx-src): $(ucx-src)-src $(ucx-src)-unpack $(ucx-src)-patch $(ucx-src)-build $(ucx-src)-check $(ucx-src)-install $(ucx-src)-modulefile
