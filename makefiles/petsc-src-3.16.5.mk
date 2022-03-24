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
# petsc-src-3.16.5

petsc-src-3.16.5-version = 3.16.5
petsc-src-3.16.5 = petsc-src-$(petsc-src-3.16.5-version)
$(petsc-src-3.16.5)-description = Portable, Extensible Toolkit for Scientific Computation (source)
$(petsc-src-3.16.5)-url = https://www.mcs.anl.gov/petsc/
$(petsc-src-3.16.5)-srcurl = http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-$(petsc-src-3.16.5-version).tar.gz
$(petsc-src-3.16.5)-builddeps =
$(petsc-src-3.16.5)-prereqs =
$(petsc-src-3.16.5)-src = $(pkgsrcdir)/$(notdir $($(petsc-src-3.16.5)-srcurl))

$($(petsc-src-3.16.5)-src): $(dir $($(petsc-src-3.16.5)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(petsc-src-3.16.5)-srcurl)

$(petsc-src-3.16.5)-src: $($(petsc-src-3.16.5)-src)
$(petsc-src-3.16.5)-unpack:
$(petsc-src-3.16.5)-patch:
$(petsc-src-3.16.5)-build:
$(petsc-src-3.16.5)-check:
$(petsc-src-3.16.5)-install:
$(petsc-src-3.16.5)-modulefile:
$(petsc-src-3.16.5)-clean:
	rm -rf $($(petsc-src-3.16.5)-src)
$(petsc-src-3.16.5): $(petsc-src-3.16.5)-src $(petsc-src-3.16.5)-unpack $(petsc-src-3.16.5)-patch $(petsc-src-3.16.5)-build $(petsc-src-3.16.5)-check $(petsc-src-3.16.5)-install $(petsc-src-3.16.5)-modulefile
