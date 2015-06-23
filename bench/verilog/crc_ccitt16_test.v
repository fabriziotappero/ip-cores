module crc_ccitt16_test;

//`define inccrc 1

`ifdef inccrc
	`define test_size 48
`else
	`define test_size 32
`endif

reg	clrcrc;
reg	clk;
//reg	txdin;
reg	wb_rst_i;
reg	crcndata;
reg	bdcrc;

reg	ser_i;

reg	[`test_size-1:0] par_i;
reg	shr_i;
reg	load_i;
wire	[`test_size-1:0] par_o;

crc_ccitt16 cc(
		.clk(					clk		), 
		.wb_rst_i(			wb_rst_i	), 
		.clrcrc(				clrcrc	), 
		.txdin(				txdin		), 
		.crcndata(			crcndata	),
		.mir_txbit_enable(	1'b1		), 
		.txdout(				txdout	), 
		.bdcrc(				bdcrc		)
	);

shift_reg #(`test_size) sr(clk, wb_rst_i, ser_i, par_i, shr_i, load_i, ser_o, par_o);

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
`ifdef inccrc
	par_i = `test_size'hc6ebA7F1F5C0;  // <== adjust size
`else
	par_i = `test_size'hBA7F1F5C0;
`endif
	@(negedge clk) load_i = 1;
	clrcrc = 1;
	$display("Step 1>>");
	@(negedge clk) load_i = 0;
	clrcrc = 0;
	crcndata = 0;
//	txdin = ser_o;
	shr_i = 1;
	for ( i=0;i<`test_size - 1 ;i=i+1 ) begin
		@(negedge clk) shr_i = 1;
		$display($time, "> %d %b  -  %b ", i, txdin, txdout); 
//		txdin = ser_o;
	end
	$display("Step 2 >>");
	@(negedge clk);
//	$display("CRC32: %h > %b", ~cc.txcrc, ~cc.txcrc);
	shr_i = 0;
	crcndata = 1;
	->ev1;
//	txdin = 0;
	for ( i=0;i<16 ; i=i+1)	
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