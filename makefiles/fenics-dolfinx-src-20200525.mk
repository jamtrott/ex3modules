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
# fenics-dolfinx-src-20200525

fenics-dolfinx-src-version = 20200525
fenics-dolfinx-src = fenics-dolfinx-src-$(fenics-dolfinx-src-version)
$(fenics-dolfinx-src)-description = FEniCS Project: DOLFIN-X Source Code (Experimental)
$(fenics-dolfinx-src)-url = https://github.com/FEniCS/dolfinx/
$(fenics-dolfinx-src)-srcurl = https://github.com/FEniCS/dolfinx/archive/29274633248cfbce175599ad2127d0949afdb166.zip
$(fenics-dolfinx-src)-builddeps =
$(fenics-dolfinx-src)-prereqs =
$(fenics-dolfinx-src)-src = $(pkgsrcdir)/$(notdir $($(fenics-dolfinx-src)-srcurl))

$($(fenics-dolfinx-src)-src): $(dir $($(fenics-dolfinx-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fenics-dolfinx-src)-srcurl)

$(fenics-dolfinx-src)-src: $($(fenics-dolfinx-src)-src)
$(fenics-dolfinx-src)-unpack:
$(fenics-dolfinx-src)-patch:
$(fenics-dolfinx-src)-build:
$(fenics-dolfinx-src)-check:
$(fenics-dolfinx-src)-install:
$(fenics-dolfinx-src)-modulefile:
$(fenics-dolfinx-src)-clean:
	rm -rf $($(fenics-dolfinx-src)-src)
$(fenics-dolfinx-src): $(fenics-dolfinx-src)-src $(fenics-dolfinx-src)-unpack $(fenics-dolfinx-src)-patch $(fenics-dolfinx-src)-build $(fenics-dolfinx-src)-check $(fenics-dolfinx-src)-install $(fenics-dolfinx-src)-modulefile
