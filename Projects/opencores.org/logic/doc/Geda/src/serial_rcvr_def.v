 module 
  serial_rcvr_def 
    #( parameter 
      SAMPLE=4'b0111,
      SIZE=4,
      START_VALUE=1'b0,
      STOP_VALUE=1'b1,
      WIDTH=8)
     (
 input   wire                 clk,
 input   wire                 edge_enable,
 input   wire                 pad_in,
 input   wire                 parity_enable,
 input   wire                 parity_force,
 input   wire                 parity_type,
 input   wire                 rcv_stb,
 input   wire                 reset,
 output   wire                 data_avail,
 output   wire                 parity_error,
 output   wire                 stop_error,
 output   wire    [ WIDTH-1 :  0]        data_out);
reg                        frame_avail;
reg                        frame_error;
reg                        frame_parity_error;
reg                        frame_rdy;
reg                        parity_calc;
reg                        parity_samp;
reg                        rxd_pad_sig;
reg                        start_detect;
reg     [ 1 :  0]              rdy_del;
reg     [ WIDTH-1 :  0]              shift_buffer;
wire                        baud_enable;
wire                        divider_reset;
wire                        last_cnt;
wire                        next_frame_error;
wire                        next_parity_calc;
wire                        next_parity_samp;
wire                        stop_cnt;
wire     [ WIDTH-1 :  0]              next_shift_buffer;
cde_divider_def
#( .RESET (0),
   .SAMPLE (8),
   .SIZE (4))
divider 
   (
    .clk      ( clk  ),
    .divider_in      ( 4'b1111  ),
    .divider_out      ( baud_enable  ),
    .enable      ( edge_enable  ),
    .reset      ( divider_reset  ));
cde_serial_rcvr
#( .BREAK (1),
   .SIZE (SIZE),
   .STOP_VALUE (STOP_VALUE),
   .WIDTH (WIDTH))
serial_rcvr 
   (
    .clk      ( clk  ),
    .edge_enable      ( baud_enable  ),
    .frame_err      ( next_frame_error  ),
    .last_cnt      ( last_cnt  ),
    .parity_calc      ( next_parity_calc  ),
    .parity_enable      ( parity_enable  ),
    .parity_force      ( parity_force  ),
    .parity_samp      ( next_parity_samp  ),
    .parity_type      ( parity_type  ),
    .reset      ( reset  ),
    .ser_in      ( pad_in  ),
    .shift_buffer      ( next_shift_buffer  ),
    .stop_cnt      ( stop_cnt  ));
always@(posedge clk)
if(reset)                                              rxd_pad_sig <= 1'b1;
else                                                   rxd_pad_sig <= pad_in;
always@(posedge clk)
if(reset)                                              start_detect <= 1'b0;
else
if(start_detect)  
  begin
    if(stop_cnt  && edge_enable )                      start_detect <= !(rxd_pad_sig ^ START_VALUE);
    else
    if(last_cnt)                                       start_detect <= 1'b0;
    else                                               start_detect <= 1'b1;
  end
else
if(!(rxd_pad_sig ^ START_VALUE) )                      start_detect <= 1'b1;
else                                                   start_detect <= start_detect;
always@(posedge clk)
  if(reset)
    begin
    frame_rdy <= 1'b0;
    rdy_del   <= 2'b00;
    end
  else
    begin
    frame_rdy <=  rdy_del[1] ;
    rdy_del   <=  {rdy_del[0],last_cnt};
    end
 always@(posedge clk)
   if (reset)                                       frame_avail <= 1'b0;
   else
   if(frame_rdy)                                    frame_avail <= 1'b1;
   else  
   if(rcv_stb)                                      frame_avail <= 1'b0;
   else                                             frame_avail <= frame_avail;
always@(posedge clk)
  if(reset)
     begin
          shift_buffer   <=  8'h00;  
          parity_calc    <=  1'b0;
          parity_samp    <=  1'b0;
          frame_parity_error   <=  1'b0;
          frame_error    <=  1'b0;
     end
  else
  if(last_cnt )
      begin
          shift_buffer   <=  next_shift_buffer;  
          parity_calc    <=  next_parity_calc;
          parity_samp    <=  next_parity_samp;
          frame_parity_error   <=  (next_parity_samp ^ next_parity_calc) && parity_enable;
          frame_error    <=  next_frame_error;
      end
  else
     begin
          shift_buffer   <=  shift_buffer;  
          parity_calc    <=  parity_calc;
          parity_samp    <=  parity_samp;
          frame_parity_error   <=  frame_parity_error;
          frame_error    <=  frame_error;
      end
assign    divider_reset = reset || (!start_detect);
assign data_out  =  shift_buffer;
assign parity_error  =  frame_parity_error;
assign stop_error   =  frame_error;
assign data_avail    =  frame_avail ;
  endmodule
