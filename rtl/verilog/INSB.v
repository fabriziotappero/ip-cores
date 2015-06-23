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
INSB:
`include "check_for_ints.v"
	else if (repdone)
		state <= IFETCH;
	else if (!cyc_o) begin
		cyc_type <= `CT_RDIO;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		adr_o <= {`SEG_SHIFT,dx};
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		res[7:0] <= dat_i;
		state <= INSB2;
	end
INSB2:
	if (!cyc_o) begin
		cyc_type <= `CT_WRMEM;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		adr_o <= esdi;
		dat_o <= res[7:0];
		we_o <= 1'b1;
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		if (df)
			di <= di - 16'd1;
		else
			di <= di + 16'd1;
		if (repz|repnz) cx <= cx_dec;
		state <= repz|repnz ? INSB : IFETCH;
	end
