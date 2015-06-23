//=============================================================================
//  2009,2010,2012 Robert Finch
//  Stratford
//  robfinch<remove>@opencores.org
//
//  WRITE_BACK state
//  - update the register file
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
//=============================================================================
//
if (wrregs)
	case({w,rrr})
	4'b0000:	ax[7:0] <= res[7:0];
	4'b0001:	cx[7:0] <= res[7:0];
	4'b0010:	dx[7:0] <= res[7:0];
	4'b0011:	bx[7:0] <= res[7:0];
	4'b0100:	ax[15:8] <= res[7:0];
	4'b0101:	cx[15:8] <= res[7:0];
	4'b0110:	dx[15:8] <= res[7:0];
	4'b0111:	bx[15:8] <= res[7:0];
	4'b1000:	ax <= res;
	4'b1001:	cx <= res;
	4'b1010:	dx <= res;
	4'b1011:	begin bx <= res; $display("BX <- %h", res); end
	4'b1100:	sp <= res;
	4'b1101:	bp <= res;
	4'b1110:	si <= res;
	4'b1111:	di <= res;
	endcase

// Write to segment register
//
if (wrsregs)
	case(rrr)
	3'd0:	es <= res;
	3'd1:	cs <= res;
	3'd2:	ss <= res;
	3'd3:	ds <= res;
	default:	;
	endcase
