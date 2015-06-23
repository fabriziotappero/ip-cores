
module MULT_BY_ALPHA51(b, z); 
input [7:0] b; 
output [7:0] z; 
assign z[0] = b[5]^b[7];  
assign z[1] = b[0]^b[6];  
assign z[2] = b[1]^b[5];  
assign z[3] = b[0]^b[2]^b[5]^b[6]^b[7];  
assign z[4] = b[1]^b[3]^b[5]^b[6]^b[7]^b[7];  
assign z[5] = b[2]^b[4]^b[6]^b[7];  
assign z[6] = b[3]^b[5]^b[7];  
assign z[7] = b[4]^b[6];  
endmodule 

module SYN2ERR(SYND1_, SYND2_, LOC);


input [7:0] SYND1_, SYND2_;
output [2:0] LOC;




wire [7:0] SYND2_inv;
wire [7:0] mult_out;

inv_gf256	inv_(.x(SYND2_), .y(SYND2_inv));
gf256mult	mult_(.a(SYND1_), .b(SYND2_inv), .z(mult_out));

assign LOC[2] = ~(mult_out[1] | mult_out[2] );
assign LOC[1] = mult_out[4];
assign LOC[0] = mult_out[2];


endmodule

/******************************************************************/

module gf256mult(a, b, z); 
input [7:0] a; 
input [7:0] b; 
output [7:0] z; 
assign z[0] = b[0]&a[0]^b[1]&a[7]^b[2]&a[6]^b[3]&a[5]^b[4]&a[4]^b[5]&a[3]^b[5]&a[7]^b[6]&a[2]^b[6]&a[6]^b[6]&a[7]^b[7]&a[1]^b[7]&a[5]^b[7]&a[6]^b[7]&a[7];  
assign z[1] = b[0]&a[1]^b[1]&a[0]^b[2]&a[7]^b[3]&a[6]^b[4]&a[5]^b[5]&a[4]^b[6]&a[3]^b[6]&a[7]^b[7]&a[2]^b[7]&a[6]^b[7]&a[7];  
assign z[2] = b[0]&a[2]^b[1]&a[1]^b[1]&a[7]^b[2]&a[0]^b[2]&a[6]^b[3]&a[5]^b[3]&a[7]^b[4]&a[4]^b[4]&a[6]^b[5]&a[3]^b[5]&a[5]^b[5]&a[7]^b[6]&a[2]^b[6]&a[4]^b[6]&a[6]^b[6]&a[7]^b[7]&a[1]^b[7]&a[3]^b[7]&a[5]^b[7]&a[6];  
assign z[3] = b[0]&a[3]^b[1]&a[2]^b[1]&a[7]^b[2]&a[1]^b[2]&a[6]^b[2]&a[7]^b[3]&a[0]^b[3]&a[5]^b[3]&a[6]^b[4]&a[4]^b[4]&a[5]^b[4]&a[7]^b[5]&a[3]^b[5]&a[4]^b[5]&a[6]^b[5]&a[7]^b[6]&a[2]^b[6]&a[3]^b[6]&a[5]^b[6]&a[6]^b[7]&a[1]^b[7]&a[2]^b[7]&a[4]^b[7]&a[5];  
assign z[4] = b[0]&a[4]^b[1]&a[3]^b[1]&a[7]^b[2]&a[2]^b[2]&a[6]^b[2]&a[7]^b[3]&a[1]^b[3]&a[5]^b[3]&a[6]^b[3]&a[7]^b[4]&a[0]^b[4]&a[4]^b[4]&a[5]^b[4]&a[6]^b[5]&a[3]^b[5]&a[4]^b[5]&a[5]^b[6]&a[2]^b[6]&a[3]^b[6]&a[4]^b[7]&a[1]^b[7]&a[2]^b[7]&a[3]^b[7]&a[7];  
assign z[5] = b[0]&a[5]^b[1]&a[4]^b[2]&a[3]^b[2]&a[7]^b[3]&a[2]^b[3]&a[6]^b[3]&a[7]^b[4]&a[1]^b[4]&a[5]^b[4]&a[6]^b[4]&a[7]^b[5]&a[0]^b[5]&a[4]^b[5]&a[5]^b[5]&a[6]^b[6]&a[3]^b[6]&a[4]^b[6]&a[5]^b[7]&a[2]^b[7]&a[3]^b[7]&a[4];  
assign z[6] = b[0]&a[6]^b[1]&a[5]^b[2]&a[4]^b[3]&a[3]^b[3]&a[7]^b[4]&a[2]^b[4]&a[6]^b[4]&a[7]^b[5]&a[1]^b[5]&a[5]^b[5]&a[6]^b[5]&a[7]^b[6]&a[0]^b[6]&a[4]^b[6]&a[5]^b[6]&a[6]^b[7]&a[3]^b[7]&a[4]^b[7]&a[5];  
assign z[7] = b[0]&a[7]^b[1]&a[6]^b[2]&a[5]^b[3]&a[4]^b[4]&a[3]^b[4]&a[7]^b[5]&a[2]^b[5]&a[6]^b[5]&a[7]^b[6]&a[1]^b[6]&a[5]^b[6]&a[6]^b[6]&a[7]^b[7]&a[0]^b[7]&a[4]^b[7]&a[5]^b[7]&a[6];  
endmodule

/******************************************************************/

module inv_gf256(x, y);
input [7:0] x;
output [7:0] y;
reg [7:0] y;

always@(x)

case(x)
0: y<= 0;
1:	y<=	1;
2:	y<=	142;
4:	y<=	71;
8:	y<=	173;
16:	y<=	216;
32:	y<=	108;
64:	y<=	54;
128:	y<=	27;
29:	y<=	131;
58:	y<=	207;
116:	y<=	233;
232:	y<=	250;
205:	y<=	125;
135:	y<=	176;
19:	y<=	88;
38:	y<=	44;
76:	y<=	22;
152:	y<=	11;
45:	y<=	139;
90:	y<=	203;
180:	y<=	235;
117:	y<=	251;
234:	y<=	243;
201:	y<=	247;
143:	y<=	245;
3:	y<=	244;
6:	y<=	122;
12:	y<=	61;
24:	y<=	144;
48:	y<=	72;
96:	y<=	36;
192:	y<=	18;
157:	y<=	9;
39:	y<=	138;
78:	y<=	69;
156:	y<=	172;
37:	y<=	86;
74:	y<=	43;
148:	y<=	155;
53:	y<=	195;
106:	y<=	239;
212:	y<=	249;
181:	y<=	242;
119:	y<=	121;
238:	y<=	178;
193:	y<=	89;
159:	y<=	162;
35:	y<=	81;
70:	y<=	166;
140:	y<=	83;
5:	y<=	167;
10:	y<=	221;
20:	y<=	224;
40:	y<=	112;
80:	y<=	56;
160:	y<=	28;
93:	y<=	14;
186:	y<=	7;
105:	y<=	141;
210:	y<=	200;
185:	y<=	100;
111:	y<=	50;
222:	y<=	25;
161:	y<=	130;
95:	y<=	65;
190:	y<=	174;
97:	y<=	87;
194:	y<=	165;
153:	y<=	220;
47:	y<=	110;
94:	y<=	55;
188:	y<=	149;
101:	y<=	196;
202:	y<=	98;
137:	y<=	49;
15:	y<=	150;
30:	y<=	75;
60:	y<=	171;
120:	y<=	219;
240:	y<=	227;
253:	y<=	255;
231:	y<=	241;
211:	y<=	246;
187:	y<=	123;
107:	y<=	179;
214:	y<=	215;
177:	y<=	229;
127:	y<=	252;
254:	y<=	126;
225:	y<=	63;
223:	y<=	145;
163:	y<=	198;
91:	y<=	99;
182:	y<=	191;
113:	y<=	209;
226:	y<=	230;
217:	y<=	115;
175:	y<=	183;
67:	y<=	213;
134:	y<=	228;
17:	y<=	114;
34:	y<=	57;
68:	y<=	146;
136:	y<=	73;
13:	y<=	170;
26:	y<=	85;
52:	y<=	164;
104:	y<=	82;
208:	y<=	41;
189:	y<=	154;
103:	y<=	77;
206:	y<=	168;
129:	y<=	84;
31:	y<=	42;
62:	y<=	21;
124:	y<=	132;
248:	y<=	66;
237:	y<=	33;
199:	y<=	158;
147:	y<=	79;
59:	y<=	169;
118:	y<=	218;
236:	y<=	109;
197:	y<=	184;
151:	y<=	92;
51:	y<=	46;
102:	y<=	23;
204:	y<=	133;
133:	y<=	204;
23:	y<=	102;
46:	y<=	51;
92:	y<=	151;
184:	y<=	197;
109:	y<=	236;
218:	y<=	118;
169:	y<=	59;
79:	y<=	147;
158:	y<=	199;
33:	y<=	237;
66:	y<=	248;
132:	y<=	124;
21:	y<=	62;
42:	y<=	31;
84:	y<=	129;
168:	y<=	206;
77:	y<=	103;
154:	y<=	189;
41:	y<=	208;
82:	y<=	104;
164:	y<=	52;
85:	y<=	26;
170:	y<=	13;
73:	y<=	136;
146:	y<=	68;
57:	y<=	34;
114:	y<=	17;
228:	y<=	134;
213:	y<=	67;
183:	y<=	175;
115:	y<=	217;
230:	y<=	226;
209:	y<=	113;
191:	y<=	182;
99:	y<=	91;
198:	y<=	163;
145:	y<=	223;
63:	y<=	225;
126:	y<=	254;
252:	y<=	127;
229:	y<=	177;
215:	y<=	214;
179:	y<=	107;
123:	y<=	187;
246:	y<=	211;
241:	y<=	231;
255:	y<=	253;
227:	y<=	240;
219:	y<=	120;
171:	y<=	60;
75:	y<=	30;
150:	y<=	15;
49:	y<=	137;
98:	y<=	202;
196:	y<=	101;
149:	y<=	188;
55:	y<=	94;
110:	y<=	47;
220:	y<=	153;
165:	y<=	194;
87:	y<=	97;
174:	y<=	190;
65:	y<=	95;
130:	y<=	161;
25:	y<=	222;
50:	y<=	111;
100:	y<=	185;
200:	y<=	210;
141:	y<=	105;
7:	y<=	186;
14:	y<=	93;
28:	y<=	160;
56:	y<=	80;
112:	y<=	40;
224:	y<=	20;
221:	y<=	10;
167:	y<=	5;
83:	y<=	140;
166:	y<=	70;
81:	y<=	35;
162:	y<=	159;
89:	y<=	193;
178:	y<=	238;
121:	y<=	119;
242:	y<=	181;
249:	y<=	212;
239:	y<=	106;
195:	y<=	53;
155:	y<=	148;
43:	y<=	74;
86:	y<=	37;
172:	y<=	156;
69:	y<=	78;
138:	y<=	39;
9:	y<=	157;
18:	y<=	192;
36:	y<=	96;
72:	y<=	48;
144:	y<=	24;
61:	y<=	12;
122:	y<=	6;
244:	y<=	3;
245:	y<=	143;
247:	y<=	201;
243:	y<=	234;
251:	y<=	117;
235:	y<=	180;
203:	y<=	90;
139:	y<=	45;
11:	y<=	152;
22:	y<=	76;
44:	y<=	38;
88:	y<=	19;
176:	y<=	135;
125:	y<=	205;
250:	y<=	232;
233:	y<=	116;
207:	y<=	58;
131:	y<=	29;
27:	y<=	128;
54:	y<=	64;
108:	y<=	32;
216:	y<=	16;
173:	y<=	8;
71:	y<=	4;
142:	y<=	2;
endcase

endmodule 
/******************************************************************/
module RS_5_3_GF256(
CLK, 
RESET,
DATA_VALID_IN,
DATA_IN,
E_D, 
DATA_VALID_OUT,
DATA_OUT);

input 
CLK, 
RESET, 
DATA_VALID_IN,
E_D;

input [7:0] DATA_IN;
output DATA_VALID_OUT;
output [7:0] DATA_OUT;
reg DATA_VALID_OUT;
reg [7:0] DATA_OUT;
reg [3:0] cntr1_;
reg [2:0] cntr2_;
reg cntr2_en;
reg [7:0] SYND1_;
reg [7:0] SYND2_;
reg [7:0] VAL;
reg [2:0] LOC2_;

wire [7:0] MULT2_;
wire [7:0] ADD3_;
wire	[2:0] LOC;

reg [7:0] FIFO0_;
reg [7:0] FIFO1_;
reg [7:0] FIFO2_;
reg [7:0] FIFO3_;
reg [7:0] FIFO4_;

assign ADD3_ = (E_D) ? (SYND1_ ^ MULT2_) : MULT2_; 

MULT_BY_ALPHA51	m0_(.b(SYND2_), .z(MULT2_));
SYN2ERR	s_( .SYND1_(SYND1_), .SYND2_(SYND2_), .LOC(LOC) );

///////////////////////////////////////////////////////////////////////

always@(posedge CLK)

if (cntr2_en)
begin
	VAL<=SYND1_;
	LOC2_<=LOC;
end





///////////////////////////////////////////////////////////////////////

always@(posedge CLK or negedge RESET)

if (!RESET)

cntr1_<=0;

else 
case(cntr1_)

0: if (!DATA_VALID_IN)
	if (E_D) 
		cntr1_<=1;
	else 
		cntr1_<=5;
1: if (!DATA_VALID_IN) cntr1_<=2;
2: if (!DATA_VALID_IN) cntr1_<=3;
3: cntr1_<=4;
4: cntr1_<=0;
5: if (!DATA_VALID_IN) cntr1_<=6;	
6: if (!DATA_VALID_IN) cntr1_<=7;
7: if (!DATA_VALID_IN) cntr1_<=8;
8: cntr1_<=0;
endcase


//////////////////////////////////////////////////////////////////////

always@(posedge CLK or negedge RESET)
if (!RESET)

cntr2_<=0;

else if (cntr2_==0)
begin 
	if (cntr2_en)
		cntr2_<=cntr2_+1;
end
else if (cntr2_==4)
	cntr2_<=0;
else
	cntr2_<=cntr2_+1;




//////////////////////////////////////////////////////////////////////

always@(posedge CLK or negedge RESET)

if (!RESET)

	DATA_VALID_OUT<=1;

else if ((cntr1_==0)&&(E_D))	
	
	DATA_VALID_OUT<=DATA_VALID_IN;

else if ( (cntr1_==1) || (cntr1_==2) )

	DATA_VALID_OUT<=DATA_VALID_IN;

else if ((cntr1_==3) || (cntr1_==4))

	DATA_VALID_OUT<=0;

else if ((cntr2_en) || (cntr2_!=0))

	DATA_VALID_OUT<=0;
else 
	DATA_VALID_OUT<=1;

	
//////////////////////////////////////////////////////////////////////
	

always@(posedge CLK or negedge RESET)

if (!RESET)

	DATA_OUT<=0;

else if ((cntr1_==0)&&(E_D))	

	DATA_OUT<=DATA_IN;

else if ( (cntr1_==1) || (cntr1_==2) )

	DATA_OUT<=DATA_IN;

else if ((cntr1_==3) || (cntr1_==4))

	DATA_OUT<=ADD3_;

else if (cntr2_en)
begin
	if(LOC==0)
		DATA_OUT<=FIFO4_ ^ SYND1_;
	else 
		DATA_OUT<=FIFO4_;

end
else if (cntr2_==LOC2_)

	DATA_OUT<=FIFO4_ ^ VAL;	
	
else 

	DATA_OUT<=FIFO4_;

//////////////////////////////////////////////////////////////////////
	

always@(posedge CLK or negedge RESET)

if (!RESET)
begin

	FIFO0_<=0;	
	FIFO1_<=0;
	FIFO2_<=0;
	FIFO3_<=0;
	FIFO4_<=0;

end
else if (((!DATA_VALID_OUT) && (!E_D)) || (cntr1_>=5) || (cntr1_<=8) || (cntr2_en) || (cntr2_!=0) )
begin
	FIFO4_<=FIFO3_;
	FIFO3_<=FIFO2_;
	FIFO2_<=FIFO1_;
	FIFO1_<=FIFO0_;
	FIFO0_<=DATA_IN;
end

//////////////////////////////////////////////////////////////////////

always@(posedge CLK or negedge RESET)

if (!RESET)
begin

	SYND1_<=0;
	SYND2_<=0;

end

else if ( !DATA_VALID_IN ) 
begin
	if (cntr1_==0)
	begin
		SYND1_<=DATA_IN;
		SYND2_<=DATA_IN;
	end	
	else 
	begin
		SYND1_<=SYND1_^ DATA_IN;
		SYND2_<=ADD3_^ DATA_IN;
	end
end		
else if ( (cntr1_==3) || (cntr1_==4) )

	begin
		SYND1_<=SYND1_^ ADD3_;
		SYND2_<=0;
	end


//////////////////////////////////////////////////////////////////////

always@(posedge CLK or negedge RESET)

if (!RESET)

	cntr2_en<=0;

else if (cntr1_==8)

	cntr2_en<=1;

else

	cntr2_en<=0;



endmodule


/******************************************************************/
/*
This stimulus file 
- Creates 256^3 message symbols,  
- Encodes these message symbols into codewords
- Then decodes them 
- And compares the decoded message to the original message.
- I there is a mismatch then the ERR output of the stimulus file is SET for 1 clock cycle.
*/




module stimulus(
CLK, 
RESET,
DATA_VALID_IN,
DATA_IN,
E_D,
ERR,  
DATA_VALID_OUT,
DATA_OUT);



input DATA_VALID_OUT;
input [7:0] DATA_OUT;
output CLK, RESET, E_D, DATA_VALID_IN;
output [7:0] DATA_IN;
output ERR;

reg ERR;
reg [7:0] c4, c3, c2, c1, c0;
reg CLK, RESET, E_D, DATA_VALID_IN;
reg [7:0] DATA_IN;

integer i, j, k;

RS_5_3_GF256	u0_(
.CLK(CLK),
.RESET(RESET),
.DATA_VALID_IN(DATA_VALID_IN),
.DATA_IN(DATA_IN),
.E_D(E_D),
.DATA_OUT(DATA_OUT),
.DATA_VALID_OUT(DATA_VALID_OUT));


/////////////////////////	CLK SIGNAL	///////////////////////

initial CLK <= 0;
always 
begin
	#50
	CLK <= !CLK;
end


/////////////////////////	RESET SIGNAL	///////////////////////

initial 
begin
	RESET <= 0;
	#500
	RESET <= 1;
end 


/////////////////////////	DATA_VALID_IN & DATA_IN & E_D	///////////////////////

initial 
begin
DATA_VALID_IN<=1;
E_D<=1;
DATA_IN<=0;
ERR<=0;
#1000

for (i = 80; i < 256; i = i+1)
	for (j = 0; j < 256; j = j+1)
		for (k = 0; k < 256; k = k+1)
		begin
			#100
			#100
			#100
			#100
			#100
			#100
			#100
			#100
			#100
			DATA_VALID_IN<=0;
			E_D<=1;
			DATA_IN<=i;
			#100
			DATA_IN<=j;
			#100
			DATA_IN<=k;
			#100
			DATA_IN<=0;
			DATA_VALID_IN<=1;
			#100
			#100
			#100
			#100
			#100
			#100
			#100
			#100
			#100
			#100
			DATA_VALID_IN<=0;
			E_D<=0;
			DATA_IN<=c4;
			#100
			DATA_IN<=c3;
			#100
			DATA_IN<=c2;
			#100
			DATA_IN<=c1;
			#100
			DATA_IN<=c0;
			#100
			DATA_VALID_IN<=1;

			#150
			if (DATA_OUT!=i)	begin ERR<=1; end
			#100
			if (DATA_OUT!=j)	begin ERR<=1; end
			#100
			if (DATA_OUT!=k)	begin ERR<=1; end
			#50
			ERR<=0;
			
		end
end


			
			
			
		

always@(posedge CLK or negedge RESET)

if (!RESET)
begin
c0<=0;
c1<=0;
c2<=0;
c3<=0;
c4<=0;
end
else if (!DATA_VALID_OUT)	
begin
c0<=DATA_OUT;
c1<=c0;
c2<=c1;
c3<=c2;
c4<=c3;
end




/////////////////////



///////////////////////////////////////////////////////////////// DEC 2





	

always
begin
	#1000000000
	$finish;
end
endmodule	

	
	
	
