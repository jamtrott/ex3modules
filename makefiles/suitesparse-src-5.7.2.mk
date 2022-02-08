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
# suitesparse-src-5.7.2

suitesparse-src-version = 5.7.2
suitesparse-src = suitesparse-src-$(suitesparse-src-version)
$(suitesparse-src)-description = A suite of sparse matrix software
$(suitesparse-src)-url = http://faculty.cse.tamu.edu/davis/suitesparse.html
$(suitesparse-src)-srcurl = https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v$(suitesparse-src-version).tar.gz
$(suitesparse-src)-builddeps =
$(suitesparse-src)-prereqs =
$(suitesparse-src)-src = $(pkgsrcdir)/suitesparse-$(notdir $($(suitesparse-src)-srcurl))

$($(suitesparse-src)-src): $(dir $($(suitesparse-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(suitesparse-src)-srcurl)

$(suitesparse-src)-src: $($(suitesparse-src)-src)
$(suitesparse-src)-unpack:
$(suitesparse-src)-patch:
$(suitesparse-src)-build:
$(suitesparse-src)-check:
$(suitesparse-src)-install:
$(suitesparse-src)-modulefile:
$(suitesparse-src)-clean:
	rm -rf $($(suitesparse-src)-src)
$(suitesparse-src): $(suitesparse-src)-src $(suitesparse-src)-unpack $(suitesparse-src)-patch $(suitesparse-src)-build $(suitesparse-src)-check $(suitesparse-src)-install $(suitesparse-src)-modulefile
