//=============================================================================
//  INTA: acknowledge interrupt
//
//
//  2009,2010,2012 Robert Finch
//  Stratford
//  robfinch<remove>opencores.org
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
// - issue two interrupt acknowledge cycles
// - one the second cycle load the interrupt number
//=============================================================================
//
INTA0:
	begin
		cyc_type <= `CT_INTA;
		inta_o <= 1'b1;
		mio_o <= 1'b0;
		lock_o <= 1'b1;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		state <= INTA1;
	end
INTA1:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		mio_o <= 1'b1;
		stb_o <= 1'b0;
		state <= INTA2;
	end
INTA2:
	begin
		cyc_type <= `CT_INTA;
		mio_o <= 1'b0;
		stb_o <= 1'b1;
		state <= INTA3;
	end
INTA3:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		inta_o <= 1'b0;
		mio_o <= 1'b1;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		int_num <= dat_i;
		state <= INT2;
	end
