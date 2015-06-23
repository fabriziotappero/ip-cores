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
/*                                 SANDBOX                                   */
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
      if ((`PMEM_SIZE !== 24576) || (`DMEM_SIZE !== 16384))
        begin
           $display(" ===============================================");
           $display("|               SIMULATION ERROR                |");
           $display("|                                               |");
           $display("|  Core must be configured for:                 |");
           $display("|               - 24kB program memory           |");
           $display("|               - 16kB data memory              |");
           $display(" ===============================================");
           $finish;        
        end


      //---------------------------------------
      // Generate stimulus
      //---------------------------------------

      repeat(1000) @(posedge mclk);
      p1_din = 8'h01;
      repeat(10) @(posedge mclk);
      p1_din = 8'h00;
      repeat(1000) @(posedge mclk);
      p1_din = 8'h01;
      repeat(10) @(posedge mclk);
      p1_din = 8'h00;
      repeat(1000) @(posedge mclk);

      stimulus_done = 1;

      $display(" ===============================================");
      $display("|               SIMULATION DONE                 |");
      $display("|       (stopped through verilog stimulus)      |");
      $display(" ===============================================");
      $finish;

   end

