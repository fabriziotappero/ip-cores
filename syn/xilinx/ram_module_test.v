module ram_module_test;

	reg clock=0,sync_reset=1;
	reg wren=0;
	reg [31:0] datain=0;
	reg M_signed=0;
	reg [7:0] uread_port=0;
	reg write_busy=0;//Apr.2.2005

	reg [13:0] Paddr=0,Daddr=0;//4KB address
	reg  [13:0] DaddrD=0;

 	reg [1:0] access_mode=0;

	wire [31:0] IR;//Instrcuntion Register
	wire [31:0] MOUT;//data out
	integer i;
	always #10 clock=~clock;

	initial begin
		#105 sync_reset=0;
		for (i=0;i< 100;i=i+1) begin
			Paddr=Paddr+1;
			@(negedge clock);

		end

	end	


ram_module_altera dut(
	 .clock(clock),
	 .sync_reset(sync_reset),
	 .IR(IR),
	 .MOUT(MOUT),
	 .Paddr(Paddr),
	 .Daddr(Daddr),
	 .wren(wren),
	 .datain(datain),
	 .access_mode(access_mode),
	 .M_signed(M_signed),
	 .uread_port(uread_port),
	 .write_busy(write_busy));





endmodule