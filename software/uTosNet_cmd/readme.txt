
  uTosNet commandline utility, readme.txt

  Simon Falsig
  University of Southern Denmark
  Copyright 2010

  This file is part of the uTosnet commandline utility

  The uTosnet commandline utility is free software: you can redistribute it 
  and/or modify it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the License,
  or (at your option) any later version.

  The uTosnet commandline utility is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with the uTosnet commandline utility. If not, see
  <http://www.gnu.org/licenses/>.


******************************************
* Description
******************************************
  The uTosNet commandline utility is meant for use with the Ethernet/SPI
  version of uTosNet. It provides a simple interface for reading and writing
  data from and to the shared memory block inside the FPGA.

******************************************
* Building
******************************************
  The uTosNet commandline utility uses the Qt framework (http://qt.nokia.com/)
  for crossplatform socket functionality. A working installation of Qt is thus
  necessary.
  Otherwise the utility itself is rather simple, and should work with most
  compilers.

  Run:
    qmake uTosNet_cmd.pro
    make release

******************************************
* Usage
******************************************
  utosnet_cmd host {W|R} address [data]

    host     The IP address of the host to connect to
    W        Perform a write operation
    R        Perform a read operation
    address  The shared memory address to access
    data     The data to write (only required when performing a write)

******************************************
* End of file
******************************************
