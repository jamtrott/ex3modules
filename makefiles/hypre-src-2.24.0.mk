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
# hypre-src-2.24.0

hypre-src-2.24-version = 2.24.0
hypre-src-2.24 = hypre-src-$(hypre-src-2.24-version)
$(hypre-src-2.24)-description = Scalable Linear Solvers and Multigrid Methods (source)
$(hypre-src-2.24)-url = https://github.com/hypre-space/hypre/
$(hypre-src-2.24)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-src-2.24-version).tar.gz
$(hypre-src-2.24)-builddeps =
$(hypre-src-2.24)-prereqs =
$(hypre-src-2.24)-src = $(pkgsrcdir)/hypre-$(notdir $($(hypre-src-2.24)-srcurl))

$($(hypre-src-2.24)-src): $(dir $($(hypre-src-2.24)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hypre-src-2.24)-srcurl)

$(hypre-src-2.24)-src: $($(hypre-src-2.24)-src)
$(hypre-src-2.24)-unpack:
$(hypre-src-2.24)-patch:
$(hypre-src-2.24)-build:
$(hypre-src-2.24)-check:
$(hypre-src-2.24)-install:
$(hypre-src-2.24)-modulefile:
$(hypre-src-2.24)-clean:
	rm -rf $($(hypre-src-2.24)-src)
$(hypre-src-2.24): $(hypre-src-2.24)-src $(hypre-src-2.24)-unpack $(hypre-src-2.24)-patch $(hypre-src-2.24)-build $(hypre-src-2.24)-check $(hypre-src-2.24)-install $(hypre-src-2.24)-modulefile
