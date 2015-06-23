`include "irda_defines.v"
// Interrupt and DMA module
module irda_interrupts (clk, wb_rst_i, f_ier, rxfifo_trigger_level, txfifo_trigger_level,  rxfifo_count,
			u_int_o, int_o, f_iir, fir_sto_detected, mir_sto_detected,
			crc32_error, mir_crc_error, rxfifo_overrun, rx_error,
			txfifo_count, txfifo_underrun, fir_state, mir_state, mir_mode, f_iir_read,
			use_dma, dma_req_t_o, dma_ack_t_i, dma_req_r_o, dma_ack_r_i);

input				clk;
input				wb_rst_i;
input	[6:0]		f_ier;
input [`IRDA_FIFO_POINTER_W:0] rxfifo_count;
input [`IRDA_FIFO_POINTER_W:0] txfifo_count;
input				u_int_o;
input [1:0]		rxfifo_trigger_level;
input				fir_sto_detected;
input				mir_sto_detected;
input				mir_crc_error;
input				crc32_error;
input				rxfifo_overrun;
input				rx_error; // is fir_rx_error | mir_rx_error
input				txfifo_underrun;
input	[1:0]		txfifo_trigger_level;
input	[2:0]		fir_state;
input	[2:0]		mir_state;
input				mir_mode;
input				f_iir_read;
input				use_dma;
output			dma_req_t_o;
input				dma_ack_t_i;
output			dma_req_r_o;
input				dma_ack_r_i;
output			int_o;
output [7:0]	f_iir;

wire	[`IRDA_FIFO_POINTER_W:0]	txfifo_count;
wire	[`IRDA_FIFO_POINTER_W:0]	rxfifo_count;
wire	[2:0]		fir_state;
wire	[2:0]		mir_state;

reg	[7:0]		f_iir;
reg				int_o;
reg				dma_req_t_o; // when transmitter is low
reg				dma_req_r_o; // when receiver is filled

reg	rxfifo_trigger_active;
reg	rxfifo_trigger_active_delay;
// the interrupt signal for bit 0 of IIR
wire	rxfifo_trigger_int = rxfifo_trigger_active_delay & rxfifo_trigger_active;

// receiver fifo trigger level reached signal (bit 0 of IIR)
always @(rxfifo_trigger_level or rxfifo_count)
begin
	case (rxfifo_trigger_level)
		2'b00 : rxfifo_trigger_active = (rxfifo_count >= 8);
		2'b01 : rxfifo_trigger_active = (rxfifo_count >= 10);
		2'b10 : rxfifo_trigger_active = (rxfifo_count >= 12);
		2'b11 : rxfifo_trigger_active = (rxfifo_count >= 14);
	endcase
end

// delay flipflop for rise detection on rxfifo_trigger_active signal for interrupt generation
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		rxfifo_trigger_active_delay <= #1 0;
	end else begin
		rxfifo_trigger_active_delay <= #1 ~rxfifo_trigger_active;
	end
end

// bit 1 of IIR (End of frame detected)
wire	sto_detected = fir_sto_detected | mir_sto_detected;
reg	sto_detected_delay;
wire	sto_detected_int = sto_detected & sto_detected_delay;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		sto_detected_delay <= #1 0;
	end else begin
		sto_detected_delay <= #1 ~sto_detected;
	end
end

// bit 2 of IIR (CRC check error). Cleared on read.
wire	crc_error = mir_crc_error | crc32_error;
reg	crc_error_delay;
wire	crc_error_int = crc_error_delay & crc_error;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		crc_error_delay <= #1 0;
	end else begin
		crc_error_delay <= #1 ~crc_error;
	end
end

// bit 3 of IIR (RX fifo overrun). Cleared on read.
reg rxfifo_overrun_delay;
wire rxfifo_overrun_int = rxfifo_overrun & rxfifo_overrun_delay;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		rxfifo_overrun_delay <= #1 0;
	end else begin
		rxfifo_overrun_delay <= #1 ~rxfifo_overrun;
	end
end

// bit 4 of IIR (Receiver error). Cleared on read.
reg rx_error_delay;
wire rx_error_int = rx_error & rx_error_delay;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		rx_error_delay <= #1 0;
	end else begin
		rx_error_delay <= #1 ~rx_error;
	end
end


// bit 5 of IIR (low TX fifo level)
reg	txfifo_trigger_active;
reg	txfifo_trigger_active_delay;
// the interrupt signal for bit 0 of IIR
wire	txfifo_trigger_int = txfifo_trigger_active_delay & txfifo_trigger_active;

// receiver fifo trigger level reached signal (bit 0 of IIR)
always @(txfifo_trigger_level or txfifo_count)
begin
	case (txfifo_trigger_level)
		2'b00 : txfifo_trigger_active = (txfifo_count <= 2);
		2'b01 : txfifo_trigger_active = (txfifo_count <= 4);
		2'b10 : txfifo_trigger_active = (txfifo_count <= 6);
		2'b11 : txfifo_trigger_active = (txfifo_count <= 8);
	endcase
end

// delay flipflop for rise detection on txfifo_trigger_active signal for interrupt generation
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		txfifo_trigger_active_delay <= #1 0;
	end else begin
		txfifo_trigger_active_delay <= #1 ~txfifo_trigger_active;
	end
end

// bit 6 of IIR (Transmitter underrun). Clear on read.
reg txfifo_underrun_delay;
wire txfifo_underrun_int = txfifo_underrun & txfifo_underrun_delay;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		txfifo_underrun_delay <= #1 0;
	end else begin
		txfifo_underrun_delay <= #1 ~txfifo_underrun;
	end
end

// bit 7 of IIR (Controller busy - idle or sending sip).
wire tx_busy = ! ( (~mir_mode && (fir_state == 0 | fir_state == 7 ) ) ||
						 ( mir_mode && (mir_state == 0 | mir_state == 6 ) ) );

// Status (IIR) register (f_iir)

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		f_iir <= #1 0;
	end else	if (f_iir_read) begin
		f_iir <= #1 f_iir & 8'b10100001;
	end else begin
		f_iir[7] <= #1 tx_busy;
		f_iir[6] <= #1 f_iir[6] | txfifo_underrun;
		f_iir[5] <= #1 txfifo_trigger_active;
		f_iir[4] <= #1 f_iir[4] | rx_error;
		f_iir[3] <= #1 f_iir[3] | rxfifo_overrun;
		f_iir[2] <= #1 f_iir[2] | crc_error;
		f_iir[1] <= #1 f_iir[1] | sto_detected;
		f_iir[0] <= #1 rxfifo_trigger_active;
	end
end

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		int_o <= #1 0;
	end else begin
		int_o <= #1 u_int_o  | (f_ier[0] & rxfifo_trigger_int )
									| (f_ier[1] & sto_detected_int )
									| (f_ier[2] & crc_error_int )
									| (f_ier[3] & rxfifo_overrun_int)
									| (f_ier[4] & rx_error_int)
									| (f_ier[5] & txfifo_trigger_int)
									| (f_ier[6] & txfifo_underrun_int);
	end
end

/////////////////
//  DMA logic  //
/////////////////

// request for DMA to supply new data to TX fifo
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		dma_req_t_o <= #1 0;
	end else if (use_dma) begin
		if (txfifo_underrun_int)
			dma_req_t_o <= #1 1;
		else if (dma_ack_t_i)
			dma_req_t_o <= #1 0;
	end else
		dma_req_t_o <= #1 0;
end

// request for DMA to read recived data from RX fifo
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		dma_req_r_o <= #1 0;
	end else if (use_dma) begin
		if (rxfifo_trigger_int)
			dma_req_r_o <= #1 1;
		else if (dma_ack_r_i)
			dma_req_r_o <= #1 0;
	end else
		dma_req_r_o <= #1 0;
end

endmodule
