// ============================================================================
//  2009-2012 Robert T Finch
//  robfinch<remove>@opencores.org
// 
//  Bus cycle type definitions
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

`define CT_INTA		3'd0
`define CT_RDIO		3'd1
`define CT_WRIO		3'd2
`define CT_HALT		3'd3
`define CT_CODE		3'd4
`define CT_RDMEM	3'd5
`define CT_WRMEM	3'd6
`define CT_PASSIVE	3'd7
