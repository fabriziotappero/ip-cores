//-----------------------------------------------------
// Design Name : uart 
// File Name   : uart.v
//-----------------------------------------------------
module uart #(
	parameter          freq_hz = 100000000,
	parameter          baud    = 115200
) (
	input              reset,
	input              clk,
	// UART lines
	input              uart_rxd,
	output reg         uart_txd,
	// 
	output reg [7:0]   rx_data,
	output reg         rx_avail,
	output reg         rx_error,
	input              rx_ack,
	input      [7:0]   tx_data,
	input              tx_wr,
	output reg         tx_busy
);

parameter divisor = freq_hz/baud/16;

//-----------------------------------------------------------------
// enable16 generator
//-----------------------------------------------------------------
reg [15:0] enable16_counter;

wire    enable16;
assign  enable16 = (enable16_counter == 0);

always @(posedge clk)
begin
	if (reset) begin
		enable16_counter <= divisor-1;
	end else begin
		enable16_counter <= enable16_counter - 1;
		if (enable16_counter == 0) begin
			enable16_counter <= divisor-1;
		end
	end
end

//-----------------------------------------------------------------
// syncronize uart_rxd
//-----------------------------------------------------------------
reg uart_rxd1;
reg uart_rxd2;

always @(posedge clk)
begin
	uart_rxd1 <= uart_rxd;
	uart_rxd2 <= uart_rxd1;
end

//-----------------------------------------------------------------
// UART RX Logic
//-----------------------------------------------------------------
reg       rx_busy;
reg [3:0] rx_count16;
reg [3:0] rx_bitcount;
reg [7:0] rxd_reg;

always @ (posedge clk)
begin
	if (reset) begin
		rx_busy     <= 0;
		rx_count16  <= 0;
		rx_bitcount <= 0;
		rx_avail    <= 0;
		rx_error    <= 0;
	end else begin 
		if (rx_ack) begin
			rx_avail <= 0;
			rx_error <= 0;
		end

		if (enable16) begin
			if (!rx_busy) begin           // look for start bit
				if (!uart_rxd2) begin     //     start bit found
					rx_busy     <= 1;
					rx_count16  <= 7;
					rx_bitcount <= 0;
				end
			end else begin
				rx_count16 <= rx_count16 + 1;

				if (rx_count16 == 0) begin      // sample 
					rx_bitcount <= rx_bitcount + 1;

					if (rx_bitcount == 0) begin          // verify startbit
						if (uart_rxd2) begin
							rx_busy <= 0;
						end
					end else if (rx_bitcount == 9) begin // look for stop bit
						rx_busy <= 0;
						if (uart_rxd2) begin             //   stop bit ok
							rx_data  <= rxd_reg;
							rx_avail <= 1;
							rx_error <= 0;
						end else begin                  //   bas stop bit
							rx_error <= 1;
						end
					end else begin
						rxd_reg <= { uart_rxd2, rxd_reg[7:1] };
					end
				end
			end 
		end
	end
end

//-----------------------------------------------------------------
// UART TX Logic
//-----------------------------------------------------------------
reg [3:0] tx_bitcount;
reg [3:0] tx_count16;
reg [7:0] txd_reg;

always @ (posedge clk)
begin
	if (reset) begin
		tx_busy     <= 0;
		uart_txd    <= 1;
		tx_count16  <= 0;
	end else begin
		if (tx_wr && !tx_busy) begin
			txd_reg     <= tx_data;
			tx_bitcount <= 0;
			tx_count16  <= 0;
			tx_busy     <= 1;
		end 

		if (enable16) begin
			tx_count16  <= tx_count16 + 1;

			if ((tx_count16 == 0) && tx_busy) begin
				tx_bitcount <= tx_bitcount + 1;
				
				if (tx_bitcount == 0) begin
					uart_txd <= 'b0;
				end else if (tx_bitcount ==  9) begin
					uart_txd <= 'b1;
				end else if (tx_bitcount == 10) begin
					tx_bitcount <= 0;
					tx_busy  <= 0;
				end else begin
					uart_txd <= txd_reg[0];
					txd_reg  <= { 1'b0, txd_reg[7:1] };
				end
			end

		end
	end
end


endmodule
