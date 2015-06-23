// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// MEMORY.v - memory operate instructions
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================
//
MEMORY1:
	begin
		case(mopcode)
		`LW:	begin
				fc_o <= {sf,2'b01};
				cyc_o <= 1'b1;
				stb_o <= 1'b1;
				sel_o <= 4'b1111;
				adr_o <= ea;
				state <= MEMORY1_ACK;
				end
		`LH,`LHU:
				begin
				fc_o <= {sf,2'b01};
				cyc_o <= 1'b1;
				stb_o <= 1'b1;
				sel_o <= ea[1] ? 4'b1100 : 4'b0011;
				adr_o <= ea;
				state <= MEMORY1_ACK;
				end
		`LB,`LBU:
				begin
				fc_o <= {sf,2'b01};
				cyc_o <= 1'b1;
				stb_o <= 1'b1;
				case(ea[1:0])
				2'd0:	sel_o <= 4'b0001;
				2'd1:	sel_o <= 4'b0010;
				2'd2:	sel_o <= 4'b0100;
				2'd3:	sel_o <= 4'b1000;
				endcase
				adr_o <= ea;
				state <= MEMORY1_ACK;
				end
		`SW:	begin
				fc_o <= {sf,2'b01};
				cyc_o <= 1'b1;
				stb_o <= 1'b1;
				we_o <= 1'b1;
				sel_o <= 4'b1111;
				adr_o <= ea;
				dat_o <= b;
				state <= MEMORY1_ACK;
				end
		`SH:	begin
				fc_o <= {sf,2'b01};
				cyc_o <= 1'b1;
				stb_o <= 1'b1;
				we_o <= 1'b1;
				sel_o <= ea[1] ? 4'b1100 : 4'b0011;
				adr_o <= ea;
				dat_o <= {2{b[15:0]}};
				state <= MEMORY1_ACK;
				end
		`SB:	begin
				fc_o <= {sf,2'b01};
				cyc_o <= 1'b1;
				stb_o <= 1'b1;
				we_o <= 1'b1;
				case(ea[1:0])
				2'd0:	sel_o <= 4'b0001;
				2'd1:	sel_o <= 4'b0010;
				2'd2:	sel_o <= 4'b0100;
				2'd3:	sel_o <= 4'b1000;
				endcase
				adr_o <= ea;
				dat_o <= {4{b[7:0]}};
				state <= MEMORY1_ACK;
				end
		endcase
	end
MEMORY1_ACK:
	if (ack_i) begin
		case(mopcode)
		`LW:	begin
				cyc_o <= 1'b0;
				stb_o <= 1'b0;
				sel_o <= 4'b0000;
				res <= dat_i;
				state <= WRITEBACK;
				end
		`LH:	begin
				cyc_o <= 1'b0;
				stb_o <= 1'b0;
				sel_o <= 4'b0000;
				if (sel_o==4'b0011)
					res <= {{16{dat_i[15]}},dat_i[15:0]};
				else
					res <= {{16{dat_i[31]}},dat_i[31:16]};
				state <= WRITEBACK;
				end
		`LHU:	begin
				cyc_o <= 1'b0;
				stb_o <= 1'b0;
				sel_o <= 4'b0000;
				if (sel_o==4'b0011)
					res <= {16'd0,dat_i[15:0]};
				else
					res <= {16'd0,dat_i[31:16]};
				state <= WRITEBACK;
				end
		`LB:	begin
				cyc_o <= 1'b0;
				stb_o <= 1'b0;
				sel_o <= 4'b0000;
				case(sel_o)
				4'b0001:	res <= {{24{dat_i[7]}},dat_i[7:0]};
				4'b0010:	res <= {{24{dat_i[15]}},dat_i[15:8]};
				4'b0100:	res <= {{24{dat_i[23]}},dat_i[23:16]};
				4'b1000:	res <= {{24{dat_i[31]}},dat_i[31:24]};
				endcase
				state <= WRITEBACK;
				end
		`LBU:	begin
				cyc_o <= 1'b0;
				stb_o <= 1'b0;
				sel_o <= 4'b0000;
				case(sel_o)
				4'b0001:	res <= {24'd0,dat_i[7:0]};
				4'b0010:	res <= {24'd0,dat_i[15:8]};
				4'b0100:	res <= {24'd0,dat_i[23:16]};
				4'b1000:	res <= {24'd0,dat_i[31:24]};
				endcase
				state <= WRITEBACK;
				end
		`SW,`SH,`SB:
				begin
				cyc_o <= 1'b0;
				stb_o <= 1'b0;
				we_o <= 1'b0;
				sel_o <= 4'b0000;
				state <= IFETCH;
				end
		endcase
	end

TAS:
	if (!cyc_o) begin
		fc_o <= {sf,2'b01};
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= ea;
	end
	else if (ack_i) begin
		cyc_o <= ~dat_i[31];
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		res <= dat_i;
		state <= TAS2;
	end
TAS2:
	if (!res[31]) begin
		if (!stb_o) begin
			fc_o <= {sf,2'b01};
			cyc_o <= 1'b1;
			stb_o <= 1'b1;
			we_o <= 1'b1;
			sel_o <= 4'b1111;
			adr_o <= ea;
			dat_o <= {1'b1,res[30:0]};
		end
		else if (ack_i) begin
			cyc_o <= 1'b0;
			stb_o <= 1'b0;
			we_o <= 1'b0;
			sel_o <= 4'b0000;
			state <= WRITEBACK;
		end
	end
	else begin
		cyc_o <= 1'b0;
		state <= WRITEBACK;
	end

