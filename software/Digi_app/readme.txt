
  uTosNet_spi Digi application, readme.txt

  Simon Falsig
  University of Southern Denmark
  Copyright 2010

  This file is part of the uTosNet_spi Digi application

  The uTosNet_spi Digi application is free software: you can redistribute it 
  and/or modify it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the License,
  or (at your option) any later version.

  The uTosNet_spi Digi application is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with the uTosNet_spi Digi application. If not, see
  <http://www.gnu.org/licenses/>.


******************************************
* Description
******************************************
  The uTosNet_spi Digi application is meant for use with the Ethernet/SPI
  version of uTosNet. It provides the server application that should run
  on the Digi Connect ME 9210 microcontroller module, in order for it to
  work with the uTosNet_spi FPGA module and PC application.

******************************************
* Building
******************************************
  Use the Digi IDE to create a new project, and use the accompanying
  root.cxx file as the main file. Then build and download it according
  to standard Digi procedures.

******************************************
* Usage
******************************************
  The server application listens on port 50000, and uses a binary protocol.
  It accepts the following kinds of packets:
  (for all packets bit 31 is MSB, all unspecified bits should be '0')


  - Read request (32 bits):
    - Bit 29:    Set to '1'
    - Bit 25-16: Set to read address
    - Set all others to '0'

    Response (32 bits):
    - Bit 31-0:  Contains read data


  - Write request (2x32 bits):
    First 32 bits:
    - Bit 11:    Set to '1'
    - Bit 9-0:   Set to write address
    Second 32 bits:
    - Bit 31-0:  Set to write data

    Response: None


  - Combined read/write (2x32 bits)
    First 32 bits:
    - Bit 29:    Set to '1'
    - Bit 25-16: Set to read address
    - Bit 11:    Set to '1'
    - Bit 9-0:   Set to write address
    Second 32 bits:
    - Bit 31-0:  Set to write data

    Response (32 bits):
    - Bit 31-0:  Contains read data

******************************************
* End of file
******************************************
