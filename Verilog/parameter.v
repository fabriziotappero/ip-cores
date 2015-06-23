/****************************************************************************************
 MODULE:		Parameters File

 FILE NAME:	parameter.v
 VERSION:	1.0
 DATE:		April 8th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Parameter Verilog File
 

 Hossein Amidi
 (C) April 2002

***************************************************************************************/

// Parameters

/****** RISC Processor ******/
parameter add_size	  = 12;
parameter padd_size    = 24;
parameter cmd_size     = 3;
parameter cs_size      = 2;
parameter dqm_size     = 4;
parameter ba_size      = 2;
parameter data_size    = 32;
parameter timing_size  = 12;

parameter DataWidth = 32;
parameter AddrWidth = 24;
parameter OpcodeWidth = 8;
parameter StateSize = 2;

parameter Byte_size = 8;
parameter uart_add  = 3;

/****** SDRAM CNTRL ******/
parameter burst 		=	  3;
parameter HiZ       =  32'hz;
parameter cas_size     = 2;
parameter rc_size      = 2;
parameter ref_dur_size = 4;
parameter burst_size   = 4;
parameter byte_size    = 8;
parameter row_size     = 12;
parameter col_size     = 10;
parameter bank_size    = 2;
parameter rowstart     = 10;
parameter colstart     = 0;
parameter bankstart    = 22;

/****** Bus Arbiter ******/
parameter arbiter_bus_size = 3;
parameter irq_size		 	= 3;

/****** DMA CNTRL ******/
parameter dma_reg_addr  = 3;
parameter dma_reg_depth = 8;
parameter dma_reg_width = 32;
parameter dma_fifo_width = 8;
parameter dma_fifo_depth = 32;
parameter dma_counter_size = 5;
parameter fifo_size = 8;

/****** UART ******/
parameter uart_reg_depth = 8;
parameter uart_reg_width = 32;
parameter uart_cnt_size = 3;
parameter ser_in_cnt = 3;
parameter ser_out_cnt = 3;

/****** LRU Cache ******/
parameter cache_reg_depth = 8;
parameter cache_reg_width = 32;
parameter cache_line_size = 53;
parameter cache_valid = 2;
parameter cache_tag = 19;

/****** Timer ******/
parameter timer_reg_depth = 4;
parameter timer_reg_width = 32;
parameter timer_addr_size = 2;
parameter timer_size = 32;

/****** Flash CNTRL ******/
parameter flash_size = 8;
parameter flash_reg_width = 32;
parameter flash_reg_depth = 8;

/*********************************************************************/

/****************************** MEMORY Map ***************************/
/* Total of 16MB of Memory for Both Data and Instruction and         */
/* internal Register mapping                                         */
/*                                                                   */
/*********************************************************************/

// FLASH Memory 64K x 8-bit, 512Kbit (F 0x000000 T 0x07FFFF)
parameter flash_mem_addr_map = 24'h000000;


// DMA Regiseters 8 x 32-bit (F 0x080000 T 0x080007)
parameter dma_reg_addr_map	= 24'h080000;

// Flash Regiseters 8 x 32-bit (F 0x080008 T 0x08000F)
parameter flash_reg_addr_map = 24'h080008;

// Data Cache Regiseters 8 x 32-bit (F 0x080010 T 0x080017)
parameter data_cache_reg_addr_map = 24'h080010;

// Instruction Cache Regiseters 8 x 32-bit (F 0x080018 T 0x08001F)
parameter instruction_cache_reg_addr_map = 24'h080018;

// Timer Regiseters 4 x 32-bit (F 0x080020 T 0x080023)
parameter timer_reg_addr_map = 24'h080020;

// UART Regiseters 8 x 32-bit (F 0x080024 T 0x08002B)
parameter uart_reg_addr_map = 24'h080024;


// SDRAM Memory 8M x 32-bit using 2M x 8-bit x 4 bank IC's.
// (F 0x7FFFFF T 0xFFFFFF)
parameter sdram_mem_addr_map = 24'h7FFFFF;


