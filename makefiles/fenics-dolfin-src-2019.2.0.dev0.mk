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
# fenics-dolfin-src-2019.2.0.dev0

fenics-dolfin-src-2019.2.0.dev0-version = 2019.2.0.dev0
fenics-dolfin-src-2019.2.0.dev0 = fenics-dolfin-src-2019.2.0.dev0-$(fenics-dolfin-src-2019.2.0.dev0-version)
$(fenics-dolfin-src-2019.2.0.dev0)-description = FEniCS Project: DOLFIN (source)
$(fenics-dolfin-src-2019.2.0.dev0)-url = https://fenicsproject.org/
$(fenics-dolfin-src-2019.2.0.dev0)-srcurl = https://bitbucket.org/fenics-project/dolfin/get/fd662efc1c0ddefa341c1dac753f717f6b6292a8.tar.gz
$(fenics-dolfin-src-2019.2.0.dev0)-builddeps =
$(fenics-dolfin-src-2019.2.0.dev0)-prereqs =
$(fenics-dolfin-src-2019.2.0.dev0)-src = $(pkgsrcdir)/$(notdir $($(fenics-dolfin-src-2019.2.0.dev0)-srcurl))

$($(fenics-dolfin-src-2019.2.0.dev0)-src): $(dir $($(fenics-dolfin-src-2019.2.0.dev0)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fenics-dolfin-src-2019.2.0.dev0)-srcurl)

$(fenics-dolfin-src-2019.2.0.dev0)-src: $($(fenics-dolfin-src-2019.2.0.dev0)-src)
$(fenics-dolfin-src-2019.2.0.dev0)-unpack:
$(fenics-dolfin-src-2019.2.0.dev0)-patch:
$(fenics-dolfin-src-2019.2.0.dev0)-build:
$(fenics-dolfin-src-2019.2.0.dev0)-check:
$(fenics-dolfin-src-2019.2.0.dev0)-install:
$(fenics-dolfin-src-2019.2.0.dev0)-modulefile:
$(fenics-dolfin-src-2019.2.0.dev0)-clean:
	rm -rf $($(fenics-dolfin-src-2019.2.0.dev0)-src)
$(fenics-dolfin-src-2019.2.0.dev0): $(fenics-dolfin-src-2019.2.0.dev0)-src $(fenics-dolfin-src-2019.2.0.dev0)-unpack $(fenics-dolfin-src-2019.2.0.dev0)-patch $(fenics-dolfin-src-2019.2.0.dev0)-build $(fenics-dolfin-src-2019.2.0.dev0)-check $(fenics-dolfin-src-2019.2.0.dev0)-install $(fenics-dolfin-src-2019.2.0.dev0)-modulefile
