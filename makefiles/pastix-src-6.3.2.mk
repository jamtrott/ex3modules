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
# pastix-src-6.3.2

pastix-src-6.3.2-version = 6.3.2
pastix-src-6.3.2 = pastix-src-$(pastix-src-6.3.2-version)
$(pastix-src-6.3.2)-description = Parallel sparse direct solver
$(pastix-src-6.3.2)-url = https://gitlab.inria.fr/solverstack/pastix
$(pastix-src-6.3.2)-srcurl = https://gitlab.inria.fr/solverstack/pastix//uploads/32711239db22edb6c291282b581b9e0b/pastix-6.3.2.tar.gz
$(pastix-src-6.3.2)-builddeps =
$(pastix-src-6.3.2)-prereqs =
$(pastix-src-6.3.2)-src = $(pkgsrcdir)/pastix-$(notdir $($(pastix-src-6.3.2)-srcurl))

$($(pastix-src-6.3.2)-src): $(dir $($(pastix-src-6.3.2)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(pastix-src-6.3.2)-srcurl)

$(pastix-src-6.3.2)-src: $($(pastix-src-6.3.2)-src)
$(pastix-src-6.3.2)-unpack:
$(pastix-src-6.3.2)-patch:
$(pastix-src-6.3.2)-build:
$(pastix-src-6.3.2)-check:
$(pastix-src-6.3.2)-install:
$(pastix-src-6.3.2)-modulefile:
$(pastix-src-6.3.2)-clean:
	rm -rf $($(pastix-src-6.3.2)-src)
$(pastix-src-6.3.2): $(pastix-src-6.3.2)-src $(pastix-src-6.3.2)-unpack $(pastix-src-6.3.2)-patch $(pastix-src-6.3.2)-build $(pastix-src-6.3.2)-check $(pastix-src-6.3.2)-install $(pastix-src-6.3.2)-modulefile
