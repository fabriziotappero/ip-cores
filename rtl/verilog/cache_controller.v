// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
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
// ============================================================================
//
// Cache controller
// Also takes care of loading the instruction buffer for non-cached access
//
`ifdef SUPPORT_DCACHE
DCACHE1:
	begin
		isDataCacheLoad <= `TRUE;
		if (isRMW)
			lock_o <= 1'b1;
		wb_burst(6'd3,{radr[31:2],4'h0});
		state <= LOAD_DCACHE;
	end
LOAD_DCACHE:
	if (ack_i) begin
		if (adr_o[3:2]==2'b10)
			cti_o <= 3'b111;
		if (adr_o[3:2]==2'b11) begin
			dmiss <= `FALSE;
			isDataCacheLoad <= `FALSE;
			wb_nack();
			state <= retstate;
		end
		adr_o[3:2] <= adr_o[3:2] + 2'd1;
	end
`ifdef SUPPORT_BERR
	else if (err_i) begin
		if (adr_o[3:2]==2'b10)
			cti_o <= 3'b111;
		if (adr_o[3:2]==2'b11) begin
			dmiss <= `FALSE;
			isDataCacheLoad <= `FALSE;
			wb_nack();
			// The state machine will be waiting for a dhit.
			// Override the next state and send the processor to the bus error state.
			intno <= 9'd508;
			state <= BUS_ERROR;
		end
		derr_address <= adr_o[33:2];
		adr_o[3:2] <= adr_o[3:2] + 2'd1;
	end
`endif
`endif
`ifdef SUPPORT_ICACHE
ICACHE1:
	if (!hit0) begin
		isInsnCacheLoad <= `TRUE;
		wb_burst(6'd3,{pc[31:4],4'h0});
		state <= LOAD_ICACHE;
	end
	else if (!hit1) begin
		isInsnCacheLoad <= `TRUE;
		wb_burst(6'd3,{pcp8[31:4],4'h0});
		state <= LOAD_ICACHE;
	end
	else
		state <= ic_whence;	// return to where we came from
LOAD_ICACHE:
	if (ack_i) begin
		if (adr_o[3:2]==2'b10)
			cti_o <= 3'b111;
		if (adr_o[3:2]==2'b11) begin
			isInsnCacheLoad <= `FALSE;
			wb_nack();
`ifdef ICACHE_2WAY
			clfsr <= {clfsr,clfsr_fb};
`endif
			state <= ICACHE1;
		end
		adr_o[3:2] <= adr_o[3:2] + 2'd1;
	end
`ifdef SUPPORT_BERR
	else if (err_i) begin
		if (adr_o[3:2]==2'b10)
			cti_o <= 3'b111;
		if (adr_o[3:2]==2'b11) begin
			isInsnCacheLoad <= `FALSE;
			wb_nack();
			derr_address <= 32'd0;
			intno <= 9'd509;
			state <= BUS_ERROR;
`ifdef ICACHE_2WAY
			clfsr <= {clfsr,clfsr_fb};
`endif
		end
		adr_o[3:2] <= adr_o[3:2] + 2'd1;
	end
`endif
`endif

LOAD_IBUF1:
	if (!cyc_o) begin
		// Emulation mode never needs to read more than two words.
		// Native mode might need up to three words.
		wb_burst((em ? 6'd1: 6'd2),{pc[31:2],2'b00});
	end
	else if (ack_i|err_i) begin
		if (em)
			cti_o <= 3'b111;
		case(pc[1:0])
		2'd0:	ibuf <= dat_i;
		2'd1:	ibuf <= dat_i[31:8];
		2'd2:	ibuf <= dat_i[31:16];
		2'd3:	ibuf <= dat_i[31:24];
		endcase
		state <= LOAD_IBUF2;
	end
LOAD_IBUF2:
	if (ack_i|err_i) begin
		state <= ic_whence==BYTE_IFETCH ? BYTE_IFETCH : LOAD_IBUF3;
		case(pc[1:0])
		2'd0:	ibuf[55:32] <= dat_i[23:0];
		2'd1:	ibuf[55:24] <= dat_i;
		2'd2:	ibuf[47:16] <= dat_i;
		2'd3:	ibuf[39:8] <= dat_i;
		endcase
		if (em) begin
			wb_nack();
			if (err_i) begin
				derr_address <= 32'd0;
				intno <= 9'd509;
				state <= BUS_ERROR;
			end
			bufadr <= pc;	// clears the miss
		end
		else
			cti_o <= 3'b111;
	end
LOAD_IBUF3:
	if (ack_i) begin
		wb_nack();
		case(pc[1:0])
		2'd0:	;
		2'd1:	;
		2'd2:	ibuf[55:48] <= dat_i[7:0];
		2'd3:	ibuf[55:40] <= dat_i[15:0];
		endcase
		state <= IFETCH;
		bufadr <= pc;	// clears the miss
	end
`ifdef SUPPORT_BERR
	else if (err_i) begin
		wb_nack();
		case(pc[1:0])
		2'd0:	;
		2'd1:	;
		2'd2:	ibuf[55:48] <= dat_i[7:0];
		2'd3:	ibuf[55:40] <= dat_i[15:0];
		endcase
		derr_address <= 32'd0;
		intno <= 9'd509;
		state <= BUS_ERROR;
		bufadr <= pc;	// clears the miss
	end
`endif
