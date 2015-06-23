/******************************************************************************
 * void - Bootloader Version 0.2.2                                            *
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
#include "stdio.h"
#include "stdlib.h"
#include "flash.h"
#include "ui.h"
#include "view.h"

#define DDR_ADDRESS ((volatile uint *) 0x20000000)

/******************************************************************************
 * Upload View                                                                *
 ******************************************************************************/
/* Wait until a flash write is completed and check for errors. */
void checkFlashWrite() {

   uchar state;         // Flash state.
   
   // Error checking.
   state = flash_wait();
   if(state & FLASH_BLOCK_LOCKED) {
      drawErrorWindow(&errErrorFlashLocked);
      return 0;
   }
   if(state & FLASH_PROGRAM_ERROR) {
      drawErrorWindow(&errErrorFlashWrite);
      return 0;
   }      
} 

/* NOTE: Automatic deduction of the number of blocks, that need to be erased 
         has not been tested extensive. */
void upload() {

   uint size;           // Image size.
   uint step;           // Progress bar step size.
   uint cval;           // Current progress value.

   // Clear screen.
   cls();

   // User Upload Menu.
   drawWindow(&wUpload);

   // Upload Initialization.
   drawMessage(&wUpload, &msgUploadWait); 
   pbUpload.val = 0;   
   drawProgressBar(&wUpload, &pbUpload);
   
   // Receive 4 bytes of size data.
   for(uchar i=0; i < 4; i++) {
      size <<= 8;
      size += rs232_receive();
   }

   // Check for image size to fit into flash.
   if(size > FLASH_BLOCK_SIZE * FLASH_BLOCKS) {
      drawErrorWindow(&errErrorFlashSize);
      return 0;
   }

   // Flash Clean Up.
   drawMessage(&wUpload, &msgUploadErase);
   pbUpload.val = 0;                         // Reset progress bar.
   drawProgressBar(&wUpload, &pbUpload);
   
   // Erase affected flash blocks.
   for(uint i=0; i < (size / FLASH_BLOCK_SIZE) + 1; i++) {
      flash_block_erase(i * FLASH_BLOCK_SIZE);

      // Update the Progress Bar.
      pbUpload.val = (i >> 1);
      drawProgressBar(&wUpload, &pbUpload);

      // Check for errors while erasing.
      if(flash_wait() & FLASH_ERASE_ERROR) {
         drawErrorWindow(&errErrorFlashErase);
         return 0;
      }
   }
   
   // Write image size at flash address 0x0.
   for(uchar i=0; i<4; i++) {
      flash_write(i, size >> ((3-i) * 8) );
      checkFlashWrite();
   }

   // Upload data.
   drawMessage(&wUpload, &msgUploadWrite);
   pbUpload.val = 0;                         // Reset progress bar.
   step = size / 64;                         // Calculate progress step size.
   cval = step;

   // Echoing received image size.
   for(uchar i=0; i<4; i++) {
      rs232_transmit( size >> ((3-i) * 8) );
   }
   
   // Write each single byte to Flash.
   for(uint i=0; i < size; i++) {
      flash_write(i + 4, rs232_receive());

      // Update status bar.
      if(i == cval) {
         pbUpload.val++;
         drawProgressBar(&wUpload, &pbUpload);
         cval += step;
      }

      checkFlashWrite();
   }

   // Go back to main menu.
   boot();
}


/******************************************************************************
 * DDR Load View                                                              *
 ******************************************************************************/
/* Load Flash contents into DDR. 
   
   Input:
      start    Image start address on flash.
      size     Image size.
 */
void load(uint start, uint size) {

   uint step;           // Progress bar step size.
   uint cval;           // Current progress value.
   
   cls();

   // User Upload Menu.
   drawWindow(&wDDRUpload);

   // Upload Initialization.
   pbUpload.val = 0;   
   drawProgressBar(&wDDRUpload, &pbUpload);
   
   step = size / 64;
   cval = step;
   
   // Copy flash data to DDR2 memory.
   // NOTE: Missing bytes, if binary file is not 4 bytes aligned.
   for(uint i=0; i < (size / 4); i++) {
   
      DDR_ADDRESS[i] = flash_read(i + start);
      
      // Update status bar.
      if(i == cval) {
         pbUpload.val++;
         drawProgressBar(&wUpload, &pbUpload);
         cval += step;
      }
   }    
}


/******************************************************************************
 * Memory View                                                                *
 ******************************************************************************/
#define NUM_OF_WORDS 77
/* TODO: Cleaner generic version.
   Quick and dirty implementation of an memory matrix view. Shows the next
   'NUM_OF_WORDS' starting at location 'adr' of the Flash and the DDR memory
   device. */
void show_memory_contents(uint adr) {

   uchar b;
   uchar t;

   b = 0; t = 0;
   for(uint i=adr; i < adr + NUM_OF_WORDS; i++) {

      if(b == 0) {
         gotoxy(6, 4 + t++);
         printf("$y%x:$w ", FLASH_MEMORY + (i << 2));
      }
      printf("%x ", flash_read(i));
      if(b++ == 6) b = 0;
   }

   b = 0; t = 0;
   for(uint i=adr; i < adr + NUM_OF_WORDS; i++) {

      if(b == 0) {
         gotoxy(6, 20 + t++);
         printf("$y%x:$w ", DDR_ADDRESS + i);
      }
      printf("%x ", DDR_ADDRESS[i]);
      if(b++ == 6) b = 0;
   }
}

/* View the memory contents of the Flash and DDR devices. Navigate through the
   address space with ARROW UP and DOWN keys. Returns to the boot loader on
   ESC key pressed. */
void view_memories() {

   uint adr = 0;

   cls();

   drawWindow(&wFlashMemory);
   drawWindow(&wDDRMemory);

   // Show contetnts starting at address 0 at the beginning.
   show_memory_contents(0);

   while(TRUE) {
      switch(getc()->chr) {
         case KEY_ARROWD:
            adr += NUM_OF_WORDS;
            show_memory_contents(adr);
            break;

         case KEY_ARROWU:
            if(adr >= NUM_OF_WORDS) adr -= NUM_OF_WORDS;
            show_memory_contents(adr);
            break;

         case KEY_ESC:
            boot();
            break;

         default:
            break;
      }
   }
}


/******************************************************************************
 * Boot View                                                                  *
 ******************************************************************************/
/* Wait for completed flash initialization. Set up main menu box. */
int main() {
   
   uchar s;
   
   // Clear screen.
   cls();

   // Wait for flash hardware initialization end.
   s = flash_wait();

   // Flash not ready.
   if( !(s & FLASH_READY) ) {
      drawErrorWindow(&errFlashNotReady);
      return 0;
   }

   // Flash command error.
   if(s & FLASH_CMD_ERROR) {
      drawErrorWindow(&errFlashState);
      flash_clear_sr();
      //boot();
      return 0;
   }

   // User Main Menu.
   drawWindow(&wBoot);

   while(TRUE) {
      switch(getc()->chr) {
         case KEY_ARROWD:
            menuKeyDown(&wBoot, &menu);
            break;

         case KEY_ARROWU:
            menuKeyUp(&wBoot, &menu);
            break;

         case KEY_ENTER:
            switch(menu.index) {
               case OPTION_UPLOAD:
                  upload();
                  break;

               case OPTION_MEMORY:
                  view_memories();
                  break;

               case OPTION_START:
                  load(1, flash_read(0));
                  start();
                  break;

               default:
                  break;
            }
            break;

         default:
            break;
      }
   }
}
