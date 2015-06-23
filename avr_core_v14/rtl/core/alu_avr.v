//************************************************************************************************
//  ALU(internal module) for AVR core
//	Version 1.2
//  Designed by Ruslan Lepetenok 
//	Modified 02.08.2003 
// (CPC/SBC/SBCI Z-flag bug found)
//  H-flag with NEG instruction found
// Modified 26.05.2012 (Verilog version)
// Modified 18.08.12 Verilog Lint
//************************************************************************************************

`timescale 1 ns / 1 ns

module alu_avr(
               alu_data_r_in, 
               alu_data_d_in, 
	       alu_c_flag_in, 
	       alu_z_flag_in, 
	       idc_add, 
	       idc_adc, 
	       idc_adiw, 
	       idc_sub, 
	       idc_subi, 
	       idc_sbc, 
	       idc_sbci, 
	       idc_sbiw, 
	       adiw_st, 
	       sbiw_st, 
	       idc_and, 
	       idc_andi, 
	       idc_or, 
	       idc_ori, 
	       idc_eor, 
	       idc_com, 
	       idc_neg, 
	       idc_inc, 
	       idc_dec, 
	       idc_cp, 
	       idc_cpc, 
	       idc_cpi, 
	       idc_cpse, 
	       idc_lsr, 
	       idc_ror, 
	       idc_asr, 
	       idc_swap, 
	       alu_data_out, 
	       alu_c_flag_out, 
	       alu_z_flag_out, 
	       alu_n_flag_out, 
	       alu_v_flag_out, 
	       alu_s_flag_out, 
	       alu_h_flag_out
	       );
   
   input [7:0]  alu_data_r_in;
   input [7:0]  alu_data_d_in;
   
   input        alu_c_flag_in;
   input        alu_z_flag_in;
   
   // OPERATION SIGNALS INPUTS
   input        idc_add;
   input        idc_adc;
   input        idc_adiw;
   input        idc_sub;
   input        idc_subi;
   input        idc_sbc;
   input        idc_sbci;
   input        idc_sbiw;
   
   input        adiw_st;
   input        sbiw_st;
   
   input        idc_and;
   input        idc_andi;
   input        idc_or;
   input        idc_ori;
   input        idc_eor;
   input        idc_com;
   input        idc_neg;
   
   input        idc_inc;
   input        idc_dec;
   
   input        idc_cp;
   input        idc_cpc;
   input        idc_cpi;
   input        idc_cpse;
   
   input        idc_lsr;
   input        idc_ror;
   input        idc_asr;
   input        idc_swap;
   
   // DATA OUTPUT
   output [7:0] alu_data_out;
   
   // FLAGS OUTPUT
   output       alu_c_flag_out;
   output       alu_z_flag_out;
   output       alu_n_flag_out;
   output       alu_v_flag_out;
   output       alu_s_flag_out;
   output       alu_h_flag_out;
   
   // ####################################################
   // INTERNAL SIGNALS
   // ####################################################
   
   wire [7:0]   alu_data_out_int;
   
   // ALU FLAGS (INTERNAL)
   wire         alu_z_flag_out_int;
   wire         alu_c_flag_in_int;		// INTERNAL CARRY FLAG
   
   wire         alu_n_flag_out_int;
   wire         alu_v_flag_out_int;
   wire         alu_c_flag_out_int;
   
   // ADDER SIGNALS --
   wire         adder_nadd_sub;		// 0 -> ADD ,1 -> SUB
   wire         adder_v_flag_out;
   
   wire [8:0]   adder_carry;
   wire [8:0]   adder_d_in;
   wire [8:0]   adder_r_in;
   wire [8:0]   adder_out;
   
   // NEG OPERATOR SIGNALS 
   wire [8:0]   neg_op_carry;
   wire [8:0]   neg_op_out;
   
   // INC, DEC OPERATOR SIGNALS 
   wire [7:0]   incdec_op_carry;
   wire [7:0]   incdec_op_out;
   
   wire [7:0]   com_op_out;
   wire [7:0]   and_op_out;
   wire [7:0]   or_op_out;
   wire [7:0]   eor_op_out;
   
   // SHIFT SIGNALS
   wire [7:0]   right_shift_out;
   
   // SWAP SIGNALS
   wire [7:0]   swap_out;
   
   // ########################################################################
   // ###############              ALU
   // ########################################################################
   
   assign adder_nadd_sub = (idc_sub | idc_subi | idc_sbc | idc_sbci | idc_sbiw | sbiw_st | idc_cp | idc_cpc | idc_cpi | idc_cpse);		// '0' -> '+'; '1' -> '-' 
   
   // SREG C FLAG (ALU INPUT)
   assign alu_c_flag_in_int = alu_c_flag_in & (idc_adc | adiw_st | idc_sbc | idc_sbci | sbiw_st | idc_cpc | idc_ror);
   
   // SREG Z FLAG ()
   // alu_z_flag_out <= (alu_z_flag_out_int and not(adiw_st or sbiw_st)) or 
   //                   ((alu_z_flag_in and alu_z_flag_out_int) and (adiw_st or sbiw_st));
   assign alu_z_flag_out = (alu_z_flag_out_int & (~(adiw_st | sbiw_st | idc_cpc | idc_sbc | idc_sbci))) | ((alu_z_flag_in & alu_z_flag_out_int) & (adiw_st | sbiw_st)) | (alu_z_flag_in & alu_z_flag_out_int & (idc_cpc | idc_sbc | idc_sbci));		// Previous value (for CPC/SBC/SBCI instructions)
   
   // SREG N FLAG
   assign alu_n_flag_out = alu_n_flag_out_int;
   
   // SREG V FLAG
   assign alu_v_flag_out = alu_v_flag_out_int;
   
   assign alu_c_flag_out = alu_c_flag_out_int;
   
   assign alu_data_out = alu_data_out_int;
   
   // #########################################################################################
   
   assign adder_d_in = {1'b0, alu_data_d_in};
   assign adder_r_in = {1'b0, alu_data_r_in};
   
   //########################## ADDEER ###################################
   
   assign adder_out[0]     = adder_d_in[0] ^ adder_r_in[0] ^ alu_c_flag_in_int;
   assign adder_carry[0]   = ((adder_d_in[0] ^ adder_nadd_sub) & adder_r_in[0]) | (((adder_d_in[0] ^ adder_nadd_sub) | adder_r_in[0]) & alu_c_flag_in_int);
   assign adder_out[8:1]   = adder_d_in[8:1] ^ adder_r_in[8:1] ^ adder_carry[7:0];
   assign adder_carry[8:1] = ((adder_d_in[8:1] ^ {8{adder_nadd_sub}}) & adder_r_in[8:1]) | (((adder_d_in[8:1] ^ {8{adder_nadd_sub}}) | adder_r_in[8:1]) & adder_carry[7:0]);
      
      
      // FLAGS  FOR ADDER INSTRUCTIONS: 
      // CARRY FLAG (C) -> adder_out(8)
      // HALF CARRY FLAG (H) -> adder_carry(3)
      // TOW'S COMPLEMENT OVERFLOW  (V) -> 
      
      assign adder_v_flag_out = (((adder_d_in[7] & adder_r_in[7] & (~adder_out[7])) | ((~adder_d_in[7]) & (~adder_r_in[7]) & adder_out[7])) & (~adder_nadd_sub)) | (((adder_d_in[7] & (~adder_r_in[7]) & (~adder_out[7])) | ((~adder_d_in[7]) & adder_r_in[7] & adder_out[7])) & adder_nadd_sub);		// ADD
      // SUB
      //#####################################################################
      
      // LOGICAL OPERATIONS FOR ONE OPERAND
      
      //########################## NEG OPERATION ####################
      
      assign neg_op_out[0]     = alu_data_d_in[0];
      assign neg_op_carry[0]   = ~alu_data_d_in[0];
      assign neg_op_out[7:1]   = (~alu_data_d_in[7:1]) ^ neg_op_carry[6:0];
      assign neg_op_carry[7:1] = (~alu_data_d_in[7:1]) & neg_op_carry[6:0];

	 
         assign neg_op_out[8]   = ~neg_op_carry[7];
         assign neg_op_carry[8] = neg_op_carry[7];		// ??!!
         
         // CARRY FLAGS  FOR NEG INSTRUCTION: 
         // CARRY FLAG -> neg_op_out(8)
         // HALF CARRY FLAG -> neg_op_carry(3)
         // TOW's COMPLEMENT OVERFLOW FLAG -> alu_data_d_in(7) and neg_op_carry(6) 
         //############################################################################	
         
         //########################## INC, DEC OPERATIONS ####################
         
         assign incdec_op_out[0]     = ~alu_data_d_in[0];
         assign incdec_op_carry[0]   = alu_data_d_in[0] ^ idc_dec;
         assign incdec_op_out[7:1]   = alu_data_d_in[7:1] ^ incdec_op_carry[6:0];
         assign incdec_op_carry[7:1] = (alu_data_d_in[7:1] ^ {7{idc_dec}}) & incdec_op_carry[6:0];
	    
	    
            
            // TOW's COMPLEMENT OVERFLOW FLAG -> (alu_data_d_in(7) xor idc_dec) and incdec_op_carry(6) 
            //####################################################################
            
            //########################## COM OPERATION ###################################
            assign com_op_out = (~alu_data_d_in);
            // FLAGS 
            // TOW's COMPLEMENT OVERFLOW FLAG (V)  -> '0'
            // CARRY FLAG (C) -> '1' 
            //############################################################################
            
            // LOGICAL OPERATIONS FOR TWO OPERANDS	
            
            //########################## AND OPERATION ###################################
            assign and_op_out = alu_data_d_in & alu_data_r_in;
            // FLAGS 
            // TOW's COMPLEMENT OVERFLOW FLAG (V)  -> '0'
            //############################################################################
            
            //########################## OR OPERATION ###################################
            assign or_op_out = alu_data_d_in | alu_data_r_in;
            // FLAGS 
            // TOW's COMPLEMENT OVERFLOW FLAG (V)  -> '0'
            //############################################################################
            
            //########################## EOR OPERATION ###################################
            assign eor_op_out = alu_data_d_in ^ alu_data_r_in;
            // FLAGS 
            // TOW's COMPLEMENT OVERFLOW FLAG (V)  -> '0'
            //############################################################################
            
            // SHIFT OPERATIONS 
            
            // ########################## RIGHT(LSR, ROR, ASR) #######################
            
            assign right_shift_out[7] = (idc_ror & alu_c_flag_in_int) | (idc_asr & alu_data_d_in[7]);		// right_shift_out(7)
	    assign right_shift_out[6:0] = alu_data_d_in[7:1];
               
               // FLAGS 
               // CARRY FLAG (C)                      -> alu_data_d_in(0) 
               // NEGATIVE FLAG (N)                   -> right_shift_out(7)
               // TOW's COMPLEMENT OVERFLOW FLAG (V)  -> N xor C  (left_shift_out(7) xor alu_data_d_in(0))
               
               // #######################################################################
               
               // ################################## SWAP ###############################
                  assign swap_out = {alu_data_d_in[3:0] , alu_data_d_in[7:4]};		     
               // #######################################################################
               // ALU OUTPUT MUX
                       
assign alu_data_out_int[7:0] = (adder_out[7:0]       & {8{(idc_add | idc_adc | (idc_adiw | adiw_st) | idc_sub | idc_subi | idc_sbc | idc_sbci | (idc_sbiw | sbiw_st) | idc_cpse | idc_cp | idc_cpc | idc_cpi)}}) | 
                               (neg_op_out[7:0]      & {8{idc_neg}}) |                          // NEG		  
			       (incdec_op_out[7:0]   & {8{(idc_inc | idc_dec)}}) | 	        // INC/DEC
			       (com_op_out[7:0]      & {8{idc_com}}) |  		        // COM
			       (and_op_out[7:0]      & {8{(idc_and | idc_andi)}}) | 	        // AND/ANDI	
			       (or_op_out[7:0]       & {8{(idc_or | idc_ori)}}) | 	        // OR/ORI	
			       (eor_op_out[7:0]      & {8{idc_eor}}) |  		        // EOR
			       (right_shift_out[7:0] & {8{(idc_lsr | idc_ror | idc_asr)}}) |    // LSR/ROR/ASR
			       (swap_out[7:0]        & {8{idc_swap}});			        // SWAP
			
			
 //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ALU FLAGS OUTPUTS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                        
 // ADDER INSTRUCTIONS
 assign alu_h_flag_out = (adder_carry[3] & (idc_add | idc_adc | idc_sub | idc_subi | idc_sbc | idc_sbci | idc_cp | idc_cpc | idc_cpi)) | ((~neg_op_carry[3]) & idc_neg);	 // H-flag problem with NEG instruction fixing  				       -- NEG
 
 assign alu_s_flag_out = alu_n_flag_out_int ^ alu_v_flag_out_int;
 
 // INC
 // DEC
 assign alu_v_flag_out_int = (adder_v_flag_out & (idc_add | idc_adc | idc_sub | idc_subi | idc_sbc | idc_sbci | adiw_st | sbiw_st | idc_cp | idc_cpi | idc_cpc)) | ((alu_data_d_in[7] & neg_op_carry[6]) & idc_neg) | ((~alu_data_d_in[7]) & incdec_op_carry[6] & idc_inc) | (alu_data_d_in[7] & incdec_op_carry[6] & idc_dec) | ((alu_n_flag_out_int ^ alu_c_flag_out_int) & (idc_lsr | idc_ror | idc_asr));		 // NEG
 // LSR,ROR,ASR
 
 assign alu_n_flag_out_int = alu_data_out_int[7];
 
 assign alu_z_flag_out_int = ~(|alu_data_out_int);
 
 // NEG
 assign alu_c_flag_out_int = (adder_out[8] & (idc_add | idc_adc | (idc_adiw | adiw_st) | idc_sub | idc_subi | idc_sbc | idc_sbci | (idc_sbiw | sbiw_st) | idc_cp | idc_cpc | idc_cpi)) | ((~alu_z_flag_out_int) & idc_neg) | (alu_data_d_in[0] & (idc_lsr | idc_ror | idc_asr)) | idc_com;		 // ADDER
                        
endmodule // alu_avr
