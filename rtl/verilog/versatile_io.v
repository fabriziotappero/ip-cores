`ifdef UART
 module raminfr   
        (clk, we, a, dpra, di, dpo); 
parameter addr_width = 4;
parameter data_width = 8;
parameter depth = 16;
input clk;   
input we;   
input  [addr_width-1:0] a;   
input  [addr_width-1:0] dpra;   
input  [data_width-1:0] di;   
output [data_width-1:0] dpo;   
reg    [data_width-1:0] ram [depth-1:0]; 
wire [data_width-1:0] dpo;
wire  [data_width-1:0] di;   
wire  [addr_width-1:0] a;   
wire  [addr_width-1:0] dpra;   
  always @(posedge clk) begin   
    if (we)   
      ram[a] <= di;   
  end   
  assign dpo = ram[dpra];   
endmodule 
`timescale 1ns/10ps
module uart_debug_if ( 
wb_dat32_o, 
wb_adr_i, ier, iir, fcr, mcr, lcr, msr, 
lsr, rf_count, tf_count, tstate, rstate
) ;
input [3-1:0] 		wb_adr_i;
output [31:0] 							wb_dat32_o;
input [3:0] 							ier;
input [3:0] 							iir;
input [1:0] 							fcr;   
input [4:0] 							mcr;
input [7:0] 							lcr;
input [7:0] 							msr;
input [7:0] 							lsr;
input [5-1:0] rf_count;
input [5-1:0] tf_count;
input [2:0] 							tstate;
input [3:0] 							rstate;
wire [3-1:0] 		wb_adr_i;
reg [31:0] 								wb_dat32_o;
always @( fcr or ier or iir or lcr or lsr or mcr or msr
			or rf_count or rstate or tf_count or tstate or wb_adr_i)
	case (wb_adr_i)
		5'b01000: wb_dat32_o = {msr,lcr,iir,ier,lsr};
		5'b01100: wb_dat32_o = {8'b0, fcr,mcr, rf_count, rstate, tf_count, tstate};
		default: wb_dat32_o = 0;
	endcase  
endmodule  
`timescale 1ns/10ps
module uart_receiver (clk, wb_rst_i, lcr, rf_pop, srx_pad_i, enable, 
	counter_t, rf_count, rf_data_out, rf_error_bit, rf_overrun, rx_reset, lsr_mask, rstate, rf_push_pulse);
input				clk;
input				wb_rst_i;
input	[7:0]	lcr;
input				rf_pop;
input				srx_pad_i;
input				enable;
input				rx_reset;
input       lsr_mask;
output	[9:0]			counter_t;
output	[5-1:0]	rf_count;
output	[11-1:0]	rf_data_out;
output				rf_overrun;
output				rf_error_bit;
output [3:0] 		rstate;
output 				rf_push_pulse;
reg	[3:0]	rstate;
reg	[3:0]	rcounter16;
reg	[2:0]	rbit_counter;
reg	[7:0]	rshift;			 
reg		rparity;		 
reg		rparity_error;
reg		rframing_error;		 
reg		rbit_in;
reg		rparity_xor;
reg	[7:0]	counter_b;	 
reg   rf_push_q;
reg	[11-1:0]	rf_data_in;
wire	[11-1:0]	rf_data_out;
wire      rf_push_pulse;
reg				rf_push;
wire				rf_pop;
wire				rf_overrun;
wire	[5-1:0]	rf_count;
wire				rf_error_bit;  
wire 				break_error = (counter_b == 0);
uart_rfifo #(11) fifo_rx(
	.clk(		clk		), 
	.wb_rst_i(	wb_rst_i	),
	.data_in(	rf_data_in	),
	.data_out(	rf_data_out	),
	.push(		rf_push_pulse		),
	.pop(		rf_pop		),
	.overrun(	rf_overrun	),
	.count(		rf_count	),
	.error_bit(	rf_error_bit	),
	.fifo_reset(	rx_reset	),
	.reset_status(lsr_mask)
);
wire 		rcounter16_eq_7 = (rcounter16 == 4'd7);
wire		rcounter16_eq_0 = (rcounter16 == 4'd0);
wire		rcounter16_eq_1 = (rcounter16 == 4'd1);
wire [3:0] rcounter16_minus_1 = rcounter16 - 1'b1;
parameter  sr_idle 					= 4'd0;
parameter  sr_rec_start 			= 4'd1;
parameter  sr_rec_bit 				= 4'd2;
parameter  sr_rec_parity			= 4'd3;
parameter  sr_rec_stop 				= 4'd4;
parameter  sr_check_parity 		= 4'd5;
parameter  sr_rec_prepare 			= 4'd6;
parameter  sr_end_bit				= 4'd7;
parameter  sr_ca_lc_parity	      = 4'd8;
parameter  sr_wait1 					= 4'd9;
parameter  sr_push 					= 4'd10;
always @(posedge clk or posedge wb_rst_i)
begin
  if (wb_rst_i)
  begin
     rstate 			<= #1 sr_idle;
	  rbit_in 				<= #1 1'b0;
	  rcounter16 			<= #1 0;
	  rbit_counter 		<= #1 0;
	  rparity_xor 		<= #1 1'b0;
	  rframing_error 	<= #1 1'b0;
	  rparity_error 		<= #1 1'b0;
	  rparity 				<= #1 1'b0;
	  rshift 				<= #1 0;
	  rf_push 				<= #1 1'b0;
	  rf_data_in 			<= #1 0;
  end
  else
  if (enable)
  begin
	case (rstate)
	sr_idle : begin
			rf_push 			  <= #1 1'b0;
			rf_data_in 	  <= #1 0;
			rcounter16 	  <= #1 4'b1110;
			if (srx_pad_i==1'b0 & ~break_error)    
			begin
				rstate 		  <= #1 sr_rec_start;
			end
		end
	sr_rec_start :	begin
  			rf_push 			  <= #1 1'b0;
				if (rcounter16_eq_7)     
					if (srx_pad_i==1'b1)    
						rstate <= #1 sr_idle;
					else             
						rstate <= #1 sr_rec_prepare;
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_rec_prepare:begin
				case (lcr[ 1:0])   
				2'b00 : rbit_counter <= #1 3'b100;
				2'b01 : rbit_counter <= #1 3'b101;
				2'b10 : rbit_counter <= #1 3'b110;
				2'b11 : rbit_counter <= #1 3'b111;
				endcase
				if (rcounter16_eq_0)
				begin
					rstate		<= #1 sr_rec_bit;
					rcounter16	<= #1 4'b1110;
					rshift		<= #1 0;
				end
				else
					rstate <= #1 sr_rec_prepare;
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_rec_bit :	begin
				if (rcounter16_eq_0)
					rstate <= #1 sr_end_bit;
				if (rcounter16_eq_7)  
					case (lcr[ 1:0])   
					2'b00 : rshift[4:0]  <= #1 {srx_pad_i, rshift[4:1]};
					2'b01 : rshift[5:0]  <= #1 {srx_pad_i, rshift[5:1]};
					2'b10 : rshift[6:0]  <= #1 {srx_pad_i, rshift[6:1]};
					2'b11 : rshift[7:0]  <= #1 {srx_pad_i, rshift[7:1]};
					endcase
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_end_bit :   begin
				if (rbit_counter==3'b0)  
					if (lcr[3])  
						rstate <= #1 sr_rec_parity;
					else
					begin
						rstate <= #1 sr_rec_stop;
						rparity_error <= #1 1'b0;   
					end
				else		 
				begin
					rstate <= #1 sr_rec_bit;
					rbit_counter <= #1 rbit_counter - 1'b1;
				end
				rcounter16 <= #1 4'b1110;
			end
	sr_rec_parity: begin
				if (rcounter16_eq_7)	 
				begin
					rparity <= #1 srx_pad_i;
					rstate <= #1 sr_ca_lc_parity;
				end
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_ca_lc_parity : begin     
				rcounter16  <= #1 rcounter16_minus_1;
				rparity_xor <= #1 ^{rshift,rparity};  
				rstate      <= #1 sr_check_parity;
			  end
	sr_check_parity: begin	   
				case ({lcr[4],lcr[5]})
					2'b00: rparity_error <= #1  rparity_xor == 0;   
					2'b01: rparity_error <= #1 ~rparity;       
					2'b10: rparity_error <= #1  rparity_xor == 1;    
					2'b11: rparity_error <= #1  rparity;	   
				endcase
				rcounter16 <= #1 rcounter16_minus_1;
				rstate <= #1 sr_wait1;
			  end
	sr_wait1 :	if (rcounter16_eq_0)
			begin
				rstate <= #1 sr_rec_stop;
				rcounter16 <= #1 4'b1110;
			end
			else
				rcounter16 <= #1 rcounter16_minus_1;
	sr_rec_stop :	begin
				if (rcounter16_eq_7)	 
				begin
					rframing_error <= #1 !srx_pad_i;  
					rstate <= #1 sr_push;
				end
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_push :	begin
        if(srx_pad_i | break_error)
          begin
            if(break_error)
        		  rf_data_in 	<= #1 {8'b0, 3'b100};  
            else
        			rf_data_in  <= #1 {rshift, 1'b0, rparity_error, rframing_error};
      		  rf_push 		  <= #1 1'b1;
    				rstate        <= #1 sr_idle;
          end
        else if(~rframing_error)   
          begin
       			rf_data_in  <= #1 {rshift, 1'b0, rparity_error, rframing_error};
      		  rf_push 		  <= #1 1'b1;
      			rcounter16 	  <= #1 4'b1110;
    				rstate 		  <= #1 sr_rec_start;
          end
			end
	default : rstate <= #1 sr_idle;
	endcase
  end   
end  
always @ (posedge clk or posedge wb_rst_i)
begin
  if(wb_rst_i)
    rf_push_q <= 0;
  else
    rf_push_q <= #1 rf_push;
end
assign rf_push_pulse = rf_push & ~rf_push_q;
reg 	[9:0]	toc_value;  
always @(lcr)
	case (lcr[3:0])
		4'b0000										: toc_value = 447;  
		4'b0100										: toc_value = 479;  
		4'b0001,	4'b1000							: toc_value = 511;  
		4'b1100										: toc_value = 543;  
		4'b0010, 4'b0101, 4'b1001				: toc_value = 575;  
		4'b0011, 4'b0110, 4'b1010, 4'b1101	: toc_value = 639;  
		4'b0111, 4'b1011, 4'b1110				: toc_value = 703;  
		4'b1111										: toc_value = 767;  
	endcase  
wire [7:0] 	brc_value;  
assign 		brc_value = toc_value[9:2];  
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		counter_b <= #1 8'd159;
	else
	if (srx_pad_i)
		counter_b <= #1 brc_value;  
	else
	if(enable & counter_b != 8'b0)             
		counter_b <= #1 counter_b - 1;   
end  
reg	[9:0]	counter_t;	 
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		counter_t <= #1 10'd639;  
	else
		if(rf_push_pulse || rf_pop || rf_count == 0)  
			counter_t <= #1 toc_value;
		else
		if (enable && counter_t != 10'b0)   
			counter_t <= #1 counter_t - 1;		
end
endmodule
`timescale 1ns/10ps
module uart_regs (clk,
	wb_rst_i, wb_addr_i, wb_dat_i, wb_dat_o, wb_we_i, wb_re_i, 
	modem_inputs,
	stx_pad_o, srx_pad_i,
	rts_pad_o, dtr_pad_o, int_o
	);
input 									clk;
input 									wb_rst_i;
input [3-1:0] 		wb_addr_i;
input [7:0] 							wb_dat_i;
output [7:0] 							wb_dat_o;
input 									wb_we_i;
input 									wb_re_i;
output 									stx_pad_o;
input 									srx_pad_i;
input [3:0] 							modem_inputs;
output 									rts_pad_o;
output 									dtr_pad_o;
output 									int_o;
wire [3:0] 								modem_inputs;
reg 										enable;
wire 										stx_pad_o;		 
wire 										srx_pad_i;
wire 										srx_pad;
reg [7:0] 								wb_dat_o;
wire [3-1:0] 		wb_addr_i;
wire [7:0] 								wb_dat_i;
reg [3:0] 								ier;
reg [3:0] 								iir;
reg [1:0] 								fcr;   
reg [4:0] 								mcr;
reg [7:0] 								lcr;
reg [7:0] 								msr;
reg [15:0] 								dl;   
reg [7:0] 								scratch;  
reg 										start_dlc;  
reg 										lsr_mask_d;  
reg 										msi_reset;  
reg [15:0] 								dlc;   
reg 										int_o;
reg [3:0] 								trigger_level;  
reg 										rx_reset;
reg 										tx_reset;
wire 										dlab;			    
wire 										cts_pad_i, dsr_pad_i, ri_pad_i, dcd_pad_i;  
wire 										loopback;		    
wire 										cts, dsr, ri, dcd;	    
wire                    cts_c, dsr_c, ri_c, dcd_c;  
wire 										rts_pad_o, dtr_pad_o;		    
wire [7:0] 								lsr;
wire 										lsr0, lsr1, lsr2, lsr3, lsr4, lsr5, lsr6, lsr7;
reg										lsr0r, lsr1r, lsr2r, lsr3r, lsr4r, lsr5r, lsr6r, lsr7r;
wire 										lsr_mask;  
assign 									lsr[7:0] = { lsr7r, lsr6r, lsr5r, lsr4r, lsr3r, lsr2r, lsr1r, lsr0r };
assign 									{cts_pad_i, dsr_pad_i, ri_pad_i, dcd_pad_i} = modem_inputs;
assign 									{cts, dsr, ri, dcd} = ~{cts_pad_i,dsr_pad_i,ri_pad_i,dcd_pad_i};
assign                  {cts_c, dsr_c, ri_c, dcd_c} = loopback ? {mcr[1],mcr[0],mcr[2],mcr[3]}
                                                               : {cts_pad_i,dsr_pad_i,ri_pad_i,dcd_pad_i};
assign 									dlab = lcr[7];
assign 									loopback = mcr[4];
assign 									rts_pad_o = mcr[1];
assign 									dtr_pad_o = mcr[0];
wire 										rls_int;   
wire 										rda_int;   
wire 										ti_int;    
wire										thre_int;  
wire 										ms_int;    
reg 										tf_push;
reg 										rf_pop;
wire [11-1:0] 	rf_data_out;
wire 										rf_error_bit;  
wire [5-1:0] 	rf_count;
wire [5-1:0] 	tf_count;
wire [2:0] 								tstate;
wire [3:0] 								rstate;
wire [9:0] 								counter_t;
wire                      thre_set_en;  
reg  [7:0]                block_cnt;    
reg  [7:0]                block_value;  
wire serial_out;
uart_transmitter transmitter(clk, wb_rst_i, lcr, tf_push, wb_dat_i, enable, serial_out, tstate, tf_count, tx_reset, lsr_mask);
  uart_sync_flops    i_uart_sync_flops
  (
    .rst_i           (wb_rst_i),
    .clk_i           (clk),
    .stage1_rst_i    (1'b0),
    .stage1_clk_en_i (1'b1),
    .async_dat_i     (srx_pad_i),
    .sync_dat_o      (srx_pad)
  );
  defparam i_uart_sync_flops.width      = 1;
  defparam i_uart_sync_flops.init_value = 1'b1;
wire serial_in = loopback ? serial_out : srx_pad;
assign stx_pad_o = loopback ? 1'b1 : serial_out;
uart_receiver receiver(clk, wb_rst_i, lcr, rf_pop, serial_in, enable, 
	counter_t, rf_count, rf_data_out, rf_error_bit, rf_overrun, rx_reset, lsr_mask, rstate, rf_push_pulse);
always @(dl or dlab or ier or iir or scratch
			or lcr or lsr or msr or rf_data_out or wb_addr_i or wb_re_i)    
begin
	case (wb_addr_i)
		3'd0   : wb_dat_o = dlab ? dl[7:0] : rf_data_out[10:3];
		3'd1	: wb_dat_o = dlab ? dl[15:8] : ier;
		3'd2	: wb_dat_o = {4'b1100,iir};
		3'd3	: wb_dat_o = lcr;
		3'd5	: wb_dat_o = lsr;
		3'd6	: wb_dat_o = msr;
		3'd7	: wb_dat_o = scratch;
		default:  wb_dat_o = 8'b0;  
	endcase  
end  
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		rf_pop <= #1 0; 
	else
	if (rf_pop)	 
		rf_pop <= #1 0;
	else
	if (wb_re_i && wb_addr_i == 3'd0 && !dlab)
		rf_pop <= #1 1;  
end
wire 	lsr_mask_condition;
wire 	iir_read;
wire  msr_read;
wire	fifo_read;
wire	fifo_write;
assign lsr_mask_condition = (wb_re_i && wb_addr_i == 3'd5 && !dlab);
assign iir_read = (wb_re_i && wb_addr_i == 3'd2 && !dlab);
assign msr_read = (wb_re_i && wb_addr_i == 3'd6 && !dlab);
assign fifo_read = (wb_re_i && wb_addr_i == 3'd0 && !dlab);
assign fifo_write = (wb_we_i && wb_addr_i == 3'd0 && !dlab);
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		lsr_mask_d <= #1 0;
	else  
		lsr_mask_d <= #1 lsr_mask_condition;
end
assign lsr_mask = lsr_mask_condition && ~lsr_mask_d;
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		msi_reset <= #1 1;
	else
	if (msi_reset)
		msi_reset <= #1 0;
	else
	if (msr_read)
		msi_reset <= #1 1;  
end
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i)
		lcr <= #1 8'b00000011;  
	else
	if (wb_we_i && wb_addr_i==3'd3)
		lcr <= #1 wb_dat_i;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i)
	begin
		ier <= #1 4'b0000;  
		dl[15:8] <= #1 8'b0;
	end
	else
	if (wb_we_i && wb_addr_i==3'd1)
		if (dlab)
		begin
			dl[15:8] <= #1 wb_dat_i;
		end
		else
			ier <= #1 wb_dat_i[3:0];  
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) begin
		fcr <= #1 2'b11; 
		rx_reset <= #1 0;
		tx_reset <= #1 0;
	end else
	if (wb_we_i && wb_addr_i==3'd2) begin
		fcr <= #1 wb_dat_i[7:6];
		rx_reset <= #1 wb_dat_i[1];
		tx_reset <= #1 wb_dat_i[2];
	end else begin
		rx_reset <= #1 0;
		tx_reset <= #1 0;
	end
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i)
		mcr <= #1 5'b0; 
	else
	if (wb_we_i && wb_addr_i==3'd4)
			mcr <= #1 wb_dat_i[4:0];
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i)
		scratch <= #1 0;  
	else
	if (wb_we_i && wb_addr_i==3'd7)
		scratch <= #1 wb_dat_i;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i)
	begin
		dl[7:0]  <= #1 8'b0;
		tf_push   <= #1 1'b0;
		start_dlc <= #1 1'b0;
	end
	else
	if (wb_we_i && wb_addr_i==3'd0)
		if (dlab)
		begin
			dl[7:0] <= #1 wb_dat_i;
			start_dlc <= #1 1'b1;  
			tf_push <= #1 1'b0;
		end
		else
		begin
			tf_push   <= #1 1'b1;
			start_dlc <= #1 1'b0;
		end  
	else
	begin
		start_dlc <= #1 1'b0;
		tf_push   <= #1 1'b0;
	end  
always @(fcr)
	case (fcr[1:0])
		2'b00 : trigger_level = 1;
		2'b01 : trigger_level = 4;
		2'b10 : trigger_level = 8;
		2'b11 : trigger_level = 14;
	endcase  
reg [3:0] delayed_modem_signals;
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
	  begin
  		msr <= #1 0;
	  	delayed_modem_signals[3:0] <= #1 0;
	  end
	else begin
		msr[3:0] <= #1 msi_reset ? 4'b0 :
			msr[3:0] | ({dcd, ri, dsr, cts} ^ delayed_modem_signals[3:0]);
		msr[7:4] <= #1 {dcd_c, ri_c, dsr_c, cts_c};
		delayed_modem_signals[3:0] <= #1 {dcd, ri, dsr, cts};
	end
end
assign lsr0 = (rf_count==0 && rf_push_pulse);   
assign lsr1 = rf_overrun;      
assign lsr2 = rf_data_out[1];  
assign lsr3 = rf_data_out[0];  
assign lsr4 = rf_data_out[2];  
assign lsr5 = (tf_count==5'b0 && thre_set_en);   
assign lsr6 = (tf_count==5'b0 && thre_set_en && (tstate ==   0));  
assign lsr7 = rf_error_bit | rf_overrun;
reg 	 lsr0_d;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr0_d <= #1 0;
	else lsr0_d <= #1 lsr0;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr0r <= #1 0;
	else lsr0r <= #1 (rf_count==1 && rf_pop && !rf_push_pulse || rx_reset) ? 0 :  
					  lsr0r || (lsr0 && ~lsr0_d);  
reg lsr1_d;  
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr1_d <= #1 0;
	else lsr1_d <= #1 lsr1;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr1r <= #1 0;
	else	lsr1r <= #1	lsr_mask ? 0 : lsr1r || (lsr1 && ~lsr1_d);  
reg lsr2_d;  
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr2_d <= #1 0;
	else lsr2_d <= #1 lsr2;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr2r <= #1 0;
	else lsr2r <= #1 lsr_mask ? 0 : lsr2r || (lsr2 && ~lsr2_d);  
reg lsr3_d;  
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr3_d <= #1 0;
	else lsr3_d <= #1 lsr3;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr3r <= #1 0;
	else lsr3r <= #1 lsr_mask ? 0 : lsr3r || (lsr3 && ~lsr3_d);  
reg lsr4_d;  
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr4_d <= #1 0;
	else lsr4_d <= #1 lsr4;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr4r <= #1 0;
	else lsr4r <= #1 lsr_mask ? 0 : lsr4r || (lsr4 && ~lsr4_d);
reg lsr5_d;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr5_d <= #1 1;
	else lsr5_d <= #1 lsr5;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr5r <= #1 1;
	else lsr5r <= #1 (fifo_write) ? 0 :  lsr5r || (lsr5 && ~lsr5_d);
reg lsr6_d;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr6_d <= #1 1;
	else lsr6_d <= #1 lsr6;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr6r <= #1 1;
	else lsr6r <= #1 (fifo_write) ? 0 : lsr6r || (lsr6 && ~lsr6_d);
reg lsr7_d;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr7_d <= #1 0;
	else lsr7_d <= #1 lsr7;
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) lsr7r <= #1 0;
	else lsr7r <= #1 lsr_mask ? 0 : lsr7r || (lsr7 && ~lsr7_d);
always @(posedge clk or posedge wb_rst_i) 
begin
	if (wb_rst_i)
		dlc <= #1 0;
	else
		if (start_dlc | ~ (|dlc))
  			dlc <= #1 dl - 1;                
		else
			dlc <= #1 dlc - 1;               
end
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		enable <= #1 1'b0;
	else
		if (|dl & ~(|dlc))      
			enable <= #1 1'b1;
		else
			enable <= #1 1'b0;
end
always @(lcr)
  case (lcr[3:0])
    4'b0000                             : block_value =  95;  
    4'b0100                             : block_value = 103;  
    4'b0001, 4'b1000                    : block_value = 111;  
    4'b1100                             : block_value = 119;  
    4'b0010, 4'b0101, 4'b1001           : block_value = 127;  
    4'b0011, 4'b0110, 4'b1010, 4'b1101  : block_value = 143;  
    4'b0111, 4'b1011, 4'b1110           : block_value = 159;  
    4'b1111                             : block_value = 175;  
  endcase  
always @(posedge clk or posedge wb_rst_i)
begin
  if (wb_rst_i)
    block_cnt <= #1 8'd0;
  else
  if(lsr5r & fifo_write)   
    block_cnt <= #1 block_value;
  else
  if (enable & block_cnt != 8'b0)   
    block_cnt <= #1 block_cnt - 1;   
end  
assign thre_set_en = ~(|block_cnt);
assign rls_int  = ier[2] && (lsr[1] || lsr[2] || lsr[3] || lsr[4]);
assign rda_int  = ier[0] && (rf_count >= {1'b0,trigger_level});
assign thre_int = ier[1] && lsr[5];
assign ms_int   = ier[3] && (| msr[3:0]);
assign ti_int   = ier[0] && (counter_t == 10'b0) && (|rf_count);
reg 	 rls_int_d;
reg 	 thre_int_d;
reg 	 ms_int_d;
reg 	 ti_int_d;
reg 	 rda_int_d;
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) rls_int_d <= #1 0;
	else rls_int_d <= #1 rls_int;
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) rda_int_d <= #1 0;
	else rda_int_d <= #1 rda_int;
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) thre_int_d <= #1 0;
	else thre_int_d <= #1 thre_int;
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) ms_int_d <= #1 0;
	else ms_int_d <= #1 ms_int;
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) ti_int_d <= #1 0;
	else ti_int_d <= #1 ti_int;
wire 	 rls_int_rise;
wire 	 thre_int_rise;
wire 	 ms_int_rise;
wire 	 ti_int_rise;
wire 	 rda_int_rise;
assign rda_int_rise    = rda_int & ~rda_int_d;
assign rls_int_rise 	  = rls_int & ~rls_int_d;
assign thre_int_rise   = thre_int & ~thre_int_d;
assign ms_int_rise 	  = ms_int & ~ms_int_d;
assign ti_int_rise 	  = ti_int & ~ti_int_d;
reg 	rls_int_pnd;
reg	rda_int_pnd;
reg 	thre_int_pnd;
reg 	ms_int_pnd;
reg 	ti_int_pnd;
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) rls_int_pnd <= #1 0; 
	else 
		rls_int_pnd <= #1 lsr_mask ? 0 :  						 
							rls_int_rise ? 1 :						 
							rls_int_pnd && ier[2];	 
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) rda_int_pnd <= #1 0; 
	else 
		rda_int_pnd <= #1 ((rf_count == {1'b0,trigger_level}) && fifo_read) ? 0 :  	 
							rda_int_rise ? 1 :						 
							rda_int_pnd && ier[0];	 
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) thre_int_pnd <= #1 0; 
	else 
		thre_int_pnd <= #1 fifo_write || (iir_read & ~iir[0] & iir[3:1] == 3'b001)? 0 : 
							thre_int_rise ? 1 :
							thre_int_pnd && ier[1];
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) ms_int_pnd <= #1 0; 
	else 
		ms_int_pnd <= #1 msr_read ? 0 : 
							ms_int_rise ? 1 :
							ms_int_pnd && ier[3];
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) ti_int_pnd <= #1 0; 
	else 
		ti_int_pnd <= #1 fifo_read ? 0 : 
							ti_int_rise ? 1 :
							ti_int_pnd && ier[0];
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)	
		int_o <= #1 1'b0;
	else
		int_o <= #1 
					rls_int_pnd		?	~lsr_mask					:
					rda_int_pnd		? 1								:
					ti_int_pnd		? ~fifo_read					:
					thre_int_pnd	? !(fifo_write & iir_read) :
					ms_int_pnd		? ~msr_read						:
					0;	 
end
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		iir <= #1 1;
	else
	if (rls_int_pnd)   
	begin
		iir[3:1] <= #1 3'b011;	 
		iir[0] <= #1 1'b0;		 
	end else  
	if (rda_int)
	begin
		iir[3:1] <= #1 3'b010;
		iir[0] <= #1 1'b0;
	end
	else if (ti_int_pnd)
	begin
		iir[3:1] <= #1 3'b110;
		iir[0] <= #1 1'b0;
	end
	else if (thre_int_pnd)
	begin
		iir[3:1] <= #1 3'b001;
		iir[0] <= #1 1'b0;
	end
	else if (ms_int_pnd)
	begin
		iir[3:1] <= #1 3'b000;
		iir[0] <= #1 1'b0;
	end else	 
	begin
		iir[3:1] <= #1 0;
		iir[0] <= #1 1'b1;
	end
end
endmodule
`timescale 1ns/10ps
module uart_rfifo (clk, 
	wb_rst_i, data_in, data_out,
	push,  
	pop,    
	overrun,
	count,
	error_bit,
	fifo_reset,
	reset_status
	);
parameter fifo_width = 8;
parameter fifo_depth = 16;
parameter fifo_pointer_w = 4;
parameter fifo_counter_w = 5;
input				clk;
input				wb_rst_i;
input				push;
input				pop;
input	[fifo_width-1:0]	data_in;
input				fifo_reset;
input       reset_status;
output	[fifo_width-1:0]	data_out;
output				overrun;
output	[fifo_counter_w-1:0]	count;
output				error_bit;
wire	[fifo_width-1:0]	data_out;
wire [7:0] data8_out;
reg	[2:0]	fifo[fifo_depth-1:0];
reg	[fifo_pointer_w-1:0]	top;
reg	[fifo_pointer_w-1:0]	bottom;
reg	[fifo_counter_w-1:0]	count;
reg				overrun;
wire [fifo_pointer_w-1:0] top_plus_1 = top + 1'b1;
raminfr #(fifo_pointer_w,8,fifo_depth) rfifo  
        (.clk(clk), 
			.we(push), 
			.a(top), 
			.dpra(bottom), 
			.di(data_in[fifo_width-1:fifo_width-8]), 
			.dpo(data8_out)
		); 
always @(posedge clk or posedge wb_rst_i)  
begin
	if (wb_rst_i)
	begin
		top		<= #1 0;
		bottom		<= #1 1'b0;
		count		<= #1 0;
		fifo[0] <= #1 0;
		fifo[1] <= #1 0;
		fifo[2] <= #1 0;
		fifo[3] <= #1 0;
		fifo[4] <= #1 0;
		fifo[5] <= #1 0;
		fifo[6] <= #1 0;
		fifo[7] <= #1 0;
		fifo[8] <= #1 0;
		fifo[9] <= #1 0;
		fifo[10] <= #1 0;
		fifo[11] <= #1 0;
		fifo[12] <= #1 0;
		fifo[13] <= #1 0;
		fifo[14] <= #1 0;
		fifo[15] <= #1 0;
	end
	else
	if (fifo_reset) begin
		top		<= #1 0;
		bottom		<= #1 1'b0;
		count		<= #1 0;
		fifo[0] <= #1 0;
		fifo[1] <= #1 0;
		fifo[2] <= #1 0;
		fifo[3] <= #1 0;
		fifo[4] <= #1 0;
		fifo[5] <= #1 0;
		fifo[6] <= #1 0;
		fifo[7] <= #1 0;
		fifo[8] <= #1 0;
		fifo[9] <= #1 0;
		fifo[10] <= #1 0;
		fifo[11] <= #1 0;
		fifo[12] <= #1 0;
		fifo[13] <= #1 0;
		fifo[14] <= #1 0;
		fifo[15] <= #1 0;
	end
  else
	begin
		case ({push, pop})
		2'b10 : if (count<fifo_depth)   
			begin
				top       <= #1 top_plus_1;
				fifo[top] <= #1 data_in[2:0];
				count     <= #1 count + 1'b1;
			end
		2'b01 : if(count>0)
			begin
        fifo[bottom] <= #1 0;
				bottom   <= #1 bottom + 1'b1;
				count	 <= #1 count - 1'b1;
			end
		2'b11 : begin
				bottom   <= #1 bottom + 1'b1;
				top       <= #1 top_plus_1;
				fifo[top] <= #1 data_in[2:0];
		        end
    default: ;
		endcase
	end
end    
always @(posedge clk or posedge wb_rst_i)  
begin
  if (wb_rst_i)
    overrun   <= #1 1'b0;
  else
  if(fifo_reset | reset_status) 
    overrun   <= #1 1'b0;
  else
  if(push & ~pop & (count==fifo_depth))
    overrun   <= #1 1'b1;
end    
assign data_out = {data8_out,fifo[bottom]};
wire	[2:0]	word0 = fifo[0];
wire	[2:0]	word1 = fifo[1];
wire	[2:0]	word2 = fifo[2];
wire	[2:0]	word3 = fifo[3];
wire	[2:0]	word4 = fifo[4];
wire	[2:0]	word5 = fifo[5];
wire	[2:0]	word6 = fifo[6];
wire	[2:0]	word7 = fifo[7];
wire	[2:0]	word8 = fifo[8];
wire	[2:0]	word9 = fifo[9];
wire	[2:0]	word10 = fifo[10];
wire	[2:0]	word11 = fifo[11];
wire	[2:0]	word12 = fifo[12];
wire	[2:0]	word13 = fifo[13];
wire	[2:0]	word14 = fifo[14];
wire	[2:0]	word15 = fifo[15];
assign	error_bit = |(word0[2:0]  | word1[2:0]  | word2[2:0]  | word3[2:0]  |
            		      word4[2:0]  | word5[2:0]  | word6[2:0]  | word7[2:0]  |
            		      word8[2:0]  | word9[2:0]  | word10[2:0] | word11[2:0] |
            		      word12[2:0] | word13[2:0] | word14[2:0] | word15[2:0] );
endmodule
`timescale 1ns/10ps
module uart_tfifo (clk, 
	wb_rst_i, data_in, data_out,
	push,  
	pop,    
	overrun,
	count,
	fifo_reset,
	reset_status
	);
parameter fifo_width = 8;
parameter fifo_depth = 16;
parameter fifo_pointer_w = 4;
parameter fifo_counter_w = 5;
input				clk;
input				wb_rst_i;
input				push;
input				pop;
input	[fifo_width-1:0]	data_in;
input				fifo_reset;
input       reset_status;
output	[fifo_width-1:0]	data_out;
output				overrun;
output	[fifo_counter_w-1:0]	count;
wire	[fifo_width-1:0]	data_out;
reg	[fifo_pointer_w-1:0]	top;
reg	[fifo_pointer_w-1:0]	bottom;
reg	[fifo_counter_w-1:0]	count;
reg				overrun;
wire [fifo_pointer_w-1:0] top_plus_1 = top + 1'b1;
raminfr #(fifo_pointer_w,fifo_width,fifo_depth) tfifo  
        (.clk(clk), 
			.we(push), 
			.a(top), 
			.dpra(bottom), 
			.di(data_in), 
			.dpo(data_out)
		); 
always @(posedge clk or posedge wb_rst_i)  
begin
	if (wb_rst_i)
	begin
		top		<= #1 0;
		bottom		<= #1 1'b0;
		count		<= #1 0;
	end
	else
	if (fifo_reset) begin
		top		<= #1 0;
		bottom		<= #1 1'b0;
		count		<= #1 0;
	end
  else
	begin
		case ({push, pop})
		2'b10 : if (count<fifo_depth)   
			begin
				top       <= #1 top_plus_1;
				count     <= #1 count + 1'b1;
			end
		2'b01 : if(count>0)
			begin
				bottom   <= #1 bottom + 1'b1;
				count	 <= #1 count - 1'b1;
			end
		2'b11 : begin
				bottom   <= #1 bottom + 1'b1;
				top       <= #1 top_plus_1;
		        end
    default: ;
		endcase
	end
end    
always @(posedge clk or posedge wb_rst_i)  
begin
  if (wb_rst_i)
    overrun   <= #1 1'b0;
  else
  if(fifo_reset | reset_status) 
    overrun   <= #1 1'b0;
  else
  if(push & (count==fifo_depth))
    overrun   <= #1 1'b1;
end    
endmodule
`timescale 1ns/10ps
module uart_sync_flops
(
  rst_i,
  clk_i,
  stage1_rst_i,
  stage1_clk_en_i,
  async_dat_i,
  sync_dat_o
);
parameter Tp            = 1;
parameter width         = 1;
parameter init_value    = 1'b0;
input                           rst_i;                   
input                           clk_i;                   
input                           stage1_rst_i;            
input                           stage1_clk_en_i;         
input   [width-1:0]             async_dat_i;             
output  [width-1:0]             sync_dat_o;              
reg     [width-1:0]             sync_dat_o;
reg     [width-1:0]             flop_0;
always @ (posedge clk_i or posedge rst_i)
begin
    if (rst_i)
        flop_0 <= #Tp {width{init_value}};
    else
        flop_0 <= #Tp async_dat_i;    
end
always @ (posedge clk_i or posedge rst_i)
begin
    if (rst_i)
        sync_dat_o <= #Tp {width{init_value}};
    else if (stage1_rst_i)
        sync_dat_o <= #Tp {width{init_value}};
    else if (stage1_clk_en_i)
        sync_dat_o <= #Tp flop_0;       
end
endmodule
`timescale 1ns/10ps
module uart_wb (clk, wb_rst_i, 
	wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_adr_i,
	wb_adr_int, wb_dat_i, wb_dat_o, wb_dat8_i, wb_dat8_o, wb_dat32_o, wb_sel_i,
	we_o, re_o  
);
input 		  clk;
input 		  wb_rst_i;
input 		  wb_we_i;
input 		  wb_stb_i;
input 		  wb_cyc_i;
input [3:0]   wb_sel_i;
input [3-1:0] 	wb_adr_i;  
input [7:0]  wb_dat_i;  
output [7:0] wb_dat_o;
reg [7:0] 	 wb_dat_o;
wire [7:0] 	 wb_dat_i;
reg [7:0] 	 wb_dat_is;
output [3-1:0]	wb_adr_int;  
input [7:0]   wb_dat8_o;  
output [7:0]  wb_dat8_i;
input [31:0]  wb_dat32_o;  
output 		  wb_ack_o;
output 		  we_o;
output 		  re_o;
wire 			  we_o;
reg 			  wb_ack_o;
reg [7:0] 	  wb_dat8_i;
wire [7:0] 	  wb_dat8_o;
wire [3-1:0]	wb_adr_int;  
reg [3-1:0]	wb_adr_is;
reg 								wb_we_is;
reg 								wb_cyc_is;
reg 								wb_stb_is;
reg [3:0] 						wb_sel_is;
wire [3:0]   wb_sel_i;
reg 			 wre ; 
reg [1:0] 	 wbstate;
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) begin
		wb_ack_o <= #1 1'b0;
		wbstate <= #1 0;
		wre <= #1 1'b1;
	end else
		case (wbstate)
			0: begin
				if (wb_stb_is & wb_cyc_is) begin
					wre <= #1 0;
					wbstate <= #1 1;
					wb_ack_o <= #1 1;
				end else begin
					wre <= #1 1;
					wb_ack_o <= #1 0;
				end
			end
			1: begin
			   wb_ack_o <= #1 0;
				wbstate <= #1 2;
				wre <= #1 0;
			end
			2,3: begin
				wb_ack_o <= #1 0;
				wbstate <= #1 0;
				wre <= #1 0;
			end
		endcase
assign we_o =  wb_we_is & wb_stb_is & wb_cyc_is & wre ;  
assign re_o = ~wb_we_is & wb_stb_is & wb_cyc_is & wre ;  
always  @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i) begin
		wb_adr_is <= #1 0;
		wb_we_is <= #1 0;
		wb_cyc_is <= #1 0;
		wb_stb_is <= #1 0;
		wb_dat_is <= #1 0;
		wb_sel_is <= #1 0;
	end else begin
		wb_adr_is <= #1 wb_adr_i;
		wb_we_is <= #1 wb_we_i;
		wb_cyc_is <= #1 wb_cyc_i;
		wb_stb_is <= #1 wb_stb_i;
		wb_dat_is <= #1 wb_dat_i;
		wb_sel_is <= #1 wb_sel_i;
	end
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i)
		wb_dat_o <= #1 0;
	else
		wb_dat_o <= #1 wb_dat8_o;
always @(wb_dat_is)
	wb_dat8_i = wb_dat_is;
assign wb_adr_int = wb_adr_is;
endmodule
`timescale 1ns/10ps
module uart_transmitter (clk, wb_rst_i, lcr, tf_push, wb_dat_i, enable,	stx_pad_o, tstate, tf_count, tx_reset, lsr_mask);
input 										clk;
input 										wb_rst_i;
input [7:0] 								lcr;
input 										tf_push;
input [7:0] 								wb_dat_i;
input 										enable;
input 										tx_reset;
input 										lsr_mask;  
output 										stx_pad_o;
output [2:0] 								tstate;
output [5-1:0] 	tf_count;
reg [2:0] 									tstate;
reg [4:0] 									counter;
reg [2:0] 									bit_counter;    
reg [6:0] 									shift_out;	 
reg 											stx_o_tmp;
reg 											parity_xor;   
reg 											tf_pop;
reg 											bit_out;
wire [8-1:0] 			tf_data_in;
wire [8-1:0] 			tf_data_out;
wire 											tf_push;
wire 											tf_overrun;
wire [5-1:0] 		tf_count;
assign 										tf_data_in = wb_dat_i;
uart_tfifo fifo_tx(	 
	.clk(		clk		), 
	.wb_rst_i(	wb_rst_i	),
	.data_in(	tf_data_in	),
	.data_out(	tf_data_out	),
	.push(		tf_push		),
	.pop(		tf_pop		),
	.overrun(	tf_overrun	),
	.count(		tf_count	),
	.fifo_reset(	tx_reset	),
	.reset_status(lsr_mask)
);
parameter s_idle        = 3'd0;
parameter s_send_start  = 3'd1;
parameter s_send_byte   = 3'd2;
parameter s_send_parity = 3'd3;
parameter s_send_stop   = 3'd4;
parameter s_pop_byte    = 3'd5;
always @(posedge clk or posedge wb_rst_i)
begin
  if (wb_rst_i)
  begin
	tstate       <= #1 s_idle;
	stx_o_tmp       <= #1 1'b1;
	counter   <= #1 5'b0;
	shift_out   <= #1 7'b0;
	bit_out     <= #1 1'b0;
	parity_xor  <= #1 1'b0;
	tf_pop      <= #1 1'b0;
	bit_counter <= #1 3'b0;
  end
  else
  if (enable)
  begin
	case (tstate)
	s_idle	 :	if (~|tf_count)  
			begin
				tstate <= #1 s_idle;
				stx_o_tmp <= #1 1'b1;
			end
			else
			begin
				tf_pop <= #1 1'b0;
				stx_o_tmp  <= #1 1'b1;
				tstate  <= #1 s_pop_byte;
			end
	s_pop_byte :	begin
				tf_pop <= #1 1'b1;
				case (lcr[ 1:0])   
				2'b00 : begin
					bit_counter <= #1 3'b100;
					parity_xor  <= #1 ^tf_data_out[4:0];
				     end
				2'b01 : begin
					bit_counter <= #1 3'b101;
					parity_xor  <= #1 ^tf_data_out[5:0];
				     end
				2'b10 : begin
					bit_counter <= #1 3'b110;
					parity_xor  <= #1 ^tf_data_out[6:0];
				     end
				2'b11 : begin
					bit_counter <= #1 3'b111;
					parity_xor  <= #1 ^tf_data_out[7:0];
				     end
				endcase
				{shift_out[6:0], bit_out} <= #1 tf_data_out;
				tstate <= #1 s_send_start;
			end
	s_send_start :	begin
				tf_pop <= #1 1'b0;
				if (~|counter)
					counter <= #1 5'b01111;
				else
				if (counter == 5'b00001)
				begin
					counter <= #1 0;
					tstate <= #1 s_send_byte;
				end
				else
					counter <= #1 counter - 1'b1;
				stx_o_tmp <= #1 1'b0;
			end
	s_send_byte :	begin
				if (~|counter)
					counter <= #1 5'b01111;
				else
				if (counter == 5'b00001)
				begin
					if (bit_counter > 3'b0)
					begin
						bit_counter <= #1 bit_counter - 1'b1;
						{shift_out[5:0],bit_out  } <= #1 {shift_out[6:1], shift_out[0]};
						tstate <= #1 s_send_byte;
					end
					else    
					if (~lcr[3])
					begin
						tstate <= #1 s_send_stop;
					end
					else
					begin
						case ({lcr[4],lcr[5]})
						2'b00:	bit_out <= #1 ~parity_xor;
						2'b01:	bit_out <= #1 1'b1;
						2'b10:	bit_out <= #1 parity_xor;
						2'b11:	bit_out <= #1 1'b0;
						endcase
						tstate <= #1 s_send_parity;
					end
					counter <= #1 0;
				end
				else
					counter <= #1 counter - 1'b1;
				stx_o_tmp <= #1 bit_out;  
			end
	s_send_parity :	begin
				if (~|counter)
					counter <= #1 5'b01111;
				else
				if (counter == 5'b00001)
				begin
					counter <= #1 4'b0;
					tstate <= #1 s_send_stop;
				end
				else
					counter <= #1 counter - 1'b1;
				stx_o_tmp <= #1 bit_out;
			end
	s_send_stop :  begin
				if (~|counter)
				  begin
						casex ({lcr[2],lcr[1:0]})
  						3'b0xx:	  counter <= #1 5'b01101;      
  						3'b100:	  counter <= #1 5'b10101;      
  						default:	  counter <= #1 5'b11101;      
						endcase
					end
				else
				if (counter == 5'b00001)
				begin
					counter <= #1 0;
					tstate <= #1 s_idle;
				end
				else
					counter <= #1 counter - 1'b1;
				stx_o_tmp <= #1 1'b1;
			end
		default :  
			tstate <= #1 s_idle;
	endcase
  end  
  else
    tf_pop <= #1 1'b0;   
end  
assign stx_pad_o = lcr[6] ? 1'b0 : stx_o_tmp;     
endmodule
`timescale 1ns/10ps
module uart_top	(
	wb_clk_i, 
	wb_rst_i, wb_adr_i, wb_dat_i, wb_dat_o, wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_sel_i,
	int_o,  
	stx_pad_o, srx_pad_i,
	rts_pad_o, cts_pad_i, dtr_pad_o, dsr_pad_i, ri_pad_i, dcd_pad_i
	);
parameter 							 uart_data_width = 8;
parameter 							 uart_addr_width = 3;
input 								 wb_clk_i;
input 								 wb_rst_i;
input [uart_addr_width-1:0] 	 wb_adr_i;
input [uart_data_width-1:0] 	 wb_dat_i;
output [uart_data_width-1:0] 	 wb_dat_o;
input 								 wb_we_i;
input 								 wb_stb_i;
input 								 wb_cyc_i;
input [3:0]							 wb_sel_i;
output 								 wb_ack_o;
output 								 int_o;
input 								 srx_pad_i;
output 								 stx_pad_o;
output 								 rts_pad_o;
input 								 cts_pad_i;
output 								 dtr_pad_o;
input 								 dsr_pad_i;
input 								 ri_pad_i;
input 								 dcd_pad_i;
wire 									 stx_pad_o;
wire 									 rts_pad_o;
wire 									 dtr_pad_o;
wire [uart_addr_width-1:0] 	 wb_adr_i;
wire [uart_data_width-1:0] 	 wb_dat_i;
wire [uart_data_width-1:0] 	 wb_dat_o;
wire [7:0] 							 wb_dat8_i;  
wire [7:0] 							 wb_dat8_o;  
wire [31:0] 						 wb_dat32_o;  
wire [3:0] 							 wb_sel_i;   
wire [uart_addr_width-1:0] 	 wb_adr_int;
wire 									 we_o;	 
wire		          	     re_o;	 
uart_wb		wb_interface(
		.clk(		wb_clk_i		),
		.wb_rst_i(	wb_rst_i	),
	.wb_dat_i(wb_dat_i),
	.wb_dat_o(wb_dat_o),
	.wb_dat8_i(wb_dat8_i),
	.wb_dat8_o(wb_dat8_o),
	 .wb_dat32_o(32'b0),								 
	 .wb_sel_i(4'b0),
		.wb_we_i(	wb_we_i		),
		.wb_stb_i(	wb_stb_i	),
		.wb_cyc_i(	wb_cyc_i	),
		.wb_ack_o(	wb_ack_o	),
	.wb_adr_i(wb_adr_i),
	.wb_adr_int(wb_adr_int),
		.we_o(		we_o		),
		.re_o(re_o)
		);
uart_regs	regs(
	.clk(		wb_clk_i		),
	.wb_rst_i(	wb_rst_i	),
	.wb_addr_i(	wb_adr_int	),
	.wb_dat_i(	wb_dat8_i	),
	.wb_dat_o(	wb_dat8_o	),
	.wb_we_i(	we_o		),
   .wb_re_i(re_o),
	.modem_inputs(	{cts_pad_i, dsr_pad_i,
	ri_pad_i,  dcd_pad_i}	),
	.stx_pad_o(		stx_pad_o		),
	.srx_pad_i(		srx_pad_i		),
	.rts_pad_o(		rts_pad_o		),
	.dtr_pad_o(		dtr_pad_o		),
	.int_o(		int_o		)
);
initial
begin
		$display("(%m) UART INFO: Data bus width is 8. No Debug interface.\n");
		$display("(%m) UART INFO: Doesn't have baudrate output\n");
end
endmodule
`endif
module versatile_io (
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    input [3:0] wbs_sel_i,
    input wbs_we_i, wbs_stb_i, wbs_cyc_i,
    output [31:0] wbs_dat_o,
    output wbs_ack_o,
`ifdef B4
    output wbs_stall_o,
`endif
`include "versatile_io_module.v"
`ifdef UART0
    output uart0_irq,
`endif
    input wbs_clk, wbs_rst,
    input clk, rst
);

wire [31:0] uart0_dat_o;
`ifdef UART0
parameter uart0_mem_map_hi = `UART0_MEM_MAP_HI;
parameter uart0_mem_map_lo = `UART0_MEM_MAP_LO;
parameter [31:0] uart0_base_adr = `UART0_BASE_ADR;
`endif
function [7:0] tobyte;
input [3:0] sel_i;
input [31:0] dat_i;
begin
    tobyte = ({8{sel_i[3]}} & dat_i[31:24]) | ({8{sel_i[2]}} & dat_i[23:16]) | ({8{sel_i[1]}} & dat_i[15:8]) | ({8{sel_i[0]}} & dat_i[7:0]);
end
endfunction

function [31:0] toword;
input [7:0] dat_i;
begin
    toword = {4{dat_i}};
end
endfunction

function [31:0] mask;
input [31:0] dat_i;
input sel;
begin
    mask = {32{sel}} & dat_i;
end
endfunction

`ifdef UART0
wire uart0_cs;
assign uart0_cs = wbs_adr_i[uart0_mem_map_hi:uart0_mem_map_lo] == uart0_base_adr[uart0_mem_map_hi:uart0_mem_map_lo];
wire [7:0] uart0_temp;
wire uart0_ack_o;
/*
uart_top uart0	(
    .wb_clk_i(wbs_clk), .wb_rst_i(wbs_rst), 	
    // Wishbone signals
    .wb_adr_i(wbs_adr_i[2:0]), .wb_dat_i(tobyte(wbs_sel_i,wbs_dat_i)), .wb_dat_o(uart0_temp), .wb_we_i(wbs_we_i), .wb_stb_i(wbs_stb_i), .wb_cyc_i(wbs_cyc_i & uart0_cs), .wb_ack_o(uart0_ack_o), .wb_sel_i(4'b0),
    .int_o(uart0_irq), // interrupt request
    // UART	signals
    // serial input/output
    .stx_pad_o(uart0_tx_pad_o), .srx_pad_i(uart0_rx_pad_i),
    // modem signals
    .rts_pad_o(), .cts_pad_i(1'b0), .dtr_pad_o(), .dsr_pad_i(1'b0), .ri_pad_i(1'b0), .dcd_pad_i(1'b0) );
*/
uart16750_wb uart0(
    // UART signals
    .rx(uart0_rx_pad_i),
    .tx(uart0_tx_pad_o),
    .irq(uart0_irq),
    // wishbone slave
    .wbs_dat_i(tobyte(wbs_sel_i,wbs_dat_i)),
    .wbs_adr_i(wbs_adr_i[2:0]),
    .wbs_we_i(wbs_we_i),
    .wbs_cyc_i(wbs_cyc_i & uart0_cs),
    .wbs_stb_i(wbs_stb_i),
    .wbs_dat_o(uart0_temp),
    .wbs_ack_o(uart0_ack_o),
    .wb_clk_i(wbs_clk),
    .wb_rst_i(wbs_rst) );
assign uart0_dat_o = mask( toword(uart0_temp), uart0_ack_o);
`else
assign uart0_dat_o = 32'h0;
assign uart0_ack_o = 1'b0;
`endif

assign wbs_dat_o = uart0_dat_o;
assign wbs_ack_o = uart0_ack_o;
`ifdef WB4
assign wbs_stall_o = 1'b0;
`endif

endmodule
