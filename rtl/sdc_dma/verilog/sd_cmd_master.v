`include "sd_defines.v"
module sd_cmd_master(
input CLK_PAD_IO,

input RST_PAD_I,
input New_CMD,
input data_write,
input data_read,



input [31:0]ARG_REG,
input [13:0]CMD_SET_REG,
input [15:0] TIMEOUT_REG,
output reg [15:0] STATUS_REG,
output reg [31:0] RESP_1_REG,

output reg [4:0] ERR_INT_REG, 
output reg [15:0] NORMAL_INT_REG, 
input ERR_INT_RST,
input NORMAL_INT_RST,

output reg [15:0] settings,
output reg go_idle_o,
output reg  [39:0] cmd_out,
output reg req_out,
output reg ack_out,
input req_in,
input ack_in,
input [39:0] cmd_in,
input [7:0] serial_status,
input card_detect
);
 
  







`define dat_ava status[6]
`define crc_valid status[5] 
`define small_rsp 7'b0101000
`define big_rsp 7'b1111111

`define CMDI CMD_SET_REG[13:8]
`define WORD_SELECT CMD_SET_REG[7:6]
`define CICE CMD_SET_REG[4]
`define CRCE CMD_SET_REG[3]
`define RTS CMD_SET_REG[1:0]
`define CTE ERR_INT_REG[0]
`define CCRCE ERR_INT_REG[1]
`define CIE  ERR_INT_REG[3]
`define EI NORMAL_INT_REG[15]
`define CC  NORMAL_INT_REG[0]
`define CICMD STATUS_REG[0]
             

//-----------Types--------------------------------------------------------

reg CRC_check_enable;
reg index_check_enable;
reg [6:0]response_size;


reg card_present;


reg [3:0]debounce;

reg [15:0]status;
reg [15:0]  Watchdog_Cnt;
reg complete;



parameter SIZE = 3;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;

parameter IDLE   =  3'b001;
parameter SETUP   =  3'b010;
parameter EXECUTE  =  3'b100;
reg ack_in_int;
reg ack_q;
reg req_q;
reg req_in_int;

always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
begin
  if (RST_PAD_I) begin
    req_q<=0;
    req_in_int<=0;
 end 
else begin
  req_q<=req_in;  
  req_in_int<=req_q;
end
end  

//---------------Input ports---------------


always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
begin
  if (RST_PAD_I) begin
    debounce<=0;
    card_present<=0;
 end 
else begin
	if (!card_detect) begin//Card present
		if (debounce!=4'b1111)
			debounce<=debounce+1'b1;
	end
	else	
		 debounce<=0;

	if (debounce==4'b1111)
       card_present<=1'b1;
	else 
	   card_present<=1'b0;
end
end  



always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
begin
  if (RST_PAD_I) begin
    ack_q<=0;
    ack_in_int<=0;
 end 
else begin
  ack_q<=ack_in;
  ack_in_int<=ack_q;
end
  
  
end



always @ ( state or New_CMD or complete or ack_in_int )
begin : FSM_COMBO
    next_state = 0;

 case(state)
 IDLE:   begin
      if (New_CMD) begin
          next_state = SETUP;
      end     
      else begin
         next_state = IDLE;
      end   
 end       
 SETUP:begin
    if (ack_in_int)             
       next_state = EXECUTE;  
     else   
       next_state = SETUP;
   end  
 EXECUTE:    begin
       if (complete) begin
          next_state = IDLE;
      end     
      else begin
         next_state = EXECUTE;
      end
 end       
   
  
 default : next_state  = IDLE;
 
 endcase 
    
end

 
 

always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
begin : FSM_SEQ
  if (RST_PAD_I ) begin
    state <= #1 IDLE;
 end 
 else begin
    state <= #1 next_state;
 end
end



always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
begin  
 if (RST_PAD_I ) begin 
    CRC_check_enable=0;
    complete =0;
    RESP_1_REG = 0;
 
    ERR_INT_REG =0;
    NORMAL_INT_REG=0;
    STATUS_REG=0;
    status=0; 
    cmd_out =0 ;
    settings=0;
    response_size=0;
    req_out=0;
    index_check_enable=0; 
    ack_out=0; 
    Watchdog_Cnt=0;
    
    `CCRCE=0;
    `EI = 0;
    `CC = 0; 
     go_idle_o=0;  
 end 
 else begin
 NORMAL_INT_REG[1] = card_present;
 NORMAL_INT_REG[2] = ~card_present;
 complete=0;
 case(state)
 IDLE: begin
    go_idle_o=0;  
    req_out=0;
		ack_out =0;
		`CICMD =0; 
    if ( req_in_int == 1) begin     //Status change
        status=serial_status;
        ack_out = 1;
      
        
    end
 end
 SETUP:  begin
     
     NORMAL_INT_REG=0; 
     ERR_INT_REG =0;
  
     index_check_enable = `CICE; 
     CRC_check_enable = `CRCE;
    
    if ( (`RTS  == 2'b10 ) || ( `RTS == 2'b11)) begin
      response_size =  7'b0101000; 
    end
    else if (`RTS == 2'b01) begin
      response_size = 7'b1111111; 
    end    
    else begin
       response_size=0;
    end    
    
    cmd_out[39:38]=2'b01;         
    cmd_out[37:32]=`CMDI;  //CMD_INDEX
    cmd_out[31:0]= ARG_REG;           //CMD_Argument      
    settings[14:13]=`WORD_SELECT;             //Reserved
    settings[12] = data_read; //Type of command
    settings[11] = data_write;
    settings[10:8]=3'b111;            //Delay
    settings[7]=`CRCE;         //CRC-check
    settings[6:0]=response_size;   //response size    
    Watchdog_Cnt = 0;
    
    `CICMD =1;    
 end   
 
 EXECUTE: begin   
    Watchdog_Cnt = Watchdog_Cnt +1;
    if (Watchdog_Cnt>TIMEOUT_REG) begin
      `CTE=1;
      `EI = 1;
      if (ack_in == 1) begin
         complete=1;
      end   
      go_idle_o=1; 
    end
    
    //Default
    req_out=0;
		ack_out =0;
    
    //Start sending when serial module is ready
   	if (ack_in_int == 1) begin	    	     
	    		req_out =1;	   			   		
	  end	
	   //Incoming New Status 
	  else if ( req_in_int == 1) begin   
        status=serial_status;
      
        ack_out = 1; 
        if ( `dat_ava ) begin //Data avaible
           complete=1;
            `EI = 0;
             
           if (CRC_check_enable & ~`crc_valid) begin 
            `CCRCE=1;
            `EI = 1;
             
           end 
           if (index_check_enable &  (cmd_out[37:32] != cmd_in [37:32]) ) begin
            `CIE=1;
            `EI = 1;
            
           end
          
             
             `CC = 1;  
            
             if (response_size !=0)
              RESP_1_REG=cmd_in[31:0];
            
          // end 
         end ////Data avaible
       end //Status change
     end //EXECUTE state
   endcase
   if (ERR_INT_RST)
     ERR_INT_REG=0;
   if (NORMAL_INT_RST)
     NORMAL_INT_REG=0;
  end
end

endmodule
