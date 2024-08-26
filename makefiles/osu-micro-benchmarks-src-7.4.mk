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
# osu-micro-benchmarks-src-7.4

osu-micro-benchmarks-src-version = 7.4
osu-micro-benchmarks-src = osu-micro-benchmarks-$(osu-micro-benchmarks-src-version)
$(osu-micro-benchmarks-src)-description = Benchmarks for MPI, OpenSHMEM, UPC and UPC++
$(osu-micro-benchmarks-src)-url = http://mvapich.cse.ohio-state.edu/benchmarks/
$(osu-micro-benchmarks-src)-srcurl = http://mvapich.cse.ohio-state.edu/download/mvapich/$(osu-micro-benchmarks-src).tar.gz
$(osu-micro-benchmarks-src)-builddeps =
$(osu-micro-benchmarks-src)-prereqs =
$(osu-micro-benchmarks-src)-src = $(pkgsrcdir)/$(notdir $($(osu-micro-benchmarks-src)-srcurl))

$($(osu-micro-benchmarks-src)-src): $(dir $($(osu-micro-benchmarks-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(osu-micro-benchmarks-src)-srcurl)

$(osu-micro-benchmarks-src)-src: $($(osu-micro-benchmarks-src)-src)
$(osu-micro-benchmarks-src)-unpack:
$(osu-micro-benchmarks-src)-patch:
$(osu-micro-benchmarks-src)-build:
$(osu-micro-benchmarks-src)-check:
$(osu-micro-benchmarks-src)-install:
$(osu-micro-benchmarks-src)-modulefile:
$(osu-micro-benchmarks-src)-clean:
	rm -rf $($(osu-micro-benchmarks-src)-src)
$(osu-micro-benchmarks-src): $(osu-micro-benchmarks-src)-src $(osu-micro-benchmarks-src)-unpack $(osu-micro-benchmarks-src)-patch $(osu-micro-benchmarks-src)-build $(osu-micro-benchmarks-src)-check $(osu-micro-benchmarks-src)-install $(osu-micro-benchmarks-src)-modulefile
