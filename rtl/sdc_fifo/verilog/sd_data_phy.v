//-------------------------
//-------------------------




`include "sd_defines.v"
`define BUFFER_OFFSET 2

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

//CRC16 
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
    if (transf_cnt_write >= `BIT_BLOCK+`BUFFER_OFFSET) 
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
    if ((transf_cnt_read >= `BIT_BLOCK-3)  && (in_dat_buffer_empty)) //Startbit consumed...
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


//----------------Seq logic------------
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
        
        if (transf_cnt_write==1+`BUFFER_OFFSET) begin
          
          crc_rst_write<=0;
          crc_en_write<=1;
          last_din <=write_buf_0[3:0]; 
          DAT_oe_o<=1;  
          DAT_dat_o<=0;
          crc_in_write<= write_buf_0[3:0]; 
          data_send_index<=1;  
          out_buff_ptr<=out_buff_ptr+1;  
        end
        else if ( (transf_cnt_write>=2+`BUFFER_OFFSET) && (transf_cnt_write<=`BIT_BLOCK-`CRC_OFF+`BUFFER_OFFSET )) begin                 
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
          
        if ( transf_cnt_write >=`BIT_BLOCK-`CRC_OFF +`BUFFER_OFFSET) begin
             crc_en_write<=0;             
         end
       end
       else if (transf_cnt_write>`BIT_BLOCK-`CRC_OFF +`BUFFER_OFFSET & crc_cnt_write!=0) begin
        
         crc_en_write<=0;
         crc_cnt_write<=crc_cnt_write-1;      
         DAT_oe_o<=1; 
         DAT_dat_o[0]<=crc_out_write[0][crc_cnt_write-1];
         DAT_dat_o[1]<=crc_out_write[1][crc_cnt_write-1];
         DAT_dat_o[2]<=crc_out_write[2][crc_cnt_write-1];
         DAT_dat_o[3]<=crc_out_write[3][crc_cnt_write-1];         
       end
       else if (transf_cnt_write==`BIT_BLOCK-2+`BUFFER_OFFSET) begin
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
     
     if (transf_cnt_read<`BIT_BLOCK_REC) begin
       
       in_dat_buffer[in_buff_ptr_read]<=DAT_dat_i;
       crc_in_read<=DAT_dat_i;
       crc_ok<=1;
       transf_cnt_read<=transf_cnt_read+1; 
       in_buff_ptr_read<=in_buff_ptr_read+1;        
     end  
     else if  ( transf_cnt_read <= (`BIT_BLOCK_REC +`BIT_CRC_CYCLE)) begin
       transf_cnt_read<=transf_cnt_read+1; 
       crc_en_read<=0;  
       last_din_read <=DAT_dat_i; 
       
       if (transf_cnt_read> `BIT_BLOCK_REC) begin       
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
          //in_dat_buffer[in_buff_ptr_read] <= {7'b0,crc_ok}
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
//Sync





  
  
endmodule



