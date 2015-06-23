module async_mem (/*AUTOARG*/
  // Outputs
  rd_data, 
  // Inputs
  wr_clk, wr_data, wr_cs, addr, rd_cs
  );

  parameter asz = 15,
	    depth = 32768;
  
  input       wr_clk;
  input [7:0] wr_data;
  input       wr_cs;

  input [asz-1:0] addr;
  inout [7:0] 	  rd_data;
  input 	  rd_cs;

  reg [7:0] 	  mem [0:depth-1];

  always @(posedge wr_clk)
    begin
      if (wr_cs)
	mem[addr] <= #1 wr_data;
    end

  assign rd_data = (rd_cs) ? mem[addr] : {8{1'bz}};
	  
endmodule // async_mem
