module bin2gray (
// *************************** Ports ********************************
      bin,
     gray
 );
// ************************ Parameters ******************************
  parameter DATA_W   = 32  ;
   
// ********************** Inputs/Outputs ****************************
  input wire  [DATA_W-1:0] bin  ;
  output wire [DATA_W-1:0] gray ;

  assign gray = {1'b0, bin[DATA_W-1:1] } ^ bin;

endmodule // bin2gray
                       
