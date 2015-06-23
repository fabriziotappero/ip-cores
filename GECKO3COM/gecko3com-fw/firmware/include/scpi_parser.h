/* GECKO3COM
 *
 * Copyright (C) 2009 by
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
/** \file     scpi_parser.h
 *********************************************************************
 * \brief     General header file for an scpi parser. 
 *
 *            This SCPI parser header file should be usefull for 
 *            different parser implementations.
 *            You can design your parser for example with a parser 
 *            generator like re2c (regular expressions to C) or by hand.
 *
 *            In this file we define a enum type for the actions to
 *            be exceduted outside the parser. Add your desired actions
 *            here and implement them elsewhere.
 *            To modify the the known commands and the according action 
 *            modify the scpi_parser.c file.
 *
 * \author    Christoph Zimmermann bfh.ch
 * \date      2009-02-04
 *
*/

#ifndef _SCPI_PARSER_H_
#define _SCPI_PARSER_H_

#include "usb_tmc.h"

/**  \brief define action flags for device dependent commands here. 
 *  command syntax is defined in the parser itself */
typedef enum {
  NOACTION,
  SYSTEM_RESET,
  rqFPGA_IDCODE,
  rqFPGA_TYPE,
  rqFPGA_DONE,
  FPGA_CONFIGURE,
  FPGA_COMMUNICATION,
  rqSPI_FILE_LIST,
  SPI_DELETE,
  SPI_WRITE,
} SCPI_Action;


/** \brief struct with the pointers for the scpi_scan
 *  
 *  struct that contains all pointer needed for the scpi scanner to work.
 *  set the source pointer to the start of the scpi message (for example to 
 *  the endpoint buffer to the byte afterthe usb tmc header). */
typedef struct Scanner {
  unsigned char	*source; /**< pointer to the data to be parsed */
  SCPI_Action   action; /**< device command parsed. this value says which action the device should execute now */
} Scanner;


/** \brief parser for scpi/IEEE488.2 commands
 *
 *  The parser for scpi 99 and IEEE488.2 commands. Most mandatory commands are 
 *  implemented (due to memory restrictions) and all of them are handled in
 *  the parser. Device dependent commands are handled outside of the parser.
 *  
 * \param[in] *offset pointer to the offset, buffer[offset] is 
 *            the current position, anything before this is already consumed.
 * \param[in] *s a Scanner struct with the member *source set to 
 *            the start of the scpi message
 * \param[in] *queue pointer to a TMC_Response_Queue
 * \return    Status value, 0 if an error occoured in this case the error is 
 *            written to the IEEE488 event register. */
int8_t scpi_scan(idata uint16_t *offset, xdata Scanner *s, xdata TMC_Response_Queue *queue);

#endif
