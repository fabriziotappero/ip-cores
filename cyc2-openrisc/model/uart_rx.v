//-----------------------------------------------------
// Design Name : uart_rx 
// File Name   : uart_rx.v
// Function    : Simple UART
// Coder       : Deepak Kumar Tala, modified by Steve Fielding
//-----------------------------------------------------
module uart_rx (
reset          ,
rxclk          ,
rx_in          

);
// Port declarations
input        reset          ;
input        rxclk          ;
input        rx_in          ;

// Internal Variables 
reg [7:0]    rx_reg         ;
reg          uld_rx_data    ;
reg          rx_enable      ;
reg [7:0]    rx_data        ;
reg [3:0]    rx_sample_cnt  ;
reg [3:0]    rx_cnt         ;  
reg          rx_frame_err   ;
reg          rx_over_run    ;
reg          rx_empty       ;
reg          rx_empty_reg   ;
reg          rx_d1          ;
reg          rx_d2          ;
reg          rx_busy        ;
integer      uart_log_file_desc;

initial begin
  uart_log_file_desc = $fopen("uart.log") ;
  if ( uart_log_file_desc < 2 )
  begin
    $write("Could not open UART log file!\n") ;
    $finish ;
  end
  $fdisplay(uart_log_file_desc, "********* Start UART Monitor log file *************\n") ;
end




// UART RX Logic
always @ (posedge rxclk or posedge reset)
if (reset) begin
  rx_reg        <= 0; 
  rx_data       <= 0;
  rx_sample_cnt <= 0;
  rx_cnt        <= 0;
  rx_frame_err  <= 0;
  rx_over_run   <= 0;
  rx_empty      <= 1;
  rx_d1         <= 1;
  rx_d2         <= 1;
  rx_busy       <= 0;
end else begin
  // Synchronize the asynch signal
  rx_d1 <= rx_in;
  rx_d2 <= rx_d1;
  // Uload the rx data
  if (uld_rx_data) begin
    rx_data  <= rx_reg;
    rx_empty <= 1;
  end
  // Receive data only when rx is enabled
  if (rx_enable) begin
    // Check if just received start of frame
    if (!rx_busy && !rx_d2) begin
      rx_busy       <= 1;
      rx_sample_cnt <= 1;
      rx_cnt        <= 0;
    end
    // Start of frame detected, Proceed with rest of data
    if (rx_busy) begin
       rx_sample_cnt <= rx_sample_cnt + 1;
       // Logic to sample at middle of data
       if (rx_sample_cnt == 7) begin
          if ((rx_d2 == 1) && (rx_cnt == 0)) begin
            rx_busy <= 0;
          end else begin
            rx_cnt <= rx_cnt + 1; 
            // Start storing the rx data
            if (rx_cnt > 0 && rx_cnt < 9) begin
              rx_reg[rx_cnt - 1] <= rx_d2;
            end
            if (rx_cnt == 9) begin
               rx_busy <= 0;
               // Check if End of frame received correctly
               if (rx_d2 == 0) begin
                 rx_frame_err <= 1;
               end else begin
                 rx_empty     <= 0;
                 rx_frame_err <= 0;
                 // Check if last rx data was not unloaded,
                 rx_over_run  <= (rx_empty) ? 0 : 1;
               end
            end
          end
       end 
    end 
  end
  if (!rx_enable) begin
    rx_busy <= 0;
  end
end

// print rx data
always @(posedge rxclk or posedge reset) begin
  if (reset == 1'b1) begin
    uld_rx_data <= 1'b0;
    rx_enable <= 1'b1;
    rx_empty_reg <= 1'b1;
  end
  else begin
    rx_empty_reg <= rx_empty;
    if (rx_empty == 1'b0 && rx_empty_reg == 1'b1) begin
      uld_rx_data <= 1'b1;
      $fwrite(uart_log_file_desc,"%c",rx_reg);
    end
    else
      uld_rx_data <= 1'b0;
  end
end

endmodule

