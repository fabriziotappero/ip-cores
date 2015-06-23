/*!
   btcminer -- BTCMiner for ZTEX USB-FPGA Modules: EZ-USB FX2 firmware for ZTEX USB FPGA Module 1.15d (one double hash pipe)
   Copyright (C) 2011-2012 ZTEX GmbH
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

#define[NUM_NONCES][1]
#define[EXTRA_SOLUTIONS][1]
#define[OFFS_NONCES][0]
#define[F_MULT][50]
//#define[F_MAX_MULT][54]
#define[F_MAX_MULT][62]
#define[HASHES_PER_CLOCK][128]
#define[BITFILE_STRING]["ztex_ufm1_15d4"]

#define[F_M1][400]
#define[F_DIV][6]
#define[F_MIN_MULT][25]

#include[btcminer.h]
