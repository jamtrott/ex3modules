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
# fenics-mshr-2019-src.1.0

fenics-mshr-2019-src-version = 2019.1.0
fenics-mshr-2019-src = fenics-mshr-2019-src-$(fenics-mshr-2019-src-version)
$(fenics-mshr-2019-src)-description = FEniCS Project: Mesh generation (source)
$(fenics-mshr-2019-src)-url = https://fenicsproject.org/
$(fenics-mshr-2019-src)-srcurl = https://bitbucket.org/fenics-project/mshr/downloads/mshr-$(fenics-mshr-2019-src-version).tar.gz
$(fenics-mshr-2019-src)-builddeps =
$(fenics-mshr-2019-src)-prereqs =
$(fenics-mshr-2019-src)-src = $(pkgsrcdir)/$(notdir $($(fenics-mshr-2019-src)-srcurl))

$($(fenics-mshr-2019-src)-src): $(dir $($(fenics-mshr-2019-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(fenics-mshr-2019-src)-srcurl)

$(fenics-mshr-2019-src)-src: $($(fenics-mshr-2019-src)-src)
$(fenics-mshr-2019-src)-unpack:
$(fenics-mshr-2019-src)-patch:
$(fenics-mshr-2019-src)-build:
$(fenics-mshr-2019-src)-check:
$(fenics-mshr-2019-src)-install:
$(fenics-mshr-2019-src)-modulefile:
$(fenics-mshr-2019-src)-clean:
	rm -rf $($(fenics-mshr-2019-src)-src)
$(fenics-mshr-2019-src): $(fenics-mshr-2019-src)-src $(fenics-mshr-2019-src)-unpack $(fenics-mshr-2019-src)-patch $(fenics-mshr-2019-src)-build $(fenics-mshr-2019-src)-check $(fenics-mshr-2019-src)-install $(fenics-mshr-2019-src)-modulefile
