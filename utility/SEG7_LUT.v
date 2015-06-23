
module dbg_7seg ( val, show_next, part, is_first );

input wire [ 63 :0 ] val;
input wire show_next;
output wire [15:0]part= curr[1]==0 ?
									( curr[0]==0 ? val[15:0] : val[31:16] ) :
									( curr[0]==0 ? val[47:32] : val[63:48] );
output wire is_first= (curr==0);


reg [1:0] curr;
initial curr= 0;

always @(posedge show_next)
begin
	curr <= curr+1;
end

endmodule

module SEG7_LUT_4 (	oSEG0,oSEG1,oSEG2,oSEG3,iDIG );
input	[15:0]	iDIG;
output	[6:0]	oSEG0,oSEG1,oSEG2,oSEG3;

SEG7_LUT	u0	(	oSEG0,iDIG[3:0]	);
SEG7_LUT	u1	(	oSEG1,iDIG[7:4]	);
SEG7_LUT	u2	(	oSEG2,iDIG[11:8]	);
SEG7_LUT	u3	(	oSEG3,iDIG[15:12]	);

endmodule

module SEG7_LUT	(	oSEG,iDIG	);
input	[3:0]	iDIG;
output reg	[6:0]	oSEG;

always @(iDIG)
begin
		case(iDIG)
		4'h1: oSEG = 7'b1111001;	// ---t----
		4'h2: oSEG = 7'b0100100; 	// |	  |
		4'h3: oSEG = 7'b0110000; 	// lt	 rt
		4'h4: oSEG = 7'b0011001; 	// |	  |
		4'h5: oSEG = 7'b0010010; 	// ---m----
		4'h6: oSEG = 7'b0000010; 	// |	  |
		4'h7: oSEG = 7'b1111000; 	// lb	 rb
		4'h8: oSEG = 7'b0000000; 	// |	  |
		4'h9: oSEG = 7'b0011000; 	// ---b----
		4'ha: oSEG = 7'b0001000;
		4'hb: oSEG = 7'b0000011;
		4'hc: oSEG = 7'b1000110;
		4'hd: oSEG = 7'b0100001;
		4'he: oSEG = 7'b0000110;
		4'hf: oSEG = 7'b0001110;
		4'h0: oSEG = 7'b1000000;
		endcase
end

endmodule
