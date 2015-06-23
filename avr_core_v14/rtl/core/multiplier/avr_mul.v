//**********************************************************************************************
// Multiplier for the AVR Core
// Version 0.3
// Modified 10.01.2007
// Designed by Ruslan Lepetenok
//**********************************************************************************************

`timescale 1 ns / 1 ns

module avr_mul(ireset, cp2, cp2en, fmul, muls, mulsu, rd_in, rr_in, mr_out, mc_out, mz_out);
   parameter     use_rst = 1;
   // AVR global clock/reset signals
   input         ireset;
   input         cp2;
   input         cp2en;
   //
   input         fmul;		// FMUL/FMULS/FMULSU
   input         muls;		// MULS/FMULS
   input         mulsu;		// MULSU/FMULSU
   input [7:0]   rd_in;
   input [7:0]   rr_in;
   output [15:0] mr_out;
   output        mc_out;		// C flag
   // Z flag
   output        mz_out;
   
   wire [15:0]   mr_out_tmp;
   
   wire [15:0]   p_sum_out;
   wire [15:0]   p_carry_out;
   wire [15:0]   p_carry_out_sh;
   
   reg [15:0]    adder_a_in;
   reg [15:0]    adder_b_in;
   wire [15:0]   adder_out;
   
   wire          gnd;
   
   reg           rr_zero_fl;
   reg           rd_zero_fl;
   
   assign gnd = 1'b0;
   
   
   mul8x8comb mul8x8comb_inst(.rd_in(rd_in), .rr_in(rr_in), .p_sum_out(p_sum_out), .p_carry_out(p_carry_out), .muls(muls), .mulsu(mulsu));
   
   assign p_carry_out_sh = {p_carry_out[15 - 1:0], 1'b0};
   
   generate
      if (use_rst == 0)
      begin : reset_is_not_used
         
         always @(posedge cp2)
         begin: partial_sum_carry_rg
            		// Clock 
            begin
               if (cp2en == 1'b1)		// Clock enable	 
               begin
                  adder_a_in <= p_sum_out;
                  adder_b_in <= p_carry_out_sh;
               end
            end
         end
      end
   endgenerate
   
   generate
      if (use_rst == 1)
      begin : reset_is_used
         
         always @(negedge ireset or posedge cp2)
         begin: partial_sum_carry_rg
            if (ireset == 1'b0)		// Reset
            begin
               adder_a_in <= {16{1'b0}};
               adder_b_in <= {16{1'b0}};
            end
            else 		// Clock
            begin
               if (cp2en == 1'b1)		// Clock enable	 	 
               begin
                  adder_a_in <= p_sum_out;
                  adder_b_in <= p_carry_out_sh;
               end
            end
         end
      end
   endgenerate
   
   
   Adder #(.AdderType(1)) Adder_Inst(.A(adder_a_in), .B(adder_b_in), .CI(gnd), .S(adder_out), .CO());
   
   assign mr_out_tmp = ((fmul == 1'b0)) ? adder_out : 		// MUL/MULS/MULSU
                       {adder_out[15 - 1:0], 1'b0};		// FMUL/FMULS/FMULSU (left shift) 
   
   // Flags
   assign mc_out = adder_out[15];
   // mz_out <= '1' when (mr_out_tmp=x"0000") else '0';
   assign mz_out = rr_zero_fl | rd_zero_fl;
   
   assign mr_out = mr_out_tmp;
   
   generate
      if (use_rst == 1)
      begin : impl_rst
         
         always @(posedge cp2 or negedge ireset)
         begin: zero_det_seq
            if (ireset == 1'b0)		// Reset 
            begin
               rr_zero_fl <= 1'b0;
               rd_zero_fl <= 1'b0;
            end
            else 		// Clock
            begin
               if (cp2en == 1'b1)		// Clock enable  
               begin
                  if (rr_in == 8'h00)
                     rr_zero_fl <= 1'b1;
                  else
                     rr_zero_fl <= 1'b0;
                  if (rd_in == 8'h00)
                     rd_zero_fl <= 1'b1;
                  else
                     rd_zero_fl <= 1'b0;
               end
            end
            end // zero_det_seq
	    
         end // impl_rst
      endgenerate
      
      generate
         if (use_rst == 0)
         begin : impl_no_rst
            
            always @(posedge cp2)
            begin: zero_det_seq
               		// Clock
               begin
                  if (cp2en == 1'b1)		// Clock enable  
                  begin
                     if (rr_in == 8'h00)
                        rr_zero_fl <= 1'b1;
                     else
                        rr_zero_fl <= 1'b0;
                     if (rd_in == 8'h00)
                        rd_zero_fl <= 1'b1;
                     else
                        rd_zero_fl <= 1'b0;
                  end
               end
               end // zero_det_seq
	       
            end // impl_no_rst
         endgenerate
         
endmodule
