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
/*                             DHRYSTONE FOR MCU                             */
/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 19 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:47:15 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/
`define NO_TIMEOUT

time mclk_start_time, mclk_end_time;
real mclk_period,     mclk_frequency;

time dhry_start_time, dhry_end_time;
real dhry_per_sec,    dhry_mips,     dhry_mips_per_mhz;

integer Number_Of_Runs;

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      //---------------------------------------
      // Check CPU configuration
      //---------------------------------------

      if ((`PMEM_SIZE !== 49152) || (`DMEM_SIZE !== 10240))
        begin
           $display(" ===============================================");
           $display("|               SIMULATION ERROR                |");
           $display("|                                               |");
           $display("|  Core must be configured for:                 |");
           $display("|               - 48kB program memory           |");
           $display("|               - 10kB data memory              |");
           $display(" ===============================================");
           $finish;
        end

      // Disable watchdog
      // (only required because RedHat/TI GCC toolchain doesn't disable watchdog properly at startup)
      `ifdef WATCHDOG
        force dut.watchdog_0.wdtcnt   = 16'h0000;
      `endif

      //---------------------------------------
      // Number of benchmark iteration
      // (Must match the C-code value)
      //---------------------------------------

      Number_Of_Runs = 100;


      //---------------------------------------
      // Measure clock period
      //---------------------------------------
      repeat(100) @(posedge mclk);
      $timeformat(-9, 3, " ns", 10);
      @(posedge mclk);
      mclk_start_time = $time;
      @(posedge mclk);
      mclk_end_time = $time;
      @(posedge mclk);
      mclk_period    = mclk_end_time-mclk_start_time;
      mclk_frequency = 1000/mclk_period;
      $display("\nINFO-VERILOG: openMSP430 System clock frequency %f MHz\n", mclk_frequency);

      //---------------------------------------
      // Measure Dhrystone run time
      //---------------------------------------

      // Detect beginning of run
      @(posedge p3_dout[0]);
      dhry_start_time = $time;
      $timeformat(-3, 3, " ms", 10);
      $display("\nINFO-VERILOG: Dhrystone loop started at %t ", dhry_start_time);
      $display("");
      $display("INFO-VERILOG: Be patient... there could be up to 13ms to simulate");
      $display("");

      // Detect end of run
      @(negedge p3_dout[0]);
      dhry_end_time = $time;
      $timeformat(-3, 3, " ms", 10);
      $display("INFO-VERILOG: Dhrystone loop ended   at %t ",   dhry_end_time);

      // Compute results
      $timeformat(-9, 3, " ns", 10);
      dhry_per_sec      = (Number_Of_Runs*1000000000)/(dhry_end_time - dhry_start_time);
      dhry_mips         = dhry_per_sec / 1757;
      dhry_mips_per_mhz = dhry_mips / mclk_frequency;

      // Report results
      $display("\INFO-VERILOG: Dhrystone per second : %f",   dhry_per_sec);
      $display("\INFO-VERILOG: DMIPS                : %f",   dhry_mips);
      $display("\INFO-VERILOG: DMIPS/MHz            : %f\n", dhry_mips_per_mhz);

      //---------------------------------------
      // Wait for the end of C-code execution
      //---------------------------------------
      @(posedge p4_dout[0]);

      stimulus_done = 1;

      $display(" ===============================================");
      $display("|               SIMULATION DONE                 |");
      $display("|       (stopped through verilog stimulus)      |");
      $display(" ===============================================");
      $finish;

   end

// Display stuff from the C-program
always @(p2_dout[0])
  begin
     $write("%s", p1_dout);
     $fflush();
  end

// Display some info to show simulation progress
initial
  begin
     @(posedge p3_dout[0]);
     #1000000;
     while (p3_dout[0])
       begin
	  $display("INFO-VERILOG: Simulated time %t ", $time);
	  #1000000;
       end
  end
