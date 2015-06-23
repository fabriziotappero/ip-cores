/*!
   btcminer -- BTCMiner for ZTEX USB-FPGA Modules: EZ-USB FX2 firmware for ZTEX USB FPGA Module 1.15b (one single hash pipe)
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
#define[EXTRA_SOLUTIONS][0]
#define[OFFS_NONCES][130]
#define[F_MULT][23]
#define[F_MAX_MULT][28]
#define[HASHES_PER_CLOCK][64]
#define[BITFILE_STRING]["ztex_ufm1_15b1"]

#include[btcminer.h]
