//**********************************************************************************************
//  General purpose register file for the AVR Core
//  Version 2.1 (Special version for the JTAG OCD)
//  Modified 02.11.2011
//  Designed by Ruslan Lepetenok
//  std_library was added
//  Converted to Verilog (Verilog-2001)
//  ((reg_rd_adr + 1) == i[4:0]) was replaced with ((reg_rd_adr[4:0] + 5'd1) == i[4:0]) to 
//  pass Formality check 
//  Modified 02.07.12
//**********************************************************************************************

`timescale 1 ns / 1 ns

module reg_file(
                cp2, 
		cp2en, 
		ireset, 
		reg_rd_in, 
		reg_rd_out, 
		reg_rd_adr, 
		reg_rr_out, 
		reg_rr_adr, 
		reg_rd_wr, 
		post_inc, 
		pre_dec, 
		reg_h_wr, 
		reg_h_out, 
		reg_h_adr, 
		reg_z_out, 
		w_op, 
		reg_rd_hb_in, 
		reg_rr_hb_out, 
		spm_out
		);
   
   parameter     use_rst = 1; // Used to implement reset for GPRF (for simulation)
   
   //Clock and reset
   input         cp2;
   input         cp2en;
   input         ireset;
   
   input [7:0]   reg_rd_in;
   output [7:0]  reg_rd_out;
   input [4:0]   reg_rd_adr;
   output [7:0]  reg_rr_out;
   input [4:0]   reg_rr_adr;
   input         reg_rd_wr;
   
   input         post_inc;		// POST INCREMENT FOR LD/ST INSTRUCTIONS
   input         pre_dec;		// PRE DECREMENT FOR LD/ST INSTRUCTIONS
   input         reg_h_wr;
   output [15:0] reg_h_out;
   input [2:0]   reg_h_adr;		// x,y,z
   output [15:0] reg_z_out;		// OUTPUT OF R31:R30 FOR LPM/ELPM/IJMP INSTRUCTIONS
   // Extended instructions 
   input         w_op;
   input [7:0]   reg_rd_hb_in;
   output [7:0]  reg_rr_hb_out;
   output [15:0] spm_out;
   
   reg [7:0]     gprf_current[0:31];
   reg [7:0]     gprf_next[0:31];
   wire [15:0]   reg_h_in;
   wire [15:0]   sg_adr16_postinc;
   wire [15:0]   sg_adr16_predec;
   reg [15:0]    sg_tmp_h_data;
   
   // Added 02.07.12
   localparam LP_GPRF_VECT_LEN = 8*32;
   
   reg [LP_GPRF_VECT_LEN-1:0]     gprf_current_vect;
   reg [LP_GPRF_VECT_LEN-1:0]     gprf_next_vect;   
   
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
 
 
   always@*
   begin : vec_array_cnv
   integer i;
   integer j;
   reg[7:0] tmp_rg_v2a;
   reg[7:0] tmp_rg_a2v;
   
    for(i = 0;i < 32;i = i + 1) begin
     tmp_rg_a2v = gprf_next[i];
     for(j = 0;j < 8;j = j + 1) begin
      gprf_next_vect[i*8+j] = tmp_rg_a2v[j];
      tmp_rg_v2a[j] = gprf_current_vect[i*8+j];
     end
      gprf_current[i] = tmp_rg_v2a; 
    end
   end // vec_array_cnv
   
   generate

    if (!use_rst)
     begin : impl_no_rst
            
      always @(posedge cp2)
      begin: gprf_seq
            gprf_current_vect <= gprf_next_vect;  // Must be modified (array)
         end // gprf_seq
      end // impl_no_rst

      else // (use_rst == 1)
      begin : impl_rst
         
         always @(posedge cp2 or negedge ireset)
         begin: gprf_seq
            if (!ireset)
             gprf_current_vect <= {LP_GPRF_VECT_LEN{1'b0}};  // Must be modified (array)
            else 
             gprf_current_vect <= gprf_next_vect;  // Must be modified (array)
            end // gprf_seq
         end // impl_rst


    endgenerate
         
         assign sg_adr16_postinc = sg_tmp_h_data + 1;		// Address incrementer
         assign sg_adr16_predec  = sg_tmp_h_data - 1;		// Address decrementer 
         
         // Address bus
         assign reg_h_out = ((pre_dec)) ? sg_adr16_predec : 		// PREDECREMENT
                            sg_tmp_h_data;		// NO PREDECREMENT
         
         // X/Y/Z registers inputs 
         assign reg_h_in = ((post_inc)) ? sg_adr16_postinc : 		// POST INC 
                           sg_adr16_predec;		// PRE DEC
         
         
//         always @(reg_h_adr or gprf_current)
         always @(*)
         begin: hi_regs_mux_comb
            sg_tmp_h_data = {16{1'b0}};
            case (reg_h_adr)
               3'b001 :		// Selects X
                  sg_tmp_h_data = {gprf_current[27], gprf_current[26]};
               3'b010 :		// Selects Y
                  sg_tmp_h_data = {gprf_current[29], gprf_current[28]};
               3'b100 :		// Selects Z
                  sg_tmp_h_data = {gprf_current[31], gprf_current[30]};
               default :
                  sg_tmp_h_data = {16{1'b0}};
            endcase
            end // hi_regs_mux_comb
            
            
//            always @(gprf_current or cp2en or reg_rd_in or reg_rd_adr or reg_rd_wr or reg_h_wr or reg_h_adr or w_op or reg_rd_hb_in or reg_h_in)
            always @(*)
            begin: gprf_comb
               integer       i;
               for(i = 0; i < 32; i = i + 1) gprf_next[i] = gprf_current[i];		// Avoid latches
               
               if (cp2en)		// Clock enable   
               begin
                  
                  if (reg_rd_wr)		// Write to GPRs 0..31 
                  begin
                     for (i = 0; i < 32; i = i + 1)
                        if ( reg_rd_adr == i[4:0])
                           gprf_next[i] = reg_rd_in;
                     
                     if (w_op)		// Write(Word) to GPRs 0..31/ 	  
                        for (i = 0; i < 32; i = i + 1)
//                           if ((reg_rd_adr + 1) == i[4:0]) // This line has a bug !!!
                         if ((reg_rd_adr[4:0] + 5'd1) == i[4:0])   // Modified for formality
                              gprf_next[i] = reg_rd_hb_in;
                  end
                  
                  else if (reg_h_wr)		// X/Y/Z regs Postincrenent/Predecrement  	
                     case (reg_h_adr)
                        3'b001 :		// X R26(Low)/R27(High)
                           begin
                              gprf_next[26] = reg_h_in[7:0];
                              gprf_next[27] = reg_h_in[15:8];
                           end
                        3'b010 :		// X R28(Low)/R29(High)
                           begin
                              gprf_next[28] = reg_h_in[7:0];
                              gprf_next[29] = reg_h_in[15:8];
                           end
                        3'b100 :		// X R30(Low)/R31(High)
                           begin
                              gprf_next[30] = reg_h_in[7:0];
                              gprf_next[31] = reg_h_in[15:8];
                           end
                        default : ; // !!!TBD!!! What to do by default???
                     endcase
               end
               		
               end  // gprf_comb
               
               assign reg_rd_out = gprf_current[reg_rd_adr];
               assign reg_rr_out = gprf_current[reg_rr_adr];
               
               assign reg_z_out = {gprf_current[31], gprf_current[30]};
               
	       wire[4:0] reg_rr_hb_idx = (reg_rr_adr + 1); // Fixed
               assign reg_rr_hb_out = gprf_current[reg_rr_hb_idx];		// !!TBD!!
               
               assign spm_out = {gprf_current[1], gprf_current[0]};
               
endmodule // reg_file
