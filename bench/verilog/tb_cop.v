//////////////////////////////////////////////////////////////////////
////                                                              ////
////  tb_cop.v                                                    ////
////                                                              ////
////  This file is part of the Ethernet IP core project           ////
////  http://www.opencores.org/projects/??????/                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Igor Mohor (igorM@opencores.org)                      ////
////                                                              ////
////  All additional information is avaliable in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001, 2002 Authors                             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
//



`include "timescale.v"

module tb_cop();


parameter Tp = 1;


reg         wb_clk_o;
reg         wb_rst_o;


// WISHBONE master 1 (input)
reg  [31:0] m1_wb_adr_o;
reg   [3:0] m1_wb_sel_o;
reg         m1_wb_we_o;
wire [31:0] m1_wb_dat_i;
reg  [31:0] m1_wb_dat_o;
reg         m1_wb_cyc_o;
reg         m1_wb_stb_o;
wire        m1_wb_ack_i;
wire        m1_wb_err_i;

// WISHBONE master 2 (input)
reg  [31:0] m2_wb_adr_o;
reg   [3:0] m2_wb_sel_o;
reg         m2_wb_we_o;
wire [31:0] m2_wb_dat_i;
reg  [31:0] m2_wb_dat_o;
reg         m2_wb_cyc_o;
reg         m2_wb_stb_o;
wire        m2_wb_ack_i;
wire        m2_wb_err_i;

// WISHBONE slave 1 (output)
wire [31:0] s1_wb_adr_i;
wire  [3:0] s1_wb_sel_i;
wire        s1_wb_we_i;
reg  [31:0] s1_wb_dat_o;
wire [31:0] s1_wb_dat_i;
wire        s1_wb_cyc_i;
wire        s1_wb_stb_i;
reg         s1_wb_ack_o;
reg         s1_wb_err_o;

// WISHBONE slave 2 (output)
wire [31:0] s2_wb_adr_i;
wire  [3:0] s2_wb_sel_i;
wire        s2_wb_we_i;
reg  [31:0] s2_wb_dat_o;
wire [31:0] s2_wb_dat_i;
wire        s2_wb_cyc_i;
wire        s2_wb_stb_i;
reg         s2_wb_ack_o;
reg         s2_wb_err_o;


reg         Wishbone1Busy;
reg         Wishbone2Busy;

reg         StartTB;

eth_cop i_eth_cop
(
  // WISHBONE common
  .wb_clk_i(wb_clk_o), .wb_rst_i(wb_rst_o), 

  // WISHBONE MASTER 1
  .m1_wb_adr_i(m1_wb_adr_o), .m1_wb_sel_i(m1_wb_sel_o), .m1_wb_we_i (m1_wb_we_o),  .m1_wb_dat_o(m1_wb_dat_i), 
  .m1_wb_dat_i(m1_wb_dat_o), .m1_wb_cyc_i(m1_wb_cyc_o), .m1_wb_stb_i(m1_wb_stb_o), .m1_wb_ack_o(m1_wb_ack_i), 
  .m1_wb_err_o(m1_wb_err_i), 

  // WISHBONE MASTER 2
  .m2_wb_adr_i(m2_wb_adr_o), .m2_wb_sel_i(m2_wb_sel_o), .m2_wb_we_i (m2_wb_we_o),  .m2_wb_dat_o(m2_wb_dat_i), 
  .m2_wb_dat_i(m2_wb_dat_o), .m2_wb_cyc_i(m2_wb_cyc_o), .m2_wb_stb_i(m2_wb_stb_o), .m2_wb_ack_o(m2_wb_ack_i), 
  .m2_wb_err_o(m2_wb_err_i), 

  // WISHBONE slave 1
 	.s1_wb_adr_o(s1_wb_adr_i), .s1_wb_sel_o(s1_wb_sel_i), .s1_wb_we_o (s1_wb_we_i),  .s1_wb_cyc_o(s1_wb_cyc_i), 
 	.s1_wb_stb_o(s1_wb_stb_i), .s1_wb_ack_i(s1_wb_ack_o), .s1_wb_err_i(s1_wb_err_o), .s1_wb_dat_i(s1_wb_dat_o),
 	.s1_wb_dat_o(s1_wb_dat_i), 
 	
  // WISHBONE slave 2
 	.s2_wb_adr_o(s2_wb_adr_i), .s2_wb_sel_o(s2_wb_sel_i), .s2_wb_we_o (s2_wb_we_i),  .s2_wb_cyc_o(s2_wb_cyc_i), 
 	.s2_wb_stb_o(s2_wb_stb_i), .s2_wb_ack_i(s2_wb_ack_o), .s2_wb_err_i(s2_wb_err_o), .s2_wb_dat_i(s2_wb_dat_o),
 	.s2_wb_dat_o(s2_wb_dat_i)
);

/*
s1_wb_adr_i   m_wb_adr_i
s1_wb_sel_i   m_wb_sel_i
s1_wb_we_i    m_wb_we_i 
s1_wb_dat_o   m_wb_dat_o
s1_wb_dat_i   m_wb_dat_i
s1_wb_cyc_i   m_wb_cyc_i
s1_wb_stb_i   m_wb_stb_i
s1_wb_ack_o   m_wb_ack_o
s1_wb_err_o   m_wb_err_o
*/



initial
begin
  s1_wb_ack_o = 0;
  s1_wb_err_o = 0;
  s1_wb_dat_o = 0;
  s2_wb_ack_o = 0;
  s2_wb_err_o = 0;
  s2_wb_dat_o = 0;

// WISHBONE master 1 (input)
  m1_wb_adr_o = 0;
  m1_wb_sel_o = 0;
  m1_wb_we_o  = 0;
  m1_wb_dat_o = 0;
  m1_wb_cyc_o = 0;
  m1_wb_stb_o = 0;

  // WISHBONE master 2 (input)
  m2_wb_adr_o = 0;
  m2_wb_sel_o = 0;
  m2_wb_we_o  = 0;
  m2_wb_dat_o = 0;
  m2_wb_cyc_o = 0;
  m2_wb_stb_o = 0;

  Wishbone1Busy = 1'b0;
  Wishbone2Busy = 1'b0;
end


// Reset pulse
initial
begin
  wb_rst_o =  1'b1;
  #100 wb_rst_o =  1'b0;
  #100 StartTB  =  1'b1;
end



// Generating WB_CLK_I clock
always
begin
  wb_clk_o = 0;
  forever #15 wb_clk_o = ~wb_clk_o;  // 2*15 ns -> 33.3 MHz    
end


integer seed_wb1, seed_wb2;
integer jj, kk;
initial
begin
  seed_wb1 = 0;
  seed_wb2 = 5;
end




initial
begin
  wait(StartTB);  // Start of testbench
  
  fork
  
  begin
    for(jj=0; jj<100; jj=jj+1)
    begin
      if(seed_wb1[3:0]<4)
        begin
          $display("(%0t) m1 write to eth start  (Data = Addr = 0x%0x)", $time, {21'h1a0000, seed_wb1[10:0]}); //0xd0000xxx
          Wishbone1Write({21'h1a0000, seed_wb1[10:0]}, {21'h1a0000, seed_wb1[10:0]});
        end
      else
      if(seed_wb1[3:0]<=7 && seed_wb1[3:0]>=4)
        begin
          $display("(%0t) m1 read to eth start  (Addr = 0x%0x)", $time, {21'h1a0000, seed_wb1[10:0]});
          Wishbone1Read({21'h1a0000, seed_wb1[10:0]});
        end
      else
      if(seed_wb1[3:0]<=11 && seed_wb1[3:0]>=8)
        begin
          $display("(%0t) m1 write to memory start  (Data = Addr = 0x%0x)", $time, {21'h000040, seed_wb1[10:0]}); //0x00020xxx
          Wishbone1Write({21'h1a0000, seed_wb1[10:0]}, {21'h000040, seed_wb1[10:0]});
        end
      else
      if(seed_wb1[3:0]>=12)
        begin
          $display("(%0t) m1 read to memory start  (Addr = 0x%0x)", $time, {21'h000040, seed_wb1[10:0]});
          Wishbone1Read({21'h000040, seed_wb1[10:0]});
        end
      
      #1 seed_wb1 = $random(seed_wb1);
      $display("seed_wb1[4:0] = 0x%0x", seed_wb1[4:0]);
      repeat(seed_wb1[4:0])   @ (posedge wb_clk_o);
    end
  end
  

  begin
    for(kk=0; kk<100; kk=kk+1)
    begin
      if(seed_wb2[3:0]<4)
        begin
          $display("(%0t) m2 write to eth start  (Data = Addr = 0x%0x)", $time, {21'h1a0000, seed_wb2[10:0]}); //0xd0000xxx
          Wishbone2Write({21'h1a0000, seed_wb2[10:0]}, {21'h1a0000, seed_wb2[10:0]});
        end
      else
      if(seed_wb2[3:0]<=7 && seed_wb2[3:0]>=4)
        begin
          $display("(%0t) m2 read to eth start  (Addr = 0x%0x)", $time, {21'h1a0000, seed_wb2[10:0]});
          Wishbone2Read({21'h1a0000, seed_wb2[10:0]});
        end
      else
      if(seed_wb2[3:0]<=11 && seed_wb2[3:0]>=8)
        begin
          $display("(%0t) m2 write to memory start  (Data = Addr = 0x%0x)", $time, {21'h000040, seed_wb2[10:0]}); //0x00020xxx
          Wishbone2Write({21'h1a0000, seed_wb2[10:0]}, {21'h000040, seed_wb2[10:0]});
        end
      else
      if(seed_wb2[3:0]>=12)
        begin
          $display("(%0t) m2 read to memory start  (Addr = 0x%0x)", $time, {21'h000040, seed_wb2[10:0]});
          Wishbone2Read({21'h000040, seed_wb2[10:0]});
        end
      
      #1 seed_wb2 = $random(seed_wb2);
      $display("seed_wb2[4:0] = 0x%0x", seed_wb2[4:0]);
      repeat(seed_wb2[4:0])   @ (posedge wb_clk_o);
    end
  end
  



  join    

  #10000 $stop;
end







task Wishbone1Write;
  input [31:0] Data;
  input [31:0] Address;
  integer ii;

  begin
    wait (~Wishbone1Busy);
    Wishbone1Busy = 1;
    @ (posedge wb_clk_o);
    #1;
    m1_wb_adr_o = Address;
    m1_wb_dat_o = Data;
    m1_wb_we_o  = 1'b1;
    m1_wb_cyc_o = 1'b1;
    m1_wb_stb_o = 1'b1;
    m1_wb_sel_o = 4'hf;

    wait(m1_wb_ack_i | m1_wb_err_i);   // waiting for acknowledge response

    // Writing information about the access to the screen
    @ (posedge wb_clk_o);
    if(m1_wb_ack_i)
      $display("(%0t) Master1 write cycle finished ok(Data: 0x%0x, Addr: 0x%0x)", $time, Data, Address);
    else
      $display("(%0t) Master1 write cycle finished with error(Data: 0x%0x, Addr: 0x%0x)", $time, Data, Address);

    #1;
    m1_wb_adr_o = 32'hx;
    m1_wb_dat_o = 32'hx;
    m1_wb_we_o  = 1'bx;
    m1_wb_cyc_o = 1'b0;
    m1_wb_stb_o = 1'b0;
    m1_wb_sel_o = 4'hx;
    #5 Wishbone1Busy = 0;
  end
endtask


task Wishbone1Read;
  input [31:0] Address;
  reg   [31:0] Data;
  integer ii;

  begin
    wait (~Wishbone1Busy);
    Wishbone1Busy = 1;
    @ (posedge wb_clk_o);
    #1;
    m1_wb_adr_o = Address;
    m1_wb_we_o  = 1'b0;
    m1_wb_cyc_o = 1'b1;
    m1_wb_stb_o = 1'b1;
    m1_wb_sel_o = 4'hf;

    wait(m1_wb_ack_i | m1_wb_err_i);   // waiting for acknowledge response
    Data = m1_wb_dat_i;

    // Writing information about the access to the screen
    @ (posedge wb_clk_o);
    if(m1_wb_ack_i)
      $display("(%0t) Master1 read cycle finished ok(Data: 0x%0x, Addr: 0x%0x)", $time, Data, Address);
    else
      $display("(%0t) Master1 read cycle finished with error(Data: 0x%0x, Addr: 0x%0x)", $time, Data, Address);

    #1;
    m1_wb_adr_o = 32'hx;
    m1_wb_dat_o = 32'hx;
    m1_wb_we_o  = 1'bx;
    m1_wb_cyc_o = 1'b0;
    m1_wb_stb_o = 1'b0;
    m1_wb_sel_o = 4'hx;
    #5 Wishbone1Busy = 0;
  end
endtask



task Wishbone2Write;
  input [31:0] Data;
  input [31:0] Address;
  integer ii;

  begin
    wait (~Wishbone2Busy);
    Wishbone2Busy = 1;
    @ (posedge wb_clk_o);
    #1;
    m2_wb_adr_o = Address;
    m2_wb_dat_o = Data;
    m2_wb_we_o  = 1'b1;
    m2_wb_cyc_o = 1'b1;
    m2_wb_stb_o = 1'b1;
    m2_wb_sel_o = 4'hf;

    wait(m2_wb_ack_i | m2_wb_err_i);   // waiting for acknowledge response

    // Writing information about the access to the screen
    @ (posedge wb_clk_o);
    if(m2_wb_ack_i)
      $display("(%0t) Master2 write cycle finished ok(Data: 0x%0x, Addr: 0x%0x)", $time, Data, Address);
    else
      $display("(%0t) Master2 write cycle finished with error(Data: 0x%0x, Addr: 0x%0x)", $time, Data, Address);

    #1;
    m2_wb_adr_o = 32'hx;
    m2_wb_dat_o = 32'hx;
    m2_wb_we_o  = 1'bx;
    m2_wb_cyc_o = 1'b0;
    m2_wb_stb_o = 1'b0;
    m2_wb_sel_o = 4'hx;
    #5 Wishbone2Busy = 0;
  end
endtask


task Wishbone2Read;
  input [31:0] Address;
  reg   [31:0] Data;
  integer ii;

  begin
    wait (~Wishbone2Busy);
    Wishbone2Busy = 1;
    @ (posedge wb_clk_o);
    #1;
    m2_wb_adr_o = Address;
    m2_wb_we_o  = 1'b0;
    m2_wb_cyc_o = 1'b1;
    m2_wb_stb_o = 1'b1;
    m2_wb_sel_o = 4'hf;

    wait(m2_wb_ack_i | m2_wb_err_i);   // waiting for acknowledge response
    Data = m2_wb_dat_i;

    // Writing information about the access to the screen
    @ (posedge wb_clk_o);
    if(m2_wb_ack_i)
      $display("(%0t) Master2 read cycle finished ok(Data: 0x%0x, Addr: 0x%0x)", $time, Data, Address);
    else
      $display("(%0t) Master2 read cycle finished with error(Data: 0x%0x, Addr: 0x%0x)", $time, Data, Address);

    #1;
    m2_wb_adr_o = 32'hx;
    m2_wb_dat_o = 32'hx;
    m2_wb_we_o  = 1'bx;
    m2_wb_cyc_o = 1'b0;
    m2_wb_stb_o = 1'b0;
    m2_wb_sel_o = 4'hx;
    #5 Wishbone2Busy = 0;
  end
endtask








integer seed_ack_s1, seed_ack_s2;
integer cnt_s1, cnt_s2;
initial
begin
  seed_ack_s1 = 1;
  cnt_s1      = 1;
  seed_ack_s2 = 2;
  cnt_s2      = 32'h88888888;
end

// Response from slave 1
always @ (posedge wb_clk_o or posedge wb_rst_o)
begin
  #1 seed_ack_s1 = $random(seed_ack_s1);
  
  wait(s1_wb_cyc_i & s1_wb_stb_i);
  
  s1_wb_dat_o = cnt_s1;
  repeat(seed_ack_s1[3:0])   @ (posedge wb_clk_o);
  
  #Tp s1_wb_ack_o = 1'b1;

  if(~s1_wb_we_i)
    cnt_s1=cnt_s1+1;

  @ (posedge wb_clk_o);
  #Tp s1_wb_ack_o = 1'b0;
end

// Response from slave 2
always @ (posedge wb_clk_o or posedge wb_rst_o)
begin
  #1 seed_ack_s2 = $random(seed_ack_s2);
  
  wait(s2_wb_cyc_i & s2_wb_stb_i);
  
  s2_wb_dat_o = cnt_s2;
  repeat(seed_ack_s2[3:0])   @ (posedge wb_clk_o);
  
  #Tp s2_wb_ack_o = 1'b1;

  if(~s1_wb_we_i)
    cnt_s2=cnt_s2+1;

  @ (posedge wb_clk_o);
  #Tp s2_wb_ack_o = 1'b0;
end

endmodule

