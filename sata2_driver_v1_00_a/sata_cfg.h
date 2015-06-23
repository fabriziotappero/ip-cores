/*
 * sata_cfg.h
 *
 * Definitions for the SATA core configuration registers
 *
 * Author: Bin Huang  <bin.arthur@gmail.com>
 *
 * 2012 (c) Reconfigurable Computing System Lab at University of North
 * Carolina at Charlotte. This file is licensed under
 * the terms of the GNU General Public License version 2. This program
 * is licensed "as is" without any warranty of any kind, whether express
 * or implied. The code originally comes from the book "Linux Device
 * Drivers" by Alessandro Rubini and Jonathan Corbet, published
 * by O'Reilly & Associates.
 */

#include "xparameters.h"

#define SATA_CFG_BASE		XPAR_SATA_CORE_0_BASEADDR
#define SATA_CFG_HIGH  		XPAR_SATA_CORE_0_HIGHADDR
#define SATA_CFG_REMAP_SIZE     (SATA_CFG_HIGH - SATA_CFG_BASE + 1)

// Structure maps to SATA Core Slave Registers
typedef struct {
  volatile unsigned int ctrl_reg;
  volatile unsigned int cmd_reg;
  volatile unsigned int status_reg;
  volatile unsigned int sector_addr_reg;
  volatile unsigned int sector_count_reg;
  volatile unsigned int sector_timer_reg;
  volatile unsigned int npi_rd_addr_reg;
  volatile unsigned int npi_wr_addr_reg;
} SATA_core_t,
  *pSATA_core_t;

// Special Commands to SATA controller
#define REG_CLEAR      0x00000000
#define SATA_LINK_READY 0x00000002
#define SW_RESET       0x00000001
#define NPI_DONE       0x00000004
#define SATA_CORE_DONE 0x00000001
#define NEW_CMD        0x00000002
#define READ_CMD       0x00000001
#define WRITE_CMD      0x00000002

#define WORDS_PER_SECTOR 128 
