`include "sd_defines.v"
//-------------------------
//-------------------------
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
//---------------Input ports---------------
 `define WRITE_CMD 32'h18
`define READ_CMD 32'h11
reg [6:0] Response_Size;
`ifdef SIM
 `define INIT_DELAY 64
`else
  `define INIT_DELAY 64
 `endif  
 
 `define tx_cmd_fifo_empty fifo_empty [1]
  
parameter SEND_SIZE = 48;
parameter CONTENT_SIZE = 40; 
parameter NCR = 2 ;

`define Vector_Index_Write  (CONTENT_SIZE-1-cmd_flow_cnt_write) 
`define Bit_Nr_Write  (SEND_SIZE-cmd_flow_cnt_write) 
//FSM
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
//
reg [7:0] cmd_flow_cnt_write;
reg [7:0] cmd_flow_cnt_read;

reg cmd_dat_internal;
//
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

always @ (state or cmd_flow_cnt_write or cmd_dat_internal or `tx_cmd_fifo_empty or read_byte_cnt or cmd_flow_cnt_write or cmd_flow_cnt_read )

begin : FSM_COMBO
 next_state  = 0;   
case(state)  
INIT: begin
  if (cmd_flow_cnt_write >= `INIT_DELAY )begin
     next_state = IDLE;
  end 
  else begin     
     next_state = INIT;
  end
end                                                
IDLE: begin    
    if (!`tx_cmd_fifo_empty)
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
      // cmd_dat_o = 0; 
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
      tx_cmd_fifo_empty_tmp<=`tx_cmd_fifo_empty;
       if (!tx_cmd_fifo_empty_tmp) begin
        if(sd_re_o)
          read_byte_cnt <= read_byte_cnt+1;
        sd_adr_o_write <=0;
        sd_re_o<=1;
       if(sd_re_o) begin
         case (read_byte_cnt) //If data is Avaible next cycle?
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
     
         if (in_buffer[37:32] == `READ_CMD)
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
        if (`Bit_Nr_Write > 8 ) begin  // 1->40 CMD, (41 >= CNT && CNT <=47) CRC, 48 stop_bit
				   if (cmd_flow_cnt_write==0)	
				    cmd_dat_o = 0; 
				   else
				    cmd_dat_o = in_buffer[`Vector_Index_Write]; 
				   
				   if (`Bit_Nr_Write > 9 ) begin //1 step ahead
			       crc_in_write = in_buffer[`Vector_Index_Write-1];
			     end else begin
			       crc_en_write=0;  
				   end    
			  end
			  else if ( (`Bit_Nr_Write <=8) && (`Bit_Nr_Write >=2) ) begin			 	
				  crc_en_write=0; 
				  cmd_dat_o = crc_val_write[(`Bit_Nr_Write)-2];	
				   if (block_read)
             start_dat_t_write<=2'b10;
		    	  	
			  end
			  else begin        
				  cmd_dat_o =1'b1;
				  
			  end		
			 cmd_flow_cnt_write=cmd_flow_cnt_write+1;
		end		
	  
	  else begin //Pre load CRC
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
      add_token_read=1; //Takes command over addres
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
    
     if (cmd_flow_cnt_read < (Response_Size))begin //40 First Bits         
        crc_in_read = cmd_dat_internal;
        if (cmd_flow_cnt_read<8 ) begin //1+1+6 (S,T,Index)          
          
          index_check[7-cmd_flow_cnt_read] = cmd_dat_internal;
          if (index_check[5:0] == `WRITE_CMD) begin
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
      	else if ( cmd_flow_cnt_read - Response_Size <=6 ) begin //7-Crc Bit
			  crc_in_buff [(Response_Size+6)-(cmd_flow_cnt_read)] = cmd_dat_internal;
			  crc_en_read=0;  
      end
      else begin  //Commpare CRC read with calcualted.
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



