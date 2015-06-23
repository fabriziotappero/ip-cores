//----------------------------------------------------------------------------
// Wishbone DDR Controller
// 
// (c) Joerg Bornschein (<jb@capsec.org>)
//----------------------------------------------------------------------------
`include "ddr_include.v"

module ddr_init 
#(
	parameter               wait200_init = 26
) (
	input                   clk, 
	input                   reset,
	input                   pulse78,
	output                  wait200,
	output                  init_done,
	//
	output                  mngt_req,
	input                   mngt_ack,
	output [`CBA_RNG]       mngt_cba       // CMD, BA and ADDRESS
);

reg              cmd_req_reg;
reg [`CMD_RNG]   cmd_cmd_reg;
reg [ `BA_RNG]   cmd_ba_reg;
reg [  `A_RNG]   cmd_a_reg;
reg [7:0]        cmd_idle_reg;

//---------------------------------------------------------------------------
// Initial 200us delay
//---------------------------------------------------------------------------

// `define WAIT200_INIT 26
// `define WAIT200_INIT 1

reg [4:0] wait200_counter;
reg       wait200_reg;

always @(posedge clk)
begin
	if (reset) begin
		wait200_reg     <= 1;
		wait200_counter <= wait200_init;
	end else begin
		if (wait200_counter == 0)
			wait200_reg <= 0;

		if (wait200_reg & pulse78)
			wait200_counter <= wait200_counter - 1;
	end
end

assign wait200 = wait200_reg;

//----------------------------------------------------------------------------
// DDR Initialization State Machine
//----------------------------------------------------------------------------

parameter s_wait200 = 0;
parameter s_init1   = 1;
parameter s_init2   = 2;
parameter s_init3   = 3;
parameter s_init4   = 4;
parameter s_init5   = 5;
parameter s_init6   = 6;
parameter s_waitack = 7;
parameter s_idle    = 8;

reg [3:0]        state;
reg              init_done_reg;

assign mngt_cba     = {cmd_cmd_reg, cmd_ba_reg, cmd_a_reg};
assign mngt_req     = cmd_req_reg;
assign mngt_pri_req = ~init_done_reg;
assign init_done    = init_done_reg;

always @(posedge clk or posedge reset)
begin
	if (reset) begin
		init_done_reg <= 0;
		state         <= s_wait200;
		cmd_idle_reg  <= 0;
		cmd_req_reg   <= 0;
		cmd_cmd_reg   <= 'b0;
		cmd_ba_reg    <= 'b0;
		cmd_a_reg     <= 'b0;
	end else begin
		case (state)
			s_wait200: begin
				if (~wait200_reg) begin
						state         <= s_init1;
						cmd_req_reg   <= 1;
						cmd_cmd_reg   <= `DDR_CMD_PRE;   // PRE ALL
						cmd_a_reg[10] <= 1'b1;
					end
				end
			s_init1: begin
					if (mngt_ack) begin
						state         <= s_init2;
						cmd_req_reg   <= 1;
						cmd_cmd_reg   <= `DDR_CMD_MRS;   // EMRS
						cmd_ba_reg    <= 2'b01;
						cmd_a_reg     <= `DDR_INIT_EMRS;
					end
				end
			s_init2: begin
					if (mngt_ack) begin
						state         <= s_init3;
						cmd_req_reg   <= 1;
						cmd_cmd_reg   <= `DDR_CMD_MRS;   // MRS
						cmd_ba_reg    <= 2'b00;
						cmd_a_reg     <= `DDR_INIT_MRS1;
					end
				end
			s_init3: begin
					if (mngt_ack) begin
						state         <= s_init4;
						cmd_req_reg   <= 1;
						cmd_cmd_reg   <= `DDR_CMD_PRE;   // PRE ALL
						cmd_a_reg[10] <= 1'b1;
					end
				end
			s_init4: begin
					if (mngt_ack) begin
						state         <= s_init5;
						cmd_req_reg   <= 1;
						cmd_cmd_reg   <= `DDR_CMD_AR;   // AR
					end
				end
			s_init5: begin
					if (mngt_ack) begin
						state         <= s_init6;
						cmd_req_reg   <= 1;
						cmd_cmd_reg   <= `DDR_CMD_AR;   // AR
					end
				end
			s_init6: begin
					if (mngt_ack) begin
						init_done_reg <= 1;
						state         <= s_waitack;
						cmd_req_reg   <= 1;
						cmd_cmd_reg   <= `DDR_CMD_MRS;  // MRS
						cmd_ba_reg    <= 2'b00;
						cmd_a_reg     <= `DDR_INIT_MRS2;
					end
				end
			s_waitack: begin
					if (mngt_ack) begin
						state         <= s_idle;
						cmd_req_reg   <= 0;
						cmd_cmd_reg   <= 'b0;
						cmd_ba_reg    <= 'b0;
						cmd_a_reg     <= 'b0;
					end
				end
			s_idle: begin
				end
		endcase ///////////////////////////////////////// INIT STATE MACHINE ///
	end
end


endmodule

