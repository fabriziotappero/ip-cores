//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores sfr top level module                             ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   special function registers for oc8051                      ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
// Revision 1.14  2003/05/07 12:39:20  simont
// fix bug in case of sequence of inc dptr instrucitons.
//
// Revision 1.13  2003/05/05 15:46:37  simont
// add aditional alu destination to solve critical path.
//
// Revision 1.12  2003/04/29 11:24:31  simont
// fix bug in case execution of two data dependent instructions.
//
// Revision 1.11  2003/04/25 17:15:51  simont
// change branch instruction execution (reduse needed clock periods).
//
// Revision 1.10  2003/04/10 12:43:19  simont
// defines for pherypherals added
//
// Revision 1.9  2003/04/09 16:24:03  simont
// change wr_sft to 2 bit wire.
//
// Revision 1.8  2003/04/09 15:49:42  simont
// Register oc8051_sfr dato output, add signal wait_data.
//
// Revision 1.7  2003/04/07 14:58:02  simont
// change sfr's interface.
//
// Revision 1.6  2003/04/07 13:29:16  simont
// change uart to meet timing.
//
// Revision 1.5  2003/04/04 10:35:07  simont
// signal prsc_ow added.
//
// Revision 1.4  2003/03/28 17:45:57  simont
// change module name.
//
// Revision 1.3  2003/01/21 13:51:30  simont
// add include oc8051_defines.v
//
// Revision 1.2  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.1  2002/11/05 17:22:27  simont
// initial import
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"


module oc8051_sfr (rst, clk,
       adr0, adr1, dat0, 
       dat1, dat2, bit_in,
       des_acc,
       we, wr_bit,
       bit_out,
       wr_sfr, acc, 
       ram_wr_sel, ram_rd_sel, 
       sp, sp_w, 
       bank_sel, 
       desAc, desOv,
       srcAc, cy,
       psw_set, rmw,
       comp_sel,
       comp_wait,

`ifdef OC8051_PORTS

  `ifdef OC8051_PORT0
       p0_out,
       p0_in,
  `endif

  `ifdef OC8051_PORT1
       p1_out,
       p1_in,
  `endif

  `ifdef OC8051_PORT2
       p2_out,
       p2_in,
  `endif

  `ifdef OC8051_PORT3
       p3_out,
       p3_in,
  `endif

`endif


  `ifdef OC8051_UART
       rxd, txd,
  `endif

       int_ack, intr,
       int0, int1,
       int_src,
       reti,

  `ifdef OC8051_TC01
       t0, t1,
  `endif

  `ifdef OC8051_TC2
       t2, t2ex,
  `endif

       dptr_hi, dptr_lo,
       wait_data);


input       rst,	// reset - pin
	    clk,	// clock - pin
            we,		// write enable
	    bit_in,
	    desAc,
	    desOv,
	    rmw;
input       int_ack,
            int0,
	    int1,
            reti,
	    wr_bit;
input [1:0] psw_set,
            wr_sfr,
	    comp_sel;
input [2:0] ram_rd_sel,
            ram_wr_sel;
input [7:0] adr0, 	//address 0 input
            adr1, 	//address 1 input
	    des_acc,
	    dat1,	//data 1 input (des1)
            dat2;	//data 2 input (des2)

output       bit_out,
             intr,
             srcAc,
	     cy,
	     wait_data,
	     comp_wait;
output [1:0] bank_sel;
output [7:0] dat0,	//data output
	     int_src,
	     dptr_hi,
	     dptr_lo,
	     acc;
output [7:0] sp,
             sp_w;

// ports
`ifdef OC8051_PORTS

`ifdef OC8051_PORT0
input  [7:0] p0_in;
output [7:0] p0_out;
wire   [7:0] p0_data;
`endif

`ifdef OC8051_PORT1
input  [7:0] p1_in;
output [7:0] p1_out;
wire   [7:0] p1_data;
`endif

`ifdef OC8051_PORT2
input  [7:0] p2_in;
output [7:0] p2_out;
wire   [7:0] p2_data;
`endif

`ifdef OC8051_PORT3
input  [7:0] p3_in;
output [7:0] p3_out;
wire   [7:0] p3_data;
`endif

`endif


// serial interface
`ifdef OC8051_UART
input        rxd;
output       txd;
`endif

// timer/counter 0,1
`ifdef OC8051_TC01
input	     t0, t1;
`endif

// timer/counter 2
`ifdef OC8051_TC2
input	     t2, t2ex;
`endif

reg        bit_out, 
           wait_data;
reg [7:0]  dat0,
           adr0_r;

reg        wr_bit_r;
reg [2:0]  ram_wr_sel_r;


wire       p,
           uart_int,
	   tf0,
	   tf1,
	   tr0,
	   tr1,
           rclk,
           tclk,
	   brate2,
	   tc2_int;


wire [7:0] b_reg, 
           psw,

`ifdef OC8051_TC2
  // t/c 2
	   t2con, 
	   tl2, 
	   th2, 
	   rcap2l, 
	   rcap2h,
`endif

`ifdef OC8051_TC01
  // t/c 0,1
	   tmod, 
	   tl0, 
	   th0, 
	   tl1,
	   th1,
`endif

  // serial interface
`ifdef OC8051_UART
           scon, 
	   pcon, 
	   sbuf,
`endif

  //interrupt control
	   ie, 
	   tcon, 
	   ip;


reg        pres_ow;
reg [3:0]  prescaler;


assign cy = psw[7];
assign srcAc = psw [6];



//
// accumulator
// ACC
oc8051_acc oc8051_acc1(.clk(clk), 
                       .rst(rst), 
		       .bit_in(bit_in), 
		       .data_in(des_acc),
		       .data2_in(dat2),
		       .wr(we),
		       .wr_bit(wr_bit_r),
		       .wr_sfr(wr_sfr),
		       .wr_addr(adr1),
		       .data_out(acc),
		       .p(p));


//
// b register
// B
oc8051_b_register oc8051_b_register (.clk(clk),
                                     .rst(rst),
				     .bit_in(bit_in),
				     .data_in(des_acc),
				     .wr(we), 
				     .wr_bit(wr_bit_r), 
				     .wr_addr(adr1),
				     .data_out(b_reg));

//
//stack pointer
// SP
oc8051_sp oc8051_sp1(.clk(clk), 
                     .rst(rst), 
		     .ram_rd_sel(ram_rd_sel), 
		     .ram_wr_sel(ram_wr_sel), 
		     .wr_addr(adr1), 
		     .wr(we), 
		     .wr_bit(wr_bit_r), 
		     .data_in(dat1), 
		     .sp_out(sp), 
		     .sp_w(sp_w));

//
//data pointer
// DPTR, DPH, DPL
oc8051_dptr oc8051_dptr1(.clk(clk), 
                         .rst(rst), 
			 .addr(adr1), 
			 .data_in(des_acc),
			 .data2_in(dat2), 
			 .wr(we), 
			 .wr_bit(wr_bit_r),
			 .data_hi(dptr_hi),
			 .data_lo(dptr_lo), 
			 .wr_sfr(wr_sfr));


//
//program status word
// PSW
oc8051_psw oc8051_psw1 (.clk(clk), 
                        .rst(rst), 
			.wr_addr(adr1), 
			.data_in(dat1),
			.wr(we), 
			.wr_bit(wr_bit_r), 
			.data_out(psw), 
			.p(p), 
			.cy_in(bit_in),
			.ac_in(desAc), 
			.ov_in(desOv), 
			.set(psw_set), 
			.bank_sel(bank_sel));

//
// ports
// P0, P1, P2, P3
`ifdef OC8051_PORTS
  oc8051_ports oc8051_ports1(.clk(clk),
                           .rst(rst),
			   .bit_in(bit_in),
			   .data_in(dat1),
			   .wr(we),
			   .wr_bit(wr_bit_r),
			   .wr_addr(adr1),

		`ifdef OC8051_PORT0
			   .p0_out(p0_out),
			   .p0_in(p0_in),
			   .p0_data(p0_data),
		`endif

		`ifdef OC8051_PORT1
			   .p1_out(p1_out),
			   .p1_in(p1_in),
			   .p1_data(p1_data),
		`endif

		`ifdef OC8051_PORT2
			   .p2_out(p2_out),
			   .p2_in(p2_in),
			   .p2_data(p2_data),
		`endif

		`ifdef OC8051_PORT3
			   .p3_out(p3_out),
			   .p3_in(p3_in),
			   .p3_data(p3_data),
		`endif

			   .rmw(rmw));
`endif

//
// serial interface
// SCON, SBUF
`ifdef OC8051_UART
  oc8051_uart oc8051_uatr1 (.clk(clk), 
                            .rst(rst), 
			    .bit_in(bit_in),
			    .data_in(dat1), 
			    .wr(we), 
			    .wr_bit(wr_bit_r), 
			    .wr_addr(adr1),
			    .rxd(rxd), 
			    .txd(txd), 
		// interrupt
			    .intr(uart_int),
		// baud rate sources
			    .brate2(brate2),
			    .t1_ow(tf1),
			    .pres_ow(pres_ow),
			    .rclk(rclk),
			    .tclk(tclk),
		//registers
			    .scon(scon),
			    .pcon(pcon),
			    .sbuf(sbuf));
`else
  assign uart_int = 1'b0;
`endif

//
// interrupt control
// IP, IE, TCON
oc8051_int oc8051_int1 (.clk(clk), 
                        .rst(rst), 
			.wr_addr(adr1), 
			.bit_in(bit_in),
			.ack(int_ack), 
			.data_in(dat1),
			.wr(we), 
			.wr_bit(wr_bit_r),
			.tf0(tf0), 
			.tf1(tf1), 
			.t2_int(tc2_int), 
			.tr0(tr0), 
			.tr1(tr1),
			.ie0(int0), 
			.ie1(int1),
			.uart_int(uart_int),
			.reti(reti),
			.intr(intr),
			.int_vec(int_src),
			.ie(ie),
			.tcon(tcon), 
			.ip(ip));


//
// timer/counter control
// TH0, TH1, TL0, TH1, TMOD
`ifdef OC8051_TC01
  oc8051_tc oc8051_tc1(.clk(clk), 
                       .rst(rst), 
		       .wr_addr(adr1),
		       .data_in(dat1), 
		       .wr(we), 
		       .wr_bit(wr_bit_r), 
		       .ie0(int0), 
		       .ie1(int1), 
		       .tr0(tr0),
		       .tr1(tr1), 
		       .t0(t0), 
		       .t1(t1), 
		       .tf0(tf0), 
		       .tf1(tf1), 
		       .pres_ow(pres_ow),
		       .tmod(tmod), 
		       .tl0(tl0), 
		       .th0(th0), 
		       .tl1(tl1), 
		       .th1(th1));
`else
  assign tf0 = 1'b0;
  assign tf1 = 1'b0;
`endif

//
// timer/counter 2
// TH2, TL2, RCAPL2L, RCAPL2H, T2CON
`ifdef OC8051_TC2
  oc8051_tc2 oc8051_tc21(.clk(clk), 
                         .rst(rst), 
			 .wr_addr(adr1),
			 .data_in(dat1), 
			 .wr(we),
			 .wr_bit(wr_bit_r), 
			 .bit_in(bit_in), 
			 .t2(t2), 
			 .t2ex(t2ex),
			 .rclk(rclk), 
			 .tclk(tclk), 
			 .brate2(brate2), 
			 .tc2_int(tc2_int), 
			 .pres_ow(pres_ow),
			 .t2con(t2con), 
			 .tl2(tl2), 
			 .th2(th2), 
			 .rcap2l(rcap2l), 
			 .rcap2h(rcap2h));
`else
  assign tc2_int = 1'b0;
  assign rclk    = 1'b0;
  assign tclk    = 1'b0;
  assign brate2  = 1'b0;
`endif



always @(posedge clk or posedge rst)
  if (rst) begin
    adr0_r <= #1 8'h00;
    ram_wr_sel_r <= #1 3'b000;
    wr_bit_r <= #1 1'b0;
//    wait_data <= #1 1'b0;
  end else begin
    adr0_r <= #1 adr0;
    ram_wr_sel_r <= #1 ram_wr_sel;
    wr_bit_r <= #1 wr_bit;
  end

assign comp_wait = !(
                    ((comp_sel==`OC8051_CSS_AZ) &
		       ((wr_sfr==`OC8051_WRS_ACC1) |
		        (wr_sfr==`OC8051_WRS_ACC2) |
			((adr1==`OC8051_SFR_ACC) & we & !wr_bit_r) |
			((adr1[7:3]==`OC8051_SFR_B_ACC) & we & wr_bit_r))) |
		    ((comp_sel==`OC8051_CSS_CY) &
		       ((|psw_set) |
			((adr1==`OC8051_SFR_PSW) & we & !wr_bit_r) |
			((adr1[7:3]==`OC8051_SFR_B_PSW) & we & wr_bit_r))) |
		    ((comp_sel==`OC8051_CSS_BIT) &
		       ((adr1[7:3]==adr0[7:3]) & (~&adr1[2:0]) &  we & !wr_bit_r) |
		       ((adr1==adr0) & adr1[7] & we & !wr_bit_r)));



//
//set output in case of address (byte)
always @(posedge clk or posedge rst)
begin
  if (rst) begin
    dat0 <= #1 8'h00;
    wait_data <= #1 1'b0;
  end else if ((wr_sfr==`OC8051_WRS_DPTR) & (adr0==`OC8051_SFR_DPTR_LO)) begin				//write and read same address
    dat0 <= #1 des_acc;
    wait_data <= #1 1'b0;
  end else if (
      (
        ((wr_sfr==`OC8051_WRS_ACC1) & (adr0==`OC8051_SFR_ACC)) | 	//write to acc
//        ((wr_sfr==`OC8051_WRS_DPTR) & (adr0==`OC8051_SFR_DPTR_LO)) |	//write to dpl
        (adr1[7] & (adr1==adr0) & we & !wr_bit_r) |			//write and read same address
        (adr1[7] & (adr1[7:3]==adr0[7:3]) & (~&adr0[2:0]) &  we & wr_bit_r) //write bit addressable to read address
      ) & !wait_data) begin
    wait_data <= #1 1'b1;

  end else if ((
      ((|psw_set) & (adr0==`OC8051_SFR_PSW)) |
      ((wr_sfr==`OC8051_WRS_ACC2) & (adr0==`OC8051_SFR_ACC)) | 	//write to acc
      ((wr_sfr==`OC8051_WRS_DPTR) & (adr0==`OC8051_SFR_DPTR_HI))	//write to dph
      ) & !wait_data) begin
    wait_data <= #1 1'b1;

  end else begin
    case (adr0) /* synopsys full_case parallel_case */
      `OC8051_SFR_ACC: 		dat0 <= #1 acc;
      `OC8051_SFR_PSW: 		dat0 <= #1 psw;

`ifdef OC8051_PORTS
  `ifdef OC8051_PORT0
      `OC8051_SFR_P0: 		dat0 <= #1 p0_data;
  `endif

  `ifdef OC8051_PORT1
      `OC8051_SFR_P1: 		dat0 <= #1 p1_data;
  `endif

  `ifdef OC8051_PORT2
      `OC8051_SFR_P2: 		dat0 <= #1 p2_data;
  `endif

  `ifdef OC8051_PORT3
      `OC8051_SFR_P3: 		dat0 <= #1 p3_data;
  `endif
`endif

      `OC8051_SFR_SP: 		dat0 <= #1 sp;
      `OC8051_SFR_B: 		dat0 <= #1 b_reg;
      `OC8051_SFR_DPTR_HI: 	dat0 <= #1 dptr_hi;
      `OC8051_SFR_DPTR_LO: 	dat0 <= #1 dptr_lo;

`ifdef OC8051_UART
      `OC8051_SFR_SCON: 	dat0 <= #1 scon;
      `OC8051_SFR_SBUF: 	dat0 <= #1 sbuf;
      `OC8051_SFR_PCON: 	dat0 <= #1 pcon;
`endif

`ifdef OC8051_TC01
      `OC8051_SFR_TH0: 		dat0 <= #1 th0;
      `OC8051_SFR_TH1: 		dat0 <= #1 th1;
      `OC8051_SFR_TL0: 		dat0 <= #1 tl0;
      `OC8051_SFR_TL1: 		dat0 <= #1 tl1;
      `OC8051_SFR_TMOD: 	dat0 <= #1 tmod;
`endif

      `OC8051_SFR_IP: 		dat0 <= #1 ip;
      `OC8051_SFR_IE: 		dat0 <= #1 ie;
      `OC8051_SFR_TCON: 	dat0 <= #1 tcon;

`ifdef OC8051_TC2
      `OC8051_SFR_RCAP2H: 	dat0 <= #1 rcap2h;
      `OC8051_SFR_RCAP2L: 	dat0 <= #1 rcap2l;
      `OC8051_SFR_TH2:    	dat0 <= #1 th2;
      `OC8051_SFR_TL2:    	dat0 <= #1 tl2;
      `OC8051_SFR_T2CON:  	dat0 <= #1 t2con;
`endif

//      default: 			dat0 <= #1 8'h00;
    endcase
    wait_data <= #1 1'b0;
  end
end


//
//set output in case of address (bit)

always @(posedge clk or posedge rst)
begin
  if (rst)
    bit_out <= #1 1'h0;
  else if (
          ((adr1[7:3]==adr0[7:3]) & (~&adr1[2:0]) &  we & !wr_bit_r) |
          ((wr_sfr==`OC8051_WRS_ACC1) & (adr0[7:3]==`OC8051_SFR_B_ACC)) 	//write to acc
	  )

    bit_out <= #1 dat1[adr0[2:0]];
  else if ((adr1==adr0) & we & wr_bit_r)
    bit_out <= #1 bit_in;
  else
    case (adr0[7:3]) /* synopsys full_case parallel_case */
      `OC8051_SFR_B_ACC:   bit_out <= #1 acc[adr0[2:0]];
      `OC8051_SFR_B_PSW:   bit_out <= #1 psw[adr0[2:0]];

`ifdef OC8051_PORTS
  `ifdef OC8051_PORT0
      `OC8051_SFR_B_P0:    bit_out <= #1 p0_data[adr0[2:0]];
  `endif

  `ifdef OC8051_PORT1
      `OC8051_SFR_B_P1:    bit_out <= #1 p1_data[adr0[2:0]];
  `endif

  `ifdef OC8051_PORT2
      `OC8051_SFR_B_P2:    bit_out <= #1 p2_data[adr0[2:0]];
  `endif

  `ifdef OC8051_PORT3
      `OC8051_SFR_B_P3:    bit_out <= #1 p3_data[adr0[2:0]];
  `endif
`endif

      `OC8051_SFR_B_B:     bit_out <= #1 b_reg[adr0[2:0]];
      `OC8051_SFR_B_IP:    bit_out <= #1 ip[adr0[2:0]];
      `OC8051_SFR_B_IE:    bit_out <= #1 ie[adr0[2:0]];
      `OC8051_SFR_B_TCON:  bit_out <= #1 tcon[adr0[2:0]];

`ifdef OC8051_UART
      `OC8051_SFR_B_SCON:  bit_out <= #1 scon[adr0[2:0]];
`endif

`ifdef OC8051_TC2
      `OC8051_SFR_B_T2CON: bit_out <= #1 t2con[adr0[2:0]];
`endif

//      default:             bit_out <= #1 1'b0;
    endcase
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    prescaler <= #1 4'h0;
    pres_ow <= #1 1'b0;
  end else if (prescaler==4'b1011) begin
    prescaler <= #1 4'h0;
    pres_ow <= #1 1'b1;
  end else begin
    prescaler <= #1 prescaler + 4'h1;
    pres_ow <= #1 1'b0;
  end
end

endmodule
