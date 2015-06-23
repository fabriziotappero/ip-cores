module ecpu_monitor ( INT_EXT       , 
                      A_ACC         ,
                      B_ACC         ,
		                  RESET_N       , 
		                  CLK
                    );
                    
  parameter DWIDTH  = 16;
  parameter OPWIDTH =  4;

  // rom parameters
  parameter Mk  =  1;
  parameter N   = 16;
  
  input                      INT_EXT       ;
  input    [(DWIDTH -1):0]   A_ACC         ;
  input    [(DWIDTH -1):0]   B_ACC         ;
  input                      RESET_N       ;
  input                      CLK           ;
  
  // monitor CPU accumulators
  always @(posedge CLK)
  begin
    $display("[%0t] ACCA=%0h  ACCB=%0h", $time, A_ACC, B_ACC);
  end

endmodule
