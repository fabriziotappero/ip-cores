module ssram_test(
	input clk,
	input reset_n,
	
	// ssram
	output reg [18:0] ssram_address,
	output reg ssram_oe_n,
	output reg ssram_writeen_n,
	output reg [3:0] ssram_byteen_n,
	output ssram_adsp_n,
	output ssram_clk,
	output ssram_globalw_n,
	output reg ssram_advance_n,
	output reg ssram_adsc_n,
	output ssram_ce1_n,
	output ssram_ce2,
	output ssram_ce3_n,
	inout [35:0] ssram_data,
	
	output [7:0] debug
);

assign debug = { 3'd0, state };

assign ssram_clk = clk;
assign ssram_globalw_n = 1'b1;
assign ssram_adsp_n = 1'b1;
assign ssram_ce1_n = 1'b0;
assign ssram_ce2 = 1'b1;
assign ssram_ce3_n = 1'b0;

reg ssram_data_oe;
reg [35:0] ssram_data_reg;
assign ssram_data = (ssram_data_oe == 1'b1) ? ssram_data_reg : 36'bZ;

reg [4:0] state;
parameter [4:0]
	S_IDLE = 5'd0,
	S_W1 = 5'd1,
	S_W2 = 5'd2,
	S_W3 = 5'd3,
	S_W4 = 5'd4,
	S_W5 = 5'd5,
	S_W6 = 5'd6,
	S_IDLE2 = 5'd7,
	S_R1 = 5'd8,
	S_R2 = 5'd9,
	S_R3 = 5'd10,
	S_R4 = 5'd11,
	S_R5 = 5'd12,
	S_R6 = 5'd13,
	S_R7 = 5'd14,
	S_R8 = 5'd15,
	S_R9 = 5'd16,
	S_IDLE3 = 5'd17,
	S_IDLE4 = 5'd18;

altsyncram debug_ram_inst(
	.clock0(clk),

	.address_a({3'b0, state}),
	.wren_a(state < 5'd17),
	.data_a(ssram_data),
	.q_a()
);
defparam 
    debug_ram_inst.operation_mode = "SINGLE_PORT",
    debug_ram_inst.width_a = 36,
    debug_ram_inst.widthad_a = 8,
    debug_ram_inst.lpm_hint = "ENABLE_RUNTIME_MOD=YES,INSTANCE_NAME=vgadeb";

	
always @(posedge clk or negedge reset_n) begin
	if(reset_n == 1'b0) begin
		ssram_address <= 19'd0;
		ssram_adsc_n <= 1'b1;
		ssram_advance_n <= 1'b1;
		ssram_data_reg <= 36'd0;
		ssram_data_oe <= 1'b0;
		ssram_oe_n <= 1'b1;
		ssram_writeen_n <= 1'b1;
		ssram_byteen_n <= 4'b1111;
		
		state <= S_IDLE;
	end
	else begin
		case(state)
			S_IDLE: begin
				ssram_address <= 19'd0;
				ssram_adsc_n <= 1'b1;
				ssram_advance_n <= 1'b1;
				ssram_data_reg <= 36'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen_n <= 4'b1111;
				
				state <= S_R1;
			end
			S_W1: begin
				// address, byte enables and write enables output
				ssram_address <= 19'h23600;
				ssram_adsc_n <= 1'b0;
				ssram_advance_n <= 1'b1;
				ssram_data_reg <= { 4'b0, 32'hC1000008 };
				ssram_data_oe <= 1'b1;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b0;
				ssram_byteen_n <= 4'b0000;
				
				state <= S_W2;
			end
			S_W2: begin
				ssram_adsc_n <= 1'b1;
				ssram_advance_n <= 1'b0;
				ssram_data_reg <= { 4'b0, 32'hC2000007 };
				
				state <= S_W3;
			end
			S_W3: begin
				ssram_data_reg <= { 4'b0, 32'hC3000006 };
				
				state <= S_W4;
			end
			S_W4: begin
				ssram_data_reg <= { 4'b0, 32'hC4000005 };
				
				state <= S_W5;
			end
			S_W5: begin
				ssram_address <= 19'h23604;
				ssram_adsc_n <= 1'b0;
				ssram_advance_n <= 1'b1;
				ssram_data_reg <= { 4'b0, 32'hC5000004 };
				
				state <= S_W6;
			end
			S_W6: begin
				ssram_adsc_n <= 1'b1;
				ssram_advance_n <= 1'b0;
				ssram_data_reg <= { 4'b0, 32'hC6000003 };
				
				state <= S_IDLE2;
			end
			
			S_IDLE2: begin
				ssram_address <= 19'd0;
				ssram_adsc_n <= 1'b1;
				ssram_advance_n <= 1'b1;
				ssram_data_reg <= 32'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen_n <= 4'b1111;
				
				state <= S_R1;
			end
			S_R1: begin
				// address and byte enables output
				ssram_address <= 19'h2D800; //19'd0;
				ssram_adsc_n <= 1'b0;
				ssram_advance_n <= 1'b1;
				ssram_data_reg <= 32'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen_n <= 4'b0000;
				
				state <= S_R2;
			end
			S_R2: begin
				// address and byte enables latched
				ssram_adsc_n <= 1'b1;
				ssram_advance_n <= 1'b0;
				
				state <= S_R3;
			end
			S_R3: begin
				// output enable output
				ssram_oe_n <= 1'b0;
				
				state <= S_R4;
			end
			S_R4: begin
				// save data output
				//if(ssram_data[31:0] == { 4'b0, 32'hC1000000 })
					state <= S_R5;
				//else
				//	state <= S_IDLE4;
			end
			S_R5: begin
				ssram_address <= 19'h2D804;//19'd4;
				ssram_adsc_n <= 1'b0;
				ssram_advance_n <= 1'b1;
				
				//if(ssram_data[31:0] == { 4'b0, 32'hC2000000 })
					state <= S_R6;
				//else
				//	state <= S_IDLE4;
			end
			S_R6: begin
				ssram_adsc_n <= 1'b1;
				ssram_advance_n <= 1'b0;
				
				//if(ssram_data[31:0] == { 4'b0, 32'hC3000000 })
					state <= S_R7;
				//else
				//	state <= S_IDLE4;
			end
			S_R7: begin
				//if(ssram_data[31:0] == { 4'b0, 32'hC4000000 })
					state <= S_R8;
				//else
				//	state <= S_IDLE4;
			end
			S_R8: begin
				//if(ssram_data[31:0] == { 4'b0, 32'hC5000000 })
					state <= S_R9;//S_IDLE3;
				//else
				//	state <= S_IDLE4;
			end
			S_R9: begin
				state <= S_IDLE3;
			end
			S_IDLE3: begin
				ssram_address <= 19'd0;
				ssram_adsc_n <= 1'b1;
				ssram_advance_n <= 1'b1;
				ssram_data_reg <= 32'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen_n <= 4'b1111;
			end
			S_IDLE4: begin
				ssram_address <= 19'd0;
				ssram_adsc_n <= 1'b1;
				ssram_advance_n <= 1'b1;
				ssram_data_reg <= 32'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen_n <= 4'b1111;
			end
		endcase
	end
end

endmodule


/*
// TEST: with static adsc_n and adsp_n -> can not write 2-burst
module ssram_test(
	input clk,
	input reset_n,
	
	// ssram
	output reg [18:0] ssram_address,
	output reg ssram_oe_n,
	output reg ssram_writeen_n,
	output reg [3:0] ssram_byteen_n,
	output ssram_adsp_n,
	output ssram_clk,
	output ssram_globalw_n,
	output ssram_advance_n,
	output ssram_adsc_n,
	output ssram_ce1_n,
	output ssram_ce2,
	output ssram_ce3_n,
	inout [35:0] ssram_data,
	
	output [7:0] debug
);

assign debug = DAT_I[31:24];

assign ssram_clk = clk;
assign ssram_globalw_n = 1'b1;
assign ssram_adsp_n = 1'b1;
assign ssram_ce1_n = 1'b0;
assign ssram_ce2 = 1'b1;
assign ssram_ce3_n = 1'b0;
assign ssram_advance_n = 1'b1;
assign ssram_adsc_n = 1'b1;

reg ssram_data_oe;
reg [35:0] ssram_data_reg;
assign ssram_data = (ssram_data_oe == 1'b1) ? ssram_data_reg : 36'bZ;

reg [31:0] DAT_I;

reg [3:0] state;
parameter [3:0]
	S_IDLE = 4'd0,
	S_W1 = 4'd1,
	S_W2 = 4'd2,
	S_W3 = 4'd3,
	S_W4 = 4'd4,
	S_W5 = 4'd5,
	S_IDLE2 = 4'd6,
	S_R1 = 4'd7,
	S_R2 = 4'd8,
	S_R3 = 4'd9,
	S_R4 = 4'd10,
	S_IDLE3 = 4'd11;

	always @(posedge clk or negedge reset_n) begin
	if(reset_n == 1'b0) begin
		ssram_address <= 19'd0;
		ssram_data_reg <= 36'd0;
		ssram_data_oe <= 1'b0;
		ssram_oe_n <= 1'b1;
		ssram_writeen_n <= 1'b1;
		ssram_byteen_n <= 4'b1111;
		
		DAT_I <= 32'd0;
		state <= S_IDLE;
	end
	else begin
		case(state)
			S_IDLE: begin
				ssram_address <= 19'd0;
				ssram_data_reg <= 36'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen_n <= 4'b1111;
				
				state <= S_W1;
			end
			S_W1: begin
				// address, byte enables and write enables output
				ssram_address <= 19'd0;
				ssram_data_reg <= 36'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b0;
				ssram_byteen_n <= 4'b0000;
				
				state <= S_W2;
			end
			S_W2: begin
				// address, byte enables and write enables latched
				ssram_data_reg <= { 4'b0, 32'h71000000 };
				ssram_data_oe <= 1'b1;
				
				ssram_address <= 19'd1;
				
				state <= S_W3;
			end
			S_W3: begin
				state <= S_W4;
			end
			S_W4: begin
				ssram_data_reg <= { 4'b0, 32'h72000000 };
				
				state <= S_IDLE2;
			end
			
			S_IDLE2: begin
				ssram_address <= 19'd0;
				ssram_data_reg <= 32'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen_n <= 4'b1111;
				
				state <= S_R1;
			end
			S_R1: begin
				// address and byte enables output
				ssram_address <= 19'd0;
				ssram_data_reg <= 32'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen_n <= 4'b0000;
				
				state <= S_R2;
			end
			S_R2: begin
				// address and byte enables latched
				state <= S_R3;
			end
			S_R3: begin
				// output enable output
				ssram_oe_n <= 1'b0;
				
				state <= S_R4;
			end
			S_R4: begin
				// save data output
				DAT_I <= ssram_data[31:0];
				
				state <= S_IDLE3;
			end
			S_IDLE3: begin
				ssram_address <= 19'd0;
				ssram_data_reg <= 32'd0;
				ssram_data_oe <= 1'b0;
				ssram_oe_n <= 1'b1;
				ssram_writeen_n <= 1'b1;
				ssram_byteen_n <= 4'b1111;
			end
		endcase
	end
end

endmodule
*/