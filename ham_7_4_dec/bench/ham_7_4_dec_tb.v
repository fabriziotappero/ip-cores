module stimulus(
clk, 
reset,
datain,
dvin,
code, 
dvout);


input dvout;
input code;

output clk, reset, dvin;
reg clk, reset, dvin;

output datain;
reg datain;

initial
begin
	reset = 0;
	#200
	reset = 1;
end

initial clk = 1;

always
begin
	#20
	clk = !clk;
end

initial
begin
	datain = 0;
	#300
	datain = 0;
	#40
	datain = 1;
	#40
	datain = 0;
	#40
	datain = 0;
	#40
	datain = 0;
	#40
	datain = 0;
	#40
	datain = 0;
	#40
	datain = 0;
	#40
	datain = 0;




end

initial
begin
	dvin = 1;
	#300
	dvin = 0;
	#280
	dvin = 1;
end

initial #10000 $finish;

ham_7_4_dec ham_7_4_dec_0(

.clk(clk),
.reset(reset),
.datain(datain),
.dvin(dvin),
.code(code),
.dvout(dvout));


endmodule

