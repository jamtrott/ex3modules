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
# hypre-src-2.17.0

hypre-src-version = 2.17.0
hypre-src = hypre-src-$(hypre-src-version)
$(hypre-src)-description = Scalable Linear Solvers and Multigrid Methods (source)
$(hypre-src)-url = https://github.com/hypre-space/hypre/
$(hypre-src)-srcurl = https://github.com/hypre-space/hypre/archive/v$(hypre-src-version).tar.gz
$(hypre-src)-builddeps =
$(hypre-src)-prereqs =
$(hypre-src)-src = $(pkgsrcdir)/$(notdir $($(hypre-src)-srcurl))

$($(hypre-src)-src): $(dir $($(hypre-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hypre-src)-srcurl)

$(hypre-src)-src: $($(hypre-src)-src)
$(hypre-src)-unpack:
$(hypre-src)-patch:
$(hypre-src)-build:
$(hypre-src)-check:
$(hypre-src)-install:
$(hypre-src)-modulefile:
$(hypre-src)-clean:
	rm -rf $($(hypre-src)-src)
$(hypre-src): $(hypre-src)-src $(hypre-src)-unpack $(hypre-src)-patch $(hypre-src)-build $(hypre-src)-check $(hypre-src)-install $(hypre-src)-modulefile
