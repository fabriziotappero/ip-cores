#*$$HEADER*#
#******************************************************************************#
#*                                                                            *#
#*                    H E A D E R   I N F O R M A T I O N                     *#
#*                                                                            *#
#******************************************************************************#

## Project Name                   : ORPSoC v2
## File Name                      : Makefile
## Prepared By                    : 
## Project Start                  : 

#*$$COPYRIGHT NOTICE*#
#******************************************************************************#
#*                                                                            *#
#*                      C O P Y R I G H T   N O T I C E                       *#
#*                                                                            *#
#******************************************************************************#
#*
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; 
#  version 2.1 of the License, a copy of which is available from
#  http://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#*$$DESCRIPTION*#
#******************************************************************************#
#*                                                                            *#
#*                           D E S C R I P T I O N                            *#
#*                                                                            *#
#******************************************************************************#
##
## Makefile for the ORPSoC software utilities
##

PROGRAMS = bin2c bin2srec bin2flimg bin2hex bin2vmem
# NB: 'loader' not in that list

CC     = gcc
CFLAGS = -O2 -Wall

% : %.c
	@/bin/rm -f $@
	$(CC) -o $@ $(CFLAGS) $<

all: $(PROGRAMS)

clean:
	/bin/rm -f $(PROGRAMS) *~ *.bak
