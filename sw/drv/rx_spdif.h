/*********************************************************************
****                                                              ****
**** WISHBONE SPDIF IP Core                                       ****
****                                                              ****
**** This file is part of the SPDIF project                       ****
**** http://www.opencores.org/cores/spdif_interface/              ****
****                                                              ****
**** Description                                                  ****
**** Definitions for the SPDIF receiver.                          ****
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

#ifndef _rx_spdif_
#define _rx_spdif_

/*** Register definitions ********************************************/

#define RX_VERSION  0x00  /* Version register */
#define RX_CONFIG   0x01  /* Configuration register */
#define RX_STATUS   0x02  /* Status register */
#define RX_INTMASK  0x03  /* interrupt mask register */
#define RX_INSTAT   0x04  /* Interrupt event register */
#define RX_CHSTCAP0 0x10  /* Capture control register 0 */
#define RX_CHSTDAT0 0x11  /* Capture data register 0 */
#define RX_CHSTCAP1 0x12  /* Capture control register 1 */
#define RX_CHSTDAT1 0x13  /* Capture data register 1 */
#define RX_CHSTCAP2 0x14  /* Capture control register 2 */
#define RX_CHSTDAT2 0x15  /* Capture data register 2 */
#define RX_CHSTCAP3 0x16  /* Capture control register 3 */
#define RX_CHSTDAT3 0x17  /* Capture data register 3 */
#define RX_CHSTCAP4 0x18  /* Capture control register 4 */
#define RX_CHSTDAT4 0x19  /* Capture data register 4 */
#define RX_CHSTCAP5 0x1a  /* Capture control register 5 */
#define RX_CHSTDAT5 0x1b  /* Capture data register 5 */
#define RX_CHSTCAP6 0x1c  /* Capture control register 6 */
#define RX_CHSTDAT6 0x1d  /* Capture data register 6 */
#define RX_CHSTCAP7 0x1e  /* Capture control register 7 */
#define RX_CHSTDAT7 0x1f  /* Capture data register 7 */


#endif

