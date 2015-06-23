//************************************************************************************************
// Scan chains for AVR debug system
// Version 0.6 
// Designed by Ruslan Lepetenok 
// Modified 07.03.2007
//************************************************************************************************

`timescale 1 ns / 1 ns

module ext_chains(
   trst_n,
   tck,
   tdi,
   tap_sm_st,
   ir,
   tdo_ext,
   chain_ac_o,
   chain_d_o,
   chain_c_o,
   chain_ac_i,
   chain_d_i,
   chain_c_i,
   chain_ac_ud,
   chain_d_ud,
   chain_c_ud
);
   parameter                impl_chain_c = 0;
   parameter                chain_c_len = 6;
   parameter                ir_len = 4;
   input                    trst_n;
   input                    tck;
   input                    tdi;
   // OCD/Flash programmer i/f
   input                    tap_sm_st;
   input [ir_len-1:0]       ir;
   output                   tdo_ext;
   // Chain i/f
   output [18:0]            chain_ac_o;
   output [8:0]             chain_d_o;
   output [chain_c_len-1:0] chain_c_o;
   input [18:0]             chain_ac_i;
   input [8:0]              chain_d_i;
   input [chain_c_len-1:0]  chain_c_i;
   output                   chain_ac_ud;
   output                   chain_d_ud;
   output                   chain_c_ud;
   
   reg [18:0]               chain_ac_sh_current;
   reg [18:0]               chain_ac_sh_next;
   reg [18:0]               chain_ac_ud_current;
   reg [18:0]               chain_ac_ud_next;
   reg [8:0]                chain_d_sh_current;
   reg [8:0]                chain_d_sh_next;
   reg [8:0]                chain_d_ud_current;
   reg [8:0]                chain_d_ud_next;
   
   reg                      chain_ac_ud_st_current;
   reg                      chain_ac_ud_st_next;
   reg                      chain_d_ud_st_current;
   reg                      chain_d_ud_st_next;
   
   // Additional Scan Chain
   wire [chain_c_len-1:0]   chain_c_sh_current;
   wire [chain_c_len-1:0]   chain_c_sh_next;
   wire [chain_c_len-1:0]   chain_c_ud_current;
   wire [chain_c_len-1:0]   chain_c_ud_next;
   
   wire                     chain_c_ud_st_current;
   wire                     chain_c_ud_st_next;
   
//   res_vect := d_in&shift_rg(shift_rg'high downto shift_rg'low+1);
   
   
   always @(tdi or ir or chain_ac_i or chain_d_i or tap_sm_st or chain_ac_sh_current or chain_d_sh_current)
   begin: shift_prc_comb
      chain_ac_sh_next = chain_ac_sh_current;
      chain_d_sh_next = chain_d_sh_current;
      
      if (ir == C_UNUSED_D)
         case (tap_sm_st)
            CaptureDR :
               chain_ac_sh_next = chain_ac_i;
            ShiftDR :
               chain_ac_sh_next = {tdi,chain_ac_sh_current[18:0+1]}; // Conversion !!! Shift direction
            default :
               chain_ac_sh_next = chain_ac_sh_current;
         endcase
      
      if (ir == C_UNUSED_E)
         case (tap_sm_st)
            CaptureDR :
               chain_d_sh_next = chain_d_i;
            ShiftDR :
               chain_d_sh_next = {tdi,chain_d_sh_current[8:0+1]}; // Conversion !!! Shift direction
            default :
               chain_d_sh_next = chain_d_sh_current;
         endcase
      end //	shift_prc_comb
      
      
      always @(ir or tap_sm_st or chain_ac_sh_current or chain_d_sh_current or chain_ac_ud_current or chain_d_ud_current)
      begin: upd_prc_comb
         chain_ac_ud_next = chain_ac_ud_current;
         chain_d_ud_next = chain_d_ud_current;
         
         if (tap_sm_st == UpdateDR)
         begin
            if (ir == C_UNUSED_D)
               chain_ac_ud_next = chain_ac_sh_current;
            
            if (ir == C_UNUSED_E)
               chain_d_ud_next = chain_d_sh_current;
         end
         end //	upd_prc_comb
         
         
         always @(ir or tap_sm_st or chain_ac_ud_st_current or chain_d_ud_st_current)
         begin: ch_upd_prc_comb
            
            chain_ac_ud_st_next = chain_ac_ud_st_current;
            chain_d_ud_st_next = chain_d_ud_st_current;
            
            case (chain_ac_ud_st_current)
               1'b0 :
                  if (ir == C_UNUSED_D & tap_sm_st == UpdateDR)
                     chain_ac_ud_st_next = 1'b1;
               1'b1 :
                  chain_ac_ud_st_next = 1'b0;
               default :
                  chain_ac_ud_st_next = 1'b0;
            endcase
            
            case (chain_d_ud_st_current)
               1'b0 :
                  if (ir == C_UNUSED_E & tap_sm_st == UpdateDR)
                     chain_d_ud_st_next = 1'b1;
               1'b1 :
                  chain_d_ud_st_next = 1'b0;
               default :
                  chain_d_ud_st_next = 1'b0;
            endcase
            end //	ch_upd_prc_comb
            
            
            always @(negedge trst_n or posedge tck)
            begin: tck_re_seq
               if (!trst_n)		// Reset
               begin
                  chain_ac_sh_current <= {19{1'b0}};
                  chain_d_sh_current <= {9{1'b0}};
                  
                  chain_ac_ud_st_current <= 1'b0;
                  chain_d_ud_st_current <= 1'b0;
               end
               
               else 		// Clock (Rising Edge)	 
               begin
                  chain_ac_sh_current <= chain_ac_sh_next;
                  chain_d_sh_current <= chain_d_sh_next;
                  
                  chain_ac_ud_st_current <= chain_ac_ud_st_next;
                  chain_d_ud_st_current <= chain_d_ud_st_next;
               end
               end // tck_re_seq
               
               
               always @(negedge trst_n or negedge tck)
               begin: tck_fe_seq
                  if (!trst_n)		// Reset
                  begin
                     chain_ac_ud_current <= {19{1'b0}};
                     chain_d_ud_current <= {9{1'b0}};
                  end
                  else 		// Clock (Falling Edge)	 
                  begin
                     chain_ac_ud_current <= chain_ac_ud_next;
                     chain_d_ud_current <= chain_d_ud_next;
                  end
                  end // tck_fe_seq
                  
                  assign chain_ac_o = chain_ac_ud_current;
                  assign chain_d_o = chain_d_ud_current;
                  
                  assign chain_ac_ud = chain_ac_ud_st_current;
                  assign chain_d_ud = chain_d_ud_st_current;
                  
                  // Out Mux
                  assign tdo_ext = ((ir == C_UNUSED_D)) ? chain_ac_sh_current[0] : 
                                   ((ir == C_UNUSED_E)) ? chain_d_sh_current[0] : 
                                   chain_c_sh_current[0];		// !!!TBD!!! 
                  
                  generate
                     if (impl_chain_c != 0)
                     begin : AdditionalSCh
                     end
                  endgenerate
                  
                  generate
                     if (impl_chain_c == 0)
                     begin : NoAdditionalSCh
                        assign chain_c_sh_next = {chain_c_len{1'b0}};
                        assign chain_c_sh_current = {chain_c_len{1'b0}};
                        assign chain_c_ud_next = {chain_c_len{1'b0}};
                        assign chain_c_ud_current = {chain_c_len{1'b0}};
                        
                        assign chain_c_ud_st_current = 1'b0;
                        assign chain_c_ud_st_next = 1'b0;
                     end
                  endgenerate
                  
                  assign chain_c_o = chain_c_ud_current;
                  assign chain_c_ud = chain_c_ud_st_current;
                  
endmodule
