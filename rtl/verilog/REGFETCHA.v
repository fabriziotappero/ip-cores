// ============================================================================
//  REGFETCHA
//  - fetch register value into 'A' side ALU
//
//
//  (C) 2009-2012  Robert Finch
//  Stratford
//  robfinch[remove]@opencores.org
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
// ============================================================================
//
REGFETCHA:
	begin
		a <= rrro;
		state <= EXECUTE;
	end
