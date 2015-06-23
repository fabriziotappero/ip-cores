//Jan.7.2005 Register File on Xilinx 
// using two dual port ram
module ram32x32_xilinx (
	data,
	wraddress,
	rdaddress_a,
	rdaddress_b,
	wren,
	clock,
	qa,
	qb);

	input	[31:0]  data;
	input	[4:0]  wraddress;
	input	[4:0]  rdaddress_a;
	input	[4:0]  rdaddress_b;
	input	  wren;
	input	  clock;
	output	[31:0]  qa;
	output	[31:0]  qb;

	

 ram32x32  ram1(//write port /read porta
	.addra(wraddress),
	.addrb(rdaddress_a),
	.clka(clock),
	.clkb(clock),
	.dina(data),
	.dinb(32'h0000_0000),
	.douta(),
	.doutb(qa),
	.wea(wren),
	.web(1'b0));    // synthesis black_box

ram32x32  ram2(//write port /read portb
	.addra(wraddress),
	.addrb(rdaddress_b),
	.clka(clock),
	.clkb(clock),
	.dina(data),
	.dinb(32'h0000_0000),
	.douta(),
	.doutb(qb),
	.wea(wren),
	.web(1'b0));    // synthesis black_box



/*  There is no specific 3port RAM on Xilinx.
      Following description is unavailable because of too many Slices required. Jan.7.2005
.
	reg [31:0] regfile [0:31];
	reg [4:0] addr_a,addr_b,w_addr;
	reg [31:0] data_port;
	integer i;

	always @(posedge clock) begin
		addr_a<=rdaddress_a;
		addr_b<=rdaddress_b;
	
	
	end





	always @ (posedge clock) begin
		  if (sync_reset) 	for (i=0;i<32;i=i+1) 	regfile[i]<=0;	
		  else if (wren)		regfile[wraddress] <=data;
	end


 

	assign qa=regfile[addr_a];
	assign qb=regfile[addr_b];


*/	

	


endmodule