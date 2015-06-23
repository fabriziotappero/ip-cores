

// Testbench for Fast Hadamhard Transforms implementation
// Developed by Kaushal D. Buch
// March, 2007.

module fht_tb ();

reg clk,reset ;

reg[7:0] data_i ;

wire[7:0] data_o ;


fht U_fht(.clk(clk), .reset(reset), .data_i(data_i) , .data_o(data_o));


initial 
begin
  clk = 'b0 ;
  reset = 'b1 ;
  #5 reset = 'b0 ;
  #15 reset = 'b1 ;  
  data_i = 8'b0010_1010 ;
  repeat(1000)
  @(posedge clk);
  $finish ;
end


always
begin
  clk = #5 ~clk ;
end

initial 
begin
  $shm_open("fht_tb");
  $shm_probe("AC");
end




endmodule


