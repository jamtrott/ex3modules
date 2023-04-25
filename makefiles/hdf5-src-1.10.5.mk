# ex3modules - Makefiles for installing software on the eX3 cluster
# Copyright (C) 2023 James D. Trotter
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

hdf5-src-1.10.5-version = 1.10.5
hdf5-src-1.10.5 = hdf5-src-$(hdf5-src-version)
$(hdf5-src-1.10.5)-description = HDF5 high performance data software library and file format (source)
$(hdf5-src-1.10.5)-url = https://www.hdfgroup.org/solutions/hdf5/
$(hdf5-src-1.10.5)-srcurl = https://support.hdfgroup.org/ftp/HDF5/current/src/hdf5-$(hdf5-src-1.10.5-version).tar.gz
$(hdf5-src-1.10.5)-builddeps =
$(hdf5-src-1.10.5)-prereqs =
$(hdf5-src-1.10.5)-src = $(pkgsrcdir)/$(notdir $($(hdf5-src-1.10.5)-srcurl))

$($(hdf5-src-1.10.5)-src): $(dir $($(hdf5-src-1.10.5)-src)).markerfile
	$(CURL) $(curl_options) --output $@ $($(hdf5-src-1.10.5)-srcurl)

$(hdf5-src-1.10.5)-src: $($(hdf5-src-1.10.5)-src)
$(hdf5-src-1.10.5)-unpack:
$(hdf5-src-1.10.5)-patch:
$(hdf5-src-1.10.5)-build:
$(hdf5-src-1.10.5)-check:
$(hdf5-src-1.10.5)-install:
$(hdf5-src-1.10.5)-modulefile:
$(hdf5-src-1.10.5)-clean:
	rm -rf $($(hdf5-src-1.10.5)-src)
$(hdf5-src-1.10.5): $(hdf5-src-1.10.5)-src $(hdf5-src-1.10.5)-unpack $(hdf5-src-1.10.5)-patch $(hdf5-src-1.10.5)-build $(hdf5-src-1.10.5)-check $(hdf5-src-1.10.5)-install $(hdf5-src-1.10.5)-modulefile
