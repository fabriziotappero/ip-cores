/* $Id: memtest.hh,v 1.8 2008-06-24 10:03:41 sybreon Exp $
** 
** VIRTUAL PERIPHERAL I/O LIBRARY
** Copyright (C) 2009 Shawn Tan <shawn.tan@aeste.net>
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

/*! 
  GPIO C Interface Library.
  @file 
*/

#ifndef VPIO_GPIO_H
#define VPIO_GPIO_H

typedef char gpioData;

/*!
   GPIO Directions.
*/

enum gpioTrisType
  {
    GPIO_INPUT  = 0, ///< Define GPIO pin as an input
    GPIO_OUTPUT = 1 ///< Define GPIO pin as an output
  };

typedef enum gpioTrisType gpioTrisType;

/*!
   GPIO Register Map.       
   This structure contains the register file of a general-purpose
   I/O. Care should be taken when using it due to endian issues.
*/

struct gpioRegs
{
  volatile gpioData regCtrl; ///< GPIO direction register.
  unsigned int /* unused */ :24;    
  volatile gpioData regLine; ///< GPIO line data register.
  unsigned int /* unused */ :24;    
};

typedef struct gpioRegs gpioRegs;

// ==== GPIO INTERFACE ====

gpioData gpioGetBit(gpioRegs* port, gpioData bit);
void gpioSetBit(gpioRegs* port, gpioData bit);
void gpioTogBit(gpioRegs* port, gpioData bit);
void gpioClrBit(gpioRegs* port, gpioData bit);

//void gpioPutTris(gpioRegs* port, gpioData mask);
void gpioSetTris(gpioRegs* port, gpioData mask);
void gpioPutData(gpioRegs* port, gpioData data);
//gpioData gpioGetTris(gpioRegs* port);
gpioData gpioGetData(gpioRegs* port);

void gpioInit(gpioRegs* port);


/*!
   Get a port bit.
   
   This function reads the value of a specific bit on a GPIO port. It
   reads the entire port line and masks out the specific bit. The
   result should be gpioDataerpreted as zero for 0 and non-zero for 1.
   
   @param port Memory-mapped I/O port.
   @param bit Get port bit value.
   @return Value of the port bit.
*/

inline
gpioData  gpioGetBit(gpioRegs* port, gpioData bit)
{
  return port->regLine & (1 << bit);  
}

/*!
   Set a port bit.
   
   This function sets a specific bit on a GPIO port to 1. It is a
   read-modify-write instruction that reads the port value, masks it
   and writes the new value to the port.
   
   @param port Memory-mapped I/O port.
   @param bit Set port bit to 1.
*/

inline
void gpioSetBit(gpioRegs* port, gpioData bit) 
{
  port->regLine |= (1 << bit);
}

/*!
   Toggle a port bit.
   
   This function toggles a specific bit on a GPIO port. It is a
   read-modify-write instruction that reads the port value, masks it
   and writes the new value to the port.
   
   @param port Memory-mapped I/O port.
   @param bit Toggle port bit between 0 and 1.
*/

inline
void gpioTogBit(gpioRegs* port, gpioData bit) 
{
  port->regLine ^= (1 << bit);
}

/*!
   Clear a port bit.

   This function clears a specific bit on a GPIO port to 0. It is a
   read-modify-write instruction that reads the port value, masks it
   and writes the new value to the port.

   @param port Memory-mapped I/O port.
   @param bit Clear port bit to 0.
 */

inline
void gpioClrBit(gpioRegs* port, gpioData bit) 
{
  port->regLine &= ~(1 << bit);
}

/*!
   Configure the entire port.

   This function configures the entire port, which controls the
   direction of specific bits of the port. It writes the entire port
   mask to the port control register.

   @see gpioTrisType
   @param port Memory-mapped I/O port.
   @param mask The entire port config mask.
 */

inline
void gpioSetTris(gpioRegs* port, gpioData mask)
{
  port->regCtrl = mask;
}


/*!
   Configure the entire port.

   This function configures the entire port, which controls the
   direction of specific bits of the port. It writes the entire port
   mask to the port control register.

   @see gpioTrisType
   @param port Memory-mapped I/O port.
   @param mask The entire port config mask.
 */

inline
gpioData gpioGetTris(gpioRegs* port)
{
  //port->regCtrl = mask;
  return port->regCtrl;
}

/*!
   Put data on the port.

   This function writes onto the entire data line of the GPIO port. It
   writes the value directly to the port register.

   @param port Memory-mapped I/O port.
   @param data The data to write to the port.
 */

inline
void gpioPutData(gpioRegs* port, gpioData data)
{
  port->regLine = data;
}

/*!
   Get data from the port.

   This function reads the entire data line of the GPIO port. It reads
   the value directly from the port register. Any output port values
   will appear on the input unless something is wrong.   

   @param port Memory-mapped I/O port.
   @return The contents of the entire port.
 */

inline
gpioData gpioGetData(gpioRegs* port)
{
  return port->regLine;
}

/*!
   Initialise the GPIO port.

   This function configures the entire GPIO port as inputs and clears
   the whole port data register. This will restore the port to its
   reset condition.

   @param port Memory-mapped I/O port.
 */

inline
void gpioInit(gpioRegs* port)
{
  gpioSetTris(port, 0);
  gpioPutData(port, 0);
}

#endif
