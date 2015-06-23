////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// Color scheme conversion				 		////
////									////
//// TODO:								////
//// - Maybe less colors will be used					////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////

// note: this converts 7 ypbpr bits into 24 rgb bits. In order to use less rgb bits just use the most significant ones.

`include "timescale.v"

module video_converter(ypbpr, rgb);

input [6:0] ypbpr;
output reg [23:0] rgb;

always @(*) begin
	case (ypbpr[2:0]) // luminance
		3'h0: begin 
			case (ypbpr[6:3])
				4'h0: rgb = 24'h000000;
				4'h1: rgb = 24'h444400;
				4'h2: rgb = 24'h702800;
				4'h3: rgb = 24'h841800;
				4'h4: rgb = 24'h880000;
				4'h5: rgb = 24'h78005C;
				4'h6: rgb = 24'h480078;
				4'h7: rgb = 24'h140084;
				4'h8: rgb = 24'h000088;
				4'h9: rgb = 24'h00187C;
				4'hA: rgb = 24'h002C5C;
				4'hB: rgb = 24'h003C2C;
				4'hC: rgb = 24'h003C00;
				4'hD: rgb = 24'h143800;
				4'hE: rgb = 24'h2C3000;
				4'hF: rgb = 24'h442800;
			endcase
		end
		3'h1: begin 
			case (ypbpr[6:3])
				4'h0: rgb = 24'h404040;
				4'h1: rgb = 24'h646410;
				4'h2: rgb = 24'h844414;
				4'h3: rgb = 24'h983418;
				4'h4: rgb = 24'h9C2020;
				4'h5: rgb = 24'h8C2074;
				4'h6: rgb = 24'h602090;
				4'h7: rgb = 24'h302098;
				4'h8: rgb = 24'h1C209C;
				4'h9: rgb = 24'h1C3890;
				4'hA: rgb = 24'h1C4C78;
				4'hB: rgb = 24'h1C5C48;
				4'hC: rgb = 24'h205C20;
				4'hD: rgb = 24'h345C1C;
				4'hE: rgb = 24'h4C501C;
				4'hF: rgb = 24'h644818;
			endcase
		end
		3'h2: begin 
			case (ypbpr[6:3])
				4'h0: rgb = 24'h6C6C6C;
				4'h1: rgb = 24'h848424;
				4'h2: rgb = 24'h985C28;
				4'h3: rgb = 24'hAC5030;
				4'h4: rgb = 24'hB03C3C;
				4'h5: rgb = 24'hA03C88;
				4'h6: rgb = 24'h783CA4;
				4'h7: rgb = 24'h4C3CAC;
				4'h8: rgb = 24'h3840B0;
				4'h9: rgb = 24'h3854A8;
				4'hA: rgb = 24'h386890;
				4'hB: rgb = 24'h387C64;
				4'hC: rgb = 24'h407C40;
				4'hD: rgb = 24'h507C38;
				4'hE: rgb = 24'h687034;
				4'hF: rgb = 24'h846830;
			endcase
		end
		3'h3: begin 
			case (ypbpr[6:3])
				4'h0: rgb = 24'h909090;
				4'h1: rgb = 24'hA0A034;
				4'h2: rgb = 24'hAC783C;
				4'h3: rgb = 24'hC06848;
				4'h4: rgb = 24'hC05858;
				4'h5: rgb = 24'hB0589C;
				4'h6: rgb = 24'h8C58B8;
				4'h7: rgb = 24'h6858C0;
				4'h8: rgb = 24'h505CC0;
				4'h9: rgb = 24'h5070BC;
				4'hA: rgb = 24'h5084AC;
				4'hB: rgb = 24'h509C80;
				4'hC: rgb = 24'h5C9C5C;
				4'hD: rgb = 24'h6C9850;
				4'hE: rgb = 24'h848C4C;
				4'hF: rgb = 24'hA08444;
			endcase
		end
		3'h4: begin 
			case (ypbpr[6:3])
				4'h0: rgb = 24'hB0B0B0;
				4'h1: rgb = 24'hB8B840;
				4'h2: rgb = 24'hBC8C4C;
				4'h3: rgb = 24'hD0805C;
				4'h4: rgb = 24'hD07070;
				4'h5: rgb = 24'hC070B0;
				4'h6: rgb = 24'hA070CC;
				4'h7: rgb = 24'h7C70D0;
				4'h8: rgb = 24'h6874D0;
				4'h9: rgb = 24'h6888CC;
				4'hA: rgb = 24'h689CC0;
				4'hB: rgb = 24'h68B494;
				4'hC: rgb = 24'h74B474;
				4'hD: rgb = 24'h84B468;
				4'hE: rgb = 24'h9CA864;
				4'hF: rgb = 24'hB89C58;
			endcase
		end
		3'h5: begin 
			case (ypbpr[6:3])
				4'h0: rgb = 24'hC8C8C8;
				4'h1: rgb = 24'hD0D050;
				4'h2: rgb = 24'hCCA05C;
				4'h3: rgb = 24'hE09470;
				4'h4: rgb = 24'hE08888;
				4'h5: rgb = 24'hD084C0;
				4'h6: rgb = 24'hB484DC;
				4'h7: rgb = 24'h9488E0;
				4'h8: rgb = 24'h7C8CE0;
				4'h9: rgb = 24'h7C9CDC;
				4'hA: rgb = 24'h7CB4D4;
				4'hB: rgb = 24'h7CD0AC;
				4'hC: rgb = 24'h8CD08C;
				4'hD: rgb = 24'h9CCC7C;
				4'hE: rgb = 24'hB4C078;
				4'hF: rgb = 24'hD0B46C;
			endcase
		end
		3'h6: begin 
			case (ypbpr[6:3])
				4'h0: rgb = 24'hDCDCDC;
				4'h1: rgb = 24'hE8E85C;
				4'h2: rgb = 24'hDCB468;
				4'h3: rgb = 24'hECA880;
				4'h4: rgb = 24'hECA0A0;
				4'h5: rgb = 24'hDC9CD0;
				4'h6: rgb = 24'hC49CEC;
				4'h7: rgb = 24'hA8A0EC;
				4'h8: rgb = 24'h90A4EC;
				4'h9: rgb = 24'h90B4EC;
				4'hA: rgb = 24'h90CCE8;
				4'hB: rgb = 24'h90E4C0;
				4'hC: rgb = 24'hA4E4A4;
				4'hD: rgb = 24'hB4E490;
				4'hE: rgb = 24'hCCD488;
				4'hF: rgb = 24'hE8CC7C;
			endcase
		end
		3'h7: begin 
			case (ypbpr[6:3])
				4'h0: rgb = 24'hECECEC;
				4'h1: rgb = 24'hFCFC68;
				4'h2: rgb = 24'hECC878;
				4'h3: rgb = 24'hFCBC94;
				4'h4: rgb = 24'hFCB4B4;
				4'h5: rgb = 24'hECB0E0;
				4'h6: rgb = 24'hD4B0FC;
				4'h7: rgb = 24'hBCB4FC;
				4'h8: rgb = 24'hA4B8FC;
				4'h9: rgb = 24'hA4C8FC;
				4'hA: rgb = 24'hA4E0FC;
				4'hB: rgb = 24'hA4FCD4;
				4'hC: rgb = 24'hB8FCB8;
				4'hD: rgb = 24'hC8FCA4;
				4'hE: rgb = 24'hE0EC9C;
				4'hF: rgb = 24'hFCE08C;
			endcase
		end
	endcase
end
endmodule

