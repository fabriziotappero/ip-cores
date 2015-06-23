//                              -*- Mode: Verilog -*-
// Filename        : k68_load.v
// Description     : RISC @mode Calculator
// Author          : Shawn Tan
// Created On      : Sat Feb  8 09:58:04 2003
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 to Shawn Tan Ser Ngiap.                  ////
////                       shawn.tan@aeste.net                   ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

`include "k68_defines.v"

module k68_load (/*AUTOARG*/
   // Outputs
   dat_a_o, dat_b_o, dat_c_o, skip_o, m_add_o, m_dat_o, m_cs_o, 
   m_we_o, rs_add_o, rt_add_o, rd_add_o, rd_dat_o, r_we_o, 
   // Inputs
   rst_i, m_clk_i, dat_c_i, add_a_i, add_b_i, add_c_i, imm_i, siz_i, 
   clk_i, pc_i, c_siz_i, m_dat_i, rs_dat_i, rt_dat_i
   ) ;
   parameter dw = `k68_DATA_W;
   parameter aw = `k68_ADDR_W;
   parameter gw = `k68_GPR_W;
   parameter kw = 6;
   parameter zero= `ZERO;
   parameter xxxx= `XXXX;
   parameter esc = `ESC;
      
   // Common I/O
   input     rst_i, m_clk_i;
      
   // Decoder I/O
   output [dw-1:0] dat_a_o, dat_b_o, dat_c_o;
   input [dw-1:0]  dat_c_i;
   output [1:0]    skip_o;
   input [kw-1:0]  add_a_i, add_b_i, add_c_i;
   input [dw-1:0]  imm_i;
   input [1:0] 	   siz_i;
   input 	   clk_i;
   input [aw-1:0]  pc_i;
   reg [dw-1:0]    dat_a_o, dat_b_o, dat_c_o;
   reg [1:0]	   skip_o;
   input [1:0] 	   c_siz_i;
   
   // Memory I/O
   output [aw-1:0] m_add_o;
   output [dw-1:0] m_dat_o;
   input [dw-1:0]  m_dat_i;
   output 	   m_cs_o;
   output 	   m_we_o;

   reg [aw-1:0]    m_add_o;
   reg [dw-1:0]    m_dat_o;
   reg [1:0] 	   m_cnt;
   reg 		   m_we, m_cs_o, m_we_o;

   // Registry I/O
   output [gw-1:0] rs_add_o, rt_add_o, rd_add_o;
   output [dw-1:0] rd_dat_o;
   input [dw-1:0]  rs_dat_i, rt_dat_i;
   output 	   r_we_o;
   
   wire [aw-1:0]    ea;
   wire [dw-1:0]    dat;
   wire [1:0] 	    skip;
   reg 		    we;
   reg [kw-1:0]     add;
   reg [1:0] 	    skipa, skipb;
   reg [1:0] 	    siz;

     
   // 
   // Async RegBank & Decode Intf
   // dat_a_o, dat_b_o
   //
   always @(/*AUTOSENSE*/add_a_i or add_b_i or add_c_i or c_siz_i
	    or m_cnt or rst_i or siz_i) begin
      if (rst_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 add <= 0;
	 siz <= 0;
	 we <= 0;
	 // End of automatics
	 
      end else begin
	 case (m_cnt)
	   2'b01: begin
	      add <= add_a_i;
	      we <= 1'b0;
	      siz <= siz_i;
	   end
	   2'b10: begin
	      add <= add_b_i;
	      we <= 1'b0;
	      siz <= siz_i;
	   end
	   2'b00: begin
	      add <= add_c_i;
	      we <= 1'b1;
	      siz <= c_siz_i;
	   end
	   2'b11: begin
	      add <= esc;
	      we <= 1'b0;
	      siz <= 2'b00;
	   end
   	   
	 endcase // case(m_cnt)
	 
      end // else: !if(rst_i)
     
   end // always @ (...
   
   // 
   // SYNC MEMORY INTERFACE
   //
   always @(posedge m_clk_i) begin
      if (rst_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 dat_a_o <= 0;
	 dat_b_o <= 0;
	 dat_c_o <= 0;
	 m_add_o <= 0;
	 m_cnt <= 0;
	 m_cs_o <= 0;
	 m_dat_o <= 0;
	 m_we_o <= 0;
	 skip_o <= 0;
	 skipa <= 0;
	 skipb <= 0;
	 // End of automatics
	 
      end else begin // if (rst_i)

	 
	 // Beginning of autoreset for uninitialized flops
	 dat_a_o <= dat_a_o;
	 dat_b_o <= dat_b_o;
	 m_add_o <= m_add_o;
	 m_cs_o <= m_cs_o;
	 m_we_o <= m_we_o;
	 dat_c_o <= dat_c_o;
	 // End of automatics
	     
	 case(m_cnt)
	   2'b01: begin
	      skipa <= skip;
	      
	      case (add_a_i[5:3])
		3'h0,3'h1: dat_a_o <= dat;
	      	3'h7:
		  case (add_a_i[2:0])
		    3'h4,3'h5: dat_a_o <= dat;
		    default: begin
		       dat_a_o <= dat_a_o;
		       m_add_o <= ea;
		       m_we_o <= 1'b0;
		       m_cs_o <= 1'b1;
		       dat_c_o <= ea;
		    end
		    
		  endcase // case(add_a_i[2:0])
		default: begin
		   dat_c_o <= ea;
		   dat_a_o <= dat_a_o;
		   m_add_o <= ea;
		   m_we_o <= 1'b0;
		   m_cs_o <= 1'b1;
		end
		
	      endcase // case(add_a_i[5:3])
	   end // case: 2'b00

	   2'b10: begin
	      skipb <= skip;
	      
	      case (add_b_i[5:3])
		3'h0,3'h1: dat_b_o <= dat;
	      	3'h7:
		  case (add_b_i[2:0])
		    3'h4,3'h5: dat_b_o <= dat;
		    default: begin
		       dat_b_o <= dat_b_o;
		       m_add_o <= ea;
		       m_we_o <= 1'b0;
		       m_cs_o <= 1'b1;
		    end
		  endcase // case(add_b_i[2:0])
		default: begin
		   dat_b_o <= dat_b_o;
		   m_add_o <= ea;
		   m_we_o <= 1'b0;
		   m_cs_o <= 1'b1;
		end
	      endcase // case(add_b_i[5:3])

	      case (add_a_i[5:3])
		3'h0,3'h1: dat_a_o <= dat_a_o;
	      	3'h7:
		  case (add_a_i[2:0])
		    3'h4,3'h5: dat_a_o <= dat_a_o;
		    default: begin
		       dat_a_o <= m_dat_i;
		    end
		    
		  endcase // case(add_a_i[2:0])
		default: begin
		   dat_a_o <= m_dat_i;
		end
		
	      endcase // case(add_a_i[5:3])
	   end // case: 2'b01

	   2'b11: begin
	      if (skip_o == 2'b00)
		skip_o <= skipa + skipb;
	      else
		skip_o <= skip_o - 1;
	      	      
	      case (add_b_i[5:3])
		3'h0,3'h1: dat_b_o <= dat_b_o;
	      	3'h7:
		  case (add_b_i[2:0])
		    3'h4,3'h5: dat_b_o <= dat_b_o;
		    default: begin
		       dat_b_o <= m_dat_i;
		    end
		  endcase // case(add_a_i[2:0])
		default: begin
		   dat_b_o <= m_dat_i;
		end
	      endcase // case(add_a_i[5:3])
      
	   end // case: 2'b:00

	   2'b00: begin
	      m_add_o <= ea;
	      m_dat_o <= dat_c_i;
	      m_cs_o <= 1'b1;
	      	      
	      case (add_c_i[5:3])
		3'h0,3'h1:begin
		   m_we_o <= 1'b0;
		end
		3'h7: begin
		   case (add_c_i[2:0])
		     3'h4,3'h7,3'h5: begin
			m_we_o <= 1'b0;
		     end
		     default: m_we_o <= 1'b1;
		   endcase // case(add_c_i[2:0])
		end
		default: m_we_o <= 1'b1;
				
	      endcase // case(add_c_i[5:3])
   
	      
	   end
	   
	     
	 endcase // case(m_cnt)
	 
	 // Increment Memory States
	 m_cnt <= m_cnt + 1'b1;

      end // else: !if(rst_i)
   end // always @ (posedge m_clk_i)
       
	 
   // @Mode Calculator
   k68_calc calc0(
		  .rs_add_o(rs_add_o), .rt_add_o(rt_add_o), .rd_add_o(rd_add_o),
		  .rd_dat_o(rd_dat_o), .r_we_o(r_we_o),

		  .ea_o(ea),
		  .dat_o(dat),
		  .skip_o(skip),

		  .we_i(we),
		  .add_i(add),
		  .dst_i(add_c_i),
		  
		  .imm_i(imm_i),
		  .dat_i(dat_c_i),
		  .pc_i(pc_i),
		  
		  .rs_dat_i(rs_dat_i), .rt_dat_i(rt_dat_i), .siz_i(siz),
		  .rst_i(rst_i)
		  );
     
  
endmodule // k68_amode


//
// General Address Mode Calculator (To Save Space)
//

module k68_calc (/*AUTOARG*/
   // Outputs
   ea_o, rs_add_o, rt_add_o, rd_add_o, rd_dat_o, r_we_o, dat_o, 
   skip_o, 
   // Inputs
   rst_i, we_i, add_i, dst_i, imm_i, dat_i, rs_dat_i, rt_dat_i, 
   siz_i, pc_i
   ) ;

   parameter kw=6;
   parameter aw = `k68_ADDR_W;
   parameter gw = `k68_GPR_W;
   parameter dw = `k68_DATA_W;
   parameter xxxx = `XXXX;
            
   input     rst_i, we_i;
   input [kw-1:0] add_i,dst_i;
   output [aw-1:0] ea_o;
   input [dw-1:0]  imm_i, dat_i;
   output [gw-1:0] rs_add_o, rt_add_o, rd_add_o;
   input [dw-1:0]  rs_dat_i, rt_dat_i;
   output [dw-1:0] rd_dat_o;
   output 	   r_we_o;
   output [dw-1:0] dat_o;
   input [1:0] 	   siz_i;
   output [1:0]    skip_o;
   input [aw-1:0]  pc_i;
   
   reg [aw-1:0]    ea_o;
   reg [gw-1:0]    rs_add_o, rt_add_o, rd_add_o;
   reg [dw-1:0]    rd_dat_o;
   reg 		   r_we_o;
   reg [1:0] 	   skip_o;
   reg [dw-1:0]    dat_o;
   
   always @ ( /*AUTOSENSE*/add_i or dat_i or imm_i or pc_i or rs_dat_i
	     or rst_i or rt_dat_i or siz_i or we_i) begin
      if (rst_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 dat_o <= 0;
	 ea_o <= 0;
	 r_we_o <= 0;
	 rd_add_o <= 0;
	 rd_dat_o <= 0;
	 rs_add_o <= 0;
	 rt_add_o <= 0;
	 skip_o <= 0;
	 // End of automatics
      end else begin // if (rst_i)

	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 dat_o <= 0;
	 ea_o <= 0;
	 r_we_o <= 0;
	 rd_add_o <= 0;
	 rd_dat_o <= 0;
	 rs_add_o <= 0;
	 rt_add_o <= 0;
	 skip_o <= 0;
	 // End of automatics
	 
	 //ea_o <= ea_o;
	 //dat_o <= dat_o;
	 r_we_o <= 1'b0;

	      case (add_i[5:3])
		3'h0,3'h1: begin // %d#, %a#
		   rt_add_o <= add_i[3:0];
		   dat_o <= rt_dat_i;
		   
		   rd_add_o <= add_i[3:0];
		   rd_dat_o <= dat_i;
		   
		   r_we_o <= we_i;
		end
		3'h2: begin // %a#@
		   rt_add_o <= {1'b1, add_i[2:0]};
		   ea_o <= rt_dat_i;
		   dat_o <= dat_i;
		end
		3'h3: begin // %a#@+
		   rt_add_o <= {1'b1, add_i[2:0]};
		   ea_o <= rt_dat_i;
		   dat_o <= dat_i;
		   rd_add_o <= {1'b1, add_i[2:0]};
		   rd_dat_o <= rt_dat_i + 3'd4;
		   r_we_o <= ~we_i;
		end // case: 3'h3
		3'h4: begin // -%a#@
		   rt_add_o <= {1'b1, add_i[2:0]};
		   ea_o <= rt_dat_i - 3'd4;
		   rd_dat_o <= rt_dat_i - 3'd4;
		   dat_o <= dat_i;
		   rd_add_o <= {1'b1, add_i[2:0]};
		   r_we_o <= we_i;
		end // case: 3'h4
		3'h5: begin // %a#(+d16)
		   rt_add_o <= {1'b1, add_i[2:0]};
		   ea_o <= rt_dat_i + {imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31:16]};
		   dat_o <= dat_i;
		   skip_o <= 2'd1;
		end
		3'h6: begin // %a#(+d8*scale)
		   rt_add_o <= {1'b1, add_i[2:0]};
		   rs_add_o <= {imm_i[31:28]};
		   ea_o <= rt_dat_i + {imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[23:16]} + (rs_dat_i << imm_i[26:25]);
		   dat_o <= dat_i;
		   skip_o <= 2'd1;
		end
		default:
		  case (add_i[2:0])
		    3'h0: begin // (xxx:w)
		       ea_o <= {imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31:16]};
		       dat_o <= dat_i;
		       skip_o <= 2'd1;
		    end
		    3'h1: begin // (xxx:l)
		       ea_o <= imm_i;
		       dat_o <= dat_i;
		       skip_o <= 2'd2;
		    end
		    3'h2: begin // %pc(+d16)
		       ea_o <= pc_i + {imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31:16]};
		       dat_o <= dat_i;
		       skip_o <= 2'd1;
		    end
		    3'h3: begin // %pc(+d8*scale)
		       rs_add_o <= {imm_i[31:28]};
		       ea_o <= pc_i + {imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[31],imm_i[23:16]} + (rs_dat_i << imm_i[26:25]);
		       dat_o <= dat_i;
		       skip_o <= 2'd1;
		    end
		    3'h4: begin // ####
		       case (siz_i)
			 2'b10,2'b11: begin
			    dat_o <= imm_i;
			    skip_o <= 2'b10;
			 end
			 
			 default: begin
			    dat_o <= {16'd0,imm_i[31:16]};
			    skip_o <= 2'b01;
			 end
			 
		       endcase // case(siz_i)
		    end // case: 3'h4
		    3'h5: begin
		       dat_o <= pc_i;
		       ea_o <= xxxx;
		       skip_o <= 2'd0;
		    end
		    3'h7: begin
		       dat_o <= 32'd0;
		       ea_o <= xxxx;
		       skip_o <= 2'd0;
		    end
		    default: begin
		       ea_o <= xxxx;
		       dat_o <= xxxx;
		       skip_o <= xxxx;
		    end
		    
		  endcase // case(add_i[2:0])
	      endcase // case(add_i[5:3])
	 
      end // else: !if(rst_i)
   end // always @ (...
     
endmodule // k68_calc
