// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation  
// All rights reserved
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
module altera_tse_lvds_reset_sequencer (
	clk,
	reset,
	rx_locked,
	rx_channel_data_align,
    pll_areset,
	rx_reset,
	rx_cda_reset
	);

	input		clk;
	input		reset;
	input		rx_locked;
	output		rx_channel_data_align;
	output		pll_areset;
	output		rx_reset; 
	output		rx_cda_reset;

	reg			rx_channel_data_align;
	reg			pll_areset;
	reg			rx_reset;
	reg			rx_cda_reset;
	
	wire			rx_locked_sync;
	reg			rx_locked_sync_d1;
	reg			rx_locked_sync_d2;
	reg			rx_locked_sync_d3;
	reg			rx_locked_stable;

	reg [2:0]   pulse_count;
	
	reg [2:0]	state;
	reg [2:0]	nextstate;
	
	// State Definitions
	parameter [2:0] stm_idle			= 3'b000; //0
	parameter [2:0] stm_pll_areset		= 3'b001; //1
	parameter [2:0] stm_rx_reset		= 3'b010; //2
	parameter [2:0] stm_rx_cda_reset	= 3'b011; //3
	parameter [2:0] stm_word_alignment	= 3'b100; //4
	
	altera_std_synchronizer #(2) rx_locked_altera_std_synchronizer (
		.clk ( clk ), 
		.reset_n ( ~reset ), 
		.din ( rx_locked ), 
		.dout ( rx_locked_sync )
	);
	
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1'b1) begin
			rx_locked_sync_d1 <= 1'b0;
			rx_locked_sync_d2 <= 1'b0;		
			rx_locked_sync_d3 <= 1'b0;
		end
		else begin
			rx_locked_sync_d1 <= rx_locked_sync;
			rx_locked_sync_d2 <= rx_locked_sync_d1;		
			rx_locked_sync_d3 <= rx_locked_sync_d2; 
		end
	end
	
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1'b1) begin
			rx_locked_stable <= 1'b0;
		end
		else begin
			rx_locked_stable <= rx_locked_sync & rx_locked_sync_d1 & rx_locked_sync_d2 & rx_locked_sync_d3;
		end
	end
	
	
	// FSM
	always @ (posedge clk or posedge reset)
	begin
		if (reset == 1'b1) begin
			state <= stm_pll_areset;    
		end
		else begin
			state <= nextstate;   
		end
	end
   
	always @ (*) 
	begin
    case (state) 
	stm_idle:
		if (reset == 1'b1) begin
			nextstate = stm_pll_areset;
		end
		else begin
			nextstate = stm_idle;
		end
	stm_pll_areset:
		begin
			nextstate = stm_rx_reset;
		end
	stm_rx_reset:
		if (rx_locked_stable == 1'b0) begin
			nextstate = stm_rx_reset;
		end
		else begin
			nextstate = stm_rx_cda_reset;
		end
	stm_rx_cda_reset:
        begin
			nextstate = stm_word_alignment;
		end
    stm_word_alignment:
		if (pulse_count == 4) begin
			nextstate = stm_idle;
		end
		else begin
			nextstate = stm_word_alignment; 
		end    
	default: 
		begin
			nextstate = stm_idle;
		end
	endcase
	end
	
	always @ (posedge clk or posedge reset) 
	begin
		if (reset == 1'b1) begin
			pll_areset <= 1'b1;
			rx_reset <= 1'b1;
			rx_cda_reset <= 1'b0;
            rx_channel_data_align <= 1'b0;
            pulse_count <= 3'b000;
		end	
		else begin
		case (nextstate)
		stm_idle: 
			begin
				pll_areset <= 1'b0;
				rx_reset <= 1'b0;
				rx_cda_reset <= 1'b0; 
                rx_channel_data_align <= 1'b0;
                pulse_count <= 3'b000;
			end
		stm_pll_areset:
			begin
				pll_areset <= 1'b1;				
				rx_reset <= 1'b1;
				rx_cda_reset <= 1'b0;
                rx_channel_data_align <= 1'b0;
                pulse_count <= 3'b000;
			end
		stm_rx_reset:
			begin
				pll_areset <= 1'b0;
				rx_cda_reset <= 1'b0;
                rx_channel_data_align <= 1'b0;
                pulse_count <= 3'b000;
			end
		stm_rx_cda_reset:
			begin
				pll_areset <= 1'b0;
				rx_reset <= 1'b0;
				rx_cda_reset <= 1'b1;
                rx_channel_data_align <= 1'b0;
                pulse_count <= 3'b000;
			end
        stm_word_alignment:
			begin
				pll_areset <= 1'b0;
				rx_reset <= 1'b0;
				rx_cda_reset <= 1'b0;
                rx_channel_data_align <= ~rx_channel_data_align;
                pulse_count <= pulse_count +1'b1;
			end        
		default: 
			begin
				pll_areset <= 1'b0;
				rx_reset <= 1'b0;
				rx_cda_reset <= 1'b0;
                rx_channel_data_align <= 1'b0;
                pulse_count <= 3'b000;
			end
		endcase
		end
	end
	
endmodule
