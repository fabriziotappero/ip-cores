/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Berne University of Applied Sciences
 *  |  _ <'|  _) |  _  |   School of Engineering and
 *  | (_) )| |   | | | |   Information Technology
 *  (____/'(_)   (_) (_)
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details. 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*********************************************************************/
/** \file     gecko3com_interfaces.h
 *********************************************************************
 * \brief     definitions to use the correct interface and/or endpoint
 *
 * \author    Christoph Zimmermann bfh.ch, GNUradio
 * \date      2009-1-13
 *
*/

#ifndef _GECKO3COM_INTERFACES_H_
#define _GECKO3COM_INTERFACES_H_

#define USB_DFU_RT_INTERFACE    1  /**< usb interface number for DFU runtime mode */

#define USB_TMC_INTERFACE       0  /**< usb interface number for USBTMC requests */
#define USB_TMC_EP_OUT          2  /**< endpoint number for USBTMC OUT messages */
#define USB_TMC_EP_IN           6  /**< endpoint number for USBTMC IN messages */


#endif /* _GECKO3COM_INTERFACES_H_ */
