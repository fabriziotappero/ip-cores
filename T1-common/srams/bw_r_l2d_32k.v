// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: bw_r_l2d_32k.v
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
//FPGA_SYN enables all FPGA related modifications
`ifdef FPGA_SYN 
`define FPGA_SYN_RED
`endif

module bw_r_l2d_32k (/*AUTOARG*/
   // Outputs
   decc_out, so, l2d_fuse_data_out, 
   // Inputs
   decc_in_l, decc_read_in, word_en_l, way_sel_l, set_l, 
   col_offset_l, wr_en_l, rclk, arst_l, mem_write_disable, 
   sehold, se, si, fuse_l2d_wren, fuse_l2d_rden, 
   fuse_l2d_rid, fuse_clk1, fuse_clk2, 
   fuse_l2d_data_in, fuse_read_data_in
   );

   input [155:0]	decc_in_l;
   input [155:0] 	decc_read_in;
   input [3:0] 		word_en_l;
   input [1:0] 		way_sel_l;
   input [9:0] 		set_l;
   input		col_offset_l;
   input		wr_en_l;
   input 		rclk;
   input 		arst_l;
   
   // Test signals
   input  		mem_write_disable;
   input 		sehold;
   input 		se;
   input 		si;
   

   // Efuse inputs
   input 		fuse_l2d_wren;
   input 		fuse_l2d_rden;
   input [2:0] 		fuse_l2d_rid;
   input 		fuse_clk1;
   input 		fuse_clk2;
   input 		fuse_l2d_data_in;
   input 		fuse_read_data_in;


   output [155:0] 	decc_out ;
   output 		so;

   // Efuse outputs
   output 		l2d_fuse_data_out;
      
   reg [155:0] 		tmp_decc_out;
   reg [155:0] 		decc_out_tmp;
   reg [155:0] 		reg_decc_in;   

`ifdef DEFINE_0IN
`else
   reg [155:0] 		way0_decc[1023:0] ;
   reg [155:0] 		way1_decc[1023:0] ;
`endif
    
   wire			acc_en_d1;
   reg [1:0] 		way_sel_d1;
   reg [9:0] 		set_d1;
   reg [3:0] 		word_en_d1;
   reg 			wr_en_d1;
   reg [155:0] 		decc_in_d1;
   reg [155:0] 		decc_out_d1;
   reg 			col_offset_d1;
   
   wire	[1:0] 		way_sel_sehold;
   wire	[9:0] 		set_sehold;
   wire	[3:0] 		word_en_sehold;
   wire 		wr_en_sehold;
   wire [155:0] 	decc_in_sehold;
   wire 		col_offset;
   
   wire [155:0] 	decc_out ;

// JC begin
// Because of this 2 cycle block,
// The following codes are just helping me for Innologic verification 
// stop_1_cyc: when col_offset = 1, the next cycle will be ignore
// keep_rd_out: The output data will be kept for another cycle
   reg			keep_rd_out;
   reg			stop_1_cyc;
   always @(posedge rclk) begin
      if (col_offset && (|way_sel_sehold)) begin
         stop_1_cyc <= 1'b1;
      end
      else stop_1_cyc <= 1'b0;
      if (acc_en_d1 & ~wr_en_d1) begin
	 keep_rd_out <= 1'b1;
      end
      else keep_rd_out <= 1'b0;
   end
// JC end  


   assign 		wr_en_sehold = (sehold) ? wr_en_d1 : ~wr_en_l;
   assign 		set_sehold = (sehold) ? set_d1 : ~set_l;
   assign 		way_sel_sehold = (sehold) ? way_sel_d1 : ~way_sel_l;
   assign 		word_en_sehold = (sehold) ? word_en_d1 : ~word_en_l;
// In Circuits, we use se to disable write, however, I modified testbench as following 
// to verify write disable:
//     force inno_tb_top.xtor.xcnt.se_l = ~mem_write_disable ;

   assign 		col_offset = (stop_1_cyc || mem_write_disable ) ? (1'b0) : ~col_offset_l ;
 
   assign acc_en_d1 = col_offset_d1 & (|way_sel_d1);   

   always @(posedge rclk) begin
      col_offset_d1 <= col_offset;
      way_sel_d1  <= way_sel_sehold;
      set_d1  <= set_sehold;
      word_en_d1 <= word_en_sehold;
      wr_en_d1  <= wr_en_sehold;
// JC 
// EVEN THOUGH We don't have any write data latch,
// Our write-data drivers act like latch which gating by 
// Worden signals.
      decc_in_d1 <= ~decc_in_l;
// JC 
//This is NOT output flops, but we can keep read outs for
// 2 cycles.      
      decc_out_d1 <= decc_out_tmp;
   end      
  

`ifdef DEFINE_0IN
   wire [155:0] decc_out0, decc_out1;

   wire [155:0] wm  = { {39{word_en_d1[3]}}, {39{word_en_d1[2]}}, {39{word_en_d1[1]}}, {39{word_en_d1[0]}} };
   wire         we0 = acc_en_d1 & wr_en_d1 & way_sel_d1[0];
   wire         we1 = acc_en_d1 & wr_en_d1 & way_sel_d1[1];

l2data_axis     data_array0 (.data_out  (decc_out0[155:0]),
                             .rclk      (rclk),
                             .adr       (set_d1[9:0]),
                             .data_in   (decc_in_d1[155:0]),
                             .we        (we0),
                             .wm        (wm[155:0]) );
l2data_axis     data_array1 (.data_out  (decc_out1[155:0]),
                             .rclk      (rclk),
                             .adr       (set_d1[9:0]),
                             .data_in   (decc_in_d1[155:0]),
                             .we        (we1),
                             .wm        (wm[155:0]) );

   always @(/*AUTOSENSE*/acc_en_d1 or decc_in_d1 or decc_out0
	    or decc_out1 or way_sel_d1 or word_en_d1 or wr_en_d1) begin
        if (acc_en_d1 & ~wr_en_d1) begin
           //////////////////////////
           // 16 or 64B byte read
           //////////////////////////
           decc_out_tmp = way_sel_d1[0] ? decc_out0[155:0] : decc_out1[155:0];
        end

        if (acc_en_d1 & wr_en_d1) begin
           //////////////////////////
           // Store word/dword OR 64B store
           //////////////////////////
           tmp_decc_out = way_sel_d1[0] ? decc_out0[155:0] : decc_out1[155:0];

           //////////////////////////////////////
           // Write data based on Word enables.
           //////////////////////////////////////

           reg_decc_in[155:117] = (decc_in_d1[155:117] & {39{word_en_d1[3]}} |
                                   tmp_decc_out[155:117] & {39{~word_en_d1[3]}});
           reg_decc_in[116:78] = (decc_in_d1[116:78] & {39{word_en_d1[2]}} |
                                  tmp_decc_out[116:78] & {39{~word_en_d1[2]}});
           reg_decc_in[77:39] = (decc_in_d1[77:39] & {39{word_en_d1[1]}} |
                                 tmp_decc_out[77:39] & {39{~word_en_d1[1]}});
           reg_decc_in[38:0] = (decc_in_d1[38:0] & {39{word_en_d1[0]}} |
				tmp_decc_out[38:0] & {39{~word_en_d1[0]}});
          
           //////////////////////////////////////////////////////////
           // the store data gets reflected onto the read output bus
           //////////////////////////////////////////////////////////
          
//           decc_out_tmp[155:0] = reg_decc_in[155:0];
// Store data is *not* reflected onto the read output bus in the physical implementation
	     decc_out_tmp[155:0] = 156'b0;
          
        end // of write operation

      if (~acc_en_d1) begin
        // no access
         decc_out_tmp[155:0] = 156'b0;
      end

   end // of always block

`else

   always @(/*AUTOSENSE*/acc_en_d1 or decc_in_d1 or set_d1
	    or way_sel_d1 or word_en_d1 or wr_en_d1) begin
      
`ifdef	INNO_MUXEX
`else
//----- PURELY FOR VERIFICATION -----------------------
      if(wr_en_d1==1'bx) begin
	`ifdef MODELSIM
         $display("L2_DATA_ERR"," wr en error %b ", wr_en_d1);
	`else
         $error("L2_DATA_ERR"," wr en error %b ", wr_en_d1);
	`endif	
      end
//----- PURELY FOR VERIFICATION -----------------------
`endif


//////////////////
// MEMORY ACCESS
//////////////////

      if (acc_en_d1) begin

`ifdef	INNO_MUXEX
`else
//----- PURELY FOR VERIFICATION -----------------------
	 if(set_d1==10'bx) begin
	`ifdef MODELSIM 
            $error("L2_DATA_ERR"," index error %h ", set_d1[9:0]);
	`else
            $display("L2_DATA_ERR"," index error %h ", set_d1[9:0]);
	`endif
	 end
//----- PURELY FOR VERIFICATION -----------------------
`endif


	if (~wr_en_d1) begin
	   //////////////////////////
	   // 16 or 64B byte read 
	   //////////////////////////
	   decc_out_tmp = way_sel_d1[0] ? way0_decc[set_d1] : way1_decc[set_d1];
//JC: For keeping data for 2 cycle
//	   keep_rd_out = 2'b01;	   
	end

	else begin
	   //////////////////////////
      	   // Store word/dword OR 64B store
	   //////////////////////////
	   tmp_decc_out = way_sel_d1[0] ? way0_decc[set_d1] : way1_decc[set_d1];
	   
//	   keep_rd_out = 2'b00;	   
	   //////////////////////////////////////
	   // Write data based on Word enables.
	   //////////////////////////////////////
	   
	   reg_decc_in[155:117] = (decc_in_d1[155:117] & {39{word_en_d1[3]}} |
				   tmp_decc_out[155:117] & {39{~word_en_d1[3]}});
	   reg_decc_in[116:78] = (decc_in_d1[116:78] & {39{word_en_d1[2]}} |
				  tmp_decc_out[116:78] & {39{~word_en_d1[2]}});
	   reg_decc_in[77:39] = (decc_in_d1[77:39] & {39{word_en_d1[1]}} |
				 tmp_decc_out[77:39] & {39{~word_en_d1[1]}});
	   reg_decc_in[38:0] = (decc_in_d1[38:0] & {39{word_en_d1[0]}} |
				tmp_decc_out[38:0] & {39{~word_en_d1[0]}});
	   
	   if (way_sel_d1[0]) way0_decc[set_d1] =  reg_decc_in;
	   if (way_sel_d1[1]) way1_decc[set_d1] =  reg_decc_in;
	   
	   //////////////////////////////////////////////////////////
	   // the store data gets reflected onto the read output bus
	   //////////////////////////////////////////////////////////

//           decc_out_tmp[155:0] = reg_decc_in[155:0];
// Store data is *not* reflected onto the read output bus in the physical implementation

	     decc_out_tmp[155:0] = 156'b0;
	   
	end // of write operation

      end
      
      else begin
	// no access
	 decc_out_tmp[155:0] = 156'b0;
      end
      
   end // of always block
`endif
   // Modeling wired-OR

// JC we don't have any flop in this level
//   assign decc_out[155:0] = decc_out_d1[155:0] | decc_read_in[155:0];   

   assign decc_out[155:0] = (acc_en_d1 & ~wr_en_d1) ? 156'bX : (keep_rd_out) ? 
			    (decc_out_d1[155:0] | decc_read_in[155:0]) : 
			    (decc_out_tmp[155:0] | decc_read_in[155:0]);
   
/////////////////////////////////////////////////////////////////////
// Redundancy Registers
/////////////////////////////////////////////////////////////////////

   reg [8:0] 	s_red_reg0;
   reg [8:0] 	s_red_reg1;
   reg [8:0] 	s_red_reg2;
   reg [8:0] 	s_red_reg3;
   reg [8:0] 	s_red_reg4;
   reg [8:0] 	s_red_reg5;
 		
   reg [8:0] 	m_red_reg0;
   reg [8:0] 	m_red_reg1;
   reg [8:0] 	m_red_reg2;
   reg [8:0] 	m_red_reg3;
   reg [8:0] 	m_red_reg4;
   reg [8:0] 	m_red_reg5;
 		   
   wire	     l2d_fuse_data_out;
   
assign l2d_fuse_data_out = s_red_reg5[8];
   
   always @(arst_l or fuse_clk1 or fuse_l2d_rid or fuse_l2d_wren or fuse_l2d_rden 
            or fuse_l2d_data_in or fuse_read_data_in 
	    or s_red_reg0 or s_red_reg1 or s_red_reg2 
	    or s_red_reg3 or s_red_reg4 or s_red_reg5) begin

      if (!arst_l) begin
         m_red_reg0[8:0] = 9'b0;
         m_red_reg1[8:0] = 9'b0;
         m_red_reg2[8:0] = 9'b0;
         m_red_reg3[8:0] = 9'b0;
         m_red_reg4[8:0] = 9'b0;
         m_red_reg5[8:0] = 9'b0;
      end

      if (arst_l && fuse_clk1) begin
      
      /////////////////////////////////
      // Write operation
      /////////////////////////////////
      
         if (fuse_l2d_wren) begin
	    case (fuse_l2d_rid) //selecting among the six registers
	      3'b101: m_red_reg0[8:0] = {s_red_reg0[7:0], fuse_l2d_data_in};// bottom odd row
	      3'b011: m_red_reg1[8:0] = {s_red_reg1[7:0], fuse_l2d_data_in};// bottom even row
	      3'b010: m_red_reg2[8:0] = {s_red_reg2[7:0], fuse_l2d_data_in};// bottom column
	      3'b100: m_red_reg3[8:0] = {s_red_reg3[7:0], fuse_l2d_data_in};// top odd row
	      3'b001: m_red_reg4[8:0] = {s_red_reg4[7:0], fuse_l2d_data_in};// top even row
	      3'b000: m_red_reg5[8:0] = {s_red_reg5[7:0], fuse_l2d_data_in};// top column
	      default: ;
	    endcase // case(fuse_l2d_rid)
         end // if (fuse_l2d_wren)
      
      /////////////////////////////////
      // Read operation
      /////////////////////////////////
      
//JC This is just temporary fix for read operation, rid = 3'b111 will turn on everything
         else if (fuse_l2d_rden) begin
		      m_red_reg0[8:0] = {s_red_reg0[7:0], fuse_read_data_in};
		      m_red_reg1[8:0] = {s_red_reg1[7:0], s_red_reg0[8]};
		      m_red_reg2[8:0] = {s_red_reg2[7:0], s_red_reg1[8]};
		      m_red_reg3[8:0] = {s_red_reg3[7:0], s_red_reg2[8]};
		      m_red_reg4[8:0] = {s_red_reg4[7:0], s_red_reg3[8]};
		      m_red_reg5[8:0] = {s_red_reg5[7:0], s_red_reg4[8]};
              end // if (fuse_l2d_rden)

      end // if (fuse_clk1)

   end // always @ (fuse_clk1 or...

//   always @(posedge efc_scdata_fuse_clk1) begin

   always @(arst_l or fuse_clk2 or fuse_l2d_rid or fuse_l2d_wren or fuse_l2d_rden 
	    or m_red_reg0 or m_red_reg1 or m_red_reg2 
	    or m_red_reg3 or m_red_reg4 or m_red_reg5) begin

`ifdef DEFINE_0IN
`else
  `ifdef FPGA_SYN_RED
  `else
      if (!arst_l) begin
         m_red_reg0[8:0] = 9'b0;
         m_red_reg1[8:0] = 9'b0;
         m_red_reg2[8:0] = 9'b0;
         m_red_reg3[8:0] = 9'b0;
         m_red_reg4[8:0] = 9'b0;
         m_red_reg5[8:0] = 9'b0;
      end
  `endif
`endif

      if (fuse_clk2) begin
      
         if (fuse_l2d_wren) begin
	    case (fuse_l2d_rid) //selecting among the six registers
	      3'b101: s_red_reg0[8:0] = m_red_reg0[8:0];// bottom odd row
	      3'b011: s_red_reg1[8:0] = m_red_reg1[8:0];// bottom even row
	      3'b010: s_red_reg2[8:0] = m_red_reg2[8:0];// bottom column
	      3'b100: s_red_reg3[8:0] = m_red_reg3[8:0];// top odd row
	      3'b001: s_red_reg4[8:0] = m_red_reg4[8:0];// top even row
	      3'b000: s_red_reg5[8:0] = m_red_reg5[8:0];// top column
	     default: ;
	    endcase // case(fuse_l2d_rid)
         end // if (fuse_l2d_wren)
         else if (fuse_l2d_rden) begin
	        s_red_reg0[8:0] = m_red_reg0[8:0];// bottom odd row
	        s_red_reg1[8:0] = m_red_reg1[8:0];// bottom even row
	        s_red_reg2[8:0] = m_red_reg2[8:0];// bottom column
	        s_red_reg3[8:0] = m_red_reg3[8:0];// top odd row
	        s_red_reg4[8:0] = m_red_reg4[8:0];// top even row
	      	s_red_reg5[8:0] = m_red_reg5[8:0];// top column
              end // if (fuse_l2d_rden)

      end // if (fuse_clk2)

   end // always @ (fuse_clk2 or...
   
endmodule // bw_r_l2d_32k

