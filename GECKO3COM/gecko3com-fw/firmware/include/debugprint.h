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

/** 
 *********************************************************************
 * \file      debugprint.h
 *********************************************************************
 * \brief     Makro definitions to print debug information when needed.
 *
 *            Supporting three different levels: Error, Warning, Info.
 *            Define the desired Value in the Makefile by the define
 *            DEBUG_LEVEL_[INFO | WARN | ERROR]
 *
 * \date      2008-12-16 
 *
 * \author    Christoph Zimmermann
*/

#ifndef _DEBUGPRINT_H_
#define _DEBUGPRINT_H_

#include <stdio.h>
#include "ser.h"

#ifdef DEBUG_LEVEL_WARN
#define DEBUG_LEVEL_ERROR
#endif

#ifdef DEBUG_LEVEL_INFO
#define DEBUG_LEVEL_WARN
#define DEBUG_LEVEL_ERROR
#endif

#ifdef DEBUG_LEVEL_INFO 
/** print debug information */
#define print_info(String) ser_printString("INFO: "); printf_tiny(String)
#else
/** print debug information */
#define print_info(String) 
#endif
         
#ifdef DEBUG_LEVEL_WARN
/** print debug warnings */
#define print_warn(String) ser_printString("WARNING: "); printf_tiny(String)
#else
/** print debug warnings */
#define print_warn(String) 
#endif

#ifdef DEBUG_LEVEL_ERROR
/** print debug errors */
#define print_err(String) ser_printString("ERROR: "); printf_tiny(String)
#else
/** print debug errors */
#define print_err(String) 
#endif


#endif /* _DEBUGPRINT_H_ */
