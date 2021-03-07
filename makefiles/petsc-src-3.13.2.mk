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
# petsc-src-3.13.2

petsc-src-version = 3.13.2
petsc-src = petsc-src-$(petsc-src-version)
$(petsc-src)-description = Portable, Extensible Toolkit for Scientific Computation (source)
$(petsc-src)-url = https://www.mcs.anl.gov/petsc/
$(petsc-src)-srcurl = http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-$(petsc-src-version).tar.gz
$(petsc-src)-builddeps =
$(petsc-src)-prereqs =
$(petsc-src)-src = $(pkgsrcdir)/$(notdir $($(petsc-src)-srcurl))

$($(petsc-src)-src): $(dir $($(petsc-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(petsc-src)-srcurl)

$(petsc-src)-src: $($(petsc-src)-src)
$(petsc-src)-unpack:
$(petsc-src)-patch:
$(petsc-src)-build:
$(petsc-src)-check:
$(petsc-src)-install:
$(petsc-src)-modulefile:
$(petsc-src)-clean:
	rm -rf $($(petsc-src)-src)
$(petsc-src): $(petsc-src)-src $(petsc-src)-unpack $(petsc-src)-patch $(petsc-src)-build $(petsc-src)-check $(petsc-src)-install $(petsc-src)-modulefile
