//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores top level module                                 ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////  8051 definitions.                                           ////
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
// Revision 1.32  2003/06/20 13:36:37  simont
// ram modules added.
//
// Revision 1.31  2003/06/17 14:17:22  simont
// BIST signals added.
//
// Revision 1.30  2003/06/03 16:51:24  simont
// include "8051_defines" added.
//
// Revision 1.29  2003/05/07 12:36:03  simont
// chsnge comp.des to des1
//
// Revision 1.28  2003/05/06 09:41:35  simont
// remove define OC8051_AS2_PCL, chane signal src_sel2 to 2 bit wide.
//
// Revision 1.27  2003/05/05 15:46:37  simont
// add aditional alu destination to solve critical path.
//
// Revision 1.26  2003/04/29 11:24:31  simont
// fix bug in case execution of two data dependent instructions.
//
// Revision 1.25  2003/04/25 17:15:51  simont
// change branch instruction execution (reduse needed clock periods).
//
// Revision 1.24  2003/04/11 10:05:59  simont
// deifne OC8051_ROM added
//
// Revision 1.23  2003/04/10 12:43:19  simont
// defines for pherypherals added
//
// Revision 1.22  2003/04/09 16:24:04  simont
// change wr_sft to 2 bit wire.
//
// Revision 1.21  2003/04/09 15:49:42  simont
// Register oc8051_sfr dato output, add signal wait_data.
//
// Revision 1.20  2003/04/03 19:13:28  simont
// Include instruction cache.
//
// Revision 1.19  2003/04/02 15:08:30  simont
// raname signals.
//
// Revision 1.18  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.17  2002/11/05 17:23:54  simont
// add module oc8051_sfr, 256 bytes internal ram
//
// Revision 1.16  2002/10/28 14:55:00  simont
// fix bug in interface to external data ram
//
// Revision 1.15  2002/10/23 16:53:39  simont
// fix bugs in instruction interface
//
// Revision 1.14  2002/10/17 18:50:00  simont
// cahnge interface to instruction rom
//
// Revision 1.13  2002/09/30 17:33:59  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"

module oc8051_top (wb_rst_i, wb_clk_i,
//interface to instruction rom
		wbi_adr_o, 
		wbi_dat_i, 
		wbi_stb_o, 
		wbi_ack_i, 
		wbi_cyc_o, 
		wbi_err_i,

//interface to data ram
		wbd_dat_i, 
		wbd_dat_o,
		wbd_adr_o, 
		wbd_we_o, 
		wbd_ack_i,
		wbd_stb_o, 
		wbd_cyc_o, 
		wbd_err_i,

// interrupt interface
		int0_i, 
		int1_i,


// port interface
  `ifdef OC8051_PORTS
	`ifdef OC8051_PORT0
		p0_i,
		p0_o,
	`endif

	`ifdef OC8051_PORT1
		p1_i,
		p1_o,
	`endif

	`ifdef OC8051_PORT2
		p2_i,
		p2_o,
	`endif

	`ifdef OC8051_PORT3
		p3_i,
		p3_o,
	`endif
  `endif

// serial interface
	`ifdef OC8051_UART
		rxd_i, txd_o,
	`endif

// counter interface
	`ifdef OC8051_TC01
		t0_i, t1_i,
	`endif

	`ifdef OC8051_TC2
		t2_i, t2ex_i,
	`endif

// BIST
`ifdef OC8051_BIST
         scanb_rst,
         scanb_clk,
         scanb_si,
         scanb_so,
         scanb_en,
`endif
// external access (active low)
		ea_in
		);



input         wb_rst_i,		// reset input
              wb_clk_i,		// clock input
              int0_i,		// interrupt 0
              int1_i,		// interrupt 1
              ea_in,		// external access
              wbd_ack_i,	// data acknowalge
              wbi_ack_i,	// instruction acknowlage
              wbd_err_i,	// data error
              wbi_err_i;	// instruction error

input [7:0]   wbd_dat_i;	// ram data input
input [31:0]  wbi_dat_i;	// rom data input

output        wbd_we_o,		// data write enable
	      wbd_stb_o,	// data strobe
	      wbd_cyc_o,	// data cycle
	      wbi_stb_o,	// instruction strobe
	      wbi_cyc_o;	// instruction cycle

output [7:0]  wbd_dat_o;	// data output

output [15:0] wbd_adr_o,	// data address
              wbi_adr_o;	// instruction address

`ifdef OC8051_PORTS

`ifdef OC8051_PORT0
input  [7:0]  p0_i;		// port 0 input
output [7:0]  p0_o;		// port 0 output
`endif

`ifdef OC8051_PORT1
input  [7:0]  p1_i;		// port 1 input
output [7:0]  p1_o;		// port 1 output
`endif

`ifdef OC8051_PORT2
input  [7:0]  p2_i;		// port 2 input
output [7:0]  p2_o;		// port 2 output
`endif

`ifdef OC8051_PORT3
input  [7:0]  p3_i;		// port 3 input
output [7:0]  p3_o;		// port 3 output
`endif

`endif






`ifdef OC8051_UART
input         rxd_i;		// receive
output        txd_o;		// transnmit
`endif

`ifdef OC8051_TC01
input         t0_i,		// counter 0 input
              t1_i;		// counter 1 input
`endif

`ifdef OC8051_TC2
input         t2_i,		// counter 2 input
              t2ex_i;		//
`endif

`ifdef OC8051_BIST
input   scanb_rst;
input   scanb_clk;
input   scanb_si;
output  scanb_so;
input   scanb_en;
wire    scanb_soi;
`endif

wire [7:0]  dptr_hi,
	    dptr_lo, 
	    ri, 
	    data_out,
            op1,
            op2,
	    op3,
            acc,
            p0_out,
	    p1_out,
	    p2_out,
	    p3_out,
            sp,
            sp_w;

wire [31:0] idat_onchip;

wire [15:0] pc;

assign wbd_cyc_o = wbd_stb_o;

wire        src_sel3;
wire [1:0]  wr_sfr,
            src_sel2;
wire [2:0]  ram_rd_sel,	// ram read
            ram_wr_sel,	// ram write
            src_sel1;

wire [7:0]  ram_data,
            ram_out,	//data from ram
	    sfr_out,
	    wr_dat,
            wr_addr,	//ram write addres
            rd_addr;	//data ram read addres
wire        sfr_bit;

wire [1:0]  cy_sel,	//carry select; from decoder to cy_selct1
            bank_sel;
wire        rom_addr_sel,	//rom addres select; alu or pc
            rmw,
	    ea_int;

wire        reti,
            intr,
	    int_ack,
	    istb;
wire [7:0]  int_src;

wire        mem_wait;
wire [2:0]  mem_act;
wire [3:0]  alu_op;	//alu operation (from decoder)
wire [1:0]  psw_set;    //write to psw or not; from decoder to psw (through register)

wire [7:0]  src1,	//alu sources 1
            src2,	//alu sources 2
            src3,	//alu sources 3
	    des_acc,
	    des1,	//alu destination 1
	    des2;	//alu destinations 2
wire        desCy,	//carry out
            desAc,
	    desOv,	//overflow
	    alu_cy,
	    wr,		//write to data ram
	    wr_o;

wire        rd,		//read program rom
            pc_wr;
wire [2:0]  pc_wr_sel;	//program counter write select (from decoder to pc)

wire [7:0]  op1_n, //from memory_interface to decoder
            op2_n,
	    op3_n;

wire [1:0]  comp_sel;	//select source1 and source2 to compare
wire        eq,		//result (from comp1 to decoder)
            srcAc,
	    cy,
	    rd_ind,
	    wr_ind,
	    comp_wait;
wire [2:0]  op1_cur;

wire        bit_addr,	//bit addresable instruction
            bit_data,	//bit data from ram to ram_select
	    bit_out,	//bit data from ram_select to alu and cy_select
	    bit_addr_o,
	    wait_data;

//
// cpu to cache/wb_interface
wire        iack_i,
            istb_o,
	    icyc_o;
wire [31:0] idat_i;
wire [15:0] iadr_o;


//
// decoder
oc8051_decoder oc8051_decoder1(.clk(wb_clk_i), 
                               .rst(wb_rst_i), 
			       .op_in(op1_n), 
			       .op1_c(op1_cur),
			       .ram_rd_sel_o(ram_rd_sel), 
			       .ram_wr_sel_o(ram_wr_sel), 
			       .bit_addr(bit_addr),

			       .src_sel1(src_sel1),
			       .src_sel2(src_sel2),
			       .src_sel3(src_sel3),

			       .alu_op_o(alu_op),
			       .psw_set(psw_set),
			       .cy_sel(cy_sel),
			       .wr_o(wr),
			       .pc_wr(pc_wr),
			       .pc_sel(pc_wr_sel),
			       .comp_sel(comp_sel),
			       .eq(eq),
			       .wr_sfr_o(wr_sfr),
			       .rd(rd),
			       .rmw(rmw),
			       .istb(istb),
			       .mem_act(mem_act),
			       .mem_wait(mem_wait),
			       .wait_data(wait_data));


wire [7:0] sub_result;
//
//alu
oc8051_alu oc8051_alu1(.rst(wb_rst_i),
                       .clk(wb_clk_i),
		       .op_code(alu_op),
		       .src1(src1),
		       .src2(src2),
		       .src3(src3),
		       .srcCy(alu_cy),
		       .srcAc(srcAc),
		       .des_acc(des_acc),
		       .sub_result(sub_result),
		       .des1(des1),
		       .des2(des2),
		       .desCy(desCy),
		       .desAc(desAc),
		       .desOv(desOv),
		       .bit_in(bit_out));

//
//data ram
oc8051_ram_top oc8051_ram_top1(.clk(wb_clk_i),
                               .rst(wb_rst_i),
			       .rd_addr(rd_addr),
			       .rd_data(ram_data),
			       .wr_addr(wr_addr),
			       .bit_addr(bit_addr_o),
			       .wr_data(wr_dat),
			       .wr(wr_o && (!wr_addr[7] || wr_ind)),
			       .bit_data_in(desCy),
			       .bit_data_out(bit_data)
`ifdef OC8051_BIST
         ,
         .scanb_rst(scanb_rst),
         .scanb_clk(scanb_clk),
         .scanb_si(scanb_soi),
         .scanb_so(scanb_so),
         .scanb_en(scanb_en)
`endif
			       );

//

oc8051_alu_src_sel oc8051_alu_src_sel1(.clk(wb_clk_i),
                                       .rst(wb_rst_i),
				       .rd(rd),

				       .sel1(src_sel1),
				       .sel2(src_sel2),
				       .sel3(src_sel3),

				       .acc(acc),
				       .ram(ram_out),
				       .pc(pc),
				       .dptr({dptr_hi, dptr_lo}),
				       .op1(op1_n),
				       .op2(op2_n),
				       .op3(op3_n),

				       .src1(src1),
				       .src2(src2),
				       .src3(src3));


//
//
oc8051_comp oc8051_comp1(.sel(comp_sel),
                         .eq(eq),
			 .b_in(bit_out),
			 .cy(cy),
			 .acc(acc),
			 .des(sub_result)
			 );


//
//program rom
`ifdef OC8051_ROM
  oc8051_rom oc8051_rom1(.rst(wb_rst_i),
                       .clk(wb_clk_i),
		       .ea_int(ea_int),
		       .addr(iadr_o),
		       .data_o(idat_onchip)
		       );
`else
  assign ea_int = 1'b0;
  assign idat_onchip = 32'h0;
  
  `ifdef OC8051_SIMULATION

    initial
    begin
      $display("\t * ");
      $display("\t * Internal rom disabled!!!");
      $display("\t * ");
    end

  `endif

`endif

//
//
oc8051_cy_select oc8051_cy_select1(.cy_sel(cy_sel), 
                                   .cy_in(cy), 
				   .data_in(bit_out),
				   .data_out(alu_cy));
//
//
oc8051_indi_addr oc8051_indi_addr1 (.clk(wb_clk_i), 
                                    .rst(wb_rst_i), 
				    .wr_addr(wr_addr),
				    .data_in(wr_dat),
				    .wr(wr_o),
				    .wr_bit(bit_addr_o), 
				    .ri_out(ri),
				    .sel(op1_cur[0]),
				    .bank(bank_sel));



assign icyc_o = istb_o;
//
//
oc8051_memory_interface oc8051_memory_interface1(.clk(wb_clk_i), 
                       .rst(wb_rst_i),
// internal ram
                       .wr_i(wr), 
		       .wr_o(wr_o), 
		       .wr_bit_i(bit_addr), 
		       .wr_bit_o(bit_addr_o), 
		       .wr_dat(wr_dat),
		       .des_acc(des_acc),
		       .des1(des1),
		       .des2(des2),
		       .rd_addr(rd_addr),
		       .wr_addr(wr_addr),
		       .wr_ind(wr_ind),
		       .bit_in(bit_data),
		       .in_ram(ram_data),
		       .sfr(sfr_out),
		       .sfr_bit(sfr_bit),
		       .bit_out(bit_out),
		       .iram_out(ram_out),

// external instrauction rom
                       .iack_i(iack_i),
                       .iadr_o(iadr_o),
                       .idat_i(idat_i),
                       .istb_o(istb_o),

// internal instruction rom
		       .idat_onchip(idat_onchip),

// data memory
                       .dadr_o(wbd_adr_o),
		       .ddat_o(wbd_dat_o),
		       .dwe_o(wbd_we_o),
		       .dstb_o(wbd_stb_o),
		       .ddat_i(wbd_dat_i),
		       .dack_i(wbd_ack_i),

// from decoder
                       .rd_sel(ram_rd_sel),
		       .wr_sel(ram_wr_sel),
		       .rn({bank_sel, op1_cur}),
		       .rd_ind(rd_ind),
		       .rd(rd),
		       .mem_act(mem_act),
		       .mem_wait(mem_wait),

// external access
                       .ea(ea_in),
		       .ea_int(ea_int),

// instructions outputs to cpu
                       .op1_out(op1_n),
		       .op2_out(op2_n),
		       .op3_out(op3_n),

// interrupt interface
                       .intr(intr), 
		       .int_v(int_src), 
		       .int_ack(int_ack), 
		       .istb(istb),
		       .reti(reti),

//pc
                       .pc_wr_sel(pc_wr_sel), 
		       .pc_wr(pc_wr & comp_wait),
		       .pc(pc),

// sfr's
                       .sp_w(sp_w), 
		       .dptr({dptr_hi, dptr_lo}),
		       .ri(ri), 
		       .acc(acc),
		       .sp(sp)
		       );


//
//

oc8051_sfr oc8051_sfr1(.rst(wb_rst_i), 
                       .clk(wb_clk_i), 
		       .adr0(rd_addr[7:0]), 
		       .adr1(wr_addr[7:0]),
		       .dat0(sfr_out),
		       .dat1(wr_dat),
		       .dat2(des2),
		       .des_acc(des_acc),
		       .we(wr_o && !wr_ind),
		       .bit_in(desCy),
		       .bit_out(sfr_bit), 
		       .wr_bit(bit_addr_o),
		       .ram_rd_sel(ram_rd_sel),
		       .ram_wr_sel(ram_wr_sel),
		       .wr_sfr(wr_sfr),
		       .comp_sel(comp_sel),
		       .comp_wait(comp_wait),
// acc
		       .acc(acc),
// sp
		       .sp(sp), 
		       .sp_w(sp_w),
// psw
		       .bank_sel(bank_sel), 
		       .desAc(desAc), 
		       .desOv(desOv), 
		       .psw_set(psw_set),
		       .srcAc(srcAc), 
		       .cy(cy),
// ports
		       .rmw(rmw),

  `ifdef OC8051_PORTS
	`ifdef OC8051_PORT0
		       .p0_out(p0_o),
		       .p0_in(p0_i),
	`endif

	`ifdef OC8051_PORT1
		       .p1_out(p1_o),
		       .p1_in(p1_i),
	`endif

	`ifdef OC8051_PORT2
		       .p2_out(p2_o),
		       .p2_in(p2_i),
	`endif

	`ifdef OC8051_PORT3
		       .p3_out(p3_o),
		       .p3_in(p3_i),
	`endif
  `endif

// uart
	`ifdef OC8051_UART
		       .rxd(rxd_i), .txd(txd_o),
	`endif

// int
		       .int_ack(int_ack),
		       .intr(intr),
		       .int0(int0_i),
		       .int1(int1_i),
		       .reti(reti),
		       .int_src(int_src),

// t/c 0,1
	`ifdef OC8051_TC01
		       .t0(t0_i),
		       .t1(t1_i),
	`endif

// t/c 2
	`ifdef OC8051_TC2
		       .t2(t2_i),
		       .t2ex(t2ex_i),
	`endif

// dptr
		       .dptr_hi(dptr_hi),
		       .dptr_lo(dptr_lo),
		       .wait_data(wait_data)
		       );




`ifdef OC8051_CACHE


  oc8051_icache oc8051_icache1(.rst(wb_rst_i), .clk(wb_clk_i),
  // cpu
        .adr_i(iadr_o),
	.dat_o(idat_i),
	.stb_i(istb_o),
	.ack_o(iack_i),
        .cyc_i(icyc_o),
  // pins
        .dat_i(wbi_dat_i),
	.stb_o(wbi_stb_o),
	.adr_o(wbi_adr_o),
	.ack_i(wbi_ack_i),
        .cyc_o(wbi_cyc_o)
`ifdef OC8051_BIST
         ,
         .scanb_rst(scanb_rst),
         .scanb_clk(scanb_clk),
         .scanb_si(scanb_si),
         .scanb_so(scanb_soi),
         .scanb_en(scanb_en)
`endif
	);

  defparam oc8051_icache1.ADR_WIDTH = 6;  // cache address wihth
  defparam oc8051_icache1.LINE_WIDTH = 2; // line address width (2 => 4x32)
  defparam oc8051_icache1.BL_NUM = 15; // number of blocks (2^BL_WIDTH-1); BL_WIDTH = ADR_WIDTH - LINE_WIDTH
  defparam oc8051_icache1.CACHE_RAM = 64; // cache ram x 32 (2^ADR_WIDTH)

  

  `ifdef OC8051_SIMULATION

    initial
    begin
      #1
      $display("\t * ");
      $display("\t * External rom interface: cache");
      $display("\t * ");
    end

  `endif



//
//    no cache
//
`else

  `ifdef OC8051_BIST
       assign scanb_soi=scanb_si;
  `endif

  `ifdef OC8051_WB

    oc8051_wb_iinterface oc8051_wb_iinterface(.rst(wb_rst_i), .clk(wb_clk_i),
    // cpu
        .adr_i(iadr_o),
	.dat_o(idat_i),
	.stb_i(istb_o),
	.ack_o(iack_i),
        .cyc_i(icyc_o),
    // external rom
        .dat_i(wbi_dat_i),
	.stb_o(wbi_stb_o),
	.adr_o(wbi_adr_o),
	.ack_i(wbi_ack_i),
        .cyc_o(wbi_cyc_o));

  `ifdef OC8051_SIMULATION

    initial
    begin
      #1
      $display("\t * ");
      $display("\t * External rom interface: WB interface");
      $display("\t * ");
    end

  `endif

  `else

    assign wbi_adr_o = iadr_o    ;
    assign idat_i    = wbi_dat_i ;
    assign wbi_stb_o = 1'b1      ;
    assign iack_i    = wbi_ack_i ;
    assign wbi_cyc_o = 1'b1      ;

  `ifdef OC8051_SIMULATION

    initial
    begin
      #1
      $display("\t * ");
      $display("\t * External rom interface: Pipelined interface");
      $display("\t * ");
    end

  `endif


  `endif

`endif



endmodule
