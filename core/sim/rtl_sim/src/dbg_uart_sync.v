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
/*                            DEBUG INTERFACE:  UART                         */
/*---------------------------------------------------------------------------*/
/* Test the UART debug interface:                                            */
/*                        - Check synchronization of the serial              */
/*                          debug interface input.                           */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 95 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-02-24 21:37:57 +0100 (Thu, 24 Feb 2011) $          */
/*===========================================================================*/

`define VERY_LONG_TIMEOUT

integer    ii;
reg [15:0] jj;

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

      // Enable metastablity emulation for the RXD path
      dbg_uart_rxd_meta = 1'b1;
  
      //--------------------------------------------------------
      // TRY VARIOUS SERIAL DEBUG INTERFACE TRANSFER
      // WITH DIFFERENT BAUD-RATES
      //--------------------------------------------------------
  
      for ( ii=0; ii < 500; ii=ii+1)
	begin
	   #1 reset_n = 0;
	   repeat(1) @(posedge mclk);
 	   #1 reset_n = 1;
	   repeat(10) @(posedge mclk);
    
	   UART_PERIOD = 650 + 1*ii;
	   $display("Synchronisation test for DBG_UART_PERIOD = %5d ns  /  ii = %-d", UART_PERIOD, ii);
	   
	   // SEND UART SYNCHRONIZATION FRAME
	   dbg_uart_sync;

	   // READ CPU_ID
	   dbg_uart_rd(CPU_ID_LO);
	   if (dbg_uart_buf !== dbg_cpu_id[15:0])
	     begin
		$display("CPU_ID_LO: read = 0x%-4h / expected = 0x%-4h", dbg_uart_buf, dbg_cpu_id[15:0]);
		tb_error("====== CPU_ID_LO incorrect (test 1) =====");
		force_end_of_sim;
	     end
	   dbg_uart_rd(CPU_ID_HI);
	   if (dbg_uart_buf !== dbg_cpu_id[31:16])
	     begin
		$display("CPU_ID_HI: read = 0x%-4h / expected = 0x%-4h", dbg_uart_buf, dbg_cpu_id[31:16]);
		tb_error("====== CPU_ID_HI incorrect (test 1) =====");
		force_end_of_sim;
	     end

	   //-----------------------------------
	   // MAKE SOME READ/WRITE ACCESS
	   //-----------------------------------
	   jj = 'h4328;
	   dbg_uart_wr(MEM_DATA,  16'h4328);
	   dbg_uart_rd(MEM_DATA);
	   if (dbg_uart_buf !== 16'h4328)
	     begin
		$display("DMEM_DATA: read = 0x%-4h / expected = 0x4328", dbg_uart_buf);
		tb_error("====== MEM_DATA incorrect (test 1) =====");
		force_end_of_sim;
	     end

	   jj = 'h3280;
	   dbg_uart_wr(MEM_DATA,  16'h3280);
	   dbg_uart_rd(MEM_DATA);
	   if (dbg_uart_buf !== 16'h3280)
	     begin
		$display("DMEM_DATA: read = 0x%-4h / expected = 0x3280", dbg_uart_buf);
		tb_error("====== MEM_DATA incorrect (test 2) =====");
		force_end_of_sim;
	     end

	   jj = 'h2800;
	   dbg_uart_wr(MEM_DATA,  16'h2800);
	   dbg_uart_rd(MEM_DATA);
	   if (dbg_uart_buf !== 16'h2800)
	     begin
		$display("DMEM_DATA: read = 0x%-4h / expected = 0x2800", dbg_uart_buf);
		tb_error("====== MEM_DATA incorrect (test 1) =====");
		force_end_of_sim;
	     end

	   jj = 'h8000;
	   dbg_uart_wr(MEM_DATA,  16'h8000);
	   dbg_uart_rd(MEM_DATA);
	   if (dbg_uart_buf !== 16'h8000)
	     begin
		$display("DMEM_DATA: read = 0x%-4h / expected = 0x8000", dbg_uart_buf);
		tb_error("====== MEM_DATA incorrect (test 2) =====");
		force_end_of_sim;
	     end

	   jj = 'h0000;
	   dbg_uart_wr(MEM_DATA,  16'h0000);
	   dbg_uart_rd(MEM_DATA);
	   if (dbg_uart_buf !== 16'h0000)
	     begin
		$display("DMEM_DATA: read = 0x%-4h / expected = 0x0000", dbg_uart_buf);
		tb_error("====== MEM_DATA incorrect (test 2) =====");
		force_end_of_sim;
	     end

	   jj = 'hffff;
	   dbg_uart_wr(MEM_DATA,  16'hffff);
	   dbg_uart_rd(MEM_DATA);
	   if (dbg_uart_buf !== 16'hffff)
	     begin
		$display("DMEM_DATA: read = 0x%-4h / expected = 0xffff", dbg_uart_buf);
		tb_error("====== MEM_DATA incorrect (test 2) =====");
		force_end_of_sim;
	     end

	   jj = 'h7f7f;
	   dbg_uart_wr(MEM_DATA,  16'h7f7f);
	   dbg_uart_rd(MEM_DATA);
	   if (dbg_uart_buf !== 16'h7f7f)
	     begin
		$display("DMEM_DATA: read = 0x%-4h / expected = 0x7f7f", dbg_uart_buf);
		tb_error("====== MEM_DATA incorrect (test 2) =====");
		force_end_of_sim;
	     end

	   jj = 'h55aa;
	   dbg_uart_wr(MEM_DATA,  16'h55aa);
	   dbg_uart_rd(MEM_DATA);
	   if (dbg_uart_buf !== 16'h55aa)
	     begin
		$display("DMEM_DATA: read = 0x%-4h / expected = 0x55aa", dbg_uart_buf);
		tb_error("====== MEM_DATA incorrect (test 2) =====");
		force_end_of_sim;
	     end

	   jj = 'h5aa5;
	   dbg_uart_wr(MEM_DATA,  16'h5aa5);
	   dbg_uart_rd(MEM_DATA);
	   if (dbg_uart_buf !== 16'h5aa5)
	     begin
		$display("DMEM_DATA: read = 0x%-4h / expected = 0x5aa5", dbg_uart_buf);
		tb_error("====== MEM_DATA incorrect (test 2) =====");
		force_end_of_sim;
	     end
	end


      //--------------------------------------------------------
      // TRY LONGEST POSSIBLE SYNCHRONIZATION FRAME
      //--------------------------------------------------------
  
      #1 reset_n = 0;
      repeat(1) @(posedge mclk);
      #1 reset_n = 1;
      repeat(10) @(posedge mclk);

      dbg_uart_rxd_pre = 1'b0;
      @(posedge dut.dbg_0.dbg_uart_0.sync_cnt[`DBG_UART_XFER_CNT_W+2]);
      dbg_uart_rxd_pre = 1'b1;

      repeat(100) @(posedge mclk);

      dbg_uart_rxd_pre = 1'b0;
      @(posedge dut.dbg_0.dbg_uart_0.xfer_cnt[`DBG_UART_XFER_CNT_W-1]);
      dbg_uart_rxd_pre = 1'b1;

      repeat(100) @(posedge mclk);


      //--------------------------------------------------------
      // END OF TEST
      //--------------------------------------------------------
  
      #1 reset_n = 0;
      repeat(1) @(posedge mclk);
      #1 reset_n = 1;
      repeat(10) @(posedge mclk);

      UART_PERIOD = 550;
      $display("Synchronisation test for DBG_UART_PERIOD = %5d ns  /  ii = %-d", UART_PERIOD, ii);
      
      // SEND UART SYNCHRONIZATION FRAME
      dbg_uart_sync;
           
      // Let the CPU run
      dbg_uart_wr(CPU_CTL,  16'h0002);

      // Generate an IRQ
      wkup[0]            = 1'b1;
      @(negedge mclk);
      irq[`IRQ_NR-16]    = 1'b1;
      @(negedge irq_acc[`IRQ_NR-16])
      @(negedge mclk);
      wkup[0]            = 1'b0;
      irq[`IRQ_NR-16]    = 1'b0;
      
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

   task force_end_of_sim;
      begin
	 repeat(10) @(posedge mclk);
	 $display(" ===============================================");
	 $display("|               SIMULATION FAILED               |");
	 $display("|     (some verilog stimulus checks failed)     |");
	 $display(" ===============================================");
	 $finish;
      end
   endtask
