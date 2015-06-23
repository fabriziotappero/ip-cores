/* -*- c -*- */
/*
 * Copyright 2003 Free Software Foundation, Inc.
 * 
 * This file is part of GNU Radio
 * 
 * GNU Radio is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * GNU Radio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNU Radio; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

/************************************************************************/
/** \file         fx2utils.h
 *************************************************************************
 * \brief         small helper functions for the Cypress EZ-USB FX2
 *  
 * \author        GNU Radio
 *
 */

#ifndef _FX2UTILS_H_
#define _FX2UTILS_H_

/** Stall the endpoint 0
 */ 
void fx2_stall_ep0 (void);

/** 
 * \brief Resets the data toggle bit of the endpoint ep
 *
 *  A description of the function and purpose of the toggle bit and
 *  when the firmware has to reset it is in the EZ-USB Technical 
 *  Reference Manual. Chapter 8 Page 16
 * \param[in] ep Endpoint number
 */
void fx2_reset_data_toggle (unsigned char ep);

/** \brief  Renumerate the FX2. 
 * This means a disconnect and reconnect from the USB bus */
void fx2_renumerate (void);



#endif /* _FX2UTILS_H_ */
