module sync_doble_ff (
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
  reg  [DATA_W-1:0]       dreg1 ;
     
  always @(posedge CLK or negedge RESET_N)
    begin
       if (!RESET_N) {DOUT, dreg1} <= 0;
       else {DOUT, dreg1} <= {dreg1, DIN};
    end

endmodule // sync_doble_ff
                                 
//*****************************************************************************

