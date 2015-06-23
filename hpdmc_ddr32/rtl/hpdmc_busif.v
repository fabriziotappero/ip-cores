/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/* Simple FML interface for HPDMC */

module hpdmc_busif #(
	parameter sdram_depth = 26
) (
	input sys_clk,
	input sdram_rst,
	
	input [sdram_depth-1:0] fml_adr,
	input fml_stb,
	input fml_we,
	output fml_ack,
	
	output mgmt_stb,
	output mgmt_we,
	output [sdram_depth-3-1:0] mgmt_address, /* in 64-bit words */
	input mgmt_ack,
	
	input data_ack
);

reg mgmt_stb_en;

assign mgmt_stb = fml_stb & mgmt_stb_en;
assign mgmt_we = fml_we;
assign mgmt_address = fml_adr[sdram_depth-1:3];

assign fml_ack = data_ack;

always @(posedge sys_clk) begin
	if(sdram_rst)
		mgmt_stb_en = 1'b1;
	else begin
		if(mgmt_ack)
			mgmt_stb_en = 1'b0;
		if(data_ack)
			mgmt_stb_en = 1'b1;
	end
end

endmodule
