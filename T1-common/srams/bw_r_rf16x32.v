// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_rf16x32.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
////////////////////////////////////////////////////////////////////////
/*
 //  Module Name:  bw_r_rf16x32
 //  Description:	
 //   1r1w array for icache and dcache valid bits.  
 //   Modified to conform to naming convention 
 //   Added 16 bit wr en 
 //   Made bit_wen and din flopped inputs 
 //   So all inputs are setup to flops in the stage before memory
 //   access.  The data output is available one cycle later (same
 //   stage as mem access) 
 // 
 //  IMPORTANT NOTE: This block has to work even in the case where
 //  there is contention between a read and write operation for the
 //  same address.  Based on ease of implementation, the behavior
 //  during contention is defined as follows.
 //    -- write always succeeds
 //    -- read data is (array_data & write_data)
 //       (i.e. old_data & new_data)
 //
 //   So read 0 always succeeds.  read 1 succeeds if the data being
 //   written is also a 1.  Otherwise it fails.
 //
 // new_data = 1, old_data = 0, does not give the expected or
 // predictable result in post layout, so the code has been modified
 // to be  
 // old new rd_data
 // --- --- -------
 // 0    0     0
 // 0    1     X
 // 1    0     0
 // 1    1     1
 //
 // **The write still succeeds in ALL cases**
 */

////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
//`include "sys.h" // system level definition file which contains the 
// time scale definition

//`include "iop.h"

////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

//FPGA_SYN enables all FPGA related modifications
`ifdef FPGA_SYN 
`define FPGA_SYN_IDCT
`endif



module bw_r_rf16x32 (/*AUTOARG*/
   // Outputs
   dout, so, 
   // Inputs
   rclk, se, si, reset_l, sehold, rst_tri_en, rd_adr1, rd_adr2, 
   rd_adr1_sel, rd_en, wr_adr, wr_en, bit_wen, din
   );

	
   input        rclk;
   input        se;
   input        si;
   input        reset_l;
   input        sehold;	      // scan enable hold
   input        rst_tri_en;
   
   // 11:5(I);10:4(D)
   input [6:0] 	rd_adr1 ;     // rd address-1
   input [6:0] 	rd_adr2 ;     // rd address-2

   input        rd_adr1_sel ;	// sel rd addr 1 
   input        rd_en ;		    // rd enable 

   // 11:7(I);10:6(D)
   input [6:2] 	wr_adr ;  // wr address 

   input        wr_en ;		// wr enable
   input [15:0] bit_wen ;	// write enable with bit select
   input        din ;		  // write data

   output [3:0]	dout ;    // valid bits for tag compare

   output       so;

   wire         clk;
   assign       clk = rclk;

   //----------------------------------------------------------------------
   // Declarations
   //----------------------------------------------------------------------
   // local signals
   wire [6:0]  	rd_index ;
  
   // 512 bit array  
`ifdef FPGA_SYN_IDCT
   reg [31:0]	idcv_ary_0000;
   reg [31:0]	idcv_ary_0001;
   reg [31:0]	idcv_ary_0010;
   reg [31:0]	idcv_ary_0011;
   reg [31:0]	idcv_ary_0100;
   reg [31:0]	idcv_ary_0101;
   reg [31:0]	idcv_ary_0110;
   reg [31:0]	idcv_ary_0111;
   reg [31:0]	idcv_ary_1000;
   reg [31:0]	idcv_ary_1001;
   reg [31:0]	idcv_ary_1010;
   reg [31:0]	idcv_ary_1011;
   reg [31:0]	idcv_ary_1100;
   reg [31:0]	idcv_ary_1101;
   reg [31:0]	idcv_ary_1110;
   reg [31:0]	idcv_ary_1111;
`else
   reg [511:0] 	idcv_ary;
`endif
   
   reg [3:0]   	vbit,
               	vbit_sa;

   reg [6:2]   	wr_index_d1;
   reg [6:0]   	rd_index_d1;

   reg         	rdreq_d1,
		            wrreq_d1;

   reg [15:0]   bit_wen_d1;
   reg          din_d1;
   reg [4:0] index;
   
   wire         rst_all;

   //----------------------------------------------------------------------
   // Code Begins Here
   //----------------------------------------------------------------------
   assign       rst_all = rst_tri_en | ~reset_l;
   
   // mux merged with flop on index
   assign rd_index = rd_adr1_sel ? rd_adr1:rd_adr2 ;

   // input flops
   always @ (posedge clk)
     begin
        if (~sehold)
          begin
	           rdreq_d1 <= rd_en ;
	           wrreq_d1 <= wr_en ;
	           rd_index_d1 <= rd_index;
	           wr_index_d1 <= wr_adr;
             bit_wen_d1 <= bit_wen;
             din_d1 <= din;
          end
     end
   

   //----------------------------------------------------------------------
   // Read Operation
   //----------------------------------------------------------------------
`ifdef FPGA_SYN_IDCT
   always @(/*AUTOSENSE*/
	    idcv_ary_0000 or idcv_ary_0001 or idcv_ary_0010 or idcv_ary_0011 or
	    idcv_ary_0100 or idcv_ary_1001 or idcv_ary_1010 or idcv_ary_0111 or
	    idcv_ary_1000 or idcv_ary_0101 or idcv_ary_0110 or idcv_ary_1011 or
	    idcv_ary_1100 or idcv_ary_1101 or idcv_ary_1110 or idcv_ary_1111 or rd_index_d1 or rdreq_d1) 
`else
   always @(/*AUTOSENSE*/idcv_ary or rd_index_d1 or rdreq_d1) 
`endif
     begin
	      if (rdreq_d1)  // should work even if there is read
		                   // write conflict.  Data can be latest
	                     // or previous but should not be x
	        begin
`ifdef FPGA_SYN_IDCT
 	    case(rd_index_d1[1:0])
              2'b00: begin
              vbit[0] = idcv_ary_0000[{rd_index_d1[6:2]}];
              vbit[1] = idcv_ary_0001[{rd_index_d1[6:2]}];
              vbit[2] = idcv_ary_0010[{rd_index_d1[6:2]}];
              vbit[3] = idcv_ary_0011[{rd_index_d1[6:2]}];
              end
              2'b01: begin
              vbit[0] = idcv_ary_0100[{rd_index_d1[6:2]}];
              vbit[1] = idcv_ary_0101[{rd_index_d1[6:2]}];
              vbit[2] = idcv_ary_0110[{rd_index_d1[6:2]}];
              vbit[3] = idcv_ary_0111[{rd_index_d1[6:2]}];
              end
              2'b10: begin
              vbit[0] = idcv_ary_1000[{rd_index_d1[6:2]}];
              vbit[1] = idcv_ary_1001[{rd_index_d1[6:2]}];
              vbit[2] = idcv_ary_1010[{rd_index_d1[6:2]}];
              vbit[3] = idcv_ary_1011[{rd_index_d1[6:2]}];
              end
              2'b11: begin
              vbit[0] = idcv_ary_1100[{rd_index_d1[6:2]}];
              vbit[1] = idcv_ary_1101[{rd_index_d1[6:2]}];
              vbit[2] = idcv_ary_1110[{rd_index_d1[6:2]}];
              vbit[3] = idcv_ary_1111[{rd_index_d1[6:2]}];
              end
            endcase
`else
	           vbit[0] = idcv_ary[{rd_index_d1, 2'b00}]; // way 0
	           vbit[1] = idcv_ary[{rd_index_d1, 2'b01}]; // way 1
	           vbit[2] = idcv_ary[{rd_index_d1, 2'b10}]; // way 2
	           vbit[3] = idcv_ary[{rd_index_d1, 2'b11}]; // way 3
`endif
	        end     // if (rdreq_d1)

        else      // i/dcache disabled or rd disabled
          begin
             vbit[3:0] = 4'bx;
          end // else: !if(rdreq_d1)
     end // always @ (...

   // r-w conflict case, returns old_data & new_data
   // 12/06 modified to be
   // 0  0  0
   // 0  1  X
   // 1  0  0
   // 1  1  1
`ifdef FPGA_SYN_IDCT
    initial
    begin
        for(index = 5'h0; index < 5'h1f; index = index+1)
        begin
            idcv_ary_0000[index] = 1'b0;
            idcv_ary_0001[index] = 1'b0;
            idcv_ary_0010[index] = 1'b0;
            idcv_ary_0011[index] = 1'b0;
            idcv_ary_0100[index] = 1'b0;
            idcv_ary_0101[index] = 1'b0;
            idcv_ary_0110[index] = 1'b0;
            idcv_ary_0111[index] = 1'b0;
            idcv_ary_1000[index] = 1'b0;
            idcv_ary_1001[index] = 1'b0;
            idcv_ary_1010[index] = 1'b0;
            idcv_ary_1011[index] = 1'b0;
            idcv_ary_1100[index] = 1'b0;
            idcv_ary_1101[index] = 1'b0;
            idcv_ary_1110[index] = 1'b0;
            idcv_ary_1111[index] = 1'b0;
        end
    end
`endif
   reg [3:0] wr_data;
   always @ (/*AUTOSENSE*/bit_wen_d1 or rd_index_d1 or rst_all
             or wr_index_d1 or wrreq_d1)
     begin
        if (rd_index_d1[6:2] == wr_index_d1[6:2])
          case (rd_index_d1[1:0])
            2'b00:  wr_data = bit_wen_d1[3:0] & {4{wrreq_d1 & ~rst_all}};
            2'b01:  wr_data = bit_wen_d1[7:4] & {4{wrreq_d1 & ~rst_all}};
            2'b10:  wr_data = bit_wen_d1[11:8] & {4{wrreq_d1 & ~rst_all}};
            default:  wr_data = bit_wen_d1[15:12] & {4{wrreq_d1 & ~rst_all}};
          endcase // case(rd_index_d1[1:0])
        else
          wr_data = 4'b0;
     end

`ifdef FPGA_SYN_IDCT
  assign dout[3:0] = (~reset_l | ~rdreq_d1) ? 4'b0000 : 
		     (~wr_data & vbit | wr_data & {4{din_d1}} & vbit);
`else
   
   // SA latch -- to make 0in happy
   always @ (/*AUTOSENSE*/clk or din_d1 or vbit or wr_data)
     begin
        if (clk)
          begin
             vbit_sa <= (~wr_data & vbit | 
                         wr_data & {4{din_d1}} & (vbit | 4'bxxxx));
          end
     end

   
// bug:2776 - remove holding the last read value
// reset_l  rdreq_d1  dout
//  0       -         0
//  1       0         0
//  1       1         vbit_sa

   assign dout[3:0] = (~reset_l | ~rdreq_d1) ? 4'b0000 : vbit_sa[3:0] ;

`endif
   

   //----------------------------------------------------------------------
   // Write Operation
   //----------------------------------------------------------------------
   // Invalidate/Write occurs on 16B boundary.
   // For this purpose, 4x4 write-enables are required.
   // Index thus corresponds to 11:7,6:5,w[1:0], where w=way (ICache)
   // Index thus corresponds to 10:6,5:4,w[1:0], where w=way (DCache)
   // Thru data-in, vld bit can be set or cleared.
   always @ (negedge clk)
     begin
	      if (wrreq_d1 & ~rst_all)  // should work even if rd-wr conflict
	        begin
             // line 0 (5:4=00)
`ifdef FPGA_SYN_IDCT
	           if (bit_wen_d1[0]) idcv_ary_0000[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[1]) idcv_ary_0001[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[2]) idcv_ary_0010[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[3]) idcv_ary_0011[{wr_index_d1[6:2]}] = din_d1;
`else
	           if (bit_wen_d1[0])
	             idcv_ary[{wr_index_d1[6:2],2'b00,2'b00}] = din_d1;
	           if (bit_wen_d1[1])
	             idcv_ary[{wr_index_d1[6:2],2'b00,2'b01}] = din_d1;
	           if (bit_wen_d1[2])
	             idcv_ary[{wr_index_d1[6:2],2'b00,2'b10}] = din_d1;
	           if (bit_wen_d1[3])
	             idcv_ary[{wr_index_d1[6:2],2'b00,2'b11}] = din_d1;
`endif

             // line 1 (5:4=01)
`ifdef FPGA_SYN_IDCT
	           if (bit_wen_d1[4]) idcv_ary_0100[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[5]) idcv_ary_0101[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[6]) idcv_ary_0110[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[7]) idcv_ary_0111[{wr_index_d1[6:2]}] = din_d1;
`else
	           if (bit_wen_d1[4])
	             idcv_ary[{wr_index_d1[6:2],2'b01,2'b00}] = din_d1;
	           if (bit_wen_d1[5])
	             idcv_ary[{wr_index_d1[6:2],2'b01,2'b01}] = din_d1;
	           if (bit_wen_d1[6])
	             idcv_ary[{wr_index_d1[6:2],2'b01,2'b10}] = din_d1;
	           if (bit_wen_d1[7])
	             idcv_ary[{wr_index_d1[6:2],2'b01,2'b11}] = din_d1;
`endif

             // line 2 (5:4=10)
`ifdef FPGA_SYN_IDCT
	           if (bit_wen_d1[8]) idcv_ary_1000[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[9]) idcv_ary_1001[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[10]) idcv_ary_1010[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[11]) idcv_ary_1011[{wr_index_d1[6:2]}] = din_d1;
`else
	           if (bit_wen_d1[8])
	             idcv_ary[{wr_index_d1[6:2],2'b10,2'b00}] = din_d1;
	           if (bit_wen_d1[9])
	             idcv_ary[{wr_index_d1[6:2],2'b10,2'b01}] = din_d1;
	           if (bit_wen_d1[10])
	             idcv_ary[{wr_index_d1[6:2],2'b10,2'b10}] = din_d1;
	           if (bit_wen_d1[11])
	             idcv_ary[{wr_index_d1[6:2],2'b10,2'b11}] = din_d1;
`endif

             // line 3 (5:4=11)
`ifdef FPGA_SYN_IDCT
	           if (bit_wen_d1[12]) idcv_ary_1100[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[13]) idcv_ary_1101[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[14]) idcv_ary_1110[{wr_index_d1[6:2]}] = din_d1;
	           if (bit_wen_d1[15]) idcv_ary_1111[{wr_index_d1[6:2]}] = din_d1;
`else
	           if (bit_wen_d1[12])
	             idcv_ary[{wr_index_d1[6:2],2'b11,2'b00}] = din_d1;
	           if (bit_wen_d1[13])
	             idcv_ary[{wr_index_d1[6:2],2'b11,2'b01}] = din_d1;
	           if (bit_wen_d1[14])
	             idcv_ary[{wr_index_d1[6:2],2'b11,2'b10}] = din_d1;
	           if (bit_wen_d1[15])
	             idcv_ary[{wr_index_d1[6:2],2'b11,2'b11}] = din_d1;
`endif

	        end
     end // always @ (...


// synopsys translate_off
//----------------------------------------------------------------
// Monitors, shadow logic and other stuff not directly related to
// memory functionality
//----------------------------------------------------------------
`ifdef INNO_MUXEX
`else
   // Address monitor
   always @ (/*AUTOSENSE*/rd_index_d1 or rdreq_d1 or wr_index_d1
             or wrreq_d1)
     begin
        if (rdreq_d1 && (rd_index_d1 == 7'bX))
          begin
             // 0in <fire -message "FATAL ERROR: bw_r_rf16x32 read address X"
`ifdef DEFINE_0IN
`else
          //$error("RFRDADDR", "Error: bw_r_rf16x32 read address is %b\n", rd_index_d1);
`endif
          end
        else if (wrreq_d1 && (wr_index_d1 == 5'bX))
          begin
             // 0in <fire -message "FATAL ERROR: bw_r_rf16x32 write address X"
`ifdef DEFINE_0IN 
`else              
          //$error("RFWRADDR", "Error: bw_r_rf16x32 write address is %b\n", wr_index_d1);
`endif
          end
     end // always @ (...


`endif // !`ifdef INNO_MUXEX
   
   
//reg [127:0] w0;
//reg [127:0] w1;
//reg [127:0] w2;
//reg [127:0] w3;
//integer  i;
//   
//    always @(idcv_ary) begin
//       for (i=0;i<128; i=i+1) begin
//          w0[i] = idcv_ary[4*i];
//          w1[i] = idcv_ary[4*i+1];
//          w2[i] = idcv_ary[4*i+2];
//          w3[i] = idcv_ary[4*i+3];
//       end
//   end
//
//   reg [511:0] icv_ary;
//
//   always @ (idcv_ary)
//     icv_ary = idcv_ary;

// synopsys translate_on 

endmodule // bw_r_rf16x32












