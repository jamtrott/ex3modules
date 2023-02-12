# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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
# fenics-dolfinx-src-0.5.2

fenics-dolfinx-src-0.5.2-version = 0.5.2
fenics-dolfinx-src-0.5.2 = fenics-dolfinx-src-$(fenics-dolfinx-src-0.5.2-version)
$(fenics-dolfinx-src-0.5.2)-description = Next generation FEniCS problem solving environment
$(fenics-dolfinx-src-0.5.2)-url = https://github.com/FEniCS/dolfinx
$(fenics-dolfinx-src-0.5.2)-srcurl = https://github.com/FEniCS/dolfinx/archive/refs/tags/v$(fenics-dolfinx-src-0.5.2-version).tar.gz
$(fenics-dolfinx-src-0.5.2)-builddeps =
$(fenics-dolfinx-src-0.5.2)-prereqs =
$(fenics-dolfinx-src-0.5.2)-src = $(pkgsrcdir)/$(notdir $($(fenics-dolfinx-src-0.5.2)-srcurl))

$($(fenics-dolfinx-src-0.5.2)-src): $(dir $($(fenics-dolfinx-src-0.5.2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fenics-dolfinx-src-0.5.2)-srcurl)

$(fenics-dolfinx-src-0.5.2)-src: $($(fenics-dolfinx-src-0.5.2)-src)
$(fenics-dolfinx-src-0.5.2)-unpack:
$(fenics-dolfinx-src-0.5.2)-patch:
$(fenics-dolfinx-src-0.5.2)-build:
$(fenics-dolfinx-src-0.5.2)-check:
$(fenics-dolfinx-src-0.5.2)-install:
$(fenics-dolfinx-src-0.5.2)-modulefile:
$(fenics-dolfinx-src-0.5.2)-clean:
	rm -rf $($(fenics-dolfinx-src-0.5.2)-src)
$(fenics-dolfinx-src-0.5.2): $(fenics-dolfinx-src-0.5.2)-src $(fenics-dolfinx-src-0.5.2)-unpack $(fenics-dolfinx-src-0.5.2)-patch $(fenics-dolfinx-src-0.5.2)-build $(fenics-dolfinx-src-0.5.2)-check $(fenics-dolfinx-src-0.5.2)-install $(fenics-dolfinx-src-0.5.2)-modulefile
