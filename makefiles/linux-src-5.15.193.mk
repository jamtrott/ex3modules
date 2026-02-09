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
# linux-src-5.15.193

linux-src-version = 5.15.193
linux-src = linux-src-$(linux-src-version)
$(linux-src)-description = Linux kernel source
$(linux-src)-url = https://www.kernel.org/
$(linux-src)-srcurl = https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$(linux-src-version).tar.xz
$(linux-src)-builddeps =
$(linux-src)-prereqs =
$(linux-src)-src = $(pkgsrcdir)/$(notdir $($(linux-src)-srcurl))

$($(linux-src)-src): $(dir $($(linux-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(linux-src)-srcurl)

$(linux-src)-src: $($(linux-src)-src)
$(linux-src)-unpack:
$(linux-src)-patch:
$(linux-src)-build:
$(linux-src)-check:
$(linux-src)-install:
$(linux-src)-modulefile:
$(linux-src)-clean:
	rm -rf $($(linux-src)-src)
$(linux-src): $(linux-src)-src $(linux-src)-unpack $(linux-src)-patch $(linux-src)-build $(linux-src)-check $(linux-src)-install $(linux-src)-modulefile
