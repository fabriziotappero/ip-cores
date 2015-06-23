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
/*                                 DIGITAL I/O                               */
/*---------------------------------------------------------------------------*/
/* Test the Digital I/O interface:                                           */
/*                                   - Read/Write register access.           */
/*                                   - I/O Functionality.                    */
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 111 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2011-05-20 22:39:02 +0200 (Fri, 20 May 2011) $          */
/*===========================================================================*/

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      // PORT 1: TEST RD/WR REGISTER ACCESS
      //--------------------------------------------------------
      @(r15==16'h0001);

      if (mem200 !== 16'h0000) tb_error("====== P1IN  != 0x0000 =====");
      if (mem202 !== 16'h55aa) tb_error("====== P1OUT != 0x55aa =====");
      if (mem204 !== 16'ha55a) tb_error("====== P1DIR != 0xa55a =====");
      if (mem206 !== 16'haa55) tb_error("====== P1IFG != 0xaa55 =====");
      if (mem208 !== 16'h5aa5) tb_error("====== P1IES != 0x5aa5 =====");
      if (mem20A !== 16'h55aa) tb_error("====== P1IE  != 0x55aa =====");
      if (mem20C !== 16'h32cd) tb_error("====== P1SEL != 0x32cd =====");

      
      // PORT 2: TEST RD/WR REGISTER ACCESS
      //--------------------------------------------------------
      @(r15==16'h0002);

      if (mem210 !== 16'h0000) tb_error("====== P2IN  != 0x0000 =====");
      if (mem212 !== 16'h55aa) tb_error("====== P2OUT != 0x55aa =====");
      if (mem214 !== 16'ha55a) tb_error("====== P2DIR != 0xa55a =====");
      if (mem216 !== 16'haa55) tb_error("====== P2IFG != 0xaa55 =====");
      if (mem218 !== 16'h5aa5) tb_error("====== P2IES != 0x5aa5 =====");
      if (mem21A !== 16'h55aa) tb_error("====== P2IE  != 0x55aa =====");
      if (mem21C !== 16'h32cd) tb_error("====== P2SEL != 0x32cd =====");

      
      // PORT 3: TEST RD/WR REGISTER ACCESS
      //--------------------------------------------------------
      @(r15==16'h0003);

      if (mem220 !== 16'h0000) tb_error("====== P3IN  != 0x0000 =====");
      if (mem222 !== 16'h55aa) tb_error("====== P3OUT != 0x55aa =====");
      if (mem224 !== 16'ha55a) tb_error("====== P3DIR != 0xa55a =====");
      if (mem226 !== 16'h32cd) tb_error("====== P3SEL != 0x32cd =====");

      
      // PORT 4: TEST RD/WR REGISTER ACCESS
      //--------------------------------------------------------
      @(r15==16'h0004);

      if (mem230 !== 16'h0000) tb_error("====== P4IN  != 0x0000 =====");
      if (mem232 !== 16'h55aa) tb_error("====== P4OUT != 0x55aa =====");
      if (mem234 !== 16'ha55a) tb_error("====== P4DIR != 0xa55a =====");
      if (mem236 !== 16'h32cd) tb_error("====== P4SEL != 0x32cd =====");

      
      // PORT 5: TEST RD/WR REGISTER ACCESS
      //--------------------------------------------------------
      @(r15==16'h0005);

      if (mem240 !== 16'h0000) tb_error("====== P5IN  != 0x0000 =====");
      if (mem242 !== 16'h55aa) tb_error("====== P5OUT != 0x55aa =====");
      if (mem244 !== 16'ha55a) tb_error("====== P5DIR != 0xa55a =====");
      if (mem246 !== 16'h32cd) tb_error("====== P5SEL != 0x32cd =====");

      
      // PORT 6: TEST RD/WR REGISTER ACCESS
      //--------------------------------------------------------
      @(r15==16'h0006);

      if (mem250 !== 16'h0000) tb_error("====== P6IN  != 0x0000 =====");
      if (mem252 !== 16'h55aa) tb_error("====== P6OUT != 0x55aa =====");
      if (mem254 !== 16'ha55a) tb_error("====== P6DIR != 0xa55a =====");
      if (mem256 !== 16'h32cd) tb_error("====== P6SEL != 0x32cd =====");


      // PORT 1: TEST I/O FUNCTIONALITY
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0000)) p1_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0001)) p1_din = 8'h02;
      @(r15==(`PER_SIZE+16'h0002)) p1_din = 8'h04;
      @(r15==(`PER_SIZE+16'h0003)) p1_din = 8'h08;
      @(r15==(`PER_SIZE+16'h0004)) p1_din = 8'h10;
      @(r15==(`PER_SIZE+16'h0005)) p1_din = 8'h20;
      @(r15==(`PER_SIZE+16'h0006)) p1_din = 8'h40;
      @(r15==(`PER_SIZE+16'h0007)) p1_din = 8'h80;
      @(r15==(`PER_SIZE+16'h0008));
      if (mem200 !== 16'h0201) tb_error("====== P1IN  != 0x0201 =====");
      if (mem202 !== 16'h0804) tb_error("====== P1IN  != 0x0804 =====");
      if (mem204 !== 16'h2010) tb_error("====== P1IN  != 0x2010 =====");
      if (mem206 !== 16'h8040) tb_error("====== P1IN  != 0x8040 =====");

      @(r15==16'h1100);
      if (p1_dout !== 8'h01) tb_error("====== P1DOUT  != 0x01 =====");
      @(r15==16'h1101);
      if (p1_dout !== 8'h02) tb_error("====== P1DOUT  != 0x02 =====");
      @(r15==16'h1102);
      if (p1_dout !== 8'h04) tb_error("====== P1DOUT  != 0x04 =====");
      @(r15==16'h1103);
      if (p1_dout !== 8'h08) tb_error("====== P1DOUT  != 0x08 =====");
      @(r15==16'h1104);
      if (p1_dout !== 8'h10) tb_error("====== P1DOUT  != 0x10 =====");
      @(r15==16'h1105);
      if (p1_dout !== 8'h20) tb_error("====== P1DOUT  != 0x20 =====");
      @(r15==16'h1106);
      if (p1_dout !== 8'h40) tb_error("====== P1DOUT  != 0x40 =====");
      @(r15==16'h1107);
      if (p1_dout !== 8'h80) tb_error("====== P1DOUT  != 0x80 =====");

      @(r15==16'h1200);
      if (p1_dout_en !== 8'h01) tb_error("====== P1DIR  != 0x01 =====");
      @(r15==16'h1201);
      if (p1_dout_en !== 8'h02) tb_error("====== P1DIR  != 0x02 =====");
      @(r15==16'h1202);
      if (p1_dout_en !== 8'h04) tb_error("====== P1DIR  != 0x04 =====");
      @(r15==16'h1203);
      if (p1_dout_en !== 8'h08) tb_error("====== P1DIR  != 0x08 =====");
      @(r15==16'h1204);
      if (p1_dout_en !== 8'h10) tb_error("====== P1DIR  != 0x10 =====");
      @(r15==16'h1205);
      if (p1_dout_en !== 8'h20) tb_error("====== P1DIR  != 0x20 =====");
      @(r15==16'h1206);
      if (p1_dout_en !== 8'h40) tb_error("====== P1DIR  != 0x40 =====");
      @(r15==16'h1207);
      if (p1_dout_en !== 8'h80) tb_error("====== P1DIR  != 0x80 =====");

      @(r15==16'h1300);
      if (p1_sel !== 8'h01) tb_error("====== P1SEL  != 0x01 =====");
      @(r15==16'h1301);
      if (p1_sel !== 8'h02) tb_error("====== P1SEL  != 0x02 =====");
      @(r15==16'h1302);
      if (p1_sel !== 8'h04) tb_error("====== P1SEL  != 0x04 =====");
      @(r15==16'h1303);
      if (p1_sel !== 8'h08) tb_error("====== P1SEL  != 0x08 =====");
      @(r15==16'h1304);
      if (p1_sel !== 8'h10) tb_error("====== P1SEL  != 0x10 =====");
      @(r15==16'h1305);
      if (p1_sel !== 8'h20) tb_error("====== P1SEL  != 0x20 =====");
      @(r15==16'h1306);
      if (p1_sel !== 8'h40) tb_error("====== P1SEL  != 0x40 =====");
      @(r15==16'h1307);
      if (p1_sel !== 8'h80) tb_error("====== P1SEL  != 0x80 =====");

      
      // PORT 2: TEST I/O FUNCTIONALITY
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0010)) p2_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0011)) p2_din = 8'h02;
      @(r15==(`PER_SIZE+16'h0012)) p2_din = 8'h04;
      @(r15==(`PER_SIZE+16'h0013)) p2_din = 8'h08;
      @(r15==(`PER_SIZE+16'h0014)) p2_din = 8'h10;
      @(r15==(`PER_SIZE+16'h0015)) p2_din = 8'h20;
      @(r15==(`PER_SIZE+16'h0016)) p2_din = 8'h40;
      @(r15==(`PER_SIZE+16'h0017)) p2_din = 8'h80;
      @(r15==(`PER_SIZE+16'h0018));
      if (mem210 !== 16'h0201) tb_error("====== P2IN  != 0x0201 =====");
      if (mem212 !== 16'h0804) tb_error("====== P2IN  != 0x0804 =====");
      if (mem214 !== 16'h2010) tb_error("====== P2IN  != 0x2010 =====");
      if (mem216 !== 16'h8040) tb_error("====== P2IN  != 0x8040 =====");

      @(r15==16'h2100);
      if (p2_dout !== 8'h01) tb_error("====== P2DOUT  != 0x01 =====");
      @(r15==16'h2101);
      if (p2_dout !== 8'h02) tb_error("====== P2DOUT  != 0x02 =====");
      @(r15==16'h2102);
      if (p2_dout !== 8'h04) tb_error("====== P2DOUT  != 0x04 =====");
      @(r15==16'h2103);
      if (p2_dout !== 8'h08) tb_error("====== P2DOUT  != 0x08 =====");
      @(r15==16'h2104);
      if (p2_dout !== 8'h10) tb_error("====== P2DOUT  != 0x10 =====");
      @(r15==16'h2105);
      if (p2_dout !== 8'h20) tb_error("====== P2DOUT  != 0x20 =====");
      @(r15==16'h2106);
      if (p2_dout !== 8'h40) tb_error("====== P2DOUT  != 0x40 =====");
      @(r15==16'h2107);
      if (p2_dout !== 8'h80) tb_error("====== P2DOUT  != 0x80 =====");

      @(r15==16'h2200);
      if (p2_dout_en !== 8'h01) tb_error("====== P2DIR  != 0x01 =====");
      @(r15==16'h2201);
      if (p2_dout_en !== 8'h02) tb_error("====== P2DIR  != 0x02 =====");
      @(r15==16'h2202);
      if (p2_dout_en !== 8'h04) tb_error("====== P2DIR  != 0x04 =====");
      @(r15==16'h2203);
      if (p2_dout_en !== 8'h08) tb_error("====== P2DIR  != 0x08 =====");
      @(r15==16'h2204);
      if (p2_dout_en !== 8'h10) tb_error("====== P2DIR  != 0x10 =====");
      @(r15==16'h2205);
      if (p2_dout_en !== 8'h20) tb_error("====== P2DIR  != 0x20 =====");
      @(r15==16'h2206);
      if (p2_dout_en !== 8'h40) tb_error("====== P2DIR  != 0x40 =====");
      @(r15==16'h2207);
      if (p2_dout_en !== 8'h80) tb_error("====== P2DIR  != 0x80 =====");

      @(r15==16'h2300);
      if (p2_sel !== 8'h01) tb_error("====== P2SEL  != 0x01 =====");
      @(r15==16'h2301);
      if (p2_sel !== 8'h02) tb_error("====== P2SEL  != 0x02 =====");
      @(r15==16'h2302);
      if (p2_sel !== 8'h04) tb_error("====== P2SEL  != 0x04 =====");
      @(r15==16'h2303);
      if (p2_sel !== 8'h08) tb_error("====== P2SEL  != 0x08 =====");
      @(r15==16'h2304);
      if (p2_sel !== 8'h10) tb_error("====== P2SEL  != 0x10 =====");
      @(r15==16'h2305);
      if (p2_sel !== 8'h20) tb_error("====== P2SEL  != 0x20 =====");
      @(r15==16'h2306);
      if (p2_sel !== 8'h40) tb_error("====== P2SEL  != 0x40 =====");
      @(r15==16'h2307);
      if (p2_sel !== 8'h80) tb_error("====== P2SEL  != 0x80 =====");

      
      // PORT 3: TEST I/O FUNCTIONALITY
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0020)) p3_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0021)) p3_din = 8'h02;
      @(r15==(`PER_SIZE+16'h0022)) p3_din = 8'h04;
      @(r15==(`PER_SIZE+16'h0023)) p3_din = 8'h08;
      @(r15==(`PER_SIZE+16'h0024)) p3_din = 8'h10;
      @(r15==(`PER_SIZE+16'h0025)) p3_din = 8'h20;
      @(r15==(`PER_SIZE+16'h0026)) p3_din = 8'h40;
      @(r15==(`PER_SIZE+16'h0027)) p3_din = 8'h80;
      @(r15==(`PER_SIZE+16'h0028));
      if (mem220 !== 16'h0201) tb_error("====== P3IN  != 0x0201 =====");
      if (mem222 !== 16'h0804) tb_error("====== P3IN  != 0x0804 =====");
      if (mem224 !== 16'h2010) tb_error("====== P3IN  != 0x2010 =====");
      if (mem226 !== 16'h8040) tb_error("====== P3IN  != 0x8040 =====");

      @(r15==16'h3100);
      if (p3_dout !== 8'h01) tb_error("====== P3DOUT  != 0x01 =====");
      @(r15==16'h3101);
      if (p3_dout !== 8'h02) tb_error("====== P3DOUT  != 0x02 =====");
      @(r15==16'h3102);
      if (p3_dout !== 8'h04) tb_error("====== P3DOUT  != 0x04 =====");
      @(r15==16'h3103);
      if (p3_dout !== 8'h08) tb_error("====== P3DOUT  != 0x08 =====");
      @(r15==16'h3104);
      if (p3_dout !== 8'h10) tb_error("====== P3DOUT  != 0x10 =====");
      @(r15==16'h3105);
      if (p3_dout !== 8'h20) tb_error("====== P3DOUT  != 0x20 =====");
      @(r15==16'h3106);
      if (p3_dout !== 8'h40) tb_error("====== P3DOUT  != 0x40 =====");
      @(r15==16'h3107);
      if (p3_dout !== 8'h80) tb_error("====== P3DOUT  != 0x80 =====");

      @(r15==16'h3200);
      if (p3_dout_en !== 8'h01) tb_error("====== P3DIR  != 0x01 =====");
      @(r15==16'h3201);
      if (p3_dout_en !== 8'h02) tb_error("====== P3DIR  != 0x02 =====");
      @(r15==16'h3202);
      if (p3_dout_en !== 8'h04) tb_error("====== P3DIR  != 0x04 =====");
      @(r15==16'h3203);
      if (p3_dout_en !== 8'h08) tb_error("====== P3DIR  != 0x08 =====");
      @(r15==16'h3204);
      if (p3_dout_en !== 8'h10) tb_error("====== P3DIR  != 0x10 =====");
      @(r15==16'h3205);
      if (p3_dout_en !== 8'h20) tb_error("====== P3DIR  != 0x20 =====");
      @(r15==16'h3206);
      if (p3_dout_en !== 8'h40) tb_error("====== P3DIR  != 0x40 =====");
      @(r15==16'h3207);
      if (p3_dout_en !== 8'h80) tb_error("====== P3DIR  != 0x80 =====");

      @(r15==16'h3300);
      if (p3_sel !== 8'h01) tb_error("====== P3SEL  != 0x01 =====");
      @(r15==16'h3301);
      if (p3_sel !== 8'h02) tb_error("====== P3SEL  != 0x02 =====");
      @(r15==16'h3302);
      if (p3_sel !== 8'h04) tb_error("====== P3SEL  != 0x04 =====");
      @(r15==16'h3303);
      if (p3_sel !== 8'h08) tb_error("====== P3SEL  != 0x08 =====");
      @(r15==16'h3304);
      if (p3_sel !== 8'h10) tb_error("====== P3SEL  != 0x10 =====");
      @(r15==16'h3305);
      if (p3_sel !== 8'h20) tb_error("====== P3SEL  != 0x20 =====");
      @(r15==16'h3306);
      if (p3_sel !== 8'h40) tb_error("====== P3SEL  != 0x40 =====");
      @(r15==16'h3307);
      if (p3_sel !== 8'h80) tb_error("====== P3SEL  != 0x80 =====");

      
      // PORT 4: TEST I/O FUNCTIONALITY
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0030)) p4_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0031)) p4_din = 8'h02;
      @(r15==(`PER_SIZE+16'h0032)) p4_din = 8'h04;
      @(r15==(`PER_SIZE+16'h0033)) p4_din = 8'h08;
      @(r15==(`PER_SIZE+16'h0034)) p4_din = 8'h10;
      @(r15==(`PER_SIZE+16'h0035)) p4_din = 8'h20;
      @(r15==(`PER_SIZE+16'h0036)) p4_din = 8'h40;
      @(r15==(`PER_SIZE+16'h0037)) p4_din = 8'h80;
      @(r15==(`PER_SIZE+16'h0038));
      if (mem230 !== 16'h0201) tb_error("====== P4IN  != 0x0201 =====");
      if (mem232 !== 16'h0804) tb_error("====== P4IN  != 0x0804 =====");
      if (mem234 !== 16'h2010) tb_error("====== P4IN  != 0x2010 =====");
      if (mem236 !== 16'h8040) tb_error("====== P4IN  != 0x8040 =====");

      @(r15==16'h4100);
      if (p4_dout !== 8'h01) tb_error("====== P4DOUT  != 0x01 =====");
      @(r15==16'h4101);
      if (p4_dout !== 8'h02) tb_error("====== P4DOUT  != 0x02 =====");
      @(r15==16'h4102);
      if (p4_dout !== 8'h04) tb_error("====== P4DOUT  != 0x04 =====");
      @(r15==16'h4103);
      if (p4_dout !== 8'h08) tb_error("====== P4DOUT  != 0x08 =====");
      @(r15==16'h4104);
      if (p4_dout !== 8'h10) tb_error("====== P4DOUT  != 0x10 =====");
      @(r15==16'h4105);
      if (p4_dout !== 8'h20) tb_error("====== P4DOUT  != 0x20 =====");
      @(r15==16'h4106);
      if (p4_dout !== 8'h40) tb_error("====== P4DOUT  != 0x40 =====");
      @(r15==16'h4107);
      if (p4_dout !== 8'h80) tb_error("====== P4DOUT  != 0x80 =====");

      @(r15==16'h4200);
      if (p4_dout_en !== 8'h01) tb_error("====== P4DIR  != 0x01 =====");
      @(r15==16'h4201);
      if (p4_dout_en !== 8'h02) tb_error("====== P4DIR  != 0x02 =====");
      @(r15==16'h4202);
      if (p4_dout_en !== 8'h04) tb_error("====== P4DIR  != 0x04 =====");
      @(r15==16'h4203);
      if (p4_dout_en !== 8'h08) tb_error("====== P4DIR  != 0x08 =====");
      @(r15==16'h4204);
      if (p4_dout_en !== 8'h10) tb_error("====== P4DIR  != 0x10 =====");
      @(r15==16'h4205);
      if (p4_dout_en !== 8'h20) tb_error("====== P4DIR  != 0x20 =====");
      @(r15==16'h4206);
      if (p4_dout_en !== 8'h40) tb_error("====== P4DIR  != 0x40 =====");
      @(r15==16'h4207);
      if (p4_dout_en !== 8'h80) tb_error("====== P4DIR  != 0x80 =====");

      @(r15==16'h4300);
      if (p4_sel !== 8'h01) tb_error("====== P4SEL  != 0x01 =====");
      @(r15==16'h4301);
      if (p4_sel !== 8'h02) tb_error("====== P4SEL  != 0x02 =====");
      @(r15==16'h4302);
      if (p4_sel !== 8'h04) tb_error("====== P4SEL  != 0x04 =====");
      @(r15==16'h4303);
      if (p4_sel !== 8'h08) tb_error("====== P4SEL  != 0x08 =====");
      @(r15==16'h4304);
      if (p4_sel !== 8'h10) tb_error("====== P4SEL  != 0x10 =====");
      @(r15==16'h4305);
      if (p4_sel !== 8'h20) tb_error("====== P4SEL  != 0x20 =====");
      @(r15==16'h4306);
      if (p4_sel !== 8'h40) tb_error("====== P4SEL  != 0x40 =====");
      @(r15==16'h4307);
      if (p4_sel !== 8'h80) tb_error("====== P4SEL  != 0x80 =====");

      
      // PORT 5: TEST I/O FUNCTIONALITY
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0040)) p5_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0041)) p5_din = 8'h02;
      @(r15==(`PER_SIZE+16'h0042)) p5_din = 8'h04;
      @(r15==(`PER_SIZE+16'h0043)) p5_din = 8'h08;
      @(r15==(`PER_SIZE+16'h0044)) p5_din = 8'h10;
      @(r15==(`PER_SIZE+16'h0045)) p5_din = 8'h20;
      @(r15==(`PER_SIZE+16'h0046)) p5_din = 8'h40;
      @(r15==(`PER_SIZE+16'h0047)) p5_din = 8'h80;
      @(r15==(`PER_SIZE+16'h0048));
      if (mem240 !== 16'h0201) tb_error("====== P5IN  != 0x0201 =====");
      if (mem242 !== 16'h0804) tb_error("====== P5IN  != 0x0804 =====");
      if (mem244 !== 16'h2010) tb_error("====== P5IN  != 0x2010 =====");
      if (mem246 !== 16'h8040) tb_error("====== P5IN  != 0x8040 =====");

      @(r15==16'h5100);
      if (p5_dout !== 8'h01) tb_error("====== P5DOUT  != 0x01 =====");
      @(r15==16'h5101);
      if (p5_dout !== 8'h02) tb_error("====== P5DOUT  != 0x02 =====");
      @(r15==16'h5102);
      if (p5_dout !== 8'h04) tb_error("====== P5DOUT  != 0x04 =====");
      @(r15==16'h5103);
      if (p5_dout !== 8'h08) tb_error("====== P5DOUT  != 0x08 =====");
      @(r15==16'h5104);
      if (p5_dout !== 8'h10) tb_error("====== P5DOUT  != 0x10 =====");
      @(r15==16'h5105);
      if (p5_dout !== 8'h20) tb_error("====== P5DOUT  != 0x20 =====");
      @(r15==16'h5106);
      if (p5_dout !== 8'h40) tb_error("====== P5DOUT  != 0x40 =====");
      @(r15==16'h5107);
      if (p5_dout !== 8'h80) tb_error("====== P5DOUT  != 0x80 =====");

      @(r15==16'h5200);
      if (p5_dout_en !== 8'h01) tb_error("====== P5DIR  != 0x01 =====");
      @(r15==16'h5201);
      if (p5_dout_en !== 8'h02) tb_error("====== P5DIR  != 0x02 =====");
      @(r15==16'h5202);
      if (p5_dout_en !== 8'h04) tb_error("====== P5DIR  != 0x04 =====");
      @(r15==16'h5203);
      if (p5_dout_en !== 8'h08) tb_error("====== P5DIR  != 0x08 =====");
      @(r15==16'h5204);
      if (p5_dout_en !== 8'h10) tb_error("====== P5DIR  != 0x10 =====");
      @(r15==16'h5205);
      if (p5_dout_en !== 8'h20) tb_error("====== P5DIR  != 0x20 =====");
      @(r15==16'h5206);
      if (p5_dout_en !== 8'h40) tb_error("====== P5DIR  != 0x40 =====");
      @(r15==16'h5207);
      if (p5_dout_en !== 8'h80) tb_error("====== P5DIR  != 0x80 =====");

      @(r15==16'h5300);
      if (p5_sel !== 8'h01) tb_error("====== P5SEL  != 0x01 =====");
      @(r15==16'h5301);
      if (p5_sel !== 8'h02) tb_error("====== P5SEL  != 0x02 =====");
      @(r15==16'h5302);
      if (p5_sel !== 8'h04) tb_error("====== P5SEL  != 0x04 =====");
      @(r15==16'h5303);
      if (p5_sel !== 8'h08) tb_error("====== P5SEL  != 0x08 =====");
      @(r15==16'h5304);
      if (p5_sel !== 8'h10) tb_error("====== P5SEL  != 0x10 =====");
      @(r15==16'h5305);
      if (p5_sel !== 8'h20) tb_error("====== P5SEL  != 0x20 =====");
      @(r15==16'h5306);
      if (p5_sel !== 8'h40) tb_error("====== P5SEL  != 0x40 =====");
      @(r15==16'h5307);
      if (p5_sel !== 8'h80) tb_error("====== P5SEL  != 0x80 =====");

      
      // PORT 6: TEST I/O FUNCTIONALITY
      //--------------------------------------------------------

      @(r15==(`PER_SIZE+16'h0050)) p6_din = 8'h01;
      @(r15==(`PER_SIZE+16'h0051)) p6_din = 8'h02;
      @(r15==(`PER_SIZE+16'h0052)) p6_din = 8'h04;
      @(r15==(`PER_SIZE+16'h0053)) p6_din = 8'h08;
      @(r15==(`PER_SIZE+16'h0054)) p6_din = 8'h10;
      @(r15==(`PER_SIZE+16'h0055)) p6_din = 8'h20;
      @(r15==(`PER_SIZE+16'h0056)) p6_din = 8'h40;
      @(r15==(`PER_SIZE+16'h0057)) p6_din = 8'h80;
      @(r15==(`PER_SIZE+16'h0058));
      if (mem250 !== 16'h0201) tb_error("====== P6IN  != 0x0201 =====");
      if (mem252 !== 16'h0804) tb_error("====== P6IN  != 0x0804 =====");
      if (mem254 !== 16'h2010) tb_error("====== P6IN  != 0x2010 =====");
      if (mem256 !== 16'h8040) tb_error("====== P6IN  != 0x8040 =====");

      @(r15==16'h6100);
      if (p6_dout !== 8'h01) tb_error("====== P6DOUT  != 0x01 =====");
      @(r15==16'h6101);
      if (p6_dout !== 8'h02) tb_error("====== P6DOUT  != 0x02 =====");
      @(r15==16'h6102);
      if (p6_dout !== 8'h04) tb_error("====== P6DOUT  != 0x04 =====");
      @(r15==16'h6103);
      if (p6_dout !== 8'h08) tb_error("====== P6DOUT  != 0x08 =====");
      @(r15==16'h6104);
      if (p6_dout !== 8'h10) tb_error("====== P6DOUT  != 0x10 =====");
      @(r15==16'h6105);
      if (p6_dout !== 8'h20) tb_error("====== P6DOUT  != 0x20 =====");
      @(r15==16'h6106);
      if (p6_dout !== 8'h40) tb_error("====== P6DOUT  != 0x40 =====");
      @(r15==16'h6107);
      if (p6_dout !== 8'h80) tb_error("====== P6DOUT  != 0x80 =====");

      @(r15==16'h6200);
      if (p6_dout_en !== 8'h01) tb_error("====== P6DIR  != 0x01 =====");
      @(r15==16'h6201);
      if (p6_dout_en !== 8'h02) tb_error("====== P6DIR  != 0x02 =====");
      @(r15==16'h6202);
      if (p6_dout_en !== 8'h04) tb_error("====== P6DIR  != 0x04 =====");
      @(r15==16'h6203);
      if (p6_dout_en !== 8'h08) tb_error("====== P6DIR  != 0x08 =====");
      @(r15==16'h6204);
      if (p6_dout_en !== 8'h10) tb_error("====== P6DIR  != 0x10 =====");
      @(r15==16'h6205);
      if (p6_dout_en !== 8'h20) tb_error("====== P6DIR  != 0x20 =====");
      @(r15==16'h6206);
      if (p6_dout_en !== 8'h40) tb_error("====== P6DIR  != 0x40 =====");
      @(r15==16'h6207);
      if (p6_dout_en !== 8'h80) tb_error("====== P6DIR  != 0x80 =====");

      @(r15==16'h6300);
      if (p6_sel !== 8'h01) tb_error("====== P6SEL  != 0x01 =====");
      @(r15==16'h6301);
      if (p6_sel !== 8'h02) tb_error("====== P6SEL  != 0x02 =====");
      @(r15==16'h6302);
      if (p6_sel !== 8'h04) tb_error("====== P6SEL  != 0x04 =====");
      @(r15==16'h6303);
      if (p6_sel !== 8'h08) tb_error("====== P6SEL  != 0x08 =====");
      @(r15==16'h6304);
      if (p6_sel !== 8'h10) tb_error("====== P6SEL  != 0x10 =====");
      @(r15==16'h6305);
      if (p6_sel !== 8'h20) tb_error("====== P6SEL  != 0x20 =====");
      @(r15==16'h6306);
      if (p6_sel !== 8'h40) tb_error("====== P6SEL  != 0x40 =====");
      @(r15==16'h6307);
      if (p6_sel !== 8'h80) tb_error("====== P6SEL  != 0x80 =====");

      
      stimulus_done = 1;
   end

