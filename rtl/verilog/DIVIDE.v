//============================================================================
//  DIVIDE.v
//
//  (C) 2009-2012 Robert Finch
//  Stratford
//  robfinch<remove>@opencores.org
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
//=============================================================================
//
// Check for divide by zero
// Load the divider
DIVIDE1:
	begin
		state <= DIVIDE2;
		// Check for divide by zero
		if (w) begin
			if (b[15:0]==16'h0000) begin
				$display("Divide by zero");
				int_num <= 8'h00;
				state <= INT2;
			end
			else
				ld_div32 <= 1'b1;
		end
		else begin
			if (b[7:0]==8'h00) begin
				$display("Divide by zero");
				int_num <= 8'h00;
				state <= INT2;
			end
			else
				ld_div16 <= 1'b1;
		end
	end
DIVIDE2:
	begin
		$display("DIVIDE2");
		ld_div32 <= 1'b0;
		ld_div16 <= 1'b0;
		state <= DIVIDE2a;
	end
DIVIDE2a:
	begin
		$display("DIVIDE2a");
		if (w & div32_done)
			state <= DIVIDE3;
		else if (!w & div16_done)
			state <= DIVIDE3;
	end

// Assign results to registers
// Trap on divider overflow
DIVIDE3:
	begin
		$display("DIVIDE3 state <= IFETCH");
		state <= IFETCH;
		if (w) begin
			ax <= q32[15:0];
			dx <= r32[15:0];
			if (TTT[0]) begin
				if (q32[31:16]!={16{q32[15]}}) begin
					$display("DIVIDE Overflow");
					int_num <= 8'h00;
					state <= INT2;
				end
			end
			else begin
				if (q32[31:16]!=16'h0000) begin
					$display("DIVIDE Overflow");
					int_num <= 8'h00;
					state <= INT2;
				end
			end
		end
		else begin
			ax[ 7:0] <= q16[7:0];
			ax[15:8] <= r16;
			if (TTT[0]) begin
				if (q16[15:8]!={8{q16[7]}}) begin
					$display("DIVIDE Overflow");
					int_num <= 8'h00;
					state <= INT2;
				end
			end
			else begin
				if (q16[15:8]!=8'h00) begin
					$display("DIVIDE Overflow");
					int_num <= 8'h00;
					state <= INT2;
				end
			end
		end
	end
