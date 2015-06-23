# $Id: sdccdefs.mk 604 2014-11-16 22:33:09Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2014-11-16   604   1.0    Initial version
#---
#
# sdcc 2.9 to 3.x transition handling ----------------------------------
#   default is sdcc 3.x; if SDCC29 is specified sdcc 2.9 is used
#

CC=sdcc

ifdef SDCC29
MAKELIBOPT=SDCC29=1
AS=asx8051
CC29COMPOPT=
else
MAKELIBOPT=
AS=sdas8051
CC29COMPOPT+=-DSDCC3XCOMPAT=1
CC29COMPOPT+=-Dat=__at
CC29COMPOPT+=-Dsfr=__sfr
CC29COMPOPT+=-Dsbit=__sbit
CC29COMPOPT+=-Dbit=__bit
CC29COMPOPT+=-Dxdata=__xdata
CC29COMPOPT+=-D_asm=__asm
CC29COMPOPT+=-D_endasm=__endasm
CC29COMPOPT+=-D_naked=__naked
CC29COMPOPT+=-Dinterrupt=__interrupt
endif
