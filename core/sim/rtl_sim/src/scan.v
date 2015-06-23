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
/*                                SCAN test                                  */
/*---------------------------------------------------------------------------*/
/* The purpose of this test is to let the scan_mode and scan_enable signals  */
/* toggle a bit in order to clean-up code coverage and give more visibility  */
/* on potential "real" coverage loss.                                        */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 85 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-01-28 22:05:37 +0100 (Fri, 28 Jan 2011) $          */
/*===========================================================================*/
    
integer ii;

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      // Disable detection of the end of test
      force inst_pc = 16'h0000;


      //  SCAN MODE
      //------------------------------

      for ( ii=0; ii < 8; ii=ii+1)
	begin
	   scan_mode = ~scan_mode;
	   repeat(5) @(posedge mclk);
	end
      scan_mode = 1'b0;
    
      reset_n       = 1'b1;
      #93;
      reset_n       = 1'b0;
      #593;
      reset_n       = 1'b1;
      repeat(20) @(posedge mclk);

      //  SCAN ENABLE
      //------------------------------

      for ( ii=0; ii < 8; ii=ii+1)
	begin
	   scan_enable = ~scan_enable;
	   repeat(5) @(posedge mclk);
	end
      scan_enable = 1'b0;
    
      reset_n       = 1'b1;
      #93;
      reset_n       = 1'b0;
      #593;
      reset_n       = 1'b1;
      repeat(20) @(posedge mclk);

      //  SCAN MODE & SCAN ENABLE
      //------------------------------

      for ( ii=0; ii < 8; ii=ii+1)
	begin
	   scan_mode = ~scan_mode;
	   repeat(5) @(posedge mclk);
	   scan_enable = ~scan_enable;
	   repeat(5) @(posedge mclk);
	   scan_enable = ~scan_enable;
	   repeat(5) @(posedge mclk);
	   scan_mode = ~scan_mode;
	   repeat(5) @(posedge mclk);
	end
      scan_mode   = 1'b0;
      scan_enable = 1'b0;
      repeat(5) @(posedge mclk);
 
      for ( ii=0; ii < 8; ii=ii+1)
	begin
	   scan_enable = ~scan_enable;
	   repeat(5) @(posedge mclk);
	   scan_mode = ~scan_mode;
	   repeat(5) @(posedge mclk);
	   scan_mode = ~scan_mode;
	   repeat(5) @(posedge mclk);
	   scan_enable = ~scan_enable;
	   repeat(5) @(posedge mclk);
	end
      scan_mode   = 1'b0;
      scan_enable = 1'b0;
    
      reset_n       = 1'b1;
      #93;
      reset_n       = 1'b0;
      #593;
      reset_n       = 1'b1;
      repeat(20) @(posedge mclk);

      release inst_pc;



      stimulus_done = 1;
   end

