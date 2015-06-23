// ============================================================================
//  FETCH_DISP8
//  - fetch 8 bit displacement
//
//
//  2009-2012  Robert Finch
//  robfinch<remove>@opencores.org
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
//  - fetch 8 bit displacement
// ============================================================================
//
FETCH_DISP8:
	if (!cyc_o) begin
		`INITIATE_CODE_READ
	end
	else if (ack_i) begin
		`TERMINATE_CODE_READ
		state <= DECODE;
		disp16 <= {{8{dat_i[7]}},dat_i};
		hasFetchedDisp8 <= 1'b1;
	end
