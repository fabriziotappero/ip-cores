//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// CALL NEAR Indirect
//
// 2009-2012 Robert Finch
// robfinch<remove>@finitron.ca
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
CALL_IN:
	if (!cyc_o)
		write(`CT_WRMEM,sssp,ip[15:8]);
	else if (ack_i) begin
		pause_stack_push();
		state <= CALL_IN1;
	end
CALL_IN1:
	if (!stb_o)
		write(`CT_WRMEM,sssp,ip[7:0]);
	else if (ack_i) begin
		nack();
		ea <= {cs,`SEG_SHIFT}+b;
		if (mod==2'b11) begin
			ip <= b;
			state <= IFETCH;
		end
		else 
			state <= CALL_IN2;
	end
CALL_IN2:
	if (!cyc_o)
		read(`CT_RDMEM,ea);
	else if (ack_i) begin
		pause_read();
		state <= CALL_IN3;
		b[7:0] <= dat_i;
	end
CALL_IN3:
	if (!stb_o)
		read(`CT_RDMEM,ea_inc);
	else if (ack_i) begin
		nack();
		state <= CALL_IN4;
		b[15:8] <= dat_i;
	end
CALL_IN4:
	begin
		state <= IFETCH;
		ip <= b;
	end

