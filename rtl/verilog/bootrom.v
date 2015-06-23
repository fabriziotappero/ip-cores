module bootrom(cyc, stb, adr, o, acko);
input cyc;
input stb;
input [19:0] adr;
output [7:0] o;
reg [7:0] o;
output acko;

wire cs = cyc && stb && adr[19:12]==8'hFF;
assign acko = cs;

reg [7:0] mem [256:2047];
integer i;

initial begin
	$readmemh("c:\\emu8086\\MyBuild\\test1.hex", mem);
	for (i = 256; i < 264; i = i + 1)
		$display("%h:%h ", i, mem[i]);

//	mem[0] = 8'hb8;		// MOV AX,0
//	mem[1] = 8'h00;
//	mem[2] = 8'h00;
//	
//	// Move to segment register
//	mem[3] = 8'h8e;		// MOV DS,AX
//	mem[4] = 8'hd8;
//	mem[5] = 8'h8e;		// MOV SS,AX
//	mem[6] = 8'hd0;
//
//	// Move immediate to register
//	mem[7] = 8'hbb;		// MOV BX,128
//	mem[8] = 8'h80;
//	mem[9] = 8'h00;
//	mem[10] = 8'hbe;		// MOV SI,1
//	mem[11] = 8'h01;
//	mem[12] = 8'h00;
//	mem[13] = 8'hbf;		// MOV DI,2
//	mem[14] = 8'h02;
//	mem[15] = 8'h00;
//	mem[16] = 8'hbd;		// MOV BP,768
//	mem[17] = 8'h00;
//	mem[18] = 8'h03;
//
//	// Displacement is zero
//	mem[19] = 8'hc6;	// MOV [BX+SI],1
//	mem[20] = 8'h00;
//	mem[21] = 8'h01;
//	mem[22] = 8'hc6;	// MOV [BX+DI],2
//	mem[23] = 8'h01;
//	mem[24] = 8'h02;
//	mem[25] = 8'hc6;	// MOV [BP+SI],3
//	mem[26] = 8'h02;
//	mem[27] = 8'h03;
//	mem[28] = 8'hc6;	// MOV [BP+DI],4
//	mem[29] = 8'h03;
//	mem[30] = 8'h04;
//	mem[31] = 8'hc6;	// MOV [SI],5
//	mem[32] = 8'h04;
//	mem[33] = 8'h05;
//	mem[34] = 8'hc6;	// MOV [DI],6
//	mem[35] = 8'h05;
//	mem[36] = 8'h06;
//	mem[37] = 8'hc6;	// MOV 0400,7
//	mem[38] = 8'h06;
//	mem[39] = 8'h07;
//	mem[40] = 8'h00;
//	mem[41] = 8'h04;
//	mem[42] = 8'hc6;	// MOV [BX],8
//	mem[43] = 8'h07;
//	mem[44] = 8'h08;
//
//	// Displacement is a single byte
//	mem[45] = 8'hc6;	// MOV [BX+SI+10],1
//	mem[46] = 8'h40;
//	mem[47] = 8'h0A;
//	mem[48] = 8'h01;
//	mem[49] = 8'hc6;	// MOV [BX+DI+10],2
//	mem[50] = 8'h41;
//	mem[51] = 8'h0A;
//	mem[52] = 8'h02;
//	mem[53] = 8'hc6;	// MOV [BP+SI+10],3
//	mem[54] = 8'h42;
//	mem[55] = 8'h0A;
//	mem[56] = 8'h03;
//	mem[57] = 8'hc6;	// MOV [BP+DI+10],4
//	mem[58] = 8'h43;
//	mem[59] = 8'h0A;
//	mem[60] = 8'h04;
//	mem[61] = 8'hc6;	// MOV [SI+10],5
//	mem[62] = 8'h44;
//	mem[63] = 8'h0A;
//	mem[64] = 8'h05;
//	mem[65] = 8'hc6;	// MOV [DI+10],6
//	mem[66] = 8'h45;
//	mem[67] = 8'h0A;
//	mem[68] = 8'h06;
//	mem[69] = 8'hc6;	// MOV [BP+10],7
//	mem[70] = 8'h46;
//	mem[71] = 8'h0A;
//	mem[72] = 8'h07;
//	mem[73] = 8'hc6;	// MOV [BX+10],8
//	mem[74] = 8'h47;
//	mem[75] = 8'h0A;
//	mem[76] = 8'h08;
//	
//	// Displacement is a two bytes
//	mem[77] = 8'hc6;	// MOV [BX+SI+1034],1
//	mem[78] = 8'h80;
//	mem[79] = 8'h0A;
//	mem[80] = 8'h04;
//	mem[81] = 8'h01;
//	mem[82] = 8'hc6;	// MOV [BX+DI+1034],2
//	mem[83] = 8'h81;
//	mem[84] = 8'h0A;
//	mem[85] = 8'h04;
//	mem[86] = 8'h02;
//	mem[87] = 8'hc6;	// MOV [BP+SI+1034],3
//	mem[88] = 8'h82;
//	mem[89] = 8'h0A;
//	mem[90] = 8'h04;
//	mem[91] = 8'h03;
//	mem[92] = 8'hc6;	// MOV [BP+DI+1034],4
//	mem[93] = 8'h83;
//	mem[94] = 8'h0A;
//	mem[95] = 8'h04;
//	mem[96] = 8'h04;
//	mem[97] = 8'hc6;	// MOV [SI+1034],5
//	mem[98] = 8'h84;
//	mem[99] = 8'h0A;
//	mem[100] = 8'h04;
//	mem[101] = 8'h05;
//	mem[102] = 8'hc6;	// MOV [DI+1034],6
//	mem[103] = 8'h85;
//	mem[104] = 8'h0A;
//	mem[105] = 8'h04;
//	mem[106] = 8'h06;
//	mem[107] = 8'hc6;	// MOV [BP+1034],7
//	mem[108] = 8'h86;
//	mem[109] = 8'h0A;
//	mem[110] = 8'h04;
//	mem[111] = 8'h07;
//	mem[112] = 8'hc6;	// MOV [BX+1034],8
//	mem[113] = 8'h87;
//	mem[114] = 8'h0A;
//	mem[115] = 8'h04;
//	mem[116] = 8'h08;
//
//	mem[117] = 8'h90;	// NOP
//	mem[118] = 8'h90;
//	mem[119] = 8'h90;
//	
//	mem[120] = 8'hb8;	// MOV AX,1
//	mem[121] = 8'h01;
//	mem[122] = 8'h00;
//	mem[123] = 8'hbb;	// MOV BX,2
//	mem[124] = 8'h02;
//	mem[125] = 8'h00;
//	mem[126] = 8'hb9;	// MOV CX,3
//	mem[127] = 8'h03;
//	mem[128] = 8'h00;
//	mem[129] = 8'hba;	// MOV DX,4
//	mem[130] = 8'h04;
//	mem[131] = 8'h00;
//	mem[132] = 8'hbc;	// MOV SP,128
//	mem[133] = 8'h80;
//	mem[134] = 8'h00;
//	mem[135] = 8'hbd;	// MOV BP,6
//	mem[136] = 8'h06;
//	mem[137] = 8'h00;
//	mem[138] = 8'hbe;	// MOV SI,7
//	mem[139] = 8'h07;
//	mem[140] = 8'h00;
//	mem[141] = 8'hbf;	// MOV DI,8
//	mem[142] = 8'h08;
//	mem[143] = 8'h00;
//	mem[144] = 8'h50;	// PUSH AX
//	mem[145] = 8'h51;	// PUSH CX
//	mem[146] = 8'h52;	// PUSH DX
//	mem[147] = 8'h53;	// PUSH BX
//	mem[148] = 8'h54;	// PUSH SP
//	mem[149] = 8'h55;	// PUSH BP
//	mem[150] = 8'h56;	// PUSH SI
//	mem[151] = 8'h57;	// PUSH DI
//	mem[152] = 8'h06;	// PUSH ES
//	mem[153] = 8'h0e;	// PUSH CS
//	mem[154] = 8'h16;	// PUSH SS
//	mem[155] = 8'h1e;	// PUSH DS
//	mem[156] = 8'h9c;	// PUSHF
//	mem[157] = 8'h90;
//	mem[158] = 8'h90;
//	mem[159] = 8'h90;
//	mem[160] = 8'hFF;	// PUSH 040B
//	mem[161] = 8'h36;
//	mem[162] = 8'h0B;
//	mem[163] = 8'h04;
//	mem[164] = 8'h90;	// NOP
//	mem[165] = 8'h8F;	// POP 040B
//	mem[166] = 8'h06;
//	mem[167] = 8'h0B;
//	mem[168] = 8'h04;
//	mem[169] = 8'h9D;	// POPF
//	mem[170] = 8'h1F;	// POP DS
//	mem[171] = 8'h17;	// POP SS
//	mem[172] = 8'h0F;	// POP CS
//	mem[173] = 8'h07;	// POP ES
//	mem[174] = 8'h5f;	// POP DI
//	mem[175] = 8'h5e;	// POP SI
//	mem[176] = 8'h5d;	// POP BP
//	mem[177] = 8'h5d;	// POP BP
//	mem[178] = 8'h5b;	// POP BX
//	mem[179] = 8'h5a;	// POP DX
//	mem[180] = 8'h59;	// POP CX
//	mem[181] = 8'h58;	// POP AX
//	
	mem[2032] = 8'hea;	// JMP FAR FF00:0100
	mem[2033] = 8'h00;
	mem[2034] = 8'h01;
	mem[2035] = 8'h00;
	mem[2036] = 8'hFF;
end

always @(adr or cs)
if (cs)
	o <= mem[adr[10:0]];
else
	o <= 8'h00;

endmodule

