# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2020 James D. Trotter
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
# fenics-dolfinx-src-0.3.0

fenics-dolfinx-src-0.3.0-version = 0.3.0
fenics-dolfinx-src-0.3.0 = fenics-dolfinx-src-0.3.0-$(fenics-dolfinx-src-0.3.0-version)
$(fenics-dolfinx-src-0.3.0)-description = FEniCS Project: DOLFIN-X Source Code (Experimental)
$(fenics-dolfinx-src-0.3.0)-url = https://github.com/FEniCS/dolfinx/
$(fenics-dolfinx-src-0.3.0)-srcurl = https://github.com/FEniCS/dolfinx/archive/refs/tags/v0.3.0.tar.gz
$(fenics-dolfinx-src-0.3.0)-builddeps =
$(fenics-dolfinx-src-0.3.0)-prereqs =
$(fenics-dolfinx-src-0.3.0)-src = $(pkgsrcdir)/fenics-dolfinx-$(notdir $($(fenics-dolfinx-src-0.3.0)-srcurl))

$($(fenics-dolfinx-src-0.3.0)-src): $(dir $($(fenics-dolfinx-src-0.3.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fenics-dolfinx-src-0.3.0)-srcurl)

$(fenics-dolfinx-src-0.3.0)-src: $($(fenics-dolfinx-src-0.3.0)-src)
$(fenics-dolfinx-src-0.3.0)-unpack:
$(fenics-dolfinx-src-0.3.0)-patch:
$(fenics-dolfinx-src-0.3.0)-build:
$(fenics-dolfinx-src-0.3.0)-check:
$(fenics-dolfinx-src-0.3.0)-install:
$(fenics-dolfinx-src-0.3.0)-modulefile:
$(fenics-dolfinx-src-0.3.0)-clean:
	rm -rf $($(fenics-dolfinx-src-0.3.0)-src)
$(fenics-dolfinx-src-0.3.0): $(fenics-dolfinx-src-0.3.0)-src $(fenics-dolfinx-src-0.3.0)-unpack $(fenics-dolfinx-src-0.3.0)-patch $(fenics-dolfinx-src-0.3.0)-build $(fenics-dolfinx-src-0.3.0)-check $(fenics-dolfinx-src-0.3.0)-install $(fenics-dolfinx-src-0.3.0)-modulefile
