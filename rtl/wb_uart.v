//---------------------------------------------------------------------------
// Wishbone UARTs / PS/2 ASCII Keyboard Top-Level
//
// Register Description:
//
// KB 0x01 STATUS    [ 0 |kry| 0 | 0 | 0 | 0  | 0   |          | ~key_rdy ]
// KB 0x01 DATA      [                  KEYBOARD DATA                     ]
// U1 0x02 COND      [                       DATA                         ]
// U1 0x03 CONS      [ 0 | 0 | 0 | 0 | 0 | rx_error | rx_avail | tx_ready ]
// U2 0x04 COND      [                       DATA                         ]
// U2 0x05 CONS      [ 0 | 0 | 0 | 0 | 0 | rx_error | rx_avail | tx_ready ]
// U3 0x06 COND      [                       DATA                         ]
// U3 0x07 CONS      [ 0 | 0 | 0 | 0 | 0 | rx_error | rx_avail | tx_ready ]
//
//---------------------------------------------------------------------------

module wb_uart #(
	parameter          clk_freq = 25000000,
	parameter          baud     = 115200
) (
	input              clk,
	input              reset,
	// Wishbone interface
	input              wb_stb_i,
	input              wb_cyc_i,
	output             wb_ack_o,
	input              wb_we_i,
	input       [31:0] wb_adr_i,
	input        [3:0] wb_sel_i,
	input       [31:0] wb_dat_i,
	output reg  [31:0] wb_dat_o,
	// Serial Wires
	inout              ps2_clk,
	inout              ps2_data,
	input              uart1_rxd,
	output             uart1_txd,
	input              uart2_rxd,
	output             uart2_txd,
	input              uart3_rxd,
	output             uart3_txd
);

//---------------------------------------------------------------------------
// Actual UART engine
//---------------------------------------------------------------------------
wire [7:0] rx_data[0:3];
wire       rx_avail[0:3];
wire       rx_error[0:3];
reg        rx_ack[0:3];
wire [7:0] tx_data;
reg        tx_wr[0:3];
wire       tx_busy[0:3];


wire	rx_extended;
wire	rx_released;
wire	rx_shift_key_on;
wire	rx_ctrl_key_on;
wire	[7:0] rx_scan_code;
wire	rx_data_ready;
wire	tx_write_ack_o;
wire	tx_error_no_keyboard_ack;

// Instantiate the module
ps2_keyboard_interface #(
    .TRAP_SHIFT_KEYS_PP(1)
) ps2_kbd (
    .clk(clk), 
    .reset(reset), 
    .ps2_clk(ps2_clk), 
    .ps2_data(ps2_data), 
    .rx_extended(rx_extended), 
    .rx_released(rx_released), 
    .rx_shift_key_on(rx_shift_key_on), 
    .rx_ctrl_key_on(rx_ctrl_key_on),     
    .rx_scan_code(rx_scan_code), 
    .rx_ascii(rx_data[0]), 
    .rx_data_ready(rx_avail[0]), 
    .rx_read(rx_ack[0]), 
    .tx_data(tx_data), 
    .tx_write(tx_wr[0]), 
    .tx_write_ack_o(tx_write_ack_o), 
    .tx_error_no_keyboard_ack(tx_error_no_keyboard_ack)
    );

uart #(
	.freq_hz(   clk_freq ),
	.baud(      baud     )
) uart1 (
	.clk(       clk      ),
	.reset(     reset    ),
	//
	.uart_rxd(  uart1_rxd ),
	.uart_txd(  uart1_txd ),
	//
	.rx_data(   rx_data[1]  ),
	.rx_avail(  rx_avail[1] ),
	.rx_error(  rx_error[1] ),
	.rx_ack(    rx_ack[1]   ),
	.tx_data(   tx_data  ),
	.tx_wr(     tx_wr[1]    ),
	.tx_busy(   tx_busy[1]  )
);

uart #(
	.freq_hz(   clk_freq ),
	.baud(      baud     )
) uart2 (
	.clk(       clk      ),
	.reset(     reset    ),
	//
	.uart_rxd(  uart2_rxd ),
	.uart_txd(  uart2_txd ),
	//
	.rx_data(   rx_data[2]  ),
	.rx_avail(  rx_avail[2] ),
	.rx_error(  rx_error[2] ),
	.rx_ack(    rx_ack[2]   ),
	.tx_data(   tx_data  ),
	.tx_wr(     tx_wr[2]    ),
	.tx_busy(   tx_busy[2]  )
);

uart #(
	.freq_hz(   clk_freq ),
	.baud(      baud     )
) uart3 (
	.clk(       clk      ),
	.reset(     reset    ),
	//
	.uart_rxd(  uart3_rxd ),
	.uart_txd(  uart3_txd ),
	//
	.rx_data(   rx_data[3]  ),
	.rx_avail(  rx_avail[3] ),
	.rx_error(  rx_error[3] ),
	.rx_ack(    rx_ack[3]   ),
	.tx_data(   tx_data  ),
	.tx_wr(     tx_wr[3]    ),
	.tx_busy(   tx_busy[3]  )
);

//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------
wire    [1:0] sel_port = wb_adr_i[2:1];

wire [7:0] ucr = { 5'b0, rx_error[sel_port], rx_avail[sel_port], ~tx_busy[sel_port] };

wire	key_ready = (~rx_released) & rx_avail[0];
wire	[7:0] kbdsr = {1'b0, key_ready, 5'b0, ~key_ready};

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

reg  ack;

assign wb_ack_o       = wb_stb_i & wb_cyc_i & ack;

assign tx_data = wb_dat_i[7:0];

always @(posedge clk)
begin
	if (reset) begin
		wb_dat_o[31:8] <= 24'b0;
		tx_wr[0]  <= 0;
		rx_ack[0] <= 0;
		tx_wr[1]  <= 0;
		rx_ack[1] <= 0;
		tx_wr[2]  <= 0;
		rx_ack[2] <= 0;
		tx_wr[3]  <= 0;
		rx_ack[3] <= 0;
		ack    <= 0;
	end else begin
		wb_dat_o[31:8] <= 24'b0;
		tx_wr[0]  <= 0;
		rx_ack[0] <= 0;
		tx_wr[1]  <= 0;
		rx_ack[1] <= 0;
		tx_wr[2]  <= 0;
		rx_ack[2] <= 0;
		tx_wr[3]  <= 0;
		rx_ack[3] <= 0;
		ack    <= 0;

		if (wb_rd & ~ack) begin
			ack <= 1;

			case (wb_adr_i[2:0])
			3'b000: begin
				wb_dat_o[7:0] <= kbdsr;
			end
			3'b001: begin
				if(rx_ctrl_key_on) begin
                    wb_dat_o[7:0] <= { 2'b00, rx_data[sel_port][5:0] };
                end else begin
                    wb_dat_o[7:0] <= rx_data[sel_port];
                end
				rx_ack[sel_port]        <= 1;
			end
			3'b010: begin
				wb_dat_o[7:0] <= rx_data[sel_port];
				rx_ack[sel_port]        <= 1;
			end
			3'b011: begin
				wb_dat_o[7:0] <= ucr;
			end
			3'b100: begin
				wb_dat_o[7:0] <= rx_data[sel_port];
				rx_ack[sel_port]        <= 1;
			end
			3'b101: begin
				wb_dat_o[7:0] <= ucr;
			end
			3'b110: begin
				wb_dat_o[7:0] <= rx_data[sel_port];
				rx_ack[sel_port]        <= 1;
			end
			3'b111: begin
				wb_dat_o[7:0] <= ucr;
			end

			default: begin
				wb_dat_o[7:0] <= 8'b0;
			end
			endcase
		end else if (wb_wr & ~ack ) begin
			ack <= 1;

			if ((wb_adr_i[0] == 1'b0) && ~tx_busy[sel_port]) begin
				tx_wr[sel_port] <= 1;
			end
		end
	end
end


endmodule
