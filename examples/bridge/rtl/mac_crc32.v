//----------------------------------------------------------------------
//  8-bit parallel CRC generator
//----------------------------------------------------------------------

module mac_crc32
  (input         clk,
   input         clear,   // also functions as reset
   input [7:0]   data,
   input         valid,

   output [31:0] crc);

  reg [31:0] 	 icrc;
  reg [31:0] 	 nxt_icrc;
  integer 	 i;
  
  assign 	 crc = ~icrc;
  
  always @*
    begin
      nxt_icrc[7:0] = icrc[7:0] ^ data;
      nxt_icrc[31:8] = icrc[31:8];

      for (i=0; i<8; i=i+1)
	begin
	  if (nxt_icrc[0])
	    nxt_icrc = nxt_icrc[31:1] ^ 32'hEDB88320;
	  else
	    nxt_icrc = nxt_icrc[31:1];
	end
    end // always @ *
      
  always @(posedge clk)
    begin
      if (clear)
	icrc <= #1 {32{1'b1}};
      else if (valid)
	icrc <= nxt_icrc;
    end

endmodule