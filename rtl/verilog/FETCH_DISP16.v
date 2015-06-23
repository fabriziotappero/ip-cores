// ============================================================================
//  FETCH_DISP16
//  - detch 16 bit displacement
//
//
//  2009-2013  Robert Finch
//  robfinch[remove]@finitron.ca
//  Stratford
//
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
//
//  Verilog 
//
// Fetch 16 bit displacement
// ============================================================================
//
FETCH_DISP16:
	begin
		code_read();
		state <= FETCH_DISP16_ACK;
	end

FETCH_DISP16_ACK:
	if (ack_i) begin
		state <= FETCH_DISP16a;
		pause_code_read();
		disp16[7:0] <= dat_i;
	end

FETCH_DISP16a:
	begin
		state <= FETCH_DISP16a_ACK;
		code_read();
	end

FETCH_DISP16a_ACK:
	if (ack_i) begin
		state <= FETCH_DISP16b;
		term_code_read();
		disp16[15:8] <= dat_i;
	end

FETCH_DISP16b:
	casex(ir)

	//-----------------------------------------------------------------
	// Flow control operations
	//-----------------------------------------------------------------
	`CALL: state <= CALL;
	`JMP: begin ip <= ip + disp16; state <= IFETCH; end
	`JMPS: begin ip <= ip + disp16; state <= IFETCH; end

	//-----------------------------------------------------------------
	// Memory Operations
	//-----------------------------------------------------------------
	
	`MOV_AL2M,`MOV_AX2M:
		begin
			res <= ax;
			ea <= {seg_reg,`SEG_SHIFT} + disp16;
			state <= STORE_DATA;
		end
	`MOV_M2AL,`MOV_M2AX:
		begin
			d <= 1'b0;
			rrr <= 3'd0;
			ea <= {seg_reg,`SEG_SHIFT} + disp16;
			state <= FETCH_DATA;
		end

	`MOV_MA:
		case(substate)
		FETCH_DATA:
			if (hasFetchedData) begin
				ir <= {4'b0,w,3'b0};
				wrregs <= 1'b1;
				res <= disp16;
				state <= IFETCH;
			end
		endcase

	`MOV_AM:
		begin
			w <= ir[0];
			state <= STORE_DATA;
			ea  <= {ds,`SEG_SHIFT} + disp16;
			res <= ir[0] ? {ah,al} : {al,al};
		end
	default:	state <= IFETCH;
	endcase
