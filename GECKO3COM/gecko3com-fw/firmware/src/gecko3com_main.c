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
/** \file     gecko3com_main.c
 *********************************************************************
 * \brief     main file for the GECKO3COM project
 *
 * \author    Christoph Zimmermann bfh.ch
 * \date      2009-1-22
 *
*/

/** enable DFU class support */
#define USB_DFU_SUPPORT

#include <string.h>
#include <stdint.h>

#include "fx2utils.h"
#include "timer.h"
#include "spi_flash.h"
#include "i2c.h"
#include "isr.h"
#include "eeprom_io.h"
#include "delay.h"

#include "gecko3com_i2c.h"
#include "gecko3com_spi.h"
#include "gecko3com_common.h"
#include "gecko3com_interfaces.h"
#include "gecko3com_commands.h"
#include "fpga_load.h"

#include "gecko3com_gpif.h"
#include "gpif_data.h"

#include "usb_common.h"
#include "usb_requests.h"
#include "usb_descriptors.h"
#include "usb_dfu.h"
#include "usb_tmc.h"
#include "scpi_parser.h"

#include "firmware_version.h"
#include "debugprint.h"
#ifdef DEBUG_LEVEL_ERROR
#include "ser.h"
#endif

/* -------------------------------------------------------------------------- */

#define WATCHDOG_TIME           100 /**< time until the watchdog times out, 100 equals 1 second */


/* Global variables --------------------------------------------------------- */

/** watchdog counter variable (UNUSED) */ 
volatile uint8_t watchdog_count = WATCHDOG_TIME; 

/** the filesize of an fpga configuration file, read from the bit file header */
idata int32_t file_size; 

/** stores the current used addres for spi flash access */
xdata uint32_t flash_adress; 
/** general pointer to pass the place where to read data to different 
functions (normally endpoint buffer) */
xdata unsigned char *buffer; 

xdata TMC_Response_Queue response_queue; /**< buffer to hold the TMC response */


/** \brief with executing this function, we confirm that we handled the 
 *  endpoint 0 data and that we are ready to get new data (rearm the endpoint).
 */
static void get_ep0_data (void)
{
  EP0BCL = 0;		/* arm EP0 for OUT xfer.  This sets the busy bit */

  while (EP0CS & bmEPBUSY)	/* wait for busy to clear */
    ;
}


/*
 * enable debug output through the serial uart
 */
#ifdef DEBUG_LEVEL_ERROR

/** \brief simple wraper to provide putchar function over serial line */
void putchar (char p)
{
  ser_putc((unsigned char) p);
}


/** \brief simple wraper to provide getchar function over serial line */
char getchar (void)
{
  return (char) ser_getc();
}
#endif


#ifdef USB_DFU_SUPPORT
/** \brief this function writes the new firmware data in endpoint 0 to the I2C \
 *  eeprom.
 * \note this function is only available when the DFU (device firware upgrade) \
 * class support is enabled.
 */
uint8_t app_firmware_write (void)
{
  static uint16_t eeprom_offset;

  get_ep0_data();
  
  if(usb_dfu_state == DFU_STATE_dfuIDLE){
    eeprom_offset = 0;
  }
 
  //  if(!eeprom_write(I2C_ADDR_BOOT, eeprom_offset, EP0BUF, wLengthL)){
  if(!eeprom_write(eeprom_offset, EP0BUF, wLengthL)){
    usb_dfu_status = DFU_STATUS_errWRITE;
    return 0;
  }

  eeprom_offset += wLengthL;
  return 1;
}
#endif


/** \brief analyze the header from the fpga configuration file and compares the 
 *  the fpga type with the on board fpga and returs the configuration file size.
 *
 * \param[in] *offset pointer to the offset, buffer[offset] 
 *            is the current position, anything before this is already consumed.
 * \param[in] *byte_count pointer to the length of the whole buffer.
 * \return    returns non-zero if successful, else 0
 */
uint8_t app_check_fpga_type_from_header(idata uint16_t *offset,		\
					idata uint16_t *byte_count) 
{
  static xdata Fpga_Info fpga_file_header;
  xdata char fpga_type[FPGA_TYPE_LEN];
  static int8_t continue_analyse;

  /* check if this is the first attempt to analyse the bit file header*/
  if(usb_tmc_transfer.new_transfer == NEWTRANSFER) {
    continue_analyse = 0;
    fpga_file_header.type = FPGA_TYPE;
    usb_tmc_transfer.transfer_size += USB_TMC_HEADER_SIZE;
  }

  /* first value to read from the header file is the fpga type */
  if(fpga_file_header.type == FPGA_TYPE){

    if(fpga_scan_file(buffer, offset, byte_count, &fpga_file_header)	\
       == FPGA_INFO_COMPLETE) {
      /* compare fpga type from header with value in eeprom */
      if(!eeprom_read(FPGA_TYPE_OFFSET, fpga_type, FPGA_TYPE_LEN)){
	return 0;
      }
      
      if(strncmp(fpga_file_header.info, fpga_type, FPGA_TYPE_LEN)) {
	//print_err("!FPGA\n");
	return 0;
      }
      
      /* next value to read from the header is the file length */
      fpga_file_header.type = FILE_LENGTH;      
      continue_analyse = FPGA_INFO_COMPLETE;
    }
    else {
      continue_analyse = FPGA_INFO_NOT_COMPLETE;
    }
  }

  /* second value to read from the header file is the file length */
  if(fpga_file_header.type == FILE_LENGTH){

    if(fpga_scan_file(buffer, offset, byte_count, &fpga_file_header)	\
       == FPGA_INFO_COMPLETE) {
      ((uint8_t*)&file_size)[0] = fpga_file_header.info[2];
      ((uint8_t*)&file_size)[1] = fpga_file_header.info[1];	
      ((uint8_t*)&file_size)[2] = fpga_file_header.info[0];
      ((uint8_t*)&file_size)[3] = 0;
      
      continue_analyse = FPGA_INFO_COMPLETE;
    }
    else {
      continue_analyse = FPGA_INFO_NOT_COMPLETE;
    }
  }

  /* adjust the offset and byte_count variables to point to the 
   * binary data after the header */
  usb_tmc_transfer.transfer_size -= *offset;

  return continue_analyse;
}


/** \brief function to configure an fpga with data from usb 
 *
 * \param[in] *offset pointer to the offset, buffer[offset] 
 *            is the current position, anything before this is already consumed.
 * \param[in] *byte_count pointer to the length of the whole buffer.
 * \return    returns non-zero if successful, else 0
 */
uint8_t app_configure_fpga(idata uint16_t *offset,	\
			   idata uint16_t *byte_count)
{ 
  /* Is this the first part of configuration? */
  if(usb_tmc_transfer.nbytes_rxd == 0) {
    /* setup all stuff */
    file_size = 0;
  }

  /* do we still analyze the file header? */
  if(file_size == 0) {
    if(!app_check_fpga_type_from_header(offset, byte_count)) {
      //print_err("bad\n");
      return 0;
    }

    /* are we now finished analyzing? */
    if(file_size != 0) {
      /* if yes, intialize fpga for configuration */
      //print_info("begin\n");
      fpga_load_begin();
    }
  }

  /* anything ready, transfer data to fpga */
  if(file_size != 0) {    
    /* transmitt config data to fpga */
    usb_tmc_transfer.transfer_size -= *byte_count; 
    usb_tmc_transfer.transfer_size += *offset;
    file_size -= *byte_count;
    file_size += *offset;

    fpga_load_xfer(buffer, offset, byte_count);
    
    //printf_tiny("buffer[0], %d\n",buffer[0]);
    
    /* transfer finished, finishing configuration */
    if(file_size == 0) {
      //print_info("end\n");
      if(!fpga_load_end()) {
	return 0;
      }
      usb_tmc_state = TMC_STATE_IDLE;
    }
  }
  
  return 1;
}


/** \brief function to write an fpga configuration from usb to the spi flash
 *
 * The SPI flash is big enough to hold store two different fpga
 * configuration files. To handle this, we split the SPI flash address
 * space simply at the half. \n
 * The data structure in the SPI flash is really simple:\n
 * \li 32bit file size value (little endian, as used by the fx2)
 * \li binary data from the fpga configuration file
 *
 * \param[in] *offset pointer to the offset, buffer[offset] 
 *            is the current position, anything before this is already consumed.
 * \param[in] *byte_count pointer to the length of the whole buffer.
 * \return    returns non-zero if successful, else 0
 */
uint8_t app_write_conf_to_flash(idata uint16_t *offset, \
				idata uint16_t *byte_count)
{
  idata uint16_t length;
  xdata uint32_t local_uint32_var;
  xdata unsigned char *local_buffer_ptr;

  /* Is this the first part of configuration? */
  if(usb_tmc_transfer.nbytes_rxd == 0) {
    /* setup all stuff */
    file_size = 0; 
    
    /* select which file slot we have to use */
    if(buffer[*offset] == '0') {
      flash_adress = start_adress_slot0(flash_dr);
      set_led_ext(GREEN);
    }
    else if(buffer[*offset] == '1'){
      flash_adress = start_adress_slot1(flash_dr);
      set_led_ext(RED);
    }
    else {
      //print_err("slot\n");
      ieee488_status.EventStatusRegister |= bmCOMMAND_ERROR;
      usb_tmc_state = TMC_STATE_IDLE;
      return 0;
    }

    *offset += 2;
  }

  /* do we still analyze the file header? */
  if(file_size == 0) {
    if(!app_check_fpga_type_from_header(offset, byte_count)) {
      return 0;
    }

    /* are we now finished analyzing? */
    if(file_size != 0) {
      /* if yes, write file size information to the SPI flash */
      //print_info("begin\n");
      spiflash_erase(&flash_dr, &flash_adress);
      local_uint32_var = file_size;
      spiflash_write(&flash_dr, &flash_adress, (uint8_t*)&local_uint32_var, \
	sizeof(file_size));
    }
  }

  /* anything ready, write data to the SPI flash */
  if(file_size != 0) {    
    //printf_tiny("off: %d\n",*offset);
    //printf_tiny("ad: %x,",((uint8_t*)&flash_adress)[3]);
    //printf_tiny("%x,",((uint8_t*)&flash_adress)[2]);
    //printf_tiny("%x,",((uint8_t*)&flash_adress)[1]);
    //printf_tiny("%x\n",((uint8_t*)&flash_adress)[0]);
    

    length = *byte_count - *offset;

    /* check if we have data to be written to the next flash sector: */
    local_uint32_var = flash_adress + *byte_count;
    if(sectorStart(local_uint32_var) != sectorStart(flash_adress)) {
      /* before we can write to the next flash sector, we have to erase it */
      spiflash_erase(&flash_dr, &local_uint32_var);
    }

    /* write data to the SPI flash */
    local_buffer_ptr = buffer;
    local_buffer_ptr += *offset;
    spiflash_write(&flash_dr, &flash_adress, local_buffer_ptr, length);
 
    /* adjust the file- and transfersize */
    usb_tmc_transfer.transfer_size -= length; 
    file_size -= length;  

    //printf_tiny("le, %d\n",length);    
    
    /* if transfer finished, back to TMC idle state */
    if(file_size <= 0) {
      file_size = 0;
      fpga_load_end();
      usb_tmc_state = TMC_STATE_IDLE;
    }
  }
  
  return 1;
}


/** \brief  erases the desired file slot in spi flash
 * 
 *  send the erase command for one spi flash memory block and loop 
 *  through the main_loop untill we finished erasing the whole fpga 
 *  configuration file slot.
 *
 * \param[in] *offset pointer to the offset, buffer[offset] 
 *            is the current position, anything before this is already consumed.
 * \return    returns non-zero if successful, else 0
 *
 * \todo   uncomment this function after finishing debuging, else no space left!
 */ 
uint8_t app_gecko3com_flash_delete(idata uint16_t *offset) {

  xdata uint32_t flash_adress;
  xdata uint32_t local_uint32_var;
  char slot;

  /* send the delete command for each block and loop through the main_loop */
  /* check busy and set usb_tmc_state back to idle when finished file delete */
  if(usb_tmc_transfer.new_transfer == NEWTRANSFER) {
    //print_info("new\n");

    /* select which file slot we have to delete */
    slot = buffer[*offset];
    if(slot == '0') {
      flash_adress = start_adress_slot0(flash_dr);
      set_led_ext(GREEN);
    }
    else if(slot == '1'){
      flash_adress = start_adress_slot1(flash_dr);
      set_led_ext(RED);
    }
    else {
      //print_err("del\n");
      ieee488_status.EventStatusRegister |= bmCOMMAND_ERROR;
      usb_tmc_state = TMC_STATE_IDLE;
      return 0;
    }
  }

  /* to "delete" means to set the file_size at the beginning of the confguration
   * file slot to zero */
  local_uint32_var = 0;
  spiflash_write(&flash_dr, &flash_adress, (uint8_t*)&local_uint32_var,4);
  usb_tmc_state = TMC_STATE_IDLE;

  return 1;
}


/** \brief Handle the class commands on endpoint 0.
 *
 * \return If we handle this one, return non-zero.
 */
unsigned char app_class_cmd (void)
{
#ifdef USB_DFU_SUPPORT
  if (usb_dfu_request()){
    if(!usb_handle_dfu_packet()){
      //print_err("dfu request\n");
      return 0;
    }
  }

  else
#endif 
  if (usb_tmc_request()){
    if(!usb_handle_tmc_packet()){
      //print_err("tmc request\n");
      return 0;
    }
  }
  else {
    //print_err("invalid class request\n");
    return 0; /* invalid class request */
  }
  
  return 1;
}


/** \brief Handle our "Vendor Extension" commands on endpoint 0.
 * 
 * \return If we handle this one, return non-zero.
 */
unsigned char app_vendor_cmd (void)
{
 /* vendor commands are only used after production
   * starting with firmware version 0.4 we remove the vendor commands
   * to save memory for more importand functions!

  if (bRequestType == VRT_VENDOR_IN){ */
    /*********************************
     *    handle the IN requests
     ********************************/
  /*
    switch (bRequest){

    default:
      return 0;
    }
  }

   else if (bRequestType == VRT_VENDOR_OUT){ */
    /***********************************
     *    handle the OUT requests
     **********************************/
  /*
    switch (bRequest){
    case VRQ_SET_SERIAL:
      get_ep0_data();
      if(wLengthL > SERIAL_NO_LEN){
	return 0;
      }
      if(!eeprom_write(I2C_ADDR_BOOT, SERIAL_NO_OFFSET, EP0BUF, wLengthL)){
	return 0;
      }
      break;

    case VRQ_SET_HW_REV:
      get_ep0_data();
      if(!eeprom_write(I2C_ADDR_BOOT, HW_REV_OFFSET, EP0BUF, 1)){
	return 0;
      }
      break;

    case VRQ_SET_FPGA_TYPE:
      get_ep0_data();
      if(wLengthL > FPGA_TYPE_LEN){
	return 0;
      }
      if(!eeprom_write(I2C_ADDR_BOOT, FPGA_TYPE_OFFSET, EP0BUF, wLengthL)){
	return 0;
      }
      break;

    case VRQ_SET_FPGA_IDCODE:
      get_ep0_data();
      if(!eeprom_write(I2C_ADDR_BOOT, FPGA_IDCODE_OFFSET, EP0BUF, FPGA_IDCODE_LEN)){
	return 0;
      }
      break;

    default:
      return 0;

    }
  }

  else */
    return 0;    /* invalid bRequestType */

  //return 1;
}


/** \brief Read h/w rev code and serial number out of boot eeprom and
 * patch the usb descriptors with these values.
 */
void patch_usb_descriptors(void)
{
  xdata uint8_t hw_rev;
  xdata unsigned char serial_no[SERIAL_NO_LEN];
  unsigned char ch;
  uint8_t i,j;

  /* hardware revision */
  eeprom_read(HW_REV_OFFSET, &hw_rev, 1);	/* LSB of device id */
  usb_desc_hw_rev_binary_patch_location_0[0] = hw_rev;
  usb_desc_hw_rev_binary_patch_location_1[0] = hw_rev;

  /* serial number */
  eeprom_read(SERIAL_NO_OFFSET, serial_no, SERIAL_NO_LEN);

  for (i = 0; i < SERIAL_NO_LEN; i++){
    ch = serial_no[i];
    if (ch == 0xff)	/* make unprogrammed EEPROM default to '0' */
      ch = '0';
    
    j = i << 1;
    usb_desc_serial_number_ascii[j] = ch;
  }
}


/** \brief  we do all the work here. infinite loop */
static void main_loop (void)
{
  tHeader *tmc_header, *tmc_response_header;
  idata uint16_t offset, byte_count;
  static idata uint32_t transfer_size;
  xdata Scanner scpi_scanner;

  uint16_t index;

  buffer = EP2FIFOBUF;
  scpi_scanner.action = NOACTION;
  index = 0;

  while (1){

    usb_tmc_transfer.new_transfer = 0;

    /* -------------------------------------------------------------------- */
    /* SETUP Package on Endpoint 0. Handle if we received one */
    if (usb_setup_packet_avail())
      usb_handle_setup_packet();
    
    /* -------------------------------------------------------------------- */
    /* Let's do some work when an Endpoint has data */
    if (!(EP2468STAT & bmEP2EMPTY) && flLOCAL == GECKO3COM_LOCAL){
      offset = 0;
      
      if(usb_tmc_state == TMC_STATE_IDLE || usb_tmc_transfer.transfer_size == 0){

	/* start to analyze the data in Endpoint 2 if it is a correct TMC 
	 * header */
	tmc_header = (tHeader*)EP2FIFOBUF;

	/* bTag sanity check. store bTag for correct IN transfer response */
	if (tmc_header->bTag == ~tmc_header->bTagInverse) {
	  usb_tmc_transfer.bTag = tmc_header->bTag;

	  /* TMC header is correct. Now find out what we have to do: */

	  /* check if this transfer is a DEV_DEP_MSG_OUT message */
	  if(tmc_header->MsgID == DEV_DEP_MSG_OUT){
	    usb_tmc_transfer.transfer_size = \
	      ((DEV_DEP_MSG_OUT_Header*)tmc_header->msg_specific)->TransferSize;
	    usb_tmc_transfer.new_transfer = NEWTRANSFER;
	    offset = USB_TMC_HEADER_SIZE;
	    
	    /* Decide if we should start the SCPI parser or not
	     * if not IDLE, the transfer size was 0 and we continue 
	     * to exectue the action and don't try to parse a new command */
	    if(usb_tmc_state == TMC_STATE_IDLE) {

	      /* fresh OUT Transfer: handle device dependent command message */
	      usb_tmc_state = TMC_STATE_OUT_TRANSFER;
	      usb_tmc_transfer.nbytes_rxd = 0;
	      
	      /* when we receive an new out message before we sent the response,
	       * we have to clear the response queue first*/
	      IEEE488_clear_mav();
	      usb_tmc_transfer.nbytes_txd = 0;
	      response_queue.length = 0;


	      /* setup variables for scpi parser. 
	       * offset points to first command byte in endpoint buffer */
	      scpi_scanner.source = EP2FIFOBUF;
	      scpi_scanner.action = NOACTION;
	    
	      /* start SCPI parser */
	      if(!scpi_scan(&offset, &scpi_scanner, &response_queue)){
		/* the parser returned an error. set flags */
		ieee488_status.EventStatusRegister |= bmCOMMAND_ERROR;
		usb_tmc_state = TMC_STATE_IDLE;
		scpi_scanner.action = NOACTION;
		usb_tmc_transfer.new_transfer = 0;
		//print_err("syntax failure\n");
	      }
	    }
	  }
	  /* finished handling an DEV_DEP_MSG_OUT message */

	  /* ---------------------------------------------------------------- */
	  /* check if this transfer is a IN request and we have a IN response 
	   * queued */
	  else if(tmc_header->MsgID == REQUEST_DEV_DEP_MSG_IN \
		  && response_queue.length > 0) {

	    /* IN Transfer: Handle response message to a device dependent 
	     * command message. For this we change the TMC state. 
	     * Sending the requested data to the IN endpoint
	     * happens further below */
	    usb_tmc_state = TMC_STATE_IN_TRANSFER;
	    usb_tmc_transfer.transfer_size = \
	      ((REQUEST_DEV_DEP_MSG_IN_Header*) tmc_header->msg_specific)\
	      ->TransferSize;
	    usb_tmc_transfer.nbytes_txd = 0;

	  }
	  else {
	    /* TMC header error: unknown message ID */
	    EP2CS |= bmEPSTALL;  
	    //print_err("ID\n");
	  }
	}

	else {
	  /* TMC header error: bTag and bTagInverse don't match */
	  EP2CS |= bmEPSTALL;   
	  //print_err("bTag\n");
	}
      }

      /* -------------------------------------------------------------------- */
      /* OUT Transfer: The SCPI parser has detected a application specific 
       * command. Here we execute the desired functions for these commands: */
      if(usb_tmc_state == TMC_STATE_OUT_TRANSFER){

	/* set the correct byte_count value */
	/* read byte counter register of EP2FIFOBUF */
	byte_count = (EP2BCH << 8) + EP2BCL;	
	
	/* decide which value is the smaller one */
	if((byte_count - offset) > usb_tmc_transfer.transfer_size) {
	  byte_count = usb_tmc_transfer.transfer_size;
	  /* transfer_size does not includ the header length: */
	  byte_count += offset; 
	}

	/* select what we have to to according to the parsed scpi command */
	switch (scpi_scanner.action) {

	case SYSTEM_RESET:
	  /* Send a global reset signal to the FPGA and all connected modules */
	  gecko3com_system_reset();
	  usb_tmc_state = TMC_STATE_IDLE;
	  break;

	case rqFPGA_IDCODE:
	  /* Request to read the FPGA JTAG ID code */
	  eeprom_read(FPGA_IDCODE_OFFSET, response_queue.buf, FPGA_IDCODE_LEN);
	  response_queue.buf[FPGA_IDCODE_LEN] = '\n';
	  response_queue.length = FPGA_IDCODE_LEN+1;
	  IEEE488_set_mav();
	  usb_tmc_state = TMC_STATE_IDLE;
	  break;

	case rqFPGA_TYPE:
	  /* Request to read the FPGA type string */
	  eeprom_read(FPGA_TYPE_OFFSET, response_queue.buf, FPGA_TYPE_LEN);
	  response_queue.buf[FPGA_TYPE_LEN] = '\n';
	  response_queue.length = FPGA_TYPE_LEN+1;
	  IEEE488_set_mav();
	  usb_tmc_state = TMC_STATE_IDLE;
	  break;

	case rqFPGA_DONE:
	  /* Is the FPGA configured or not? Check the "done" pin*/
	  if(fpga_done()) {
	    response_queue.buf[0] = '1';
	  }
	  else {
	    response_queue.buf[0] = '0';
	  }
	  response_queue.buf[1] = '\n';
	  response_queue.length = 2;
	  usb_tmc_state = TMC_STATE_IDLE;
	  break;

	case FPGA_CONFIGURE:
	  /* Configure the FPGA directly */
	  if(!app_configure_fpga(&offset, &byte_count)) {
	    //print_err("conf\n");
	    ieee488_status.EventStatusRegister |= bmEXECUTION_ERROR;
	    usb_tmc_state = TMC_STATE_IDLE;
	  }
	  break;

	case FPGA_COMMUNICATION:
	  /* Switch the context from the FX2 to the FPGA. 
	   * After this command all endpoint 2 and 6 data goes directly to the 
	   * FPGA, the FX2 doesn't parse commands anymore. Use endpoint 0 TMC 
	   * commands to switch back */
	  if(fpga_done()) {
	    init_gpif();	  
	    flLOCAL = GECKO3COM_REMOTE;
	  }
	  else {
	    ieee488_status.EventStatusRegister |= bmEXECUTION_ERROR;
	  }
	  usb_tmc_state = TMC_STATE_IDLE;
	  break;

	case SPI_DELETE:
	  /* Erases one of the file spaces in the SPI flash  */
	  if(!app_gecko3com_flash_delete(&offset)) {
	    ieee488_status.EventStatusRegister |= bmEXECUTION_ERROR;
	  }
	  usb_tmc_state = TMC_STATE_IDLE;
	  break;

	case SPI_WRITE:
	  /* Writes a FPGA configuration file into a file space in the 
	   * SPI flash. */
	  if(!app_write_conf_to_flash(&offset, &byte_count)) {
	    ieee488_status.EventStatusRegister |= bmEXECUTION_ERROR;
	    usb_tmc_state = TMC_STATE_IDLE;
	  }
	  break;

	default:

	  usb_tmc_state = TMC_STATE_IDLE;
	}
      }
      
      usb_tmc_transfer.nbytes_rxd += ((EP2BCH << 8) + EP2BCL - \ 
				      USB_TMC_HEADER_SIZE);

      /* finished handling usb package. 
       * rearm OUT endpoint to receive new data */
      OUTPKTEND = bmSKIP | USB_TMC_EP_OUT;

    } /* end of OUT Transfer clause */
    

    /* -------------------------------------------------------------------- */
    /* Let's continue to send data when an Endpoint is free */
    /* IN Transfer: Generate a valid TMC IN header and send the response 
     * message data to the endpoint */
    if (!(EP2468STAT & bmEP6FULL) && usb_tmc_state == TMC_STATE_IN_TRANSFER){
      
      /* fresh IN transfer, send first header */
      if(usb_tmc_transfer.nbytes_txd == 0) {
	index = 0;
	tmc_response_header = (tHeader*)EP6FIFOBUF;
	tmc_response_header->MsgID = REQUEST_DEV_DEP_MSG_IN;
	tmc_response_header->bTag = usb_tmc_transfer.bTag;
	tmc_response_header->bTagInverse = ~usb_tmc_transfer.bTag;
	tmc_response_header->Reserved = 0;
	((DEV_DEP_MSG_IN_Header*)tmc_response_header->msg_specific)-> \
	  TransferSize = response_queue.length;
	((DEV_DEP_MSG_IN_Header*)tmc_response_header->msg_specific)->\
	  Reserved[0] = 0;
	((DEV_DEP_MSG_IN_Header*)tmc_response_header->msg_specific)->\
	  Reserved[1] = 0;
	((DEV_DEP_MSG_IN_Header*)tmc_response_header->msg_specific)->\
	  Reserved[2] = 0;

	/* if we can send all data in one usb packet, 
	   set EOM (end of message) bit */
	/* WARNING: set EOM bit in the LAST tmc transfer. 
	 * we transmitt anything in one transfer so we set this bit always. */
	/*if(USBCS & bmHSM && response_queue.length <= 500 | \
	  response_queue.length <= 56)*/
	  ((DEV_DEP_MSG_OUT_Header*)tmc_response_header->msg_specific)->\
	    bmTransferAttributes = bmTA_EOM;
	  /*else
	  ((DEV_DEP_MSG_OUT_Header*)tmc_response_header->msg_specific)->\
	  bmTransferAttributes = 0;*/

	index = USB_TMC_HEADER_SIZE;
      } /* finished writing header */


      /* Transmit data */
      for(usb_tmc_transfer.nbytes_txd; \
	  usb_tmc_transfer.nbytes_txd <= response_queue.length; \
	  usb_tmc_transfer.nbytes_txd++){
	
	/* copy the data from the response queue to the IN endpoint */
	EP6FIFOBUF[index++] = response_queue.buf[usb_tmc_transfer.nbytes_txd];
	
	/* we send any response in one packet so we don't have to check if 
	 * the endpoint buffer is full */
	/*if(!(USBCS & bmHSM) && index == 64 |	\
	   index == 512)
	  break;
	*/
      }

      EP6BCH = index >> 8;
      EP6BCL = index & 0xFF;
      index = 0;

      /* detect end of transfer */
      if(usb_tmc_transfer.nbytes_txd >= response_queue.length){
	usb_tmc_state = TMC_STATE_IDLE;
	IEEE488_clear_mav();
	response_queue.length = 0;
      }     
    } /* end of IN Transfer clause */

    
    
    if(flLOCAL == GECKO3COM_REMOTE) {
      /* if we operate in REMOTE mode (means we pass the data to the FPGA)
       * continously check the DONE pin from the FPGA, to avoid that bad things
       * happen when someone reconfigures the FPGA through JTAG */
      if(!fpga_done()) {
	
	mdelay(50);
	if(!fpga_done()) {
	  set_led_ext(ORANGE);
	  deactivate_gpif();
	  flLOCAL = GECKO3COM_LOCAL;
	}
      }

      //if(!(EP2468STAT & bmEP2EMPTY) && (GPIFTRIG & bmGPIF_IDLE)) {
	/* check if there is a active IN transfer */
	/*if((GPIFREADYSTAT & bmWRX) != bmWRX) {
	  flGPIF = 0;
	  gpif_trigger_write();
	}
	}*/

      /* check if this is a end of a IN transfer */
      /*if(!(EP2468STAT & bmEP6EMPTY) && (GPIFTRIG & bmGPIF_IDLE)) {
	INPKTEND = USB_TMC_EP_IN;
	flGPIF |= bmGPIF_PENDING_DATA;
	gpif_trigger_read();
	}*/
    }

    /* if the LED flag is set to off, disable the external LED */
    if(flLED == LEDS_OFF) {
      set_led_ext(LEDS_OFF);
    }


    /* resets the watchdog timer back to the initial value */
    watchdog_count = WATCHDOG_TIME;

  } /* end of infinite main loop */
}


/** \brief ISR called at 100 Hz from timer2 interrupt
 *
 * Toggle led 0
 */
void isr_tick (void) interrupt
{
  static uint8_t count = 1;      

  if (--count == 0){
    count = 50;
    toggle_led_0();
    flLED = LEDS_OFF;
  }

  //  if (--watchdog_count == 0){
  //    clear_timer_irq(); 
  //  #ifdef DEBUG_LEVEL_ERROR
    //  print_err("Watchdog timed out! System reset\n");
  //mdelay(100);             /* wait 100 ms to give the uart some time to 
  //                          * transmit */
  //  #endif

      /* simulate CPU reset */  /* FIXME this stuff here does not work. 
				 * no idea how to simulate an CPU reset 
				 * instead... */
      /* _asm
      ljmp    __reset_vector
      _endasm;*/
  //}

#ifdef USB_DFU_SUPPORT
  if (usb_dfu_state == DFU_STATE_appDETACH){
    if (--usb_dfu_timeout == 0){
      usb_toggle_dfu_handlers();
    } 
  }
#endif

  clear_timer_irq();
}


/** \brief starting point of execution.
 *
 * we initialize all system components here. after that we go to the main_loop
 * function there all the work is done.
 */
void main(void)
{ 
  /* variables needed for the stand-alone fpga configuration */
  uint8_t led_color;
  idata uint16_t i, local_offset;
  xdata uint32_t spi_base_adress;

  init_gecko3com();
  init_io_ext();
  init_usb_tmc();
  init_fpga_interface();
  init_spiflash(&flash_dr);

  /* disconnect USB, so the host doesn't wait for us during the fpga 
   *configuration process (takes up to 20s) */
  USBCS |= bmDISCON;    

#ifdef DEBUG_LEVEL_ERROR
  ser_init();
  //printf_tiny("hi\n");
#endif

  /* set the context switch flag to local operation, not fpga */
  flLOCAL = GECKO3COM_LOCAL;

  /* enable GPIF state output for debuging  */
  IFCONFIG |= bmGSTATE;

  EA = 0;		/* disable all interrupts */

  patch_usb_descriptors();
  setup_autovectors();
  usb_install_handlers();
  hook_timer_tick((unsigned short) isr_tick);

  EA = 1;		/* global interrupt enable */

  /* finished initializing GECKO3COM system */ 
  /*------------------------------------------------------------------------*/

  /* start to configure the FPGA from the configuration SPI flash */
  /* read which configuration, the first or second, we should use: */
  if(get_switch()){
    led_color = GREEN;
    spi_base_adress = start_adress_slot0(flash_dr);
  }
  else {
    led_color = RED;
    spi_base_adress = start_adress_slot1(flash_dr);
  }
  
  /* read the configuration file size from the spi flash */
  spiflash_read(&flash_dr, &spi_base_adress, response_queue.buf, 4);
  ((idata uint8_t*)&file_size)[0] = response_queue.buf[0];
  ((idata uint8_t*)&file_size)[1] = response_queue.buf[1];	
  ((idata uint8_t*)&file_size)[2] = response_queue.buf[2];
  ((idata uint8_t*)&file_size)[3] = response_queue.buf[3];
  spi_base_adress += 4;

  /* debug stuff */
  //response_queue.buf[0] = init_spiflash(&flash_dr);
  //IEEE488_set_mav();
  //response_queue.length = 1;

  /* there is nothing to configure when the filesize is 0 or 0xFFFFFFFF */
  if(file_size == 0 || file_size == 0xFFFFFFFF) {
    /* show that we don't load a config */
    set_led_ext(ORANGE);
  }
  else {
    fpga_load_begin();
    i = TMC_RESPONSE_QUEUE_LENGTH-1;
    while(file_size > 0) {
      set_led_ext(led_color); /* show which config we load */
      
      if(i > file_size) {
  	i = (uint8_t)file_size;
      }
      spiflash_read(&flash_dr, &spi_base_adress, response_queue.buf, i);
      
      local_offset = 0;
      fpga_load_xfer(response_queue.buf, &local_offset, &i);
      file_size -= i;
      spi_base_adress += i;
    }
    fpga_load_end();
  }
 
  USBCS &= ~bmDISCON;		/* reconnect USB */
  
  main_loop();
}
