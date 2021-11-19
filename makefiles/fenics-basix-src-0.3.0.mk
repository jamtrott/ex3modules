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
# fenics-basix-src-0.3.0

fenics-basix-src-0.3.0-version = 0.3.0
fenics-basix-src-0.3.0 = fenics-basix-src-0.3.0-$(fenics-basix-src-0.3.0-version)
$(fenics-basix-src-0.3.0)-description = FEniCS Project: DOLFIN-X Source Code (Experimental)
$(fenics-basix-src-0.3.0)-url = https://github.com/FEniCS/basix/
$(fenics-basix-src-0.3.0)-srcurl = https://github.com/FEniCS/basix/archive/refs/tags/v0.3.0.tar.gz
$(fenics-basix-src-0.3.0)-builddeps =
$(fenics-basix-src-0.3.0)-prereqs =
$(fenics-basix-src-0.3.0)-src = $(pkgsrcdir)/fenics-basix-$(notdir $($(fenics-basix-src-0.3.0)-srcurl))

$($(fenics-basix-src-0.3.0)-src): $(dir $($(fenics-basix-src-0.3.0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fenics-basix-src-0.3.0)-srcurl)

$(fenics-basix-src-0.3.0)-src: $($(fenics-basix-src-0.3.0)-src)
$(fenics-basix-src-0.3.0)-unpack:
$(fenics-basix-src-0.3.0)-patch:
$(fenics-basix-src-0.3.0)-build:
$(fenics-basix-src-0.3.0)-check:
$(fenics-basix-src-0.3.0)-install:
$(fenics-basix-src-0.3.0)-modulefile:
$(fenics-basix-src-0.3.0)-clean:
	rm -rf $($(fenics-basix-src-0.3.0)-src)
$(fenics-basix-src-0.3.0): $(fenics-basix-src-0.3.0)-src $(fenics-basix-src-0.3.0)-unpack $(fenics-basix-src-0.3.0)-patch $(fenics-basix-src-0.3.0)-build $(fenics-basix-src-0.3.0)-check $(fenics-basix-src-0.3.0)-install $(fenics-basix-src-0.3.0)-modulefile
