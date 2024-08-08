# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2024 James D. Trotter
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
# openmpi-src-4.1.4

openmpi-src-4.1.4-version = 4.1.4
openmpi-src-4.1.4 = openmpi-src-$(openmpi-src-4.1.4-version)
$(openmpi-src-4.1.4)-description = A High Performance Message Passing Library (source)
$(openmpi-src-4.1.4)-url = https://www.open-mpi.org/
$(openmpi-src-4.1.4)-srcurl = https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-$(openmpi-src-4.1.4-version).tar.bz2
$(openmpi-src-4.1.4)-builddeps =
$(openmpi-src-4.1.4)-prereqs =
$(openmpi-src-4.1.4)-src = $(pkgsrcdir)/$(notdir $($(openmpi-src-4.1.4)-srcurl))

$($(openmpi-src-4.1.4)-src): $(dir $($(openmpi-src-4.1.4)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(openmpi-src-4.1.4)-srcurl)

$(openmpi-src-4.1.4)-src: $($(openmpi-src-4.1.4)-src)
$(openmpi-src-4.1.4)-unpack:
$(openmpi-src-4.1.4)-patch:
$(openmpi-src-4.1.4)-build:
$(openmpi-src-4.1.4)-check:
$(openmpi-src-4.1.4)-install:
$(openmpi-src-4.1.4)-modulefile:
$(openmpi-src-4.1.4)-clean:
	rm -rf $($(openmpi-src-4.1.4)-src)
$(openmpi-src-4.1.4): $(openmpi-src-4.1.4)-src $(openmpi-src-4.1.4)-unpack $(openmpi-src-4.1.4)-patch $(openmpi-src-4.1.4)-build $(openmpi-src-4.1.4)-check $(openmpi-src-4.1.4)-install $(openmpi-src-4.1.4)-modulefile
