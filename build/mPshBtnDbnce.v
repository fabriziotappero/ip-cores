/*
Copyright © 2012 JeffLieu-lieumychuong@gmail.com

	This file is part of SGMII-IP-Core.
    SGMII-IP-Core is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SGMII-IP-Core is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SGMII-IP-Core.  If not, see <http://www.gnu.org/licenses/>.

File		:	sgmii_demo.v
Description	:	This file implements top-level file to test SGMII core

Remarks		:

Revision	:
	Date	Author	Description

*/	

module mPshBtnDbnce #(parameter pDbncePeriod=8191,pDbncerWidth=13)(
	input i_Clk,
	input i_PshBtn,
	output reg o_Dbnced);

	
	reg r_PshBtnIn_D1;
	reg r_PshBtnIn_D2;
	reg r_PshBtnIn_D3;
	reg [pDbncerWidth-1:0] rv_Dbncer;
	
	always@(posedge i_Clk)
		begin 
			r_PshBtnIn_D1 <= i_PshBtn;
			r_PshBtnIn_D2 <= r_PshBtnIn_D1;
		    r_PshBtnIn_D3 <= r_PshBtnIn_D2;
			
			if(r_PshBtnIn_D3^r_PshBtnIn_D2) rv_Dbncer <= pDbncePeriod;
			else begin 
				if(~(|rv_Dbncer)) rv_Dbncer<=rv_Dbncer-1;
				else o_Dbnced <= r_PshBtnIn_D3;
				end			
		end
endmodule

