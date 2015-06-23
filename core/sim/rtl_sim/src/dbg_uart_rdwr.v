/*===========================================================================*/
/* Copyright (C) 2001 Authors                                                */
/*                                                                           */
/* This source file may be used and distributed without restriction provided */
/* that this copyright statement is not removed from the file and that any   */
/* derivative work contains the original copyright notice and the associated */
/* disclaimer.                                                               */
/*                                                                           */
/* This source file is free software; you can redistribute it and/or modify  */
/* it under the terms of the GNU Lesser General Public License as published  */
/* by the Free Software Foundation; either version 2.1 of the License, or    */
/* (at your option) any later version.                                       */
/*                                                                           */
/* This source is distributed in the hope that it will be useful, but WITHOUT*/
/* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     */
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public       */
/* License for more details.                                                 */
/*                                                                           */
/* You should have received a copy of the GNU Lesser General Public License  */
/* along with this source; if not, write to the Free Software Foundation,    */
/* Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA        */
/*                                                                           */
/*===========================================================================*/
/*                            DEBUG INTERFACE:  RD / WR                      */
/*---------------------------------------------------------------------------*/
/* Test the UART debug interface:                                            */
/*                        - Check RD/WR access to all adressable             */
/*        	            debug registers.                                 */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 95 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-02-24 21:37:57 +0100 (Thu, 24 Feb 2011) $          */
/*===========================================================================*/

`define LONG_TIMEOUT

reg  [2:0] cpu_version;
reg        cpu_asic;
reg  [4:0] user_version;
reg  [6:0] per_space;
reg        mpy_info;
reg  [8:0] dmem_size;
reg  [5:0] pmem_size;
reg [31:0] dbg_id;

// Set oMSP parameters for later check
defparam dut.INST_NR  = 8'h12;
defparam dut.TOTAL_NR = 8'h34;

integer    ii;


initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
`ifdef DBG_EN
`ifdef DBG_UART
    #1 dbg_en = 1;
      repeat(30) @(posedge mclk);
      stimulus_done = 0;

      // SEND UART SYNCHRONIZATION FRAME
      dbg_uart_tx(DBG_SYNC);

      // STOP CPU
      dbg_uart_wr(CPU_CTL ,  16'h0001);

      // TEST READ/WR TO ALL DEBUG REGISTERS
      //--------------------------------------------------------

      cpu_version  =  `CPU_VERSION;
`ifdef ASIC
      cpu_asic     =  1'b1;
`else
      cpu_asic     =  1'b0;
`endif
      user_version =  `USER_VERSION;
      per_space    = (`PER_SIZE  >> 9);
`ifdef MULTIPLIER
      mpy_info     =  1'b1;
`else
      mpy_info     =  1'b0;
`endif
      dmem_size    = (`DMEM_SIZE >> 7);
      pmem_size    = (`PMEM_SIZE >> 10);

      dbg_id       = {pmem_size,
		      dmem_size,
		      mpy_info,
		      per_space,
		      user_version,
		      cpu_asic,
                      cpu_version};

      // Check reset value
      for ( ii=0; ii < 64; ii=ii+1)
	begin
	   dbg_uart_rd(ii[7:0]);

	   case(ii)
	     0       : if (dbg_uart_buf !== dbg_id[15:0])  tb_error("READ 1 ERROR (CPU_ID_LO)");
	     1       : if (dbg_uart_buf !== dbg_id[31:16]) tb_error("READ 1 ERROR (CPU_ID_HI)");
	     2       : if (dbg_uart_buf !== 16'h0000)      tb_error("READ 1 ERROR (CPU_CTL)");
	     3       : if (dbg_uart_buf !== 16'h0005)      tb_error("READ 1 ERROR (CPU_STAT)");
	    24       : if (dbg_uart_buf !== 16'h3412)      tb_error("READ 1 ERROR (CPU_NR)");
	     default : if (dbg_uart_buf !== 16'h0000)      tb_error("READ 1 ERROR");
	   endcase
	end

      // Write access
      for ( ii=0; ii < 64; ii=ii+1)
	begin
	   // Skip write for MEM_CNT
	   if (ii!=7)
	     dbg_uart_wr(ii[7:0] ,  16'hffff);
	end
      
      // Read value back
      for ( ii=0; ii < 64; ii=ii+1)
	begin
	   dbg_uart_rd(ii[7:0]);

	   case(ii)
	     0       : if (dbg_uart_buf !== dbg_id[15:0])  tb_error("READ 2 ERROR (CPU_ID_LO)");
	     1       : if (dbg_uart_buf !== dbg_id[31:16]) tb_error("READ 2 ERROR (CPU_ID_HI)");
	     2       : if (dbg_uart_buf !== 16'h0078)      tb_error("READ 2 ERROR (CPU_CTL)");
	     3       : if ((dbg_uart_buf !== 16'h0004)&0)  tb_error("READ 2 ERROR (CPU_STAT)");
	     4       : if (dbg_uart_buf !== 16'h000E)      tb_error("READ 2 ERROR (MEM_CTL)");
	     5       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (MEM_ADDR)");
	     6       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (MEM_DATA)");
	     7       : if (dbg_uart_buf !== 16'h0000)      tb_error("READ 2 ERROR (MEM_CNT)");
`ifdef DBG_HWBRK_0
   `ifdef DBG_HWBRK_RANGE
	     8       : if (dbg_uart_buf !== 16'h001F)      tb_error("READ 2 ERROR (BRK0_CTL)");
   `else
	     8       : if (dbg_uart_buf !== 16'h000F)      tb_error("READ 2 ERROR (BRK0_CTL)");
   `endif
	     9       : if (dbg_uart_buf !== 16'h0000)      tb_error("READ 2 ERROR (BRK0_STAT)");
	    10       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (BRK0_ADDR0)");
	    11       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (BRK0_ADDR1)");
`endif
`ifdef DBG_HWBRK_1
   `ifdef DBG_HWBRK_RANGE
	    12       : if (dbg_uart_buf !== 16'h001F)      tb_error("READ 2 ERROR (BRK1_CTL)");
   `else
	    12       : if (dbg_uart_buf !== 16'h000F)      tb_error("READ 2 ERROR (BRK1_CTL)");
   `endif
	    13       : if (dbg_uart_buf !== 16'h0000)      tb_error("READ 2 ERROR (BRK1_STAT)");
	    14       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (BRK1_ADDR0)");
	    15       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (BRK1_ADDR1)");
`endif
`ifdef DBG_HWBRK_2
   `ifdef DBG_HWBRK_RANGE
	    16       : if (dbg_uart_buf !== 16'h001F)      tb_error("READ 2 ERROR (BRK2_CTL)");
   `else
	    16       : if (dbg_uart_buf !== 16'h000F)      tb_error("READ 2 ERROR (BRK2_CTL)");
   `endif
	    17       : if (dbg_uart_buf !== 16'h0000)      tb_error("READ 2 ERROR (BRK2_STAT)");
	    18       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (BRK2_ADDR0)");
	    19       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (BRK2_ADDR1)");
`endif
`ifdef DBG_HWBRK_3
   `ifdef DBG_HWBRK_RANGE
	    20       : if (dbg_uart_buf !== 16'h001F)      tb_error("READ 2 ERROR (BRK3_CTL)");
   `else
	    20       : if (dbg_uart_buf !== 16'h000F)      tb_error("READ 2 ERROR (BRK3_CTL)");
   `endif
	    21       : if (dbg_uart_buf !== 16'h0000)      tb_error("READ 2 ERROR (BRK3_STAT)");
	    22       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (BRK3_ADDR0)");
	    23       : if (dbg_uart_buf !== 16'hFFFF)      tb_error("READ 2 ERROR (BRK3_ADDR1)");
`endif
	    24       : if (dbg_uart_buf !== 16'h3412)      tb_error("READ 2 ERROR (CPU_NR)");
	     default : if (dbg_uart_buf !== 16'h0000)      tb_error("READ 2 ERROR");
	   endcase
	end

      
      dbg_uart_wr(CPU_CTL    ,  16'h0002); 
      repeat(10) @(posedge mclk);

      stimulus_done = 1;
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|   (serial debug interface UART not included)  |");
       $display(" ===============================================");
       $finish;
`endif
`else

       $display(" ===============================================");
       $display("|               SIMULATION SKIPPED              |");
       $display("|      (serial debug interface not included)    |");
       $display(" ===============================================");
       $finish;
`endif
   end

