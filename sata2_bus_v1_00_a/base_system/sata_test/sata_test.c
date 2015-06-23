/*-- Copyright (C) 2012
 Ashwin A. Mendon

 This file is part of SATA2 core.

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

#include "xparameters.h"
#include "xutil.h"
#include "stdio.h"

#define SATA_CORE_BASE XPAR_SATA_CORE_0_BASEADDR 
#define DDR_BASE       XPAR_DDR3_SDRAM_MPMC_BASEADDR
#define UART_BASE      XPAR_RS232_UART_1_BASEADDR  
#define SATA_LINK_READY 0x00000002
#define SATA_CORE_DONE 0x00000001
//#define NPI_DONE       0x00000008
#define REG_CLEAR      0x00000000
#define SW_RESET       0x00000001
#define NEW_CMD        0x00000002
#define WRITE_CMD      0x00000002
#define READ_CMD       0x00000001
#define WORDS_PER_SECTOR 128 
#define NPI_BLOCKS_PER_SECTOR 8 
#define SZ_WORD    4

#define SECTOR_ADDRESS 0x00000000
#define NUM_SECTORS    0x00004000

#define REVERSE(a) (((a & 0xff000000) >> 24) | ((a & 0x00ff0000) >> 8)  | ((a & 0x0000ff00) << 8)  |  ((a & 0x000000ff) << 24))

// User Selectable Read/Write Addr Space Offset
#define READ_SPACE_OFFSET     0x8000  // select offset in multiples of 128 bytes (NPI core addr increments in 128 byte offsets)
#define WRITE_SPACE_OFFSET   0x16000  // select offset in multiples of 128 bytes

// Structure maps to Slave Registers
typedef struct {
  volatile unsigned int ctrl_reg;
  volatile unsigned int cmd_reg;
  volatile unsigned int status_reg;
  volatile unsigned int sector_addr_reg;
  volatile unsigned int sector_count_reg;
  volatile unsigned int sector_timer_reg;
  volatile unsigned int npi_rd_addr_reg;
  volatile unsigned int npi_wr_addr_reg;
} sata_core;

volatile sata_core *scp;
volatile u32* uartstat =  (u32*)UART_BASE;
volatile u32* ddr3 =  (u32*)DDR_BASE;

void read_sectors(int sector_addr, int sector_count); 
void write_sectors(int sector_addr, int sector_count); 

volatile unsigned int i,j;

int main (void) {
  int cmd_key, loop, reset;
  scp = (sata_core *)(SATA_CORE_BASE);
  scp->ctrl_reg = REG_CLEAR;
  scp->cmd_reg = REG_CLEAR;
 
  xil_printf("\n\r STATUS REG : %x\r\n", scp->status_reg);
  // SATA CORE RESET
  while ((scp->status_reg & SATA_LINK_READY) != SATA_LINK_READY) {
    scp->ctrl_reg = SW_RESET;
    xil_printf("\n\r ---GTX RESET--- \r\n");
    scp->ctrl_reg = REG_CLEAR;
    for(i=0; i<10000000; i++);
      j = j+i;
    xil_printf("\n\r STATUS REG : %x\r\n", scp->status_reg);
  }
  // SATA CORE RESET 
 
  xil_printf("\n\r ---Testing Sata Core--- \r\n");
 
  while (loop != 51) {
  
  // Read/Write Command 
    xil_printf("\n\rSelect Command: Read-(1) or Write-(2): \r\n");
    cmd_key = uartstat[0];
    while(cmd_key < '0' || cmd_key > '9') cmd_key = uartstat[0]; 		
    printf("\nKey:%d", cmd_key); 
    if(cmd_key == 49) 
      read_sectors(SECTOR_ADDRESS, NUM_SECTORS);
    else {
      write_sectors(SECTOR_ADDRESS, NUM_SECTORS);
    }
 
    xil_printf("\n\n\rExit(e)?: Press '3'\r\n");
    loop = uartstat[0];
    while(loop < '0' || loop > '9') loop = uartstat[0]; 		
    //scp->ctrl_reg = REG_CLEAR;
  }

  xil_printf("\n\n\r Done ! \r\n");
  
  return 0;
}


void read_sectors(int sector_addr, int sector_count) {
      unsigned int i, j, ddr_data; 

      // DDR Read Space Start Address 
      scp->npi_wr_addr_reg = DDR_BASE + READ_SPACE_OFFSET;
      // Clear SATA Control Register 
      scp->ctrl_reg = REG_CLEAR;
      // Input Sector Address, Count and Command to Sata Core
      scp->sector_addr_reg = sector_addr;
      scp->sector_count_reg = sector_count;
      scp->cmd_reg = (READ_CMD);
      // Trigger SATA Core
      scp->ctrl_reg = (NEW_CMD);

      // Wait for Command Completion 
      xil_printf("\n\r STATUS REG : %x\r\n", scp->status_reg);
      while ((scp->status_reg & SATA_CORE_DONE) != SATA_CORE_DONE);

      xil_printf("\nDATA in DDR\n");
      for(i = 0; i< (WORDS_PER_SECTOR * sector_count); i++) {
        //xil_printf("\n\r DATA %d %d", i, ddr3[i+(READ_SPACE_OFFSET/SZ_WORD)]);
      }
      //Time to Read/Write Sectors from Disk 
      xil_printf("\n\r SECTOR Clock Cycles:%d\r\n",scp->sector_timer_reg);
}


void write_sectors(int sector_addr, int sector_count) {
      int i=0, j=0;

      xil_printf("\nFill DDR with DATA at DDR Write Address\n"); 
      for(i = 0; i< (WORDS_PER_SECTOR * NUM_SECTORS); i++, j++)
      {
        if(j == (4*WORDS_PER_SECTOR))
           j=0;
        ddr3[i + (WRITE_SPACE_OFFSET/SZ_WORD)] = j; 
      }

      // DDR Write Space Start Address 
      scp->npi_rd_addr_reg = DDR_BASE + WRITE_SPACE_OFFSET;
      // Clear SATA Control Register 
      scp->ctrl_reg = REG_CLEAR;


      // Input Sector Address, Count, DATA and Command to Sata Core
      scp->sector_addr_reg = sector_addr;
      scp->sector_count_reg = sector_count;
      scp->cmd_reg = (WRITE_CMD);
      // Trigger SATA Core
      scp->ctrl_reg = (NEW_CMD);
     
      // Wait for Command Completion 
      xil_printf("\n\r STATUS REG : %x\r\n", scp->status_reg);
      while ((scp->status_reg & SATA_CORE_DONE) != SATA_CORE_DONE);

      //Time to Read/Write Sectors from Disk 
      xil_printf("\n\r SECTOR Clock Cycles:%d\r\n", scp->sector_timer_reg);
}


