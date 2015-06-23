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
/*                     8 BIT PERIPHERAL TEMPLATE                             */
/*---------------------------------------------------------------------------*/
/* Test the 8 bit peripheral template:                                       */
/*                                     - Read/Write register access.         */
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

      // TEST RD/WR REGISTER ACCESS
      //--------------------------------------------------------
      @(r15==16'h0001);

      if (mem200 !== 16'hee11) tb_error("====== CNTRL1: @0x200 != 0xee11 =====");
      if (mem202 !== 16'h55aa) tb_error("====== CNTRL2: @0x202 != 0x55aa =====");
      if (mem204 !== 16'ha55a) tb_error("====== CNTRL3: @0x204 != 0xa55a =====");
      if (mem206 !== 16'haa55) tb_error("====== CNTRL4: @0x206 != 0xaa55 =====");

      
      stimulus_done = 1;
   end

