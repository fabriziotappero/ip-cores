module sd_controller_fifo_wba
( 
  wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o, 
  wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o, 
  sd_cmd_dat_i,sd_cmd_out_o,  sd_cmd_oe_o, 
  sd_dat_dat_i, sd_dat_out_o , sd_dat_oe_o, sd_clk_o_pad
);
input           wb_clk_i;     
input           wb_rst_i;     
input   [7:0]  wb_dat_i;     
output  [7:0]  wb_dat_o;     
input   [2:0]  wb_adr_i;     
input    [3:0]  wb_sel_i;     
input           wb_we_i;      
input           wb_cyc_i;     
input           wb_stb_i;     
output reg          wb_ack_o;     
input wire [3:0] sd_dat_dat_i;
output wire [3:0] sd_dat_out_o;
output wire sd_dat_oe_o;
input wire sd_cmd_dat_i;
output wire sd_cmd_out_o;
output wire sd_cmd_oe_o;
output sd_clk_o_pad;
wire sd_clk_i;
reg [7:0] controll_reg;
reg [7:0] status_reg;
reg [7:0] command_timeout_reg;
  assign sd_clk_i = wb_clk_i;
assign sd_clk_o=sd_clk_i;
reg [1:0] wb_fifo_adr_i_writer;
reg [1:0] wb_fifo_adr_i_reader;
wire [1:0] wb_fifo_adr_i;
reg add_token_read;
wire [7:0] wb_fifo_dat_i;
wire [7:0] wb_fifo_dat_o;
reg [7:0]  wb_dat_i_storage;
reg [7:0] wb_dat_o_i;
reg time_enable;
assign sd_clk_o_pad  = sd_clk_i ;
assign wb_fifo_adr_i = add_token_read ? wb_fifo_adr_i_reader : wb_fifo_adr_i_writer;
assign wb_fifo_dat_i =wb_dat_i_storage;
assign wb_dat_o = wb_adr_i[0] ? wb_fifo_dat_o :   wb_dat_o_i ;
wire [1:4]fifo_full ;
wire [1:4]fifo_empty;
reg wb_fifo_we_i;
reg wb_fifo_re_i;
wire [1:0] sd_adr_o;
wire [7:0] sd_dat_o;
wire [7:0] sd_dat_i;
sd_fifo sd_fifo_0
( 
   .wb_adr_i  (wb_fifo_adr_i ),
   .wb_dat_i  (wb_fifo_dat_i),
   .wb_dat_o  (wb_fifo_dat_o ),
   .wb_we_i   (wb_fifo_we_i),
   .wb_re_i   (wb_fifo_re_i),
   .wb_clk  (wb_clk_i),
   .sd_adr_i (sd_adr_o ),
   .sd_dat_i (sd_dat_o),
   .sd_dat_o (sd_dat_i ),
   .sd_we_i (sd_we_o),
   .sd_re_i (sd_re_o),
   .sd_clk (sd_clk_o),
   .fifo_full ( fifo_full ),
   .fifo_empty (fifo_empty    ),
   .rst (wb_rst_i) 
  ) ; 
wire [1:0] sd_adr_o_cmd;
wire [7:0] sd_dat_i_cmd;
wire [7:0] sd_dat_o_cmd;
wire [1:0] sd_adr_o_dat;
wire [7:0] sd_dat_i_dat;
wire [7:0] sd_dat_o_dat;
wire [1:0] st_dat_t;
sd_cmd_phy sdc_cmd_phy_0
(
  .sd_clk (sd_clk_o),
  .rst (wb_rst_i ),
  .cmd_dat_i ( sd_cmd_dat_i  ),
  .cmd_dat_o (sd_cmd_out_o   ),
  .cmd_oe_o (sd_cmd_oe_o   ),  
  .sd_adr_o (sd_adr_o_cmd),
  .sd_dat_i (sd_dat_i_cmd),
  .sd_dat_o (sd_dat_o_cmd),
  .sd_we_o (sd_we_o_cmd),
  .sd_re_o (sd_re_o_cmd),
  .fifo_full ( fifo_full[1:2] ),
  .fifo_empty ( fifo_empty [1:2]),
  .start_dat_t (st_dat_t),
  .fifo_acces_token (fifo_acces_token)
  ); 
  sd_data_phy sd_data_phy_0 (
  .sd_clk (sd_clk_o),
  .rst (wb_rst_i | controll_reg[0]),
  .DAT_oe_o ( sd_dat_oe_o  ),
  .DAT_dat_o (sd_dat_out_o),
  .DAT_dat_i  (sd_dat_dat_i ),
  .sd_adr_o (sd_adr_o_dat   ),
  .sd_dat_i (sd_dat_i_dat  ),
  .sd_dat_o (sd_dat_o_dat  ),
  .sd_we_o  (sd_we_o_dat),
  .sd_re_o (sd_re_o_dat),
  .fifo_full ( fifo_full[3:4] ),
  .fifo_empty ( fifo_empty [3:4]),
  .start_dat (st_dat_t),
  .fifo_acces (~fifo_acces_token)  
  ); 
  assign sd_adr_o =  fifo_acces_token ? sd_adr_o_cmd : sd_adr_o_dat; 
  assign sd_dat_o =  fifo_acces_token ? sd_dat_o_cmd : sd_dat_o_dat;
  assign sd_we_o  = fifo_acces_token ? sd_we_o_cmd : sd_we_o_dat;
  assign sd_re_o  =  fifo_acces_token ? sd_re_o_cmd : sd_re_o_dat;
 assign sd_dat_i_dat = sd_dat_i;
 assign sd_dat_i_cmd = sd_dat_i;
  always @(posedge wb_clk_i or posedge wb_rst_i)
	begin
	if (wb_rst_i)
	    status_reg<=0;
	  else begin	
      status_reg[0] <= fifo_full[1];
      status_reg[1] <= fifo_empty[2];
      status_reg[2] <=  fifo_full[3];
      status_reg[3] <=  fifo_empty[4];
    end
  end
  reg delayed_ack;
  always @(posedge wb_clk_i or posedge wb_rst_i)
	begin	
	  if (wb_rst_i) 
	    wb_ack_o <=0; 
	   else 
	     wb_ack_o <=wb_stb_i & wb_cyc_i &  ~wb_ack_o & delayed_ack;
	end
  always @(posedge wb_clk_i or posedge wb_rst_i)
	begin	
    if ( wb_rst_i )begin
	    command_timeout_reg<=255;
	    wb_dat_i_storage<=0;
	    controll_reg<=0;
	    wb_fifo_we_i<=0;
	    wb_fifo_adr_i_writer<=0;
	    time_enable<=0;
	  end
	  else if (wb_stb_i  & wb_cyc_i & (~wb_ack_o))begin 
	    if (wb_we_i) begin
	      case (wb_adr_i) 
	      4'h0 : begin
	        wb_fifo_adr_i_writer<=0;
	        wb_fifo_we_i<=1&!delayed_ack;
	        wb_dat_i_storage<=wb_dat_i;	       
	        command_timeout_reg<=255;
	        time_enable<=1;
	      end       
        4'h2 : begin
	        wb_fifo_adr_i_writer<=2;
	        wb_fifo_we_i<=1&!delayed_ack;
	        wb_dat_i_storage<=wb_dat_i;
	        command_timeout_reg<=255;
	        time_enable<=0;
	      end        
        4'h5 : controll_reg <= wb_dat_i;
  	      endcase
	    end  	  
	   end
	   else begin
	      wb_fifo_we_i<=0;
	     if (!status_reg[1])
	       time_enable<=0; 
	     if ((command_timeout_reg!=0) && (time_enable))
	         command_timeout_reg<=command_timeout_reg-1;   
	   end   
end
always @(posedge wb_clk_i or posedge wb_rst_i )begin
   if ( wb_rst_i) begin
     add_token_read<=0;
     delayed_ack<=0;
     wb_fifo_re_i<=0;
      wb_fifo_adr_i_reader<=0;
      wb_dat_o_i<=0;
  end 
 else begin  
    delayed_ack<=0;
    wb_fifo_re_i<=0;
   if (wb_stb_i  & wb_cyc_i & (~wb_ack_o)) begin 
   delayed_ack<=delayed_ack+1;
    add_token_read<=0;
    if (!wb_we_i) begin
      case (wb_adr_i)
      4'h1 : begin
         add_token_read<=1;
         wb_fifo_adr_i_reader<=1;
	      wb_fifo_re_i<=1&delayed_ack; 
      end
      4'h3 :begin
         add_token_read<=1;
         wb_fifo_adr_i_reader<=3;
	       wb_fifo_re_i<=1 & delayed_ack;
     end 
      4'h4 : wb_dat_o_i <= status_reg;
      4'h6 : wb_dat_o_i <= command_timeout_reg;
     endcase
    end
  end  
end
end
endmodule
module sd_cmd_phy ( 
input sd_clk, 
input rst, 
input  cmd_dat_i,
output reg cmd_dat_o, 
output reg cmd_oe_o,
output  [1:0] sd_adr_o,
input [7:0] sd_dat_i,
output reg [7:0] sd_dat_o,
output reg sd_we_o,
output reg sd_re_o,
input  [1:2] fifo_full,
input [1:2] fifo_empty,
output  [1:0]  start_dat_t,
output fifo_acces_token
);
reg [6:0] Response_Size;
parameter SEND_SIZE = 48;
parameter CONTENT_SIZE = 40; 
parameter NCR = 2 ;
parameter SIZE = 5;
parameter 
INIT          = 5'b00001,
IDLE          = 5'b00010,
WRITE         = 5'b00100,
BUFFER_WRITE  = 5'b01000,
READ          = 5'b10000;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
reg [1:0] start_dat_t_read;
reg [1:0] start_dat_t_write;
reg [39:0] in_buffer;
reg [2:0] read_byte_cnt;
reg [7:0] cmd_flow_cnt_write;
reg [7:0] cmd_flow_cnt_read;
reg cmd_dat_internal;
reg big_resp;
reg  crc_rst_write;
reg  crc_en_write;
reg  crc_in_write; 
wire [6:0] crc_val_write;
reg [1:0] sd_adr_o_read;
reg [1:0] sd_adr_o_write;
reg  crc_rst_read;
reg  crc_en_read;
reg  crc_in_read; 
wire [6:0] crc_val_read;
reg crc_buffering_write;
reg block_write;
reg block_read;
reg in_buff_ptr;
reg out_buff_ptr;
reg [2:0] read_index_cnt;
reg  [7:0] in_buff_0;
reg  [7:0] in_buff_1;
reg [6:0] crc_in_buff;
reg [7:0] response_status;
reg [6:0] index_check;
reg add_token_read;
CRC_7 CRC_7_WRITE( 
.BITVAL (crc_in_write),
.Enable (crc_en_write),
.CLK (sd_clk),
.RST (crc_rst_write),
.CRC (crc_val_write));
CRC_7 CRC_7_READ( 
.BITVAL (crc_in_read),
.Enable (crc_en_read),
.CLK (sd_clk),
.RST (crc_rst_read),
.CRC (crc_val_read));
always @ (posedge sd_clk or posedge rst )
begin
	if  (rst) begin
		cmd_dat_internal <=1'b1;
	end
	else begin  
		cmd_dat_internal<=cmd_dat_i;
	end
end
always @ (state or cmd_flow_cnt_write or cmd_dat_internal or fifo_empty [1] or read_byte_cnt or cmd_flow_cnt_write or cmd_flow_cnt_read )
begin : FSM_COMBO
 next_state  = 0;   
case(state)  
INIT: begin
  if (cmd_flow_cnt_write >= 64 )begin
     next_state = IDLE;
  end 
  else begin     
     next_state = INIT;
  end
end                                                
IDLE: begin    
    if (!fifo_empty [1])
      next_state =BUFFER_WRITE;
    else if (!cmd_dat_internal) 
      next_state =READ; 
    else 
      next_state =IDLE;
end
BUFFER_WRITE: begin
  if (read_byte_cnt>=5)
   next_state = WRITE;
  else
   next_state =BUFFER_WRITE;
end
WRITE : begin 
     if (cmd_flow_cnt_write >= SEND_SIZE) 
        next_state = IDLE;          
      else 
        next_state = WRITE;
end
READ : begin
      if (cmd_flow_cnt_read >= Response_Size+7)
        next_state = IDLE;          
      else 
        next_state = READ;
end		
default : next_state  = INIT;
 endcase     
end 
always @ (posedge sd_clk or posedge rst  )
begin : FSM_SEQ
  if (rst ) begin
    state <= #1 INIT;
 end  
 else begin
    state <= #1 next_state;
 end
end
reg fifo_acces_read,fifo_acces_write;
assign fifo_acces_token = fifo_acces_read | fifo_acces_write;
assign sd_adr_o = add_token_read ? sd_adr_o_read : sd_adr_o_write;
assign start_dat_t = add_token_read ?  start_dat_t_read : start_dat_t_write;
reg tx_cmd_fifo_empty_tmp; 
always @ (negedge sd_clk or posedge rst  )
begin : OUTPUT_LOGIC
 if (rst  ) begin    
   crc_in_write=0;
   crc_en_write=0;
   crc_rst_write=0;
   fifo_acces_write=0;   
   cmd_oe_o=1; 		
   cmd_dat_o = 1;  
   crc_buffering_write=0;
   sd_re_o<=0;
   read_byte_cnt<=0;  
   block_read<=0;
   sd_adr_o_write<=0;
   cmd_flow_cnt_write=0;
   start_dat_t_write<=0;
   in_buffer<=0;
    tx_cmd_fifo_empty_tmp<=0;
    Response_Size<=40;    
 end
 else begin
  case(state)
    INIT : begin
      cmd_flow_cnt_write=cmd_flow_cnt_write+1;
      cmd_oe_o=1; 		
      cmd_dat_o = 1;  
      crc_buffering_write=0;
      start_dat_t_write<=0;
    end
    IDLE: begin
       cmd_flow_cnt_write=0;
       cmd_oe_o=0; 		
       start_dat_t_write<=0;
       crc_in_write=0;
       crc_en_write=0;
       crc_rst_write=1; 
       read_byte_cnt<=0;     
       block_read<=0;
       fifo_acces_write=0;
       in_buffer<=0;  
    end
     BUFFER_WRITE : begin
      sd_re_o<=0;
      fifo_acces_write=1;   
      tx_cmd_fifo_empty_tmp<=fifo_empty [1];
       if (!tx_cmd_fifo_empty_tmp) begin
        if(sd_re_o)
          read_byte_cnt <= read_byte_cnt+1;
        sd_adr_o_write <=0;
        sd_re_o<=1;
       if(sd_re_o) begin
         case (read_byte_cnt) 
          0: in_buffer[39:32] <=sd_dat_i;                   
          1: in_buffer[31:24] <=sd_dat_i;
          2: in_buffer[23:16] <=sd_dat_i;
           3: in_buffer[15:8] <=sd_dat_i;
           4: in_buffer[7:0] <=sd_dat_i;
         endcase 
         if (in_buffer[39]) 
           Response_Size<=127;
         else
           Response_Size<=40;               
         if (in_buffer[37:32] == 32'h11)
               block_read<=1;
      end 
    end 
   end  
    WRITE: begin
       sd_re_o<=0;
       cmd_oe_o=1; 		
       cmd_dat_o = 1;        
       crc_en_write =0;
       crc_rst_write=0;
        crc_en_write=1;
      if (crc_buffering_write==1)  begin
        cmd_oe_o =1;
        if ((SEND_SIZE-cmd_flow_cnt_write) > 8 ) begin  
				   if (cmd_flow_cnt_write==0)	
				    cmd_dat_o = 0; 
				   else
				    cmd_dat_o = in_buffer[(CONTENT_SIZE-1-cmd_flow_cnt_write)]; 
				   if ((SEND_SIZE-cmd_flow_cnt_write) > 9 ) begin 
			       crc_in_write = in_buffer[(CONTENT_SIZE-1-cmd_flow_cnt_write)-1];
			     end else begin
			       crc_en_write=0;  
				   end    
			  end
			  else if ( ((SEND_SIZE-cmd_flow_cnt_write) <=8) && ((SEND_SIZE-cmd_flow_cnt_write) >=2) ) begin			 	
				  crc_en_write=0; 
				  cmd_dat_o = crc_val_write[((SEND_SIZE-cmd_flow_cnt_write))-2];	
				   if (block_read)
             start_dat_t_write<=2'b10;
			  end
			  else begin        
				  cmd_dat_o =1'b1;
			  end		
			 cmd_flow_cnt_write=cmd_flow_cnt_write+1;
		end		
	  else begin 
		    crc_buffering_write=1;
	   	  crc_in_write = 0;
	  end	    
    end
  endcase
 end
end
always @ (posedge sd_clk or posedge rst  )
begin
  if (rst) begin
   crc_rst_read=1;
   crc_en_read=0;
   crc_in_read=0; 
   cmd_flow_cnt_read=0;
   response_status =0;
   block_write=0;
   index_check=0;
   in_buff_ptr=0;
   out_buff_ptr=0;
   sd_adr_o_read<=0;
   add_token_read=0; 
   in_buff_0<=0;
   in_buff_1<=0;
   read_index_cnt=0;
    fifo_acces_read=0;   
    sd_dat_o<=0;
    start_dat_t_read<=0;
    sd_we_o<=0;
    crc_in_buff=0;
  end
  else begin
   case (state) 
   IDLE : begin
        crc_en_read=0;
        crc_rst_read=1;
        cmd_flow_cnt_read=1;
        index_check=0;
        block_write=0;
        in_buff_ptr=0;
        out_buff_ptr=0;
        add_token_read=0; 
        read_index_cnt=0;
        sd_we_o<=0;  
        add_token_read=0;
         fifo_acces_read=0;
         start_dat_t_read<=0;
   end
   READ : begin
      fifo_acces_read=1;
      add_token_read=1; 
      crc_en_read=1;
      crc_rst_read=0;
      sd_we_o<=0;
     if (in_buff_ptr != out_buff_ptr) begin
     sd_adr_o_read <=1;
     sd_we_o<=1;  
       if (in_buff_ptr)
        sd_dat_o <=in_buff_0;
      else
        sd_dat_o <=in_buff_1;
     out_buff_ptr=out_buff_ptr+1;
     end
     if (cmd_flow_cnt_read < (Response_Size))begin 
        crc_in_read = cmd_dat_internal;
        if (cmd_flow_cnt_read<8 ) begin 
          index_check[7-cmd_flow_cnt_read] = cmd_dat_internal;
          if (index_check[5:0] == 32'h18) begin
             block_write=1;
          end
        end
        else begin                   
          if (!in_buff_ptr) begin
             in_buff_0[7-read_index_cnt]<=cmd_dat_internal;
          end
          else begin
             in_buff_1[7-read_index_cnt]<=cmd_dat_internal;
          end
          read_index_cnt=read_index_cnt+1;
          if (read_index_cnt==0)
             in_buff_ptr=in_buff_ptr+1;
        end             
       end  
      	else if ( cmd_flow_cnt_read - Response_Size <=6 ) begin 
			  crc_in_buff [(Response_Size+6)-(cmd_flow_cnt_read)] = cmd_dat_internal;
			  crc_en_read=0;  
      end
      else begin  
			   if ((crc_in_buff != crc_val_read)) begin
				   response_status[0]=1;					   			  			
		    	end  
		    	else begin
		    	  response_status[0]=0;
		    	end 
		    	sd_adr_o_read <=1;
        		 sd_we_o<=1; 
		    	sd_dat_o<=response_status;
		     if (block_write)
		    	  start_dat_t_read<=2'b01;
      end        
       cmd_flow_cnt_read = cmd_flow_cnt_read+1;
   end  
  endcase
  end
end
endmodule
module sd_fifo
  (
    input  [1:0] wb_adr_i,
    input [7:0]  wb_dat_i,
    output [7:0] wb_dat_o,
    input 	 wb_we_i,
    input 	 wb_re_i,
    input 	 wb_clk,
    input [1:0]  sd_adr_i,
    input [7:0]  sd_dat_i,
    output [7:0] sd_dat_o,
    input 	 sd_we_i,
    input 	 sd_re_i,
    input 	 sd_clk,
    output [1:4] fifo_full,
    output [1:4] fifo_empty,
    input 	 rst 	 
   );
   wire [8:0] 	 wptr1, rptr1, wptr2, rptr2, wptr3, rptr3, wptr4, rptr4;
   wire [8:0] 	 wadr1, radr1, wadr2, radr2, wadr3, radr3, wadr4, radr4;
   wire 	 dpram_we_a, dpram_we_b;
   wire [10:0] 	 dpram_a_a, dpram_a_b;   
   sd_counter wptr1a
     (
      .q(wptr1),
      .q_bin(wadr1),
      .cke((wb_adr_i==2'd0) & wb_we_i & !fifo_full[1]),
      .clk(wb_clk),
      .rst(rst)
      );
   sd_counter rptr1a
     (
      .q(rptr1),
      .q_bin(radr1),
      .cke((sd_adr_i==2'd0) & sd_re_i & !fifo_empty[1]),
      .clk(sd_clk),
      .rst(rst)
      );
  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(9)
     )
    cmp1
    ( 
      .wptr(wptr1), 
      .rptr(rptr1), 
      .fifo_empty(fifo_empty[1]), 
      .fifo_full(fifo_full[1]), 
      .wclk(wb_clk), 
      .rclk(sd_clk), 
      .rst(rst)
      );
   sd_counter wptr2a
     (
      .q(wptr2),
      .q_bin(wadr2),
      .cke((sd_adr_i==2'd1) & sd_we_i & !fifo_full[2]),
      .clk(sd_clk),
      .rst(rst)
      );
   sd_counter rptr2a
     (
      .q(rptr2),
      .q_bin(radr2),
      .cke((wb_adr_i==2'd1) & wb_re_i & !fifo_empty[2]),
      .clk(wb_clk),
      .rst(rst)
      );
  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(9)
     )
    cmp2
    ( 
      .wptr(wptr2), 
      .rptr(rptr2), 
      .fifo_empty(fifo_empty[2]), 
      .fifo_full(fifo_full[2]), 
      .wclk(sd_clk), 
      .rclk(wb_clk), 
      .rst(rst)
      );
   sd_counter wptr3a
     (
      .q(wptr3),
      .q_bin(wadr3),
      .cke((wb_adr_i==2'd2) & wb_we_i & !fifo_full[3]),
      .clk(wb_clk),
      .rst(rst)
      );
   sd_counter rptr3a
     (
      .q(rptr3),
      .q_bin(radr3),
      .cke((sd_adr_i==2'd2) & sd_re_i & !fifo_empty[3]),
      .clk(sd_clk),
      .rst(rst)
      );
  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(9)
     )
    cmp3
    ( 
      .wptr(wptr3), 
      .rptr(rptr3), 
      .fifo_empty(fifo_empty[3]), 
      .fifo_full(fifo_full[3]), 
      .wclk(wb_clk), 
      .rclk(sd_clk), 
      .rst(rst)
      );
   sd_counter wptr4a
     (
      .q(wptr4),
      .q_bin(wadr4),
      .cke((sd_adr_i==2'd3) & sd_we_i & !fifo_full[4]),
      .clk(sd_clk),
      .rst(rst)
      );
   sd_counter rptr4a
     (
      .q(rptr4),
      .q_bin(radr4),
      .cke((wb_adr_i==2'd3) & wb_re_i & !fifo_empty[4]),
      .clk(wb_clk),
      .rst(rst)
      );
  versatile_fifo_async_cmp
    #
    (
     .ADDR_WIDTH(9)
     )
    cmp4
    ( 
      .wptr(wptr4), 
      .rptr(rptr4), 
      .fifo_empty(fifo_empty[4]), 
      .fifo_full(fifo_full[4]), 
      .wclk(sd_clk), 
      .rclk(wb_clk), 
      .rst(rst)
      );
   assign dpram_we_a = ((wb_adr_i==2'd0) & !fifo_full[1]) ? wb_we_i :
		       ((wb_adr_i==2'd2) & !fifo_full[3]) ? wb_we_i :
		       1'b0;
   assign dpram_we_b = ((sd_adr_i==2'd1) & !fifo_full[2]) ? sd_we_i :
		       ((sd_adr_i==2'd3) & !fifo_full[4]) ? sd_we_i :
		       1'b0;
   assign dpram_a_a = (wb_adr_i==2'd0) ? {wb_adr_i,wadr1} :
		      (wb_adr_i==2'd1) ? {wb_adr_i,radr2} :
		      (wb_adr_i==2'd2) ? {wb_adr_i,wadr3} :
		      {wb_adr_i,radr4};
   assign dpram_a_b = (sd_adr_i==2'd0) ? {sd_adr_i,radr1} :
		      (sd_adr_i==2'd1) ? {sd_adr_i,wadr2} :
		      (sd_adr_i==2'd2) ? {sd_adr_i,radr3} : 
		      {sd_adr_i,wadr4};
   versatile_fifo_dptam_dw 
     dpram
     (
      .d_a(wb_dat_i),
      .q_a(wb_dat_o),
      .adr_a(dpram_a_a), 
      .we_a(dpram_we_a),
      .clk_a(wb_clk),
      .q_b(sd_dat_o),
      .adr_b(dpram_a_b),
      .d_b(sd_dat_i), 
      .we_b(dpram_we_b),
      .clk_b(sd_clk)
      );
endmodule 
module sd_counter
  (
    output reg [9:1] q,
    output [9:1]    q_bin,
    input cke,
    input clk,
    input rst
   );
   reg [9:1] qi;
   wire [9:1] q_next;   
   assign q_next =
   qi + 9'd1;
   always @ (posedge clk or posedge rst)
     if (rst)
       qi <= 9'd0;
     else
   if (cke)
     qi <= q_next;
   always @ (posedge clk or posedge rst)
     if (rst)
       q <= 9'd0;
     else
       if (cke)
	 q <= (q_next>>1) ^ q_next;
   assign q_bin = qi;
endmodule
module versatile_fifo_async_cmp ( wptr, rptr, fifo_empty, fifo_full, wclk, rclk, rst );
   parameter ADDR_WIDTH = 4;   
   parameter N = ADDR_WIDTH-1;
   parameter Q1 = 2'b00;
   parameter Q2 = 2'b01;
   parameter Q3 = 2'b11;
   parameter Q4 = 2'b10;
   parameter going_empty = 1'b0;
   parameter going_full  = 1'b1;
   input [N:0]  wptr, rptr;   
   output reg	fifo_empty, fifo_full;
   input 	wclk, rclk, rst;   
   reg 	direction, direction_set, direction_clr;
   wire async_empty, async_full;
   reg 	fifo_full2, fifo_empty2;   
   always @ (wptr[N:N-1] or rptr[N:N-1])
     case ({wptr[N:N-1],rptr[N:N-1]})
       {Q1,Q2} : direction_set <= 1'b1;
       {Q2,Q3} : direction_set <= 1'b1;
       {Q3,Q4} : direction_set <= 1'b1;
       {Q4,Q1} : direction_set <= 1'b1;
       default : direction_set <= 1'b0;
     endcase
   always @ (wptr[N:N-1] or rptr[N:N-1] or rst)
     if (rst)
       direction_clr <= 1'b1;
     else
       case ({wptr[N:N-1],rptr[N:N-1]})
	 {Q2,Q1} : direction_clr <= 1'b1;
	 {Q3,Q2} : direction_clr <= 1'b1;
	 {Q4,Q3} : direction_clr <= 1'b1;
	 {Q1,Q4} : direction_clr <= 1'b1;
	 default : direction_clr <= 1'b0;
       endcase
   always @ (posedge direction_set or posedge direction_clr)
     if (direction_clr)
       direction <= going_empty;
     else
       direction <= going_full;
   assign async_empty = (wptr == rptr) && (direction==going_empty);
   assign async_full  = (wptr == rptr) && (direction==going_full);
   always @ (posedge wclk or posedge rst or posedge async_full)
     if (rst)
       {fifo_full, fifo_full2} <= 2'b00;
     else if (async_full)
       {fifo_full, fifo_full2} <= 2'b11;
     else
       {fifo_full, fifo_full2} <= {fifo_full2, async_full};
   always @ (posedge rclk or posedge async_empty)
     if (async_empty)
       {fifo_empty, fifo_empty2} <= 2'b11;
     else
       {fifo_empty,fifo_empty2} <= {fifo_empty2,async_empty};   
endmodule 
module CRC_7(BITVAL, Enable, CLK, RST, CRC);
   input        BITVAL;
   input Enable;
   input        CLK;                           
   input        RST;                             
   output [6:0] CRC;                               
   reg    [6:0] CRC;   
   wire         inv;
   assign inv = BITVAL ^ CRC[6];                   
    always @(posedge CLK or posedge RST) begin
		if (RST) begin
			CRC = 0;   
        end
		else begin
			if (Enable==1) begin
				CRC[6] = CRC[5];
				CRC[5] = CRC[4];
				CRC[4] = CRC[3];
				CRC[3] = CRC[2] ^ inv;
				CRC[2] = CRC[1];
				CRC[1] = CRC[0];
				CRC[0] = inv;
			end
		end
     end
endmodule
module CRC_16(BITVAL, Enable, CLK, RST, CRC);
 input        BITVAL;
   input Enable;
   input        CLK;                           
   input        RST;                             
   output reg [15:0] CRC;                               
   wire         inv;
   assign inv = BITVAL ^ CRC[15];                   
  always @(posedge CLK or posedge RST) begin
		if (RST) begin
			CRC = 0;   
        end
      else begin
        if (Enable==1) begin
         CRC[15] = CRC[14];
         CRC[14] = CRC[13];
         CRC[13] = CRC[12];
         CRC[12] = CRC[11] ^ inv;
         CRC[11] = CRC[10];
         CRC[10] = CRC[9];
         CRC[9] = CRC[8];
         CRC[8] = CRC[7];
         CRC[7] = CRC[6];
         CRC[6] = CRC[5];
         CRC[5] = CRC[4] ^ inv;
         CRC[4] = CRC[3];
         CRC[3] = CRC[2];
         CRC[2] = CRC[1];
         CRC[1] = CRC[0];
         CRC[0] = inv;
        end
         end
      end
endmodule
module sd_data_phy(
input sd_clk,
input rst,
output reg DAT_oe_o,
output reg[3:0] DAT_dat_o,
input  [3:0] DAT_dat_i,
output  [1:0] sd_adr_o,
input [7:0] sd_dat_i,
output reg [7:0] sd_dat_o,
output reg sd_we_o,
output reg sd_re_o,
input  [3:4] fifo_full,
input [3:4] fifo_empty,
input  [1:0] start_dat,
input fifo_acces
);
 reg [5:0] in_buff_ptr_read;
 reg [5:0] out_buff_ptr_read;
 reg crc_ok;
 reg [3:0] last_din_read;
reg [7:0] tmp_crc_token ;  
reg[2:0] crc_read_count;
reg [3:0] crc_in_write;
reg crc_en_write;
reg crc_rst_write;
wire [15:0] crc_out_write [3:0];
reg [3:0] crc_in_read;
reg crc_en_read;
reg crc_rst_read;
wire [15:0] crc_out_read [3:0];  
  reg[7:0] next_out;
    reg data_read_index;  
reg [10:0] transf_cnt_write;
reg [10:0] transf_cnt_read;
parameter SIZE = 6;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE        = 6'b000001;
parameter WRITE_DAT   = 6'b000010;
parameter READ_CRC   = 6'b000100;
parameter WRITE_CRC  = 6'b001000;   
parameter  READ_WAIT = 6'b010000;
parameter  READ_DAT  = 6'b100000;
reg in_dat_buffer_empty;
reg [2:0] crc_status_token; 
reg busy_int;
reg add_token;   
genvar i;
generate
for(i=0; i<4; i=i+1) begin:CRC_16_gen_write
  CRC_16 CRC_16_i (crc_in_write[i],crc_en_write, sd_clk, crc_rst_write, crc_out_write[i]);
end
endgenerate
generate
for(i=0; i<4; i=i+1) begin:CRC_16_gen_read
  CRC_16 CRC_16_i (crc_in_read[i],crc_en_read, sd_clk, crc_rst_read, crc_out_read[i]);
end
endgenerate
reg q_start_bit;
always @ (state or start_dat or DAT_dat_i[0] or  transf_cnt_write or transf_cnt_read or busy_int or crc_read_count or sd_we_o or  in_dat_buffer_empty )
begin : FSM_COMBO
 next_state  = 0;   
case(state)
  IDLE: begin
   if (start_dat == 2'b01) 
      next_state=WRITE_DAT;
    else if  (start_dat == 2'b10)
      next_state=READ_WAIT;
    else 
      next_state=IDLE;
    end
  WRITE_DAT: begin
    if (transf_cnt_write >= 1044+2) 
       next_state= READ_CRC;
   else if (start_dat == 2'b11)
        next_state=IDLE;
    else 
       next_state=WRITE_DAT;
  end
  READ_WAIT: begin
    if (DAT_dat_i[0]== 0 ) 
       next_state= READ_DAT;
    else 
       next_state=READ_WAIT;
  end
  READ_CRC: begin
    if ( (crc_read_count == 3'b111) &&(busy_int ==1) ) 
       next_state= WRITE_CRC;
    else 
       next_state=READ_CRC;    
  end
  WRITE_CRC: begin
       next_state= IDLE;
  end
  READ_DAT: begin
    if ((transf_cnt_read >= 1044-3)  && (in_dat_buffer_empty)) 
       next_state= IDLE;
    else if (start_dat == 2'b11)
        next_state=IDLE;   
    else 
       next_state=READ_DAT;
    end  
 endcase
end 
always @ (posedge sd_clk or posedge rst   )
 begin 
  if (rst ) begin
    q_start_bit<=1;
 end 
 else begin
    q_start_bit <= DAT_dat_i[0];
 end
end
always @ (posedge sd_clk or posedge rst   )
begin : FSM_SEQ
  if (rst ) begin
    state <= #1 IDLE;
 end 
 else begin
    state <= #1 next_state;
 end
end
reg [4:0] crc_cnt_write;
reg [4:0]crc_cnt_read;
reg [3:0] last_din;
reg [2:0] crc_s ;
reg [7:0] write_buf_0,write_buf_1, sd_data_out;
reg out_buff_ptr,in_buff_ptr;
reg data_send_index;
reg [1:0] sd_adr_o_read;  
reg [1:0] sd_adr_o_write;
reg read_byte_cnt;       
assign sd_adr_o = add_token ? sd_adr_o_read : sd_adr_o_write;
assign sd_adr_o = add_token ? sd_adr_o_read : sd_adr_o_write;         
reg [3:0] in_dat_buffer [63:0];
always @ (negedge sd_clk or posedge rst   )
begin
if (rst) begin
  DAT_oe_o<=0;
  crc_en_write<=0;
  crc_rst_write<=1;
  transf_cnt_write<=0;
  crc_cnt_write<=15;
  crc_status_token<=7;       
  data_send_index<=0;
  out_buff_ptr<=0;
  in_buff_ptr<=0;  
  read_byte_cnt<=0;
   write_buf_0<=0;
    write_buf_1<=0;
    sd_re_o<=0; 
    sd_data_out<=0;
    sd_adr_o_write<=0;
    crc_in_write<=0;
    DAT_dat_o<=0;
     last_din<=0;    
end  
else begin
 case(state)
   IDLE: begin
      DAT_oe_o<=0;    
      crc_en_write<=0;
      crc_rst_write<=1;     
      crc_cnt_write<=16;
      read_byte_cnt<=0;
      crc_status_token<=7;
      data_send_index<=0;
      out_buff_ptr<=0;
      in_buff_ptr<=0;  
        sd_re_o<=0;
        transf_cnt_write<=0;
   end     
   WRITE_DAT: begin     
      transf_cnt_write<=transf_cnt_write+1; 
      if ( (in_buff_ptr != out_buff_ptr) ||  (transf_cnt_write<2) ) begin
       read_byte_cnt<=read_byte_cnt+1;
       sd_re_o<=0;
        case (read_byte_cnt)
        0:begin
           sd_adr_o_write <=2;
           sd_re_o<=1; 
        end 
        1:begin
          if (!in_buff_ptr)
             write_buf_0<=sd_dat_i;         
          else
            write_buf_1 <=sd_dat_i;
          in_buff_ptr<=in_buff_ptr+1;     
        end    
     endcase
     end
      if (!out_buff_ptr)
        sd_data_out<=write_buf_0;
      else
       sd_data_out<=write_buf_1;
        if (transf_cnt_write==1+2) begin
          crc_rst_write<=0;
          crc_en_write<=1;
          last_din <=write_buf_0[3:0]; 
          DAT_oe_o<=1;  
          DAT_dat_o<=0;
          crc_in_write<= write_buf_0[3:0]; 
          data_send_index<=1;  
          out_buff_ptr<=out_buff_ptr+1;  
        end
        else if ( (transf_cnt_write>=2+2) && (transf_cnt_write<=1044-19+2 )) begin                 
          DAT_oe_o<=1;    
        case (data_send_index) 
           0:begin 
              last_din <=sd_data_out[3:0];
              crc_in_write <=sd_data_out[3:0];
               out_buff_ptr<=out_buff_ptr+1;
           end
           1:begin 
              last_din <=sd_data_out[7:4];
              crc_in_write <=sd_data_out[7:4];
           end
         endcase 
          data_send_index<=data_send_index+1;
          DAT_dat_o<= last_din; 
        if ( transf_cnt_write >=1044-19 +2) begin
             crc_en_write<=0;             
         end
       end
       else if (transf_cnt_write>1044-19 +2 & crc_cnt_write!=0) begin
         crc_en_write<=0;
         crc_cnt_write<=crc_cnt_write-1;      
         DAT_oe_o<=1; 
         DAT_dat_o[0]<=crc_out_write[0][crc_cnt_write-1];
         DAT_dat_o[1]<=crc_out_write[1][crc_cnt_write-1];
         DAT_dat_o[2]<=crc_out_write[2][crc_cnt_write-1];
         DAT_dat_o[3]<=crc_out_write[3][crc_cnt_write-1];         
       end
       else if (transf_cnt_write==1044-2+2) begin
          DAT_oe_o<=1; 
          DAT_dat_o<=4'b1111;
      end   
      else if (transf_cnt_write !=0) begin
         DAT_oe_o<=0;          
      end
   end
 endcase
end
end
always @ (posedge sd_clk or posedge rst   )
begin
  if (rst) begin
    add_token<=0;   
    sd_adr_o_read<=0;
    crc_read_count<=0;
    sd_we_o<=0; 
    tmp_crc_token<=0;
    crc_rst_read<=0;
    crc_en_read<=0;
    in_buff_ptr_read<=0;
    out_buff_ptr_read<=0;
    crc_cnt_read<=0;
    transf_cnt_read<=0;
    data_read_index<=0;
    in_dat_buffer_empty<=0;
    next_out<=0; 
    busy_int<=0;
    sd_dat_o<=0;
  end  
  else begin
   case(state)
   IDLE: begin          
     add_token<=0;
     crc_read_count<=0;
     sd_we_o<=0; 
     tmp_crc_token<=0;
      crc_rst_read<=1;
      crc_en_read<=0;
      in_buff_ptr_read<=0;
     out_buff_ptr_read<=0;
      crc_cnt_read<=15;
      transf_cnt_read<=0;
      data_read_index<=0;
      in_dat_buffer_empty<=0;
    end
    READ_DAT: begin  
     add_token<=1; 
      crc_rst_read<=0;
      crc_en_read<=1;
      if (fifo_acces) begin
        if ( (in_buff_ptr_read - out_buff_ptr_read) >=2) begin
          data_read_index<=~data_read_index;
          case(data_read_index)
            0: begin
             sd_adr_o_read<=3;
             sd_we_o<=0; 
             next_out[3:0]<=in_dat_buffer[out_buff_ptr_read ];
             next_out[7:4]<=in_dat_buffer[out_buff_ptr_read+1 ];
           end
           1: begin
              out_buff_ptr_read<=out_buff_ptr_read+2;
            sd_dat_o<=next_out; 
            sd_we_o<=1;  
            end
          endcase    
          end  
        else
           in_dat_buffer_empty<=1;
      end
     if (transf_cnt_read<1024) begin
       in_dat_buffer[in_buff_ptr_read]<=DAT_dat_i;
       crc_in_read<=DAT_dat_i;
       crc_ok<=1;
       transf_cnt_read<=transf_cnt_read+1; 
       in_buff_ptr_read<=in_buff_ptr_read+1;        
     end  
     else if  ( transf_cnt_read <= (1024 +16)) begin
       transf_cnt_read<=transf_cnt_read+1; 
       crc_en_read<=0;  
       last_din_read <=DAT_dat_i; 
       if (transf_cnt_read> 1024) begin       
         crc_cnt_read <=crc_cnt_read-1;
          if  (crc_out_read[0][crc_cnt_read] != last_din[0])
           crc_ok<=0;
          if  (crc_out_read[1][crc_cnt_read] != last_din[1])
           crc_ok<=0;
          if  (crc_out_read[2][crc_cnt_read] != last_din[2])
           crc_ok<=0;
          if  (crc_out_read[3][crc_cnt_read] != last_din[3])
           crc_ok<=0;  
         if (crc_cnt_read==0) begin
         end
      end
    end  
    end
    READ_CRC: begin
       if (crc_read_count<3'b111) begin
         crc_read_count<=crc_read_count+1;
         tmp_crc_token[crc_read_count]  <= DAT_dat_i[0];     
        end
      busy_int <=DAT_dat_i[0];  
    end
    WRITE_CRC: begin
      add_token<=1;
      sd_adr_o_read<=3;
      sd_we_o<=1; 
      sd_dat_o<=tmp_crc_token;      
    end
  endcase
end
end
endmodule
