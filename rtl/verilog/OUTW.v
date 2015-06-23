//=============================================================================
//  OUTW
//  - output word data to IO.
//
//
//  2009,2010 Robert Finch
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
//=============================================================================
//
OUTW:	// Entry point for OUT port,AX
	begin
		`INITIATE_CODE_READ
		state <= OUTW_NACK;
	end
OUTW_NACK:
	if (ack_i) begin
		`TERMINATE_CODE_READ
		ea <= {12'h000,dat_i};
		state <= OUTW1;
	end
OUTW1:	// Entry point for OUT [DX],AX
	begin
		cyc_type <= `CT_WRIO;
		lock_o <= 1'b1;
		mio_o <= 1'b0;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= ea;
		dat_o <= al;
		state <= OUTW1_NACK;
	end
OUTW1_NACK:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		state <= OUTW2;
	end
OUTW2:
	begin
		cyc_type <= `CT_WRIO;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= ea_inc;
		dat_o <= ah;
		state <= OUTW2_NACK;
	end
OUTW2_NACK:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		lock_o <= 1'b0;
		mio_o <= 1'b1;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		state <= IFETCH;
	end

