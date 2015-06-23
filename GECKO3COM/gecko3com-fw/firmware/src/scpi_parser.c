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
/** \file     scpi_parser.c
 *********************************************************************
 * \brief     Parser for the SCPI commands. 
 *
 *            The supported commands are defined here in the parser. 
 *            So if you would like to extend the known set of commands,
 *            you have to add them here. \n
 *            The parser excecutes the necessary Function(s) for the 
 *            detected command or it sets the "action" enum
 *            variable to signal wich command was parsed.
 *            In these way this parser handles most IEEE488.2 and SCPI 1999.0 
 *            mandatory commands and SCPI 1999.0 itself. 
 *
 * \note      when used with USB 1.1 systems, the maximum command length 
 *            you can define is limited to 52 characters because we only
 *            parse commands in the first packet.
 *
 *
 * \author    Christoph Zimmermann bfh.ch * \date      2009-02-04
 *
*/

#include <stdint.h>
#include <ctype.h>
#include <string.h>

#include "scpi_parser.h"
#include "usb_tmc.h"
#include "usb_descriptors.h"
#include "firmware_version.h"
#include "debugprint.h"


#define SCPI_VERSION "1999.0\n" /**< Version of the SCPI standard this device complies to */

#define MAXFILL       12 /**< Maximum length of the longest command, defines the buffer size of the parser */


/** helper function to convert a unsigned byte to an ascii string
 *
 *  \param[in]  byte unsigned byte to convert
 *  \param[out] ascii string with "\n" at the end
 *  \return     length of string
 */
static uint8_t byte2ascii(uint8_t byte, xdata unsigned char *ascii) {
  idata unsigned char first_digit, second_digit, third_digit;

  first_digit = byte % 10;
  byte -= first_digit;
  byte /= 10;
  second_digit = byte % 10;
  if(second_digit == 0) {
    ascii[0] = first_digit + '0';
    ascii[1] = '\n';
    return 2;
  }
  byte -= second_digit;
  byte /= 10;
  third_digit = byte % 10;
  if(third_digit == 0) {
    ascii[0] = second_digit + '0';
    ascii[1] = first_digit + '0';
    ascii[2] = '\n';
    return 3;
  }
  ascii[0] = third_digit + '0';
  ascii[1] = second_digit + '0';
  ascii[2] = first_digit + '0';
  ascii[3] = '\n';
  return 4;
}

/** helper function to convert an ascii string to a unsigned byte
 *
 *  \param[in]  ascii string with '\n' or '\0' at the end
 *  \return byte result unsigned byte, 0 if case of error
 */
static uint8_t ascii2byte(const xdata unsigned char *ascii) {
  idata uint8_t byte = 0, i = 0;
  idata unsigned char local_char;

  for(i; i<4;i++) {
    local_char = ascii[i];
    if(local_char >= '0' && local_char <= '9') {
      byte = byte*10 + (local_char - '0');
    }
    else if(local_char == '\n' || local_char == '\0') {
      return byte;
    }
    else {
      ieee488_status.EventStatusRegister |= bmEXECUTION_ERROR;
      return 0;
    }
  }

  ieee488_status.EventStatusRegister |= bmEXECUTION_ERROR;
  return 0;
}


/** helper function to copy unicode 16 chars from the usb descriptor to an 
 * ascii string to form the *idn? response 
 * 
 * \param[in] pointer to string to fill
 * \param[in] pointer to usb string descriptor to read from
 * \return pointer that points to the last character in the string (one before \0)
 */
static char* descr2string(char *target, const xdata char *descriptor) {
  uint8_t i, j, descriptor_length;

  /* the first byte in the descriptor is the length, second byte is the type */
  descriptor_length = (uint8_t)descriptor[0] - 2;
  descriptor_length >>= 1;

  for (i = 0; i < descriptor_length; i++){
    j = i << 1;
    j += 2;
    target[i] = descriptor[j];
  }
  target[i+1] = '\0';

  return &target[i];
}


/* -------------------------------------------------------------------- */
/** \brief SCPI command parser */
int8_t scpi_scan(idata uint16_t *offset, xdata Scanner *s, xdata TMC_Response_Queue *queue){

  xdata unsigned char buffer[MAXFILL];
  unsigned char *string_index;
  uint8_t i;
  char * xdata srcPtr = s->source;
  xdata unsigned char * xdata bufferPtr = buffer;

  xdata uint16_t * xdata localqueuelength = &queue->length;
  xdata uint8_t * xdata localqueue = queue->buf;

  srcPtr += *offset;

  for(i=0;i<MAXFILL;i++) {
    buffer[i] = tolower(*srcPtr);
    srcPtr++;
  }

  /* this set of commands the mandatory IEEE488 commands */

  if(*bufferPtr == '*') {
    bufferPtr++;
    
    if(!strncmp("cls", bufferPtr, 3)) {
      /** \li *cls, clear status command */
      ieee488_status.EventStatusRegister = 0;
      ieee488_status.StatusByteRegister = 0;
      usb_tmc_state = TMC_STATE_IDLE;
      return 1;
    }

    if(!strncmp("ese", bufferPtr, 3)) {
      bufferPtr += 3;
      if(*bufferPtr == ' ') {
	/** \li *ese, standard event status enable command */
	ieee488_status.EventStatusEnable = ascii2byte(bufferPtr+1);
	usb_tmc_state = TMC_STATE_IDLE;
	return 1;  
      }
      else if(*bufferPtr == '?') {
	/** \li *ese?, standard event status enable query */
	*localqueuelength = byte2ascii(ieee488_status.EventStatusEnable,localqueue);
	IEEE488_set_mav();
	usb_tmc_state = TMC_STATE_IDLE;
	return 1;  
      }
      else {
	return 0;
      }
    }

    if(!strncmp("esr?", bufferPtr, 4)) {
      /** \li *esr?, standard event status register query */
      queue->length = byte2ascii(ieee488_status.EventStatusRegister,queue->buf);
      IEEE488_set_mav();
      ieee488_status.EventStatusRegister = 0;
      usb_tmc_state = TMC_STATE_IDLE;
      return 1;  
    }
    
    if(!strncmp("idn?", bufferPtr, 4)) {
      /** \li *idn?, identification query */
      string_index = descr2string((char*)queue->buf, \
				  string_descriptors[(uint8_t)full_speed_device_descr[14]] \
				  );
      *string_index = ',';
      string_index++;
      string_index = descr2string(string_index, \
				  string_descriptors[(uint8_t)full_speed_device_descr[15]] \
				  );
      *string_index = ',';
      string_index++;
      string_index = descr2string(string_index, \
				  string_descriptors[(uint8_t)full_speed_device_descr[16]]\
				  );
      
      strcat((char*)queue->buf, ",");
      strcat((char*)queue->buf, FIRMWARE_VERSION);
      
      queue->length = strlen((char*)queue->buf);
      
      usb_tmc_state = TMC_STATE_IDLE;
      IEEE488_set_mav();
      return 1; 
    }
    
    if(!strncmp("opc", bufferPtr, 3)) {
      bufferPtr += 3;
      if(*bufferPtr == '?') {
	/** \li *opc?, operation complete query */
	queue->buf[0] = '1';
	queue->buf[1] = '\n';
	queue->length = 2;
	usb_tmc_state = TMC_STATE_IDLE;
	IEEE488_set_mav();
	return 1;  
      }
      else {
	/** \li *opc, operation complete command */
	ieee488_status.OPC_Received = 1;
	usb_tmc_state = TMC_STATE_IDLE;
	return 1;  
      }
    }
      
    if(!strncmp("rst", bufferPtr, 3)) {
      /** \li *rst, reset command. resets the FPGA and connected modules */
      s->action = SYSTEM_RESET;
      return 1;  
    }
    
    if(!strncmp("sre", bufferPtr, 3)) {
      bufferPtr += 3;
      if(*bufferPtr == ' ') {
	/** \li *sre, service request enable command */
	ieee488_status.ServiceRequestEnable = ascii2byte(bufferPtr+1);
	usb_tmc_state = TMC_STATE_IDLE;
	return 1;  
      }
      else if(*bufferPtr == '?') {
	/** \li *sre?, service request enable query */
	queue->length = byte2ascii(ieee488_status.ServiceRequestEnable,queue->buf);
	usb_tmc_state = TMC_STATE_IDLE;
	return 1;  
      }
      else {
	return 0;
      }
    }
    
    if(!strncmp("stb?", bufferPtr, 4)) {
      /** \li *stb?, read status byte query */
      queue->length = byte2ascii(IEEE488_status_query(&ieee488_status),queue->buf);
      usb_tmc_state = TMC_STATE_IDLE;
      IEEE488_set_mav();
      return 1;  
    }
    
    if(!strncmp("wai", bufferPtr, 3)) {
      /** \li *wai, wait-to-continue command */
      /* we excecute only sequential commands, so we are always finished */
      return 1;  
    }
    
    else {
      return 0;
    }
  }

  /* -------------------------------------------------------------------- */
  /* this set of regular expressions are for the mandatory SCPI 99 commands. 
   * many are missing because we have not enought memory 
   */
  if(!strncmp("syst:", bufferPtr, 5)) {
    bufferPtr += 5;
    
    if(!strncmp("err?", bufferPtr, 4)) {
      /** \li syst:err?, gets an error message if there is one */
      if(ieee488_status.EventStatusRegister & bmCOMMAND_ERROR){
	strcpy((char*)queue->buf, "-100, \"Command error\"\n");
	queue->length = 22;
	ieee488_status.EventStatusRegister &= ~bmCOMMAND_ERROR;
      }
      else if(ieee488_status.EventStatusRegister & bmEXECUTION_ERROR){
	strcpy((char*)queue->buf, "-200, \"Execution error\"\n");
	queue->length = 24;
	ieee488_status.EventStatusRegister &= ~bmEXECUTION_ERROR;
      }
      else {
	strcpy((char*)queue->buf, "0, \"No error\"\n");
	queue->length = 14;
      }
      usb_tmc_state = TMC_STATE_IDLE;
      IEEE488_set_mav();
      return 1;  
    }
    
    if(!strncmp("vers?", bufferPtr, 5)) {
      /** \li syst:vers?, returns the SCPI standard version number */
      strcpy((char*)queue->buf, SCPI_VERSION);
      queue->length = 7;
      usb_tmc_state = TMC_STATE_IDLE;
      IEEE488_set_mav();
      return 1;  
    }
    
    else {
      return 0;
    }
  }
  
  /* -------------------------------------------------------------------- */
  /* this set of regular expressions are for the device functions */
  if(!strncmp("fpga:", bufferPtr, 5)) {
    bufferPtr += 5;
    
    if(!strncmp("conf ", bufferPtr, 5)) {
      /** \li fpga:conf, configures the fpga with the following bitfile */
      s->action = FPGA_CONFIGURE;
      *offset += 10;
      return 1;
    }
    
    if(!strncmp("type?", bufferPtr, 5)) {
      /** \li fpga:type?, returns the fpga type as string */
      s->action = rqFPGA_TYPE; 
      *offset += 10;
      return 1;  
    }
    
    if(!strncmp("id?", bufferPtr, 3)) {
      /** \li fpga:id?, returns the jtag id code of the fpga as 32bit int */
      s->action = rqFPGA_IDCODE;
      *offset += 8;
      return 1; 
    }
    
    if(!strncmp("done?", bufferPtr, 5)) {
      /** \li fpga:done?, is true when the fpga is configured */ 
      s->action = rqFPGA_DONE;
      *offset += 10;
      return 1; 
    }

    if(!strncmp("data", bufferPtr, 4)) {
      /** \li fpga:data, context switch to fpga. After this command you 
       *      communicate directly with the fpga. The GECKO3COM firmware does 
       *      not interprete the SCPI commands anymore. */ 
      s->action = FPGA_COMMUNICATION;
      *offset += 9;
      return 1; 
    }

    else {
      return 0;
    }
  }
  
  if(!strncmp("mem:", bufferPtr, 4)) {
    bufferPtr += 4;
    
    if(!strncmp("data ", bufferPtr, 5)) {
      /** \li mem:data, receives a bitfile to store in SPI flash.
       * available memory slots are 0 and 1 */
      s->action = SPI_WRITE;
      *offset += 9;

      return 1;
    }
    
    if(!strncmp("del ", bufferPtr, 4)) {
      /** \li mem:del, DEPRICATED deletes the desired fpga configuration, 
       * available memory slots are 0 and 1 */
      s->action = SPI_DELETE;
      *offset += 8;

      return 1;  
    }

    else {
      return 0;
    }
  }
  
  /* matches all. when no command is parsed return an error */

  return 0;
}

