module sync_single_ff (
// *************************** Ports ********************************
        DIN ,
       DOUT ,
        CLK ,
    RESET_N              
 );
   
// ************************ Parameters ******************************
  parameter DATA_W   = 32  ;

// ********************** Inputs/Outputs ****************************
  input wire  [DATA_W-1:0]  DIN ;
  output reg  [DATA_W-1:0] DOUT ;
  input                     CLK ;
  input                 RESET_N ;                

// **************************  Regs  ********************************
  always @(posedge CLK or negedge RESET_N)
    begin
       if (!RESET_N) {DOUT } <= 0;
       else {DOUT} <= { DIN};
    end

endmodule // sync_single_ff
                                 
//*****************************************************************************

