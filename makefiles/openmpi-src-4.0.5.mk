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
# openmpi-src-4.0.5

openmpi-src-version = 4.0.5
openmpi-src = openmpi-src-$(openmpi-src-version)
$(openmpi-src)-description = A High Performance Message Passing Library (source)
$(openmpi-src)-url = https://www.open-mpi.org/
$(openmpi-src)-srcurl = https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-$(openmpi-src-version).tar.bz2
$(openmpi-src)-builddeps =
$(openmpi-src)-prereqs =
$(openmpi-src)-src = $(pkgsrcdir)/$(notdir $($(openmpi-src)-srcurl))

$($(openmpi-src)-src): $(dir $($(openmpi-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(openmpi-src)-srcurl)

$(openmpi-src)-src: $($(openmpi-src)-src)
$(openmpi-src)-unpack:
$(openmpi-src)-patch:
$(openmpi-src)-build:
$(openmpi-src)-check:
$(openmpi-src)-install:
$(openmpi-src)-modulefile:
$(openmpi-src)-clean:
	rm -rf $($(openmpi-src)-src)
$(openmpi-src): $(openmpi-src)-src $(openmpi-src)-unpack $(openmpi-src)-patch $(openmpi-src)-build $(openmpi-src)-check $(openmpi-src)-install $(openmpi-src)-modulefile
