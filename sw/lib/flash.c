/******************************************************************************
 * Numonyx™ 128 Mbit EMBEDDED FLASH MEMORY J3 Version D                       *
 ******************************************************************************
 * Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>          *
 *                                                                            *
 * This program is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation, either version 3 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 ******************************************************************************/
#include "stddef.h"
#include "flash.h"

/* Read the status register. */
uchar flash_read_status() {
   FLASH_MEMORY[0] = CMD_READ_SR;
   return FLASH_MEMORY[0];
}

/* Clear the status register. */
void flash_clear_sr() {
   FLASH_MEMORY[0] = CMD_CLEAR_SR;
}

/* Write a byte of data to a specific device address. 
   Writing only changes '1' to '0'. If you overwrite data that would change '0'
   to '1', erase the block beforhand. */
void flash_write(uint adr, uchar b) {
   FLASH_MEMORY[adr] = CMD_BYTE_PROGRAM;
   FLASH_MEMORY[adr] = b;
}

/* Read 32bit of data from a specific device address. 
   Issues a Read Array Command each time, although device stays in Array Read
   mode until another command operation takes place. */
uint flash_read(uint adr) {
   FLASH_MEMORY[0] = CMD_READ_ARRAY;
   return ( (volatile uint *) FLASH_MEMORY )[adr];
}

/* Erase block. Point to an address within the block address space you want to
   erase. 16 Mbytes, organized as 128-Kbyte erase blocks. */
void flash_block_erase(uint blk) {
   FLASH_MEMORY[blk] = CMD_BLOCK_ERASE_SETUP;
   FLASH_MEMORY[blk] = CMD_BLOCK_ERASE_CONFIRM;
}

/* Wait for the end of a operation and return the status register when ready. 
   Block erasure and writing data takes longer than a WB write operation. 
   So after each erase or write one should call flash_wait() or do something 
   else meanwhile. */
uchar flash_wait() {

   uchar s;
   
   while( !( (s = flash_read_status()) & FLASH_READY) );
   return s;
}
