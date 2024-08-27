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

ucx-src-1.12.1-version = 1.12.1
ucx-src-1.12.1 = ucx-src-1.12.1-$(ucx-src-1.12.1-version)
$(ucx-src-1.12.1)-description = Optimized communication layer for MPI, PGAS/OpenSHMEM and RPC/data-centric applications (source)
$(ucx-src-1.12.1)-url = http://www.openucx.org/
$(ucx-src-1.12.1)-srcurl = https://github.com/openucx/ucx/archive/v$(ucx-src-1.12.1-version).tar.gz
$(ucx-src-1.12.1)-builddeps =
$(ucx-src-1.12.1)-prereqs =
$(ucx-src-1.12.1)-src = $(pkgsrcdir)/ucx-$(notdir $($(ucx-src-1.12.1)-srcurl))

$($(ucx-src-1.12.1)-src): $(dir $($(ucx-src-1.12.1)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(ucx-src-1.12.1)-srcurl)

$(ucx-src-1.12.1)-src: $($(ucx-src-1.12.1)-src)
$(ucx-src-1.12.1)-unpack:
$(ucx-src-1.12.1)-patch:
$(ucx-src-1.12.1)-build:
$(ucx-src-1.12.1)-check:
$(ucx-src-1.12.1)-install:
$(ucx-src-1.12.1)-modulefile:
$(ucx-src-1.12.1)-clean:
	rm -rf $($(ucx-src-1.12.1)-src)
$(ucx-src-1.12.1): $(ucx-src-1.12.1)-src $(ucx-src-1.12.1)-unpack $(ucx-src-1.12.1)-patch $(ucx-src-1.12.1)-build $(ucx-src-1.12.1)-check $(ucx-src-1.12.1)-install $(ucx-src-1.12.1)-modulefile
