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
# hypre-src-2.26.0

hypre-src-2.26-version = 2.26.0
hypre-src-2.26 = hypre-src-$(hypre-src-2.26-version)
$(hypre-src-2.26)-description = Scalable Linear Solvers and Multigrid Methods (source)
$(hypre-src-2.26)-url = https://github.com/hypre-space/hypre/
$(hypre-src-2.26)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-src-2.26-version).tar.gz
$(hypre-src-2.26)-builddeps =
$(hypre-src-2.26)-prereqs =
$(hypre-src-2.26)-src = $(pkgsrcdir)/hypre-$(notdir $($(hypre-src-2.26)-srcurl))

$($(hypre-src-2.26)-src): $(dir $($(hypre-src-2.26)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hypre-src-2.26)-srcurl)

$(hypre-src-2.26)-src: $($(hypre-src-2.26)-src)
$(hypre-src-2.26)-unpack:
$(hypre-src-2.26)-patch:
$(hypre-src-2.26)-build:
$(hypre-src-2.26)-check:
$(hypre-src-2.26)-install:
$(hypre-src-2.26)-modulefile:
$(hypre-src-2.26)-clean:
	rm -rf $($(hypre-src-2.26)-src)
$(hypre-src-2.26): $(hypre-src-2.26)-src $(hypre-src-2.26)-unpack $(hypre-src-2.26)-patch $(hypre-src-2.26)-build $(hypre-src-2.26)-check $(hypre-src-2.26)-install $(hypre-src-2.26)-modulefile
