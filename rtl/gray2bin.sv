module gray2bin (
// *************************** Ports ********************************
     gray ,
      bin  
 );
// ************************ Parameters ******************************
  parameter DATA_W   = 32  ;

// ********************** Inputs/Outputs ****************************
  input wire  [DATA_W-1:0] gray ;
  output wire [DATA_W-1:0] bin  ;

  genvar                   i ;
   
  generate
       for (i=0; i<DATA_W; i++) begin
          assign bin[i] = ^(gray >> i);
       end    
  endgenerate
   
endmodule // gray2bin
