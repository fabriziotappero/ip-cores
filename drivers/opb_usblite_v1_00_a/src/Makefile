#--
#--    opb_usblite - opb_uartlite replacement
#--
#--    opb_usblite is using components from Rudolf Usselmann see
#--    http://www.opencores.org/cores/usb_phy/
#--    and Joris van Rantwijk see http://www.xs4all.nl/~rjoris/fpga/usb.html
#--
#--    Copyright (C) 2010 Ake Rehnman
#--
#--    This program is free software: you can redistribute it and/or modify
#--    it under the terms of the GNU Lesser General Public License as published by
#--    the Free Software Foundation, either version 3 of the License, or
#--    (at your option) any later version.
#--
#--    This program is distributed in the hope that it will be useful,
#--    but WITHOUT ANY WARRANTY; without even the implied warranty of
#--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#--    GNU Lesser General Public License for more details.
#--
#--    You should have received a copy of the GNU Lesser General Public License
#--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#--


COMPILER=
ARCHIVER=
CP=cp
COMPILER_FLAGS=
EXTRA_COMPILER_FLAGS=
LIB=libxil.a

RELEASEDIR=../../../lib
INCLUDEDIR=../../../include
INCLUDES=-I./. -I${INCLUDEDIR}

INCLUDEFILES=usblite_l.h
LIBSOURCES=*.c
OUTS = *.o 


libs:
	echo "Compiling usblite"
	$(COMPILER) $(COMPILER_FLAGS) $(EXTRA_COMPILER_FLAGS) $(INCLUDES) $(LIBSOURCES)
	$(ARCHIVER) -r ${RELEASEDIR}/${LIB} ${OUTS} 
	make clean

include: 
	 ${CP} ${INCLUDEFILES} ${INCLUDEDIR}

clean:
	rm -rf ${OUTS}

