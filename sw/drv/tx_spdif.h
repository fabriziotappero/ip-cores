/*********************************************************************
****                                                              ****
**** WISHBONE SPDIF IP Core                                       ****
****                                                              ****
**** This file is part of the SPDIF project                       ****
**** http://www.opencores.org/cores/spdif_interface/              ****
****                                                              ****
**** Description                                                  ****
**** Definitions for the SPDIF transmitter.                       ****
****                                                              ****
****                                                              ****
**** To Do:                                                       ****
**** -                                                            ****
****                                                              ****
**** Author(s):                                                   ****
**** - Geir Drange, gedra@opencores.org                           ****
****                                                              ****
**********************************************************************
****                                                              ****
**** Copyright (C) 2004 Authors and OPENCORES.ORG                 ****
****                                                              ****
**** This source file may be used and distributed without         ****
**** restriction provided that this copyright statement is not    ****
**** removed from the file and that any derivative work contains  ****
**** the original copyright notice and the associated disclaimer. ****
****                                                              ****
**** This source file is free software; you can redistribute it   ****
**** and/or modify it under the terms of the GNU Lesser General   ****
**** Public License as published by the Free Software Foundation; ****
**** either version 2.1 of the License, or (at your option) any   ****
**** later version.                                               ****
****                                                              ****
**** This source is distributed in the hope that it will be       ****
**** useful, but WITHOUT ANY WARRANTY; without even the implied   ****
**** warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ****
**** PURPOSE. See the GNU Lesser General Public License for more  ****
**** details.                                                     ****
****                                                              ****
**** You should have received a copy of the GNU Lesser General    ****
**** Public License along with this source; if not, download it   ****
**** from http://www.opencores.org/lgpl.shtml                     ****
****                                                              ****
**********************************************************************
**
** CVS Revision History
**
** $Log: not supported by cvs2svn $
**
**/

#ifndef _tx_spdif_
#define _tx_spdif_

/*** Register definitions ********************************************/

#define TX_VERSION  0x00  /* Version register */
#define TX_CONFIG   0x01  /* Configuration register */
#define TX_CHSTAT   0x02  /* Channel status control register */
#define TX_INTMASK  0x03  /* interrupt mask register */
#define TX_INSTAT   0x04  /* Interrupt event register */
#define TX_UD_BASE  0x20  /* User data buffer base address */
#define TX_CS_BASE  0x40  /* Channel status buffer base address */


#endif

