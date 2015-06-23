// ============================================================================
//        __
//   \\__/ o\    (C) 2013,2014  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
`ifdef SUPPORT_STRING
MVN3:
	begin
		next_state(IFETCH);
		res <= alu_out;
		if (&acc)
			pc <= pc + pc_inc;
	end
CMPS1:
	begin
		next_state(IFETCH);
		res <= alu_out;
		if (a!=b || &acc) begin
			cf <= !(ltu|eq);
			nf <= lt;
			vf <= 1'b0;
			zf <= eq;
			pc <= pc + pc_inc;
		end
	end
`endif
`ifdef SUPPORT_816
MVN816:
	begin
		next_state(BYTE_IFETCH);
		if (&acc[15:0]) begin
			pc <= pc + pc_inc8;
			dbr <= ir[15:8];
		end
	end
`endif
