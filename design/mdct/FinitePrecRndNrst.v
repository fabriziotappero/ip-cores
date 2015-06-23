//-----------------------------------------------------------------------------
// Title         : Finite Precision Symmetric Reduction module

// Introduces 2 clock cycles of latency

`timescale  1 ns / 100 ps

module FinitePrecRndNrst
  
#(
  parameter   C_IN_SZ=37,
              C_OUT_SZ=16,
              C_FRAC_SZ=15      
)
(   input wire                         CLK,
    input wire                         RST,
    
    input wire  signed [C_IN_SZ-1:0]   datain,
    input wire                         dataval,
    output wire signed [C_OUT_SZ-1:0]  dataout,                        
    
    output reg                         clip_inc,
    output reg                         dval_out
 );
   
   wire                                 sign;
   wire signed [C_IN_SZ-1:0]            rc_val;
   reg  signed [C_IN_SZ-1:0]            data_round_f;
   wire signed [C_IN_SZ-C_FRAC_SZ-1:0]  data_round;
   reg  signed [C_OUT_SZ-1:0]           data_rs;
   reg                                  dataval_d1;     
   reg                                  sign_d1;
   
   assign sign = datain[C_IN_SZ-1];
   assign rc_val = { {(C_IN_SZ-C_FRAC_SZ){1'b0}}, 1'b1, {(C_FRAC_SZ-1){1'b0}} };

   always @(posedge CLK or posedge RST)
    if(RST)
      begin
        data_round_f <= 'b0;
        dataval_d1   <= 1'b0;
        sign_d1      <= 1'b0;
        dval_out     <= 1'b0;
      end
    else
      begin
        data_round_f <= datain + rc_val;
        
        dataval_d1   <= dataval;
        dval_out     <= dataval_d1;
        sign_d1      <= sign;
      end
 
   assign data_round = data_round_f[C_IN_SZ-1:C_FRAC_SZ];
      
   // saturation / clipping
   always @(posedge CLK or posedge RST)
    if(RST)
      begin
        data_rs  <= 'b0;
        clip_inc <= 1'b0; 
      end
    else
      begin
         clip_inc <= 1'b0;
         
         // clipping condition
         if( 
             (
               (C_IN_SZ-C_FRAC_SZ != C_OUT_SZ) &&
               (~(&data_round[C_IN_SZ-C_FRAC_SZ-1 : C_OUT_SZ-1])) ==  
               (|(data_round[C_IN_SZ-C_FRAC_SZ-1 : C_OUT_SZ-1]))
             )
           || // special case
             (
               (C_IN_SZ-C_FRAC_SZ == C_OUT_SZ) &&
               (data_round[C_IN_SZ-C_FRAC_SZ-1] != sign_d1) &&
               data_round != {C_OUT_SZ{1'b0}}
             )
           )
           begin
             // clipping counter
             if(dataval_d1)
               clip_inc <= 1'b1;
                   
             if(sign_d1)
               // do saturation
               data_rs  <= -(2**(C_OUT_SZ)/2)+1;
             else
               // do saturation
               data_rs  <= (2**(C_OUT_SZ)/2)-1;             
           end
         else
           data_rs <= data_round[C_OUT_SZ-1:0];
      end
      
   assign dataout = data_rs;
   
   //always @(posedge CLK or posedge RST)
   // if(RST)
   //   begin
   //     dataout <= 0;
   //   end
   // else
   //   begin
   //     dataout <= data_rs;
   //   end


endmodule

