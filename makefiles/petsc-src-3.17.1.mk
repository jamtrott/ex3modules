# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2022 James D. Trotter
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
# petsc-src-3.17.1

petsc-src-3.17.1-version = 3.17.1
petsc-src-3.17.1 = petsc-src-$(petsc-src-3.17.1-version)
$(petsc-src-3.17.1)-description = Portable, Extensible Toolkit for Scientific Computation (source)
$(petsc-src-3.17.1)-url = https://www.mcs.anl.gov/petsc/
$(petsc-src-3.17.1)-srcurl = http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-$(petsc-src-3.17.1-version).tar.gz
$(petsc-src-3.17.1)-builddeps =
$(petsc-src-3.17.1)-prereqs =
$(petsc-src-3.17.1)-src = $(pkgsrcdir)/$(notdir $($(petsc-src-3.17.1)-srcurl))

$($(petsc-src-3.17.1)-src): $(dir $($(petsc-src-3.17.1)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(petsc-src-3.17.1)-srcurl)

$(petsc-src-3.17.1)-src: $($(petsc-src-3.17.1)-src)
$(petsc-src-3.17.1)-unpack:
$(petsc-src-3.17.1)-patch:
$(petsc-src-3.17.1)-build:
$(petsc-src-3.17.1)-check:
$(petsc-src-3.17.1)-install:
$(petsc-src-3.17.1)-modulefile:
$(petsc-src-3.17.1)-clean:
	rm -rf $($(petsc-src-3.17.1)-src)
$(petsc-src-3.17.1): $(petsc-src-3.17.1)-src $(petsc-src-3.17.1)-unpack $(petsc-src-3.17.1)-patch $(petsc-src-3.17.1)-build $(petsc-src-3.17.1)-check $(petsc-src-3.17.1)-install $(petsc-src-3.17.1)-modulefile
