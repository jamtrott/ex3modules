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
# ucx-src-1.17.0

ucx-src-1.17.0-version = 1.17.0
ucx-src-1.17.0 = ucx-src-1.17.0-$(ucx-src-1.17.0-version)
$(ucx-src-1.17.0)-description = Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications (source)
$(ucx-src-1.17.0)-url = http://www.openucx.org/
$(ucx-src-1.17.0)-srcurl = https://github.com/openucx/ucx/archive/v$(ucx-src-1.17.0-version).tar.gz
$(ucx-src-1.17.0)-builddeps =
$(ucx-src-1.17.0)-prereqs =
$(ucx-src-1.17.0)-src = $(pkgsrcdir)/ucx-$(notdir $($(ucx-src-1.17.0)-srcurl))

$($(ucx-src-1.17.0)-src): $(dir $($(ucx-src-1.17.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ucx-src-1.17.0)-srcurl)

$(ucx-src-1.17.0)-src: $($(ucx-src-1.17.0)-src)
$(ucx-src-1.17.0)-unpack:
$(ucx-src-1.17.0)-patch:
$(ucx-src-1.17.0)-build:
$(ucx-src-1.17.0)-check:
$(ucx-src-1.17.0)-install:
$(ucx-src-1.17.0)-modulefile:
$(ucx-src-1.17.0)-clean:
	rm -rf $($(ucx-src-1.17.0)-src)
$(ucx-src-1.17.0): $(ucx-src-1.17.0)-src $(ucx-src-1.17.0)-unpack $(ucx-src-1.17.0)-patch $(ucx-src-1.17.0)-build $(ucx-src-1.17.0)-check $(ucx-src-1.17.0)-install $(ucx-src-1.17.0)-modulefile
