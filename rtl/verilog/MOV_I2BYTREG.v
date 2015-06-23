// ============================================================================
//  MOV_I2BYTREG.v
//
//
//  2009,2010,2012  Robert Finch
//  robfinch[remove]@opencores.org
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
//  Verilog 
//
// ============================================================================
//
MOV_I2BYTREG:
	if (ack_i) begin
		`TERMINATE_CODE_READ
		w <= 1'b0;				// select byte size
		rrr <= ir[2:0];
		res <= {8'h00,dat_i};
		wrregs <= 1'b1;
		state <= IFETCH;
	end
