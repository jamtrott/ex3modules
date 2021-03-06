# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2021 James D. Trotter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as puhdf5hed by
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
# hdf5-src-1.10.5

hdf5-src-version = 1.10.5
hdf5-src = hdf5-src-$(hdf5-src-version)
$(hdf5-src)-description = HDF5 high performance data software library and file format (source)
$(hdf5-src)-url = https://www.hdfgroup.org/solutions/hdf5/
$(hdf5-src)-srcurl = https://support.hdfgroup.org/ftp/HDF5/current/src/hdf5-$(hdf5-src-version).tar.gz
$(hdf5-src)-builddeps =
$(hdf5-src)-prereqs =
$(hdf5-src)-src = $(pkgsrcdir)/$(notdir $($(hdf5-src)-srcurl))

$($(hdf5-src)-src): $(dir $($(hdf5-src)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hdf5-src)-srcurl)

$(hdf5-src)-src: $($(hdf5-src)-src)
$(hdf5-src)-unpack:
$(hdf5-src)-patch:
$(hdf5-src)-build:
$(hdf5-src)-check:
$(hdf5-src)-install:
$(hdf5-src)-modulefile:
$(hdf5-src)-clean:
	rm -rf $($(hdf5-src)-src)
$(hdf5-src): $(hdf5-src)-src $(hdf5-src)-unpack $(hdf5-src)-patch $(hdf5-src)-build $(hdf5-src)-check $(hdf5-src)-install $(hdf5-src)-modulefile
