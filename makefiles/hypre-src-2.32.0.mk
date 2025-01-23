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
# hypre-src-2.32.0

hypre-src-2.32.0-version = 2.32.0
hypre-src-2.32.0 = hypre-src-$(hypre-src-2.32.0-version)
$(hypre-src-2.32.0)-description = Scalable Linear Solvers and Multigrid Methods (source)
$(hypre-src-2.32.0)-url = https://github.com/hypre-space/hypre/
$(hypre-src-2.32.0)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-src-2.32.0-version).tar.gz
$(hypre-src-2.32.0)-builddeps =
$(hypre-src-2.32.0)-prereqs =
$(hypre-src-2.32.0)-src = $(pkgsrcdir)/hypre-$(notdir $($(hypre-src-2.32.0)-srcurl))

$($(hypre-src-2.32.0)-src): $(dir $($(hypre-src-2.32.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hypre-src-2.32.0)-srcurl)

$(hypre-src-2.32.0)-src: $($(hypre-src-2.32.0)-src)
$(hypre-src-2.32.0)-unpack:
$(hypre-src-2.32.0)-patch:
$(hypre-src-2.32.0)-build:
$(hypre-src-2.32.0)-check:
$(hypre-src-2.32.0)-install:
$(hypre-src-2.32.0)-modulefile:
$(hypre-src-2.32.0)-clean:
	rm -rf $($(hypre-src-2.32.0)-src)
$(hypre-src-2.32.0): $(hypre-src-2.32.0)-src $(hypre-src-2.32.0)-unpack $(hypre-src-2.32.0)-patch $(hypre-src-2.32.0)-build $(hypre-src-2.32.0)-check $(hypre-src-2.32.0)-install $(hypre-src-2.32.0)-modulefile
