// ============================================================================
//  IRET
//  - return from interrupt
//
//
//  2009-2012  Robert Finch
//  robfinch@opencores.org
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
//
//  Verilog 
//
//  IRET: return from interrupt
//  Fetch cs:ip from stack
//  pop ip
//  pop cs
//  pop flags
// ============================================================================
//
IRET1:
	begin
		`INITIATE_STACK_POP
		state <= IRET2;
	end
IRET2:
	if (ack_i) begin
		`PAUSE_STACK_POP
		ip[7:0] <= dat_i;
		state <= IRET3;
	end
IRET3:
	begin
		`CONTINUE_STACK_POP
		state <= IRET4;
	end
IRET4:
	if (ack_i) begin
		`PAUSE_STACK_POP
		ip[15:8] <= dat_i;
		state <= IRET5;
	end
IRET5:
	begin
		`CONTINUE_STACK_POP
		state <= IRET6;
	end
IRET6:
	if (ack_i) begin
		`PAUSE_STACK_POP
		cs[7:0] <= dat_i;
		state <= IRET7;
	end
IRET7:
	begin
		`CONTINUE_STACK_POP
		state <= IRET8;
	end
IRET8:
	if (ack_i) begin
		`PAUSE_STACK_POP
		cs[15:8] <= dat_i;
		state <= IRET9;
	end
IRET9:
	begin
		`CONTINUE_STACK_POP
		state <= IRET10;
	end
IRET10:
	if (ack_i) begin
		`PAUSE_STACK_POP
		cf <= dat_i[0];
		pf <= dat_i[2];
		af <= dat_i[4];
		zf <= dat_i[6];
		sf <= dat_i[7];
		state <= IRET11;
	end
IRET11:
	begin
		`CONTINUE_STACK_POP
		state <= IRET12;
	end
IRET12:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		sp    <= sp_inc;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		tf <= dat_i[0];
		ie <= dat_i[1];
		df <= dat_i[2];
		vf <= dat_i[3];
		state <= IFETCH;
	end
