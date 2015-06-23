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
/*                  Special Function Registers (SFRs)                        */
/*---------------------------------------------------------------------------*/
/* Test the SFR registers.                                                   */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 85 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-01-28 22:05:37 +0100 (Fri, 28 Jan 2011) $          */
/*===========================================================================*/
    
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

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      //  NMI
      //------------------------------
      @(r15 === 16'h1000);

      // NMI feature is verified in the NMI.S43 test

      @(r15 === 16'h1001);

      //  WATCHDOG
      //------------------------------
      @(r15 === 16'h2000);

      // WATCHDOG feature is verified in the WDT_*.S43 tests
	
      @(r15 === 16'h2001);

	
      //  READ/WRITE IFG1
      //------------------------------
      @(r15 === 16'h3000);

      @(r15 === 16'h3001);
      if (r10 !== 16'h0000)   tb_error("====== IFG1 incorrect (test 1) =====");

      @(r15 === 16'h3002);
      `ifdef NMI
         `ifdef WATCHDOG
      if (r10 !== 16'h0011)   tb_error("====== IFG1 incorrect (test 2) =====");
         `else
      if (r10 !== 16'h0010)   tb_error("====== IFG1 incorrect (test 3) =====");
         `endif
      `else
         `ifdef WATCHDOG
      if (r10 !== 16'h0001)   tb_error("====== IFG1 incorrect (test 4) =====");
         `else
      if (r10 !== 16'h0000)   tb_error("====== IFG1 incorrect (test 5) =====");
         `endif
      `endif
	
      @(r15 === 16'h3003);
      if (r10 !== 16'h0000)   tb_error("====== IFG1 incorrect (test 6) =====");
	
      @(r15 === 16'h3004);
      `ifdef NMI
         `ifdef WATCHDOG
      if (r10 !== 16'h0011)   tb_error("====== IFG1 incorrect (test 7) =====");
         `else
      if (r10 !== 16'h0010)   tb_error("====== IFG1 incorrect (test 8) =====");
         `endif
      `else
         `ifdef WATCHDOG
      if (r10 !== 16'h0001)   tb_error("====== IFG1 incorrect (test 9) =====");
         `else
      if (r10 !== 16'h0000)   tb_error("====== IFG1 incorrect (test 10) =====");
         `endif
      `endif
	
      @(r15 === 16'h3005);
      if (r10 !== 16'h0000)   tb_error("====== IFG1 incorrect (test 11) =====");

      @(r15 === 16'h3006);
      if (r10 !== 16'h0000)   tb_error("====== IFG1 incorrect (test 12) =====");

	
      //  READ/WRITE IE1
      //------------------------------
      @(r15 === 16'h4000);

      @(r15 === 16'h4001);
      if (r10 !== 16'h0000)   tb_error("====== IE1 incorrect (test 1) =====");

      @(r15 === 16'h4002);
      `ifdef NMI
         `ifdef WATCHDOG
      if (r10 !== 16'h0011)   tb_error("====== IE1 incorrect (test 2) =====");
         `else
      if (r10 !== 16'h0010)   tb_error("====== IE1 incorrect (test 3) =====");
         `endif
      `else
         `ifdef WATCHDOG
      if (r10 !== 16'h0001)   tb_error("====== IE1 incorrect (test 4) =====");
         `else
      if (r10 !== 16'h0000)   tb_error("====== IE1 incorrect (test 5) =====");
         `endif
      `endif
	
      @(r15 === 16'h4003);
      if (r10 !== 16'h0000)   tb_error("====== IE1 incorrect (test 6) =====");
	
      @(r15 === 16'h4004);
      `ifdef NMI
         `ifdef WATCHDOG
      if (r10 !== 16'h0011)   tb_error("====== IE1 incorrect (test 7) =====");
         `else
      if (r10 !== 16'h0010)   tb_error("====== IE1 incorrect (test 8) =====");
         `endif
      `else
         `ifdef WATCHDOG
      if (r10 !== 16'h0001)   tb_error("====== IE1 incorrect (test 9) =====");
         `else
      if (r10 !== 16'h0000)   tb_error("====== IE1 incorrect (test 10) =====");
         `endif
      `endif
	
      @(r15 === 16'h4005);
      if (r10 !== 16'h0000)   tb_error("====== IE1 incorrect (test 11) =====");

      @(r15 === 16'h4006);
      if (r10 !== 16'h0000)   tb_error("====== IE1 incorrect (test 12) =====");

	
      // READ/WRITE CPU_ID
      //------------------------------
      @(r15 === 16'h5000);

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

      @(r15 === 16'h5001);
      if (r10 !== dbg_id[15:0])   tb_error("====== CPU_ID_LO incorrect (test 1) =====");
      if (r11 !== dbg_id[31:16])  tb_error("====== CPU_ID_HI incorrect (test 2) =====");
     
      @(r15 === 16'h5002);
      if (r10 !== dbg_id[15:0])   tb_error("====== CPU_ID_LO incorrect (test 3) =====");
      if (r11 !== dbg_id[31:16])  tb_error("====== CPU_ID_HI incorrect (test 4) =====");
     
      @(r15 === 16'h5003);
      if (r10 !== dbg_id[15:0])   tb_error("====== CPU_ID_LO incorrect (test 5) =====");
      if (r11 !== dbg_id[31:16])  tb_error("====== CPU_ID_HI incorrect (test 6) =====");
     

      // READ/WRITE CPU_NR
      //------------------------------
      @(r15 === 16'h6000);

      @(r15 === 16'h6001);
      if (r10 !== 16'h3412)       tb_error("====== CPU_NR incorrect (test 1) =====");
     
      @(r15 === 16'h6002);
      if (r10 !== 16'h3412)       tb_error("====== CPU_NR incorrect (test 2) =====");
     
      @(r15 === 16'h6003);
      if (r10 !== 16'h3412)       tb_error("====== CPU_NR incorrect (test 3) =====");
     


      stimulus_done = 1;
   end

