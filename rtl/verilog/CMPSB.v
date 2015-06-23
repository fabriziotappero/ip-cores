//=============================================================================
//  CMPSB
//
//
//  2009-2013 Robert Finch
//  Stratford
//  robfinch<remove>@finitron.ca
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
//=============================================================================
//
CMPSB:
	begin
		read(`CT_RDMEM,{seg_reg,`SEG_SHIFT} + si);
		lock_o <= 1'b0;
		state <= CMPSB1;
	end
CMPSB1:
	if (ack_i) begin
		nack();
		state <= CMPSB2;
		lock_o <= 1'b0;
		a[ 7:0] <= dat_i[7:0];
		a[15:8] <= {8{dat_i[7]}};
	end
CMPSB2:
	begin
		state <= CMPSB3;
		read(`CT_RDMEM,esdi);
		lock_o <= 1'b0;
	end
CMPSB3:
	if (ack_i) begin
		nack();
		state <= CMPSB4;
		lock_o <= 1'b0;
		b[ 7:0] <= dat_i[7:0];
		b[15:8] <= {8{dat_i[7]}};
	end
CMPSB4:
	begin
		pf <= pres;
		zf <= reszb;
		sf <= resnb;
		af <= carry   (1'b1,a[3],b[3],alu_o[3]);
		cf <= carry   (1'b1,a[7],b[7],alu_o[7]);
		vf <= overflow(1'b1,a[7],b[7],alu_o[7]);
		if (df) begin
			si <= si_dec;
			di <= di_dec;
		end
		else begin
			si <= si_inc;
			di <= di_inc;
		end
		if ((repz & !cxz & zf) | (repnz & !cxz & !zf)) begin
			cx <= cx_dec;
			ip <= ir_ip;
			state <= IFETCH;
		end
		else
			state <= IFETCH;
	end

