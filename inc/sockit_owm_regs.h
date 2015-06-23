//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Minimalistic 1-wire (onewire) master with Avalon MM bus interface       //
//                                                                          //
//  Copyright (C) 2010  Iztok Jeras                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  This program is free software: you can redistribute it and/or modify    //
//  it under the terms of the GNU Lesser General Public License             //
//  as published by the Free Software Foundation, either                    //
//  version 3 of the License, or (at your option) any later version.        //
//                                                                          //
//  This program is distributed in the hope that it will be useful,         //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


#ifndef __SOCKIT_OWM_REGS_H__
#define __SOCKIT_OWM_REGS_H__

#include <io.h>

//////////////////////////////////////////////////////////////////////////////
// control status register                                                  //
//////////////////////////////////////////////////////////////////////////////

#define SOCKIT_OWM_CTL_REG               0
#define IOADDR_SOCKIT_OWM_CTL(base)      IO_CALC_ADDRESS_NATIVE(base, SOCKIT_OWM_CTL_REG)
#define IORD_SOCKIT_OWM_CTL(base)        IORD(base, SOCKIT_OWM_CTL_REG)
#define IOWR_SOCKIT_OWM_CTL(base, data)  IOWR(base, SOCKIT_OWM_CTL_REG, data)

#define SOCKIT_OWM_CTL_DAT_MSK           (0x00000001)  // data bit
#define SOCKIT_OWM_CTL_DAT_OFST          (0)
#define SOCKIT_OWM_CTL_RST_MSK           (0x00000002)  // reset
#define SOCKIT_OWM_CTL_RST_OFST          (1)
#define SOCKIT_OWM_CTL_OVD_MSK           (0x00000004)  // overdrive
#define SOCKIT_OWM_CTL_OVD_OFST          (2)
#define SOCKIT_OWM_CTL_CYC_MSK           (0x00000008)  // cycle
#define SOCKIT_OWM_CTL_CYC_OFST          (3)
#define SOCKIT_OWM_CTL_PWR_MSK           (0x00000010)  // power (strong pull-up), if there is a single 1-wire line
#define SOCKIT_OWM_CTL_PWR_OFST          (5)
#define SOCKIT_OWM_CTL_RSV_MSK           (0x00000020)  // reserved
#define SOCKIT_OWM_CTL_RSV_OFST          (5)
#define SOCKIT_OWM_CTL_IRQ_MSK           (0x00000040)  // irq status
#define SOCKIT_OWM_CTL_IRQ_OFST          (6)
#define SOCKIT_OWM_CTL_IEN_MSK           (0x00000080)  // irq enable
#define SOCKIT_OWM_CTL_IEN_OFST          (7)

#define SOCKIT_OWM_CTL_SEL_MSK           (0x00000f00)  // port select number
#define SOCKIT_OWM_CTL_SEL_OFST          (8)

#define SOCKIT_OWM_CTL_POWER_MSK         (0xffff0000)  // power (strong pull-up), if there is more than one 1-wire line
#define SOCKIT_OWM_CTL_POWER_OFST        (16)

// two common commands
#define SOCKIT_OWM_CTL_DLY_MSK           (                         SOCKIT_OWM_CTL_RST_MSK | SOCKIT_OWM_CTL_DAT_MSK)
#define SOCKIT_OWM_CTL_IDL_MSK           (SOCKIT_OWM_CTL_OVD_MSK | SOCKIT_OWM_CTL_RST_MSK | SOCKIT_OWM_CTL_DAT_MSK)

//////////////////////////////////////////////////////////////////////////////
// clock divider ratio register                                             //
//////////////////////////////////////////////////////////////////////////////

#define SOCKIT_OWM_CDR_REG               1
#define IOADDR_SOCKIT_OWM_CDR(base)      IO_CALC_ADDRESS_NATIVE(base, SOCKIT_OWM_CDR_REG)
#define IORD_SOCKIT_OWM_CDR(base)        IORD(base, SOCKIT_OWM_CDR_REG)
#define IOWR_SOCKIT_OWM_CDR(base, data)  IOWR(base, SOCKIT_OWM_CDR_REG, data)

#define SOCKIT_OWM_CDR_N_MSK             (0x0000ffff)  // normal    mode
#define SOCKIT_OWM_CDR_N_OFST            (0)
#define SOCKIT_OWM_CDR_O_MSK             (0xffff0000)  // overdrive mode
#define SOCKIT_OWM_CDR_O_OFST            (16)


#endif /* __SOCKIT_OWM_REGS_H__ */
