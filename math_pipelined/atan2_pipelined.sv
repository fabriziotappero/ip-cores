


`define PI_x64 (68'sd57952155664616982739/4)

module atan2_pipelined(
	input clk,
	input signed [UP:0] y,
	input signed [UP:0] x,
	output signed [UP:0] oangle,
	output signed [UP:0] odebug
	);

parameter BITS_HIGH= 16;
parameter BITS_LOW= 16;
parameter BITS_GUARD= 0;

parameter IS_IBNIZ= 0;//	пїЅпїЅпїЅпїЅ 0, пїЅпїЅ f=atan2	пїЅпїЅпїЅпїЅ 1, пїЅпїЅ f=atan2/2PI
//	пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ.

//	пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
parameter UP= BITS_HIGH +BITS_LOW -1;

// пїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ- пїЅпїЅпїЅ пїЅпїЅпїЅпїЅ(пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ)
parameter UPL= 			 BITS_LOW -1;

//	пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ "пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ" пїЅпїЅпїЅ "пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ" пїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
parameter UPG= UP   +BITS_GUARD;
parameter UPLG= UPL +BITS_GUARD;
	
`define BOUT (UPL)	//	пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ

reg signed [UPG:0] cx [`BOUT:0];
reg signed [UPG:0] csin [`BOUT:0];
reg signed [UPG:0] ccos [`BOUT:0];

//wire signed [UPG:0] x0= (x[UP] ? -x : x)<<<BITS_GUARD;

assign oangle= cx[`BOUT]>>>(BITS_GUARD);
assign odebug= csin[`BOUT]>>>BITS_GUARD;

//	пїЅпїЅпїЅпїЅ, пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ 1.00...001
wire signed [63:0] C_ANGLE [63:0];

//	
wire signed [UPG:0] cx2 [`BOUT:0];
wire signed [UPG:0] csin2 [`BOUT:0];
wire signed [UPG:0] ccos2 [`BOUT:0];


always @*
begin
	integer ind;
	for (ind=0; ind< `BOUT; ind=ind+1)
	begin
		if ( csin[ind] >0 )
		begin
			cx2[ind]<= cx[ind]+ (C_ANGLE[ind] >>> (62-UPLG));
			csin2[ ind ]<= csin[ ind ] - (ccos[ ind ] >>>(ind) );
			ccos2[ ind ]<= ccos[ ind ] + (csin[ ind ] >>>(ind) );
		end
		else
		begin
			cx2[ind]<= cx[ind]- (C_ANGLE[ind] >>> (62-UPLG));
			csin2[ ind ]<= csin[ ind ] + (ccos[ ind ] >>>(ind) );
			ccos2[ ind ]<= ccos[ ind ] - (csin[ ind ] >>>(ind) );
		end
	end
	
end

always @( posedge clk ) 
begin
	integer ind;

	csin[0]= {y, {BITS_GUARD{1'h0}}};
	ccos[0]= {x, {BITS_GUARD{1'h0}}};
	cx[0]=0;
	//	пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ, CORDIC
	
	for (ind=0; ind< `BOUT; ind=ind+1)
	begin
		if ( csin2[ind] >0 )
		begin
			cx[ind+1]<= cx2[ind]+ (C_ANGLE[ind] >>> (62-UPLG));
			csin[ ind +1 ]<= csin2[ ind ] - (ccos2[ ind ] >>>(ind) );
			ccos[ ind +1 ]<= ccos2[ ind ] + (csin2[ ind ] >>>(ind) );
		end
		else
		begin
			cx[ind+1]<= cx2[ind]- (C_ANGLE[ind] >>> (62-UPLG));
			csin[ ind +1 ]<= csin2[ ind ] + (ccos2[ ind ] >>>(ind) );
			ccos[ ind +1 ]<= ccos2[ ind ] - (csin2[ ind ] >>>(ind) );
		end
	end
	//	пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅ
//	begin
//		ind= UP-2;
//		if ( cx[ind] >0 )
//		begin
//			cx[ind+1]<= cx[ind]- (C_ANGLE[ind-BITS_HIGH+1] >>> (63-UPLG));
//			csin[ ind +1 ]<= s_sign[ind] ?-(csin[ ind ] + (ccos[ ind ] >>>(ind-(BITS_HIGH-1) +1) )) :
//													  csin[ ind ] - (ccos[ ind ] >>>(ind-(BITS_HIGH-1) +1) );	
//			ccos[ ind +1 ]<= c_sign[ind] ? -(ccos[ ind ] - (csin[ ind ] >>>(ind-(BITS_HIGH-1) +1) )) :
//														ccos[ ind ] + (csin[ ind ] >>>(ind-(BITS_HIGH-1) +1) );
//		end
//		else
//		begin
//			cx[ind+1]<= cx[ind]+ (C_ANGLE[ind-BITS_HIGH+1] >>> (63-UPLG));
//			csin[ ind +1 ]<= s_sign[ind] ?-(csin[ ind ] + (ccos[ ind ] >>>(ind-(BITS_HIGH-1) +1) )) :
//													  csin[ ind ] + (ccos[ ind ] >>>(ind-(BITS_HIGH-1) +1) );	
//			
//			ccos[ ind +1 ]<= c_sign[ind] ? -(ccos[ ind ] - (csin[ ind ] >>>(ind-(BITS_HIGH-1) +1) )) :
//														ccos[ ind ] - (csin[ ind ] >>>(ind-(BITS_HIGH-1) +1) );
//		end
//		s_sign[ind+1]<= s_sign[ind];
//		c_sign[ind+1]<= c_sign[ind];
//	end
	
	
//	if ( x[UP] )
//	begin
//	end
//	else
//	begin
//		cx[0]= x;
//	end
end

	//for ( i=0; i<64; i++){
	//	double dval= atan(1./pow(2.,i)) * pow(2.,63.); //((long long)1 << i);
	//	unsigned long long val= dval;
	//	unsigned long long val_ibn= dval/6.283185307179586476925286766559;
	//	cout << "assign C_ANGLE[" << dec << i << "]= IS_IBNIZ?"
	//		" 64'h" << hex << val_ibn << ":"
	//		" 64'h" << hex << val << ";" << endl;
	//}

assign C_ANGLE[0]= IS_IBNIZ? 64'h1000000000000000: 64'h6487ed5110b46000;
assign C_ANGLE[1]= IS_IBNIZ? 64'h0972028ecef98400: 64'h3b58ce0ac3769e00;
assign C_ANGLE[2]= IS_IBNIZ? 64'h4fd9c2daf71cf40: 64'h1f5b75f92c80dd00;
assign C_ANGLE[3]= IS_IBNIZ? 64'h28888ea0eeecd20: 64'h0feadd4d5617b700;
assign C_ANGLE[4]= IS_IBNIZ? 64'h14586a1872c4d80: 64'h7fd56edcb3f7a80;
assign C_ANGLE[5]= IS_IBNIZ? 64'h0a2ebf0ac823140: 64'h3ffaab7752ec4a0;
assign C_ANGLE[6]= IS_IBNIZ? 64'h517b0f2e141318: 64'h1fff555bbb729b0;
assign C_ANGLE[7]= IS_IBNIZ? 64'h28be2a88ea2158: 64'h0fffeaaadddd4b8;
assign C_ANGLE[8]= IS_IBNIZ? 64'h145f29a368619c: 64'h7fffd5556eeedc;
assign C_ANGLE[9]= IS_IBNIZ? 64'h0a2f975d98559c: 64'h3ffffaaaab7778;
assign C_ANGLE[10]= IS_IBNIZ? 64'h517cc0048dd3d: 64'h1fffff55555bbc;
assign C_ANGLE[11]= IS_IBNIZ? 64'h28be60a54065b: 64'h0fffffeaaaaade;
assign C_ANGLE[12]= IS_IBNIZ? 64'h145f3066ff630: 64'h7fffffd555557;
assign C_ANGLE[13]= IS_IBNIZ? 64'h0a2f98360b979: 64'h3ffffffaaaaaa;
assign C_ANGLE[14]= IS_IBNIZ? 64'h517cc1b57488: 64'h1fffffff55555;
assign C_ANGLE[15]= IS_IBNIZ? 64'h28be60db5d3d: 64'h0fffffffeaaaa;
assign C_ANGLE[16]= IS_IBNIZ? 64'h145f306dc2fe: 64'h7fffffffd555;
assign C_ANGLE[17]= IS_IBNIZ? 64'h0a2f9836e40a: 64'h3ffffffffaaa;
assign C_ANGLE[18]= IS_IBNIZ? 64'h517cc1b7256: 64'h1fffffffff55;
assign C_ANGLE[19]= IS_IBNIZ? 64'h28be60db935: 64'h0fffffffffea;
assign C_ANGLE[20]= IS_IBNIZ? 64'h145f306dc9c: 64'h7fffffffffd;
assign C_ANGLE[21]= IS_IBNIZ? 64'h0a2f9836e4e: 64'h3ffffffffff;
assign C_ANGLE[22]= IS_IBNIZ? 64'h517cc1b727: 64'h1ffffffffff;
assign C_ANGLE[23]= IS_IBNIZ? 64'h28be60db93: 64'h0ffffffffff;
assign C_ANGLE[24]= IS_IBNIZ? 64'h145f306dc9: 64'h7fffffffff;
assign C_ANGLE[25]= IS_IBNIZ? 64'h0a2f9836e4: 64'h3fffffffff;
assign C_ANGLE[26]= IS_IBNIZ? 64'h517cc1b72: 64'h1fffffffff;
assign C_ANGLE[27]= IS_IBNIZ? 64'h28be60db9: 64'h1000000000;
assign C_ANGLE[28]= IS_IBNIZ? 64'h145f306dc: 64'h0800000000;
assign C_ANGLE[29]= IS_IBNIZ? 64'h0a2f9836e: 64'h400000000;
assign C_ANGLE[30]= IS_IBNIZ? 64'h517cc1b7: 64'h200000000;
assign C_ANGLE[31]= IS_IBNIZ? 64'h28be60db: 64'h100000000;
assign C_ANGLE[32]= IS_IBNIZ? 64'h145f306d: 64'h080000000;
assign C_ANGLE[33]= IS_IBNIZ? 64'h0a2f9836: 64'h40000000;
assign C_ANGLE[34]= IS_IBNIZ? 64'h517cc1b: 64'h20000000;
assign C_ANGLE[35]= IS_IBNIZ? 64'h28be60d: 64'h10000000;
assign C_ANGLE[36]= IS_IBNIZ? 64'h145f306: 64'h08000000;
assign C_ANGLE[37]= IS_IBNIZ? 64'h0a2f983: 64'h4000000;
assign C_ANGLE[38]= IS_IBNIZ? 64'h517cc1: 64'h2000000;
assign C_ANGLE[39]= IS_IBNIZ? 64'h28be60: 64'h1000000;
assign C_ANGLE[40]= IS_IBNIZ? 64'h145f30: 64'h0800000;
assign C_ANGLE[41]= IS_IBNIZ? 64'h0a2f98: 64'h400000;
assign C_ANGLE[42]= IS_IBNIZ? 64'h517cc: 64'h200000;
assign C_ANGLE[43]= IS_IBNIZ? 64'h28be6: 64'h100000;
assign C_ANGLE[44]= IS_IBNIZ? 64'h145f3: 64'h080000;
assign C_ANGLE[45]= IS_IBNIZ? 64'h0a2f9: 64'h40000;
assign C_ANGLE[46]= IS_IBNIZ? 64'h517c: 64'h20000;
assign C_ANGLE[47]= IS_IBNIZ? 64'h28be: 64'h10000;
assign C_ANGLE[48]= IS_IBNIZ? 64'h145f: 64'h08000;
assign C_ANGLE[49]= IS_IBNIZ? 64'h0a2f: 64'h4000;
assign C_ANGLE[50]= IS_IBNIZ? 64'h517: 64'h2000;
assign C_ANGLE[51]= IS_IBNIZ? 64'h28b: 64'h1000;
assign C_ANGLE[52]= IS_IBNIZ? 64'h145: 64'h0800;
assign C_ANGLE[53]= IS_IBNIZ? 64'h0a2: 64'h400;
assign C_ANGLE[54]= IS_IBNIZ? 64'h51: 64'h200;
assign C_ANGLE[55]= IS_IBNIZ? 64'h28: 64'h100;
assign C_ANGLE[56]= IS_IBNIZ? 64'h14: 64'h080;
assign C_ANGLE[57]= IS_IBNIZ? 64'h0a: 64'h40;
assign C_ANGLE[58]= IS_IBNIZ? 64'h5: 64'h20;
assign C_ANGLE[59]= IS_IBNIZ? 64'h2: 64'h10;
assign C_ANGLE[60]= IS_IBNIZ? 64'h1: 64'h08;
assign C_ANGLE[61]= IS_IBNIZ? 64'h0: 64'h4;
assign C_ANGLE[62]= IS_IBNIZ? 64'h0: 64'h2;
assign C_ANGLE[63]= IS_IBNIZ? 64'h0: 64'h1;
endmodule
	
	

	