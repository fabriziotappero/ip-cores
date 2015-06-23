


`define PI_x64 (68'sd57952155664616982739/4)
`define K_DEFORM (64'h26dd3b6a10d7969a)

	
module sin_pipelined(
	input clk,
	input signed [UP:0] x,
	output signed [UP:0] osin,		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	output signed [UP:0] ocos,
	output signed [UP:0] odebug
	);

parameter BITS_HIGH= 16;
parameter BITS_LOW= 16;
parameter BITS_GUARD= 2;
//	Производные константы, не переопределять.

//	разрядность аргумента
parameter UP= BITS_HIGH +BITS_LOW -1;

// у результата старшая часть- все нули(или единицы)
parameter UPL= 			 BITS_LOW -1;

//	добавляем "сторожевые" или "мусорные" биты для точности
parameter UPG= UP   +BITS_GUARD;
parameter UPLG= UPL +BITS_GUARD;
	
`define BOUT (UP)	//	Чтобы мониторить промежуточные стадии при отладке
reg signed [UPG:0] cx [`BOUT:0];

reg signed [UPLG+1:0] csin [`BOUT:BITS_HIGH-1];//!!!+2!!!!
reg signed [UPLG+1:0] ccos [`BOUT:BITS_HIGH-1];

wire signed [UPG:0] x0= (x[UP] ? -x : x)<<<BITS_GUARD;

//wire [UP:0] p_osin= s_sign[BITS_HIGH-1]? (-cx[BITS_HIGH-1]>>BITS_GUARD): cx[BITS_HIGH-1]>>BITS_GUARD;	//	!!!!!!!!!!!!!!!!!!!!!
//wire [UP:0] p_osin= s_sign[BITS_HIGH+1]? (-csin[BITS_HIGH+1][UPLG:BITS_GUARD]>>BITS_GUARD): csin[BITS_HIGH+1][UPLG:BITS_GUARD]>>BITS_GUARD;	//	!!!!!!!!!!!!!!!!!!!!!
//wire [UPL:0] p_osin= csin[BITS_HIGH][UPLG:BITS_GUARD];
//wire [UPL:0] p_osin= csin[UPL][UPLG:BITS_GUARD] +csin[UPL][BITS_GUARD-1];

assign osin= csin[`BOUT]>>>BITS_GUARD;	//	!!!!!!!!!!!!!!!!!!!!!
assign ocos= ccos[`BOUT]>>>BITS_GUARD;	//	!!!!!!!!!!!!!!!!!!!!!
assign odebug= cx[`BOUT]>>>BITS_GUARD;	//	!!!!!!!!!!!!!!!!!!!!!

//assign osin= s_sign[`BOUT]? (-cx[`BOUT]>>BITS_GUARD): cx[`BOUT]>>>BITS_GUARD;	//	!!!!!!!!!!!!!!!!!!!!!
//assign ocos= ccos[UPL][UPLG:BITS_GUARD] +ccos[UPL][BITS_GUARD-1];

//	углы, для которых поворот соответствует умножению на 1.00...001
wire signed [63:0] C_ANGLE [63:0];

reg s_sign [UP:0];
reg c_sign [UP:BITS_HIGH-2];
reg xy_swap [UP:BITS_HIGH-1];

always @( posedge clk ) 
begin
	integer ind;

	//	сохраняем знак, чтобы в конце обратить синус ( sin(-x)=sin(x) )
	for (ind=0; ind< BITS_HIGH-4; ind=ind+1)
	begin
	end

	//	x <- x-Pi*n
//	s_sign[BITS_HIGH-2]<= ( cx[BITS_HIGH-3]- (`PI_x64>>(67-(UPG-(BITS_HIGH-3)) )) >0 
//																? s_sign[BITS_HIGH-3] : ~s_sign[BITS_HIGH-3] );
//														
//	c_sign[BITS_HIGH-2]<= ( cx[BITS_HIGH-3]- (`PI_x64>>(67-(UPG-(BITS_HIGH-3)) )) >0 
//																? s_sign[BITS_HIGH-3] : ~s_sign[BITS_HIGH-3] );
													
												
	//	x <- x-Pi*n/2
//	s_sign[BITS_HIGH-1]<= s_sign[BITS_HIGH-2];

	//	приводим аргумент к беззнаковому виду
	s_sign[0]<= x[UP];
	cx[0]<= ( x0- (`PI_x64>>>(65-(UPG) )) >0 ? x0- (`PI_x64>>>(65-(UPG) )) : x0 );
	
	//	вычитаем 2*Pi*n
	for (ind=0; ind< BITS_HIGH-4; ind=ind+1)
	begin
		cx[ind+1]<= ( cx[ind]- (`PI_x64>>>(66-(UPG-ind) )) >0 ? cx[ind]- (`PI_x64>>>(66-(UPG-ind) )) : cx[ind] );
		s_sign[ind+1]<= s_sign[ind];
	end
	
//	for (ind=BITS_HIGH-4; ind< BITS_HIGH-1; ind=ind+1)
	begin
	//	вычитаем Pi*n
		ind= BITS_HIGH-4;
		if ( cx[ind]- (`PI_x64>>>(66-(UPG-ind) )) >0 )
		begin
			cx[ind+1]<= (`PI_x64>>>(65-(UPG-ind) ))-cx[ind];
			s_sign[ind+1]<= ~s_sign[ind];
		end
		else
		begin
			cx[ind+1]<= cx[ind];
			s_sign[ind+1]<= s_sign[ind];
		end
	end
	begin
		ind= BITS_HIGH-3;
		if ( cx[ind]- (`PI_x64>>>(66-(UPG-ind) )) >0 )
		begin
			cx[ind+1]<= (`PI_x64>>>(65-(UPG-ind) ))-cx[ind];
			s_sign[ind+1]<= s_sign[ind];
			c_sign[ind+1]<= 1'h1;
		end
		else
		begin
			cx[ind+1]<= cx[ind];
			s_sign[ind+1]<= s_sign[ind];
			c_sign[ind+1]<= 1'h0;
		end
	end
	
	begin
		ind= BITS_HIGH-2;
		if ( cx[ind] > (`PI_x64>>(66-(UPG-ind) )) )
		begin
			cx[ind+1]<= (s_sign[ind]^c_sign[ind]) ? ((`PI_x64>>>(65-(UPG-ind) ))-cx[ind]) : -((`PI_x64>>>(65-(UPG-ind) ))-cx[ind]);
			csin[ind+1]<= 0;
			ccos[ind+1]<= -(`K_DEFORM>>(64-UPLG-3))
																	+(1<<BITS_GUARD);	//	to avoid results >=|1.0|, if you prefer more precision, you need to 
//			csin[ind+1]<= s_sign[ind] ?  -(64'sh9B74) : 64'sh9B74;
//			ccos[ind+1]<= 0;
		end
		else
		begin
			cx[ind+1]<= (s_sign[ind]^c_sign[ind]) ? -(cx[ind]) : (cx[ind]);
			csin[ind+1]<= 0; 
			ccos[ind+1]<= (`K_DEFORM>>(64-UPLG-3))
																	-(1<<BITS_GUARD);	//	to avoid results >=|1.0|
//			csin[ind+1]<= 0; 
//			ccos[ind+1]<= c_sign[ind] ?  -(64'sh9B74) : 64'sh9B74;
		end
		s_sign[ind+1]<= 0;
		c_sign[ind+1]<= 0;
	end

`define BHm1 (BITS_HIGH-1)	
	//	собственно, CORDIC
//				cx[16]<= cx[15]- 32'sh00003000;//(C_ANGLE[ind-`BHm1] >> (64-UPLG));

	//	Каждый "проход по циклу" создаёт ступень конвеера 
	for (ind=`BHm1; ind< `BOUT; ind=ind+1)	
	// ind - псевдопеременная цикла, `BHm1, `BOUT - макропеременные, определённые
	//	с помощью директивы `define
	// меняя `BHm1, `BOUT, UPLG можно настроить такие параметры как 
	// разрядность, глубина конвеера.
	begin
		if ( cx[ind] >0 )
		begin
			//	поворот туда (см. CORDIC)
			// cx, csin, ccos - массивы шин, cx[ind] - конкретная шина
			//	шина, в свою очередь, это массив битов (число)
			cx[ind+1]<= cx[ind]- (C_ANGLE[ind-`BHm1] >>> (64-UPLG));
			csin[ ind +1 ]<= csin[ ind ] + (ccos[ ind ] >>>(ind-`BHm1 ) );
			ccos[ ind +1 ]<= ccos[ ind ] - (csin[ ind ] >>>(ind-`BHm1 ) );
		end
		else
		begin
			//	поворот cуда 
			cx[ind+1]<= cx[ind]+ (C_ANGLE[ind-`BHm1] >>> (64-UPLG));
			csin[ ind +1 ]<= csin[ ind ] - (ccos[ ind ] >>>(ind-`BHm1 ) );
			ccos[ ind +1 ]<= ccos[ ind ] + (csin[ ind ] >>>(ind-`BHm1 ) );
		end
	end
	//	Последний шаг
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

//	for ( i=0; i<64; i++){
//		double dval= atan(1./pow(2.,i)) * pow(2.,63.); //((long long)1 << i);
//		unsigned long long val= dval;
//		cout << "assign C_ANGLE[" << dec << i << "]= 64'h" << hex << val << ";" << endl;
//	}

assign C_ANGLE[0] = 64'sh6487ed5110b46000;
assign C_ANGLE[1] = 64'sh3b58ce0ac3769e00;
assign C_ANGLE[2] = 64'sh1f5b75f92c80dd00;
assign C_ANGLE[3] = 64'shfeadd4d5617b700;
assign C_ANGLE[4] = 64'sh7fd56edcb3f7a80;
assign C_ANGLE[5] = 64'sh3ffaab7752ec4a0;
assign C_ANGLE[6] = 64'sh1fff555bbb729b0;
assign C_ANGLE[7] = 64'shfffeaaadddd4b8;
assign C_ANGLE[8] = 64'sh7fffd5556eeedc;
assign C_ANGLE[9] = 64'sh3ffffaaaab7778;
assign C_ANGLE[10]= 64'sh1fffff55555bbc;
assign C_ANGLE[11]= 64'shfffffeaaaaade;
assign C_ANGLE[12]= 64'sh7fffffd555557;
assign C_ANGLE[13]= 64'sh3ffffffaaaaaa;
assign C_ANGLE[14]= 64'sh1fffffff55555;
assign C_ANGLE[15]= 64'shfffffffeaaaa;
assign C_ANGLE[16]= 64'sh7fffffffd555;
assign C_ANGLE[17]= 64'sh3ffffffffaaa;
assign C_ANGLE[18]= 64'sh1fffffffff55;
assign C_ANGLE[19]= 64'shfffffffffea;
assign C_ANGLE[20]= 64'sh7fffffffffd;
assign C_ANGLE[21]= 64'sh3ffffffffff;
assign C_ANGLE[22]= 64'sh1ffffffffff;
assign C_ANGLE[23]= 64'shffffffffff;
assign C_ANGLE[24]= 64'sh7fffffffff;
assign C_ANGLE[25]= 64'sh3fffffffff;
assign C_ANGLE[26]= 64'sh1fffffffff;
assign C_ANGLE[27]= 64'sh1000000000;
assign C_ANGLE[28]= 64'sh800000000;
assign C_ANGLE[29]= 64'sh400000000;
assign C_ANGLE[30]= 64'sh200000000;
assign C_ANGLE[31]= 64'sh100000000;
assign C_ANGLE[32]= 64'sh80000000;
assign C_ANGLE[33]= 64'sh40000000;
assign C_ANGLE[34]= 64'sh20000000;
assign C_ANGLE[35]= 64'sh10000000;
assign C_ANGLE[36]= 64'sh8000000;
assign C_ANGLE[37]= 64'sh4000000;
assign C_ANGLE[38]= 64'sh2000000;
assign C_ANGLE[39]= 64'sh1000000;
assign C_ANGLE[40]= 64'sh800000;
assign C_ANGLE[41]= 64'sh400000;
assign C_ANGLE[42]= 64'sh200000;
assign C_ANGLE[43]= 64'sh100000;
assign C_ANGLE[44]= 64'sh80000;
assign C_ANGLE[45]= 64'sh40000;
assign C_ANGLE[46]= 64'sh20000;
assign C_ANGLE[47]= 64'sh10000;
assign C_ANGLE[48]= 64'sh8000;
assign C_ANGLE[49]= 64'sh4000;
assign C_ANGLE[50]= 64'sh2000;
assign C_ANGLE[51]= 64'sh1000;
assign C_ANGLE[52]= 64'sh800;
assign C_ANGLE[53]= 64'sh400;
assign C_ANGLE[54]= 64'sh200;
assign C_ANGLE[55]= 64'sh100;
assign C_ANGLE[56]= 64'sh80;
assign C_ANGLE[57]= 64'sh40;
assign C_ANGLE[58]= 64'sh20;
assign C_ANGLE[59]= 64'sh10;
assign C_ANGLE[60]= 64'sh8;
assign C_ANGLE[61]= 64'sh4;
assign C_ANGLE[62]= 64'h2;
assign C_ANGLE[63]= 64'h1;
endmodule
	
	

	