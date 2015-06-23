/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Bern University of Applied Sciences
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
/** \file     fpga_load.h
 *********************************************************************
 * \brief     functions to configure an FPGA
 *
 *            use a define to select the handled FPGA \n
 *            currently following vendors are suported:
 *            \li XILINX
 *            \li ALTERA, as stub. needs work
 *
 * \author    GNUradio team, Christoph Zimmermann bfh.ch
 * \date      2009-1-19
 *
*/

#ifndef INCLUDED_FPGA_LOAD_H
#define INCLUDED_FPGA_LOAD_H

/** \brief initialize the ports and pins used for fpga configuration */
void init_fpga_interface(void);

/** \brief prepares the fpga to accept configuration data */
uint8_t fpga_load_begin(void);

/** \brief transfer configuration data to the fpga
 *
 * \param[in] *p pointer to the buffer to read from.
 *            normally this is a endpoint buffer.
 * \param[in] *offset pointer to the offset, buffer[offset] is 
 *            the current position, anything before this is already consumed.
 * \param[in] *bytecount pointer to the length of the whole 
 *            buffer.
 * \return    returns non-zero if successful, else 0
 */
uint8_t fpga_load_xfer(xdata unsigned char *p, idata uint16_t *offset,\
			idata uint16_t *bytecount);

/** \brief finalize the fpga configuration process */
uint8_t fpga_load_end(void);

/* ------------------------------------------------------------------------- */
/* Xilinx stuff. We use slave parallel mode to configure the FPGA
 */
#ifdef XILINX

#define FPGA_INFO_LEN 19
#define FPGA_INFO_COMPLETE 1
#define FPGA_INFO_NOT_COMPLETE -1

typedef enum  {
  FILENAME = 'a',
  FPGA_TYPE = 'b',
  COMPILE_DATE = 'c',
  COMPILE_TIME = 'd',
  FILE_LENGTH = 'e',
} Fpga_Info_Type;

typedef struct { 
  uint16_t position;  /**< current position inside the input buffer */
  Fpga_Info_Type type; /**< type of desired information, like filename, fpga type etc. */
  char info[FPGA_INFO_LEN]; /**< char array that contains the desired information */
} Fpga_Info; /**< struct used to hold neccesary information to parse the bit file header */


/** \brief function to scan the bit file header
 *
 * this function scans the provided buffer for the desired information type
 * (selected in the Fpga_Info struct) and copies the data to the output array.
 * When no data or not the complete data is found, the function returns a 
 * "FPGA_INFO_NOT_COMPLETE", when exectued the next time, it will continue 
 * searching or copying the information. \n 
 * This makes it possible to detect information split over serveral usb packets.
 *
 * \param[in] *p pointer to the buffer to read from.
 *            normally this is a endpoint buffer.
 * \param[in] *offset pointer to the offset, buffer[offset] is 
 *            the current position, anything before this is already consumed.
 * \param[in] *length pointer to the length of the whole buffer.
 * \param[in] *info pointer to a Fpga_Info struct which 
 *            contains the desired information and the pointe to the output 
 *            buffer.
 * \return FPGA_INFO_NOT_COMPLETE or FPGA_INFO_COMPLETE
 */
int8_t fpga_scan_file(const xdata unsigned char *p,  idata uint16_t *offset, \
		      idata uint16_t *length, xdata Fpga_Info* info);


#define fpga_done()   ((XILINX_DONE & bmXILINX_DONE) == bmXILINX_DONE) /**< check if DONE is set */
#endif


/* ------------------------------------------------------------------------- */
/* Altera stuff. only copied from USRP source code. does not work. only a 
 * guide to give you a start to port GECKO3COM to other boards using Altera
 * devices
 */
#ifdef ALTERA
#define fpga_done()   ((status & bmALTERA_CONF_DONE) == bmALTERA_CONF_DONE)  /**< check if DONE is set */
#endif

#endif /* INCLUDED_FPGA_LOAD_H */
