//=============================================================================
//  CMPSW
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
//
//=============================================================================
//
CMPSW:
`include "check_for_ints.v"
	else begin
		cyc_type <= `CT_RDMEM;
		lock_o <= 1'b0;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= {seg_reg,4'b0} + si;
		state <= CMPSW1;
	end
CMPSW1:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		stb_o <= 1'b0;
		if (df) begin
			si <= si_dec;
			a[15:8] <= dat_i;
		end
		else begin
			si <= si_inc;
			a[ 7:0] <= dat_i;
		end
		state <= CMPSW2;
	end
CMPSW2:
	if (!stb_o) begin
		cyc_type <= `CT_RDMEM;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= {seg_reg,4'b0} + si;
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		if (df) begin
			si <= si_dec;
			a[7:0] <= dat_i;
		end
		else begin
			si <= si_inc;
			a[15:8] <= dat_i;
		end
		state <= CMPSW3;
	end
CMPSW3:
	if (!cyc_o) begin
		cyc_type <= `CT_RDMEM;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		adr_o <= esdi;
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		stb_o <= 1'b0;
		if (df) begin
			di <= di_dec;
			b[15:8] <= dat_i;
		end
		else begin
			di <= di_inc;
			b[ 7:0] <= dat_i;
		end
		state <= CMPSW4;
	end
CMPSW4:
	if (!stb_o) begin
		cyc_type <= `CT_RDMEM;
		lock_o <= 1'b0;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= esdi;
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		if (df) begin
			di <= di_dec;
			b[7:0] <= dat_i;
		end
		else begin
			di <= di_inc;
			b[15:8] <= dat_i;
		end
		state <= CMPSW5;
	end
CMPSW5:
	begin
		pf <= pres;
		zf <= reszw;
		sf <= resnw;
		af <= carry   (1'b1,a[3],b[3],alu_o[3]);
		cf <= carry   (1'b1,a[15],b[15],alu_o[15]);
		vf <= overflow(1'b1,a[15],b[15],alu_o[15]);
		if ((repz & !cxz & zf) | (repnz & !cxz & !zf)) begin
			cx <= cx_dec;
			state <= CMPSW;
		end
		else
			state <= IFETCH;
	end

