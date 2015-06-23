module crc_test;

reg	clrcrc;
reg	clk;
//reg	txdin;
reg	wb_rst_i;
reg	crcndata;
reg	bdcrc;

reg	ser_i;
reg	[15+32:0] par_i;
reg	shr_i;
reg	load_i;
wire	[15:0] par_o;

crc32_rx cc(
	.clrcrc(clrcrc	),
	.clk(clk	),
	.txdin(txdin	),
	.wb_rst_i(wb_rst_i	),
	.crcndata(crcndata	),
	.txdout(txdout	),
	.bdcrc(bdcrc	),
	.fir_rx4_enable(1'b1	)
	);

shift_reg #(16+32) sr(clk, wb_rst_i, ser_i, par_i, shr_i, load_i, ser_o, par_o);

assign txdin = ser_o;

initial
begin
	clk = 0;
	clrcrc = 0;
	wb_rst_i = 0;
//	txdin = 0;
	crcndata = 1;
	bdcrc = 0;
	ser_i = 0;
	par_i = 0;
	load_i = 0;
	shr_i = 0;
end

integer i;
event ev1;
initial
begin
	@(negedge clk) wb_rst_i = 1;
	@(negedge clk) wb_rst_i = 0;
	par_i = 48'hFD03F766ABB1;
	@(negedge clk) load_i = 1;
	clrcrc = 1;
	$display("Step 1>>");
	@(negedge clk) load_i = 0;
	clrcrc = 0;
	crcndata = 0;
//	txdin = ser_o;
	shr_i = 1;
	for ( i=0;i<15+32 ;i=i+1 ) begin
		@(negedge clk) shr_i = 1;
//		$display($time, "> %d %b", i, txdin); 
//		txdin = ser_o;
	end
	$display("Step 2 >>");
	@(negedge clk);
//	$display("CRC32: %h > %b", ~cc.txcrc, ~cc.txcrc);
	shr_i = 0;
	crcndata = 1;
	->ev1;
//	txdin = 0;
	for ( i=0;i<32 ; i=i+1)	
		@(negedge clk) 
		begin
			$display("Bit %d: %b", i, txdout);	
		end
	$finish;
end

integer j;
reg	[3:0] t;
always @(ev1)
begin
	forever
	begin
		for (j=0; j<4; j=j+1)
		begin
			@(posedge clk);
			#1 t[j] = txdout;
		end
	$display($time, " > %h  >  %b", t, t);	
	end
end
/*
always @(posedge clk)
begin
		#2 $display($time, "> %b  < %b", txdout, txdin);	
end
*/
always
	#5 clk = ~clk;
	
endmodule