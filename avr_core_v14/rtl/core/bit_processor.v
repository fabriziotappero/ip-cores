//************************************************************************************************
// "Bit processor" for AVR core
// Version 1.41(Special version for the JTAG OCD)
// Designed by Ruslan Lepetenok
// Modified 07.11.2011
// Unused inputs(sreg_bit_num[2..0],idc_sbi,idc_cbi,idc_bld) was removed.
// std_library was added
// Converted to Verilog
// Modified 18.08.12
//************************************************************************************************

`timescale 1 ns / 1 ns

module bit_processor(
   		     //Clock and reset
   		     input  wire        cp2,
   		     input  wire        cp2en,
   		     input  wire        ireset,
   		     
   		     input  wire [2:0]  bit_num_r_io,	  // BIT NUMBER FOR CBI/SBI/BLD/BST/SBRS/SBRC/SBIC/SBIS INSTRUCTIONS
   		     input  wire [7:0]  dbusin,  	  // SBI/CBI/SBIS/SBIC  IN
   		     output wire [7:0]  bitpr_io_out,	  // SBI/CBI OUT	
   		     input  wire [7:0]  sreg_out,	  // BRBS/BRBC/BLD IN 
   		     input  wire [2:0]  branch,  	  // NUMBER (0..7) OF BRANCH CONDITION FOR BRBS/BRBC INSTRUCTION
   		     output wire [7:0]  bit_pr_sreg_out,  // BCLR/BSET/BST(T-FLAG ONLY) 	    
   		     output wire [7:0]  bld_op_out,	  // BLD OUT (T FLAG)
   		     input  wire [7:0]  reg_rd_out,	  // BST/SBRS/SBRC IN	 
   		     output wire        bit_test_op_out,  // output wire OF SBIC/SBIS/SBRS/SBRC/BRBC/BRBS
   		     // Instructions and states
   		     input  wire        sbi_st,
   		     input  wire        cbi_st,
   		     input  wire        idc_bst,
   		     input  wire        idc_bset,
   		     input  wire        idc_bclr,
   		     input  wire        idc_sbic,
   		     input  wire        idc_sbis,
   		     input  wire        idc_sbrs,
   		     input  wire        idc_sbrc,
   		     input  wire        idc_brbs,
   		     input  wire        idc_brbc,
   		     input  wire        idc_reti 	       
   		     );
 
 //####################################################################################################		     
    
   localparam LP_SYNC_RST = 0; // Reserved for the future use
    
   wire         sreg_t_flag;		//  For  bld instruction
   
   reg [7:0]    temp_in_data_current;
   wire[7:0]    temp_in_data_next;
   
   wire [7:0]   sreg_t_temp;
   wire [7:0]   bit_num_decode;
   wire [7:0]   bit_pr_sreg_out_int;
   
   // SBIS/SBIC/SBRS/SBRC signals
   wire [7:0]   bit_test_in;
   wire [7:0]   bit_test_mux_out;
   
   // BRBS/BRBC signals
   wire [7:0]   branch_decode;
   wire [7:0]   branch_mux;
   
function[7:0] fn_bit_num_dcd;
 input[2:0]    arg;
 reg[7:0]      res;    
 integer       i;
  begin
   res = {8{1'b0}};
   for(i=0;i<8;i=i+1) begin
    res[i] = (i[2:0] == arg) ? 1'b1 : 1'b0;
   end // for
  fn_bit_num_dcd = res; 
  end
endfunction // fn_bit_num_dcd   
   
 //####################################################################################################  
   
   assign sreg_t_flag = sreg_out[6];
   
   // SBI/CBI store register
   always @(posedge cp2 or negedge ireset)
   begin: main_seq
      if (!ireset)
       temp_in_data_current <= {8{1'b0}};
      else 
      begin
       temp_in_data_current <= temp_in_data_next;
      end
   end // main_seq
      
// ########################################################################################

assign sreg_t_temp[0]   = (bit_num_decode[0]) ? reg_rd_out[0] : 1'b0;
assign sreg_t_temp[7:1] = (bit_num_decode[7:1] & reg_rd_out[7:1]) | (~bit_num_decode[7:1] & sreg_t_temp[6:0]);
      
// ########################################################################################
  
// BCLR/BSET/BST/RETI logic
assign bit_pr_sreg_out_int[6:0] = ({7{idc_bset}} & (~reg_rd_out[6:0])) | ((~{7{idc_bclr}}) & reg_rd_out[6:0]);

// SREG register bit 7 - interrupt enable flag
assign bit_pr_sreg_out_int[7] = (idc_bset & (~reg_rd_out[7])) | ((~idc_bclr) & reg_rd_out[7]) | idc_reti;

assign bit_pr_sreg_out = (idc_bst) ? {bit_pr_sreg_out_int[7], sreg_t_temp[7], bit_pr_sreg_out_int[5:0]} : bit_pr_sreg_out_int;
   			 

// SBIC/SBIS/SBRS/SBRC logic
assign bit_test_in = (idc_sbis || idc_sbic) ? dbusin : reg_rd_out;

assign bit_test_mux_out[0] = (bit_num_decode[0]) ? bit_test_in[0] : 1'b0;
assign bit_test_mux_out[7:1] = (bit_num_decode[7:1] & bit_test_in[7:1]) | (~bit_num_decode[7:1] & bit_test_mux_out[6:0]);					     

assign bit_test_op_out = (bit_test_mux_out[7] & (idc_sbis | idc_sbrs)) | ((~bit_test_mux_out[7]) & (idc_sbic | idc_sbrc)) | (branch_mux[7] & idc_brbs) | ((~branch_mux[7]) & idc_brbc);

assign branch_mux[0] = (branch_decode[0]) ? sreg_out[0] : 1'b0;
assign branch_mux[7:1] = (branch_decode[7:1] & sreg_out[7:1]) | (~branch_decode[7:1] & branch_mux[6:0]);			 

// BLD logic (bld_inst)
assign bld_op_out = (fn_bit_num_dcd(bit_num_r_io) & {8{sreg_t_flag}}) | (~fn_bit_num_dcd(bit_num_r_io) & reg_rd_out);

// BRBS/BRBC LOGIC (branch_decode_logic)
assign branch_decode = fn_bit_num_dcd(branch); 

// BST part (load T bit of SREG from the general purpose register)
assign bit_num_decode = fn_bit_num_dcd(bit_num_r_io); 

 generate
  genvar       i;
   for (i = 0; i < 8; i = i + 1)
    begin : sbi_cbi_dcd_gen

      // (SBI/CBI logic)
      assign bitpr_io_out[i] = (sbi_st && bit_num_decode[i]) ? 1'b1 :  // SBI
                               (cbi_st && bit_num_decode[i]) ? 1'b0 :  // CBI
                               temp_in_data_current[i];		      // ???

    end // sbi_cbi_dcd_gen

   // Synchronous reset support
   if(LP_SYNC_RST) begin : sync_rst
    assign temp_in_data_next = (!ireset) ? {8{1'b0}} : ((cp2en) ? dbusin : temp_in_data_current);
   end // sync_rst
   else begin : async_rst
    assign temp_in_data_next = (cp2en) ? dbusin : temp_in_data_current;
   end // async_rst

 endgenerate


			   
endmodule // bit_processor

