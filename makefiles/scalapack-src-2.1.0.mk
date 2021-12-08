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
# scalapack-src-2.1.0

scalapack-src-version = 2.1.0
scalapack-src = scalapack-src-$(scalapack-src-version)
$(scalapack-src)-description = Scalable Linear Algebra PACKage
$(scalapack-src)-url = http://www.netlib.org/scalapack/
$(scalapack-src)-srcurl = http://www.netlib.org/scalapack/scalapack-$(scalapack-src-version).tgz
$(scalapack-src)-builddeps =
$(scalapack-src)-prereqs =
$(scalapack-src)-src = $(pkgsrcdir)/$(notdir $($(scalapack-src)-srcurl))

$($(scalapack-src)-src): $(dir $($(scalapack-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(scalapack-src)-srcurl)

$(scalapack-src)-src: $($(scalapack-src)-src)
$(scalapack-src)-unpack:
$(scalapack-src)-patch:
$(scalapack-src)-build:
$(scalapack-src)-check:
$(scalapack-src)-install:
$(scalapack-src)-modulefile:
$(scalapack-src)-clean:
	rm -rf $($(scalapack-src)-src)
$(scalapack-src): $(scalapack-src)-src $(scalapack-src)-unpack $(scalapack-src)-patch $(scalapack-src)-build $(scalapack-src)-check $(scalapack-src)-install $(scalapack-src)-modulefile
