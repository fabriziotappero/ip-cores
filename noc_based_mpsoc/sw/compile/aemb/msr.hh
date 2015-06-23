/* $Id: msr.hh,v 1.9 2008-04-28 20:29:15 sybreon Exp $
** 
** AEMB2 HI-PERFORMANCE CPU 
** Copyright (C) 2004-2007 Shawn Tan Ser Ngiap <shawn.tan@aeste.net>
**  
** This file is part of AEMB.
**
** AEMB is free software: you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** AEMB is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
** License for more details.
**
** You should have received a copy of the GNU General Public License
** along with AEMB.  If not, see <http://www.gnu.org/licenses/>.
*/

/**
   Basic MSR functions
   @file msr.hh  
   
   These functions provide read/write access to the Machine Status
   Register. It also contains the bit definitions of the register.
 */

#ifndef _AEMB_MSR_HH
#define _AEMB_MSR_HH

// STANDARD BITS
#define AEMB_MSR_BE   (1 << 0) ///< Buslock Enable
#define AEMB_MSR_IE   (1 << 1) ///< Interrupt Enable
#define AEMB_MSR_C    (1 << 2) ///< Arithmetic Carry
#define AEMB_MSR_BIP  (1 << 3) ///< Break in Progress
#define AEMB_MSR_EE  (1 << 8) ///< Exception Enable
#define AEMB_MSR_EIP  (1 << 9) ///< Exception in Progress
    
#define AEMB_MSR_ITE  (1 << 5) ///< Instruction Cache Enable
#define AEMB_MSR_DZ   (1 << 6) ///< Division by Zero
#define AEMB_MSR_DTE  (1 << 7) ///< Data Cache Enable
  
// CUSTOM BITS  
#define AEMB_MSR_MTX  (1 << 4) ///< Hardware Mutex
#define AEMB_MSR_PHA  (1 << 29) ///< Hardware Thread Phase
#define AEMB_MSR_HTX  (1 << 30) ///< Hardware Threads Extension
#define AEMB_MSR_CC   (1 << 31) ///< Carry Copy

#ifdef __cplusplus
extern "C" {
#endif

  /**
     Read the value of the MSR register
     @return register contents
  */
  
  inline int aembGetMSR()
  {
    int rmsr;
    asm volatile ("mfs %0, rmsr":"=r"(rmsr));
    return rmsr;
  }
  
  /**
     Write a value to the MSR register
     @param rmsr value to write
  */  

  inline void aembPutMSR(int rmsr) 
  { 
    asm volatile ("mts rmsr, %0"::"r"(rmsr)); 
  }

  /**
     Read and clear the MSR
     @param rmsk clear mask
     @return msr value
   */

  inline int aembClrMSR(const short rmsk)
  {
    int tmp;
    //asm volatile ("msrclr %0, %1":"=r"(tmp):"K"(rmsk):"memory");
    return tmp;
  }

  /**
     Read and set the MSR
     @param rmsk set mask
     @return msr value
   */

  inline int aembSetMSR(const short rmsk)
  {
    int tmp;
    //asm volatile ("msrset %0, %1":"=r"(tmp):"K"(rmsk):"memory");
    return tmp;
  }

  /** Enable global interrupts */
  inline int aembEnableInterrupts() 
  { 
    int msr;
    asm volatile ("msrset %0, %1":"=r"(msr):"K"(AEMB_MSR_IE));
    return msr;
  }

  /** Disable global interrupts */
  inline int aembDisableInterrupts() 
  { 
    int msr;
    asm volatile ("msrclr %0, %1":"=r"(msr):"K"(AEMB_MSR_IE));
    return msr;
  }

  /** Enable global exception */
  inline int aembEnableException() 
  { 
    int msr;
    asm volatile ("msrset %0, %1":"=r"(msr):"K"(AEMB_MSR_EE));
    return msr;
  }

  /** Disable global exception */
  inline int aembDisableException() 
  { 
    int msr;
    asm volatile ("msrclr %0, %1":"=r"(msr):"K"(AEMB_MSR_EE));
    return msr;
  }

  /** Enable data caches */
  inline int aembEnableDataTag() 
  { 
    int msr;
    asm volatile ("msrset %0, %1":"=r"(msr):"K"(AEMB_MSR_DTE));
    return msr;
  }

  /** Disable data caches */  
  inline int aembDisableDataTag()  
  { 
    int msr;
    asm volatile ("msrclr %0, %1":"=r"(msr):"K"(AEMB_MSR_DTE));
    return msr;
  }

  /** Enable inst caches */
  inline int aembEnableInstTag() 
  { 
    int msr;
    asm volatile ("msrset %0, %1":"=r"(msr):"K"(AEMB_MSR_ITE));
    return msr;
  }

  /** Disable inst caches */  
  inline int aembDisableInstTag()  
  { 
    int msr;
    asm volatile ("msrclr %0, %1":"=r"(msr):"K"(AEMB_MSR_ITE));
    return msr;
  }

#ifdef __cplusplus
}
#endif

#endif
