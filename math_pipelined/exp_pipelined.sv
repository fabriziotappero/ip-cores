
module exp_pipelined(
	input clk,
	input signed [ARG_HIGH+ ARG_LOW-1:0] ix,
	output [RES_HIGH+ RES_LOW-1:0] oexp
	);

parameter ARG_HIGH= 4;
parameter ARG_LOW= 16;
parameter ARG_GUARD= 0;

parameter RES_HIGH= 16;
parameter RES_LOW= 16;
parameter RES_GUARD= 0;

//	Внутренние константы, не переопределять.
parameter A_BITS= ARG_HIGH+ ARG_LOW+ ARG_GUARD;
parameter A_UP= A_BITS-1;

parameter R_BITS= RES_HIGH+ RES_LOW+ RES_GUARD;
parameter STEPS= RES_HIGH+ RES_LOW;
parameter R_UP= R_BITS-1;

bit [A_UP:0] x [STEPS:0];
bit [R_UP:0] bexp [STEPS:0];

assign oexp= bexp[STEPS]>>RES_GUARD;

`define LN2x64 (64'hB17217F7D1CF79AB)
wire signed [63:0] C_LN_10001 [63:0];	//	Ln(1+1/2^x)

always @( posedge clk ) 
begin
	integer ind;

	x[0]<= ix<<<ARG_GUARD;
	bexp[0]<= 64'h1<<(RES_LOW+RES_GUARD);
	for (ind=0; ind<ARG_HIGH; ind++ )
	begin
		if ( x[ind]>(`LN2x64>>( 64-A_BITS+ind )) )
		begin
			x [ind+1]<= x[ind] - (`LN2x64>>( 64-A_BITS+ind ));
			bexp[ind+1]<= bexp[ind]<<(64'h1<<(ARG_HIGH-ind-1));
		end
		else
		begin
			x [ind+1]<= x [ind];
			bexp[ind+1]<= bexp[ind];
		end
	end
	for (ind=ARG_HIGH; ind<STEPS; ind++ )
	begin
		if ( x[ind]>(C_LN_10001[ind-ARG_HIGH]>>( 67-A_BITS )) )
		begin
			x [ind+1]<= x[ind] - (C_LN_10001[ind-ARG_HIGH]>>( 67-A_BITS ));
			bexp[ind+1]<= bexp[ind] + (bexp[ind]>>(ind-ARG_HIGH+1));
		end
		else
		begin
			x [ind+1]<= x [ind];
			bexp[ind+1]<= bexp[ind];
		end
	end
end

//	for ( i=0; i<64; i++){
//		double dval= log(1+1./pow(2.,1+i)) * pow(2.,64.); //((long long)1 << i);
//		unsigned long long val= i>30 ? 1ull<<(63-i) :dval;
//		cout << "assign C_LN_10001[" << dec << i << "]= 64'h" << hex << val << ";" << endl;
//	}

assign C_LN_10001[0]= 64'h67cc8fb2fe613000;//	Точность первых понижена!
assign C_LN_10001[1]= 64'h391fef8f35344400;
assign C_LN_10001[2]= 64'h1e27076e2af2e600;
assign C_LN_10001[3]= 64'hf85186008b15300;
assign C_LN_10001[4]= 64'h7e0a6c39e0cc000;
assign C_LN_10001[5]= 64'h3f815161f807c80;
assign C_LN_10001[6]= 64'h1fe02a6b1067890;
assign C_LN_10001[7]= 64'hff805515885e00;
assign C_LN_10001[8]= 64'h7fe00aa6ac4398;
assign C_LN_10001[9]= 64'h3ff80155156220;
assign C_LN_10001[10]= 64'h1ffe002aa6ab11;
assign C_LN_10001[11]= 64'hfff8005551558;
assign C_LN_10001[12]= 64'h7ffe000aaa6aa;
assign C_LN_10001[13]= 64'h3fff800155515;
assign C_LN_10001[14]= 64'h1fffe0002aaa6;
assign C_LN_10001[15]= 64'hffff80005555;
assign C_LN_10001[16]= 64'h7fffe0000aaa;
assign C_LN_10001[17]= 64'h3ffff8000155;
assign C_LN_10001[18]= 64'h1ffffe00002a;
assign C_LN_10001[19]= 64'hfffff800005;
assign C_LN_10001[20]= 64'h7ffffe00000;
assign C_LN_10001[21]= 64'h3fffff80000;
assign C_LN_10001[22]= 64'h1fffffe0000;
assign C_LN_10001[23]= 64'hffffff8000;
assign C_LN_10001[24]= 64'h7fffffe000;
assign C_LN_10001[25]= 64'h3ffffff800;
assign C_LN_10001[26]= 64'h1ffffffe00;
assign C_LN_10001[27]= 64'hfffffff80;
assign C_LN_10001[28]= 64'h7ffffffe0;
assign C_LN_10001[29]= 64'h3fffffff8;
assign C_LN_10001[30]= 64'h1fffffffe;
assign C_LN_10001[31]= 64'h100000000;
assign C_LN_10001[32]= 64'h80000000;
assign C_LN_10001[33]= 64'h40000000;
assign C_LN_10001[34]= 64'h20000000;
assign C_LN_10001[35]= 64'h10000000;
assign C_LN_10001[36]= 64'h8000000;
assign C_LN_10001[37]= 64'h4000000;
assign C_LN_10001[38]= 64'h2000000;
assign C_LN_10001[39]= 64'h1000000;
assign C_LN_10001[40]= 64'h800000;
assign C_LN_10001[41]= 64'h400000;
assign C_LN_10001[42]= 64'h200000;
assign C_LN_10001[43]= 64'h100000;
assign C_LN_10001[44]= 64'h80000;
assign C_LN_10001[45]= 64'h40000;
assign C_LN_10001[46]= 64'h20000;
assign C_LN_10001[47]= 64'h10000;
assign C_LN_10001[48]= 64'h8000;
assign C_LN_10001[49]= 64'h4000;
assign C_LN_10001[50]= 64'h2000;
assign C_LN_10001[51]= 64'h1000;
assign C_LN_10001[52]= 64'h800;
assign C_LN_10001[53]= 64'h400;
assign C_LN_10001[54]= 64'h200;
assign C_LN_10001[55]= 64'h100;
assign C_LN_10001[56]= 64'h80;
assign C_LN_10001[57]= 64'h40;
assign C_LN_10001[58]= 64'h20;
assign C_LN_10001[59]= 64'h10;
assign C_LN_10001[60]= 64'h8;
assign C_LN_10001[61]= 64'h4;
assign C_LN_10001[62]= 64'h2;
assign C_LN_10001[63]= 64'h1;

endmodule


